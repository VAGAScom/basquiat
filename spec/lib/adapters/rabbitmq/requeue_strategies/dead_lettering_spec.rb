require 'spec_helper'
require 'basquiat/adapters/rabbitmq_adapter'

describe 'DeadLetterExchange' do
  let(:adapter) { Basquiat::Adapters::RabbitMq.new }
  let(:base_options) do
    { servers:   [{ host: ENV.fetch('BASQUIAT_RABBITMQ_1_PORT_5672_TCP_ADDR') { 'localhost' },
                    port: ENV.fetch('BASQUIAT_RABBITMQ_1_PORT_5672_TCP_PORT') { 5672 } }],
      publisher: { persistent: true } }
  end

  before(:each) do
    adapter.adapter_options(base_options)
    adapter.class.register_strategy :dlx, Basquiat::Adapters::RabbitMq::DeadLettering
  end

  after(:each) { remove_queues_and_exchanges(adapter) }

  it 'creates the dead letter exchange' do
    adapter.adapter_options(requeue: { enabled: true, strategy: 'dlx' })
    adapter.strategy # initialize the strategy
    channel = adapter.session.channel
    expect(channel.exchanges.keys).to contain_exactly('my.test_exchange', 'basquiat.dlx')
  end

  it 'creates and binds a dead letter queue' do
    # Initialize the strategy since we won't be listening to anything
    adapter.adapter_options(requeue: { enabled: true, strategy: 'dlx' })
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
    end.to change { channel.queues['basquiat.dlq'].message_count }.by(1)
  end

  context 'checks if it was the queue that unacked it' do
    before(:each) do
      adapter.adapter_options(requeue: { enabled: true, strategy: 'dlx' })
      session = adapter.session
      adapter.strategy # initialize strategy

      queue = session.channel.queue('sample_queue', arguments: { 'x-dead-letter-exchange' => 'basquiat.dlx' })
      queue.bind(session.exchange, routing_key: 'sample.message')

      queue.subscribe(manual_ack: true, block: false) do |di, _, _|
        adapter.session.channel.ack(di.delivery_tag)
      end
    end

    it 'process the message if true' do
      sample = 1
      adapter.subscribe_to('sample.message', ->(msg) do
        sample += 1; (sample % 2).zero? ? msg.ack : msg.unack
      end)

      adapter.listen(block: false)
      adapter.publish('sample.message', key: 'message')

      sleep 5
      expect(sample).to eq(2)
    end

    it 'drops the message if not'
  end
end
