require 'spec_helper'
require 'basquiat/adapters/rabbitmq_adapter'

describe Basquiat::Adapters::RabbitMq::DeadLettering do
  let(:adapter) { Basquiat::Adapters::RabbitMq.new }
  let(:base_options) do
    { connection: { hosts: [ENV.fetch('BASQUIAT_RABBITMQ_1_PORT_5672_TCP_ADDR') { 'localhost' }],
                    port:  ENV.fetch('BASQUIAT_RABBITMQ_1_PORT_5672_TCP_PORT') { 5672 } },
      publisher:  { persistent: true } }
  end

  before(:each) do
    adapter.adapter_options(base_options)
    adapter.class.register_strategy :dlx, Basquiat::Adapters::RabbitMq::DeadLettering
    adapter.adapter_options(requeue: { enabled: true, strategy: 'dlx' })
  end

  after(:each) { remove_queues_and_exchanges(adapter) }

  it 'creates the dead letter exchange' do
    adapter.strategy # initialize the strategy
    channel = adapter.session.channel
    expect(channel.exchanges.keys).to contain_exactly('my.test_exchange', 'basquiat.dlx')
  end

  it 'creates and binds a dead letter queue' do
    # Initialize the strategy since we won't be listening to anything
    session = adapter.session
    adapter.strategy

    # Grabs the Bunny::Channel from the session for checks
    channel = session.channel
    expect(channel.queues.keys).to include('basquiat.dlq')
    expect(channel.queues['basquiat.dlq'].arguments)
        .to match(hash_including('x-dead-letter-exchange' => session.exchange.name, 'x-message-ttl' => 1000))
    expect(session.queue.arguments).to match(hash_including('x-dead-letter-exchange' => 'basquiat.dlx'))

    expect do
      channel.exchanges['basquiat.dlx'].publish('some message', routing_key: 'some.event')
      sleep 0.1
    end.to change { channel.queues['basquiat.dlq'].message_count }.by(1)
  end

  context 'unacked the message from' do
    before(:each) do
      session = adapter.session
      adapter.strategy # initialize strategy

      queue = session.channel.queue('sample_queue', arguments: { 'x-dead-letter-exchange' => 'basquiat.dlx' })
      queue.bind(session.exchange, routing_key: 'sample.message')

      queue.subscribe(manual_ack: true, block: false) do |di, _, _|
        adapter.session.channel.ack(di.delivery_tag)
      end
    end

    it 'this queue then process the message' do
      sample = 0
      adapter.subscribe_to('sample.message', lambda do |msg|
        sample += 1
        sample == 3 ? msg.ack : msg.unack
      end)

      adapter.listen(block: false)
      adapter.publish('sample.message', key: 'message')

      sleep 3
      expect(sample).to eq(3)
    end

    it 'another queue then drop the message' do
      ack_count = 0
      sample    = 0

      other = Basquiat::Adapters::RabbitMq.new
      other.adapter_options(base_options.merge(queue: { name: 'other_queue' }, requeue: { enabled: true, strategy: 'dlx', ttl: 5 }))
      other.subscribe_to('sample.message', lambda do |msg|
        ack_count += 1
      end)

      adapter.subscribe_to('sample.message', lambda do |msg|
        if sample == 3
          msg.ack
        else
          sample += 1
          msg.unack
        end
      end)

      other.listen(block: false)
      adapter.listen(block: false)
      adapter.publish('sample.message', key: 'message')

      sleep 3
      remove_queues_and_exchanges(other)
      expect(ack_count).to eq(1)
      expect(sample).to eq(3)
    end
  end
end
