require 'spec_helper'
require 'basquiat/adapters/rabbitmq_adapter'

describe 'Requeue Strategies' do
  let(:adapter) { Basquiat::Adapters::RabbitMq.new }
  let(:base_options) do
    { servers:   [{ host: ENV.fetch('BASQUIAT_RABBITMQ_1_PORT_5672_TCP_ADDR') { 'localhost' },
                    port: ENV.fetch('BASQUIAT_RABBITMQ_1_PORT_5672_TCP_PORT') { 5672 } }],
      publisher: { persistent: true } }
  end

  before(:each) { adapter.adapter_options(base_options) }
  after(:each) { remove_queues_and_exchanges }

  describe 'BasickAcknowledge (aka the default)' do
    it 'acks a message by default' do
      adapter.subscribe_to('some.event', ->(_) { 'Everything is AWESOME!' })
      adapter.listen(block: false)

      adapter.publish('some.event', data: 'stupid message')
      sleep 0.7 # Wait for the listening thread.

      expect(adapter.session.queue.message_count).to eq(0)
      expect(adapter.session.queue).to_not have_unacked_messages
    end

    it 'support declared acks' do
      adapter.subscribe_to('some.event', ->(msg) { msg.ack })
      adapter.listen(block: false)

      adapter.publish('some.event', data: 'stupid message')
      sleep 0.7 # Wait for the listening thread.

      expect(adapter.session.queue.message_count).to eq(0)
      expect(adapter.session.queue).to_not have_unacked_messages
    end
  end

  describe 'DeadLetterExchange' do
    before(:each) do
      adapter.class.register_strategy :dlx, Basquiat::Adapters::RabbitMq::DeadLettering
    end

    it 'creates the dead letter exchange' do
      adapter.adapter_options(requeue: { enabled: true, strategy: 'dlx' })

      adapter.send(:strategy).new(adapter.session)
      channel = adapter.session.channel
      expect(channel.exchanges.keys).to contain_exactly('my.test_exchange', 'basquiat.dlx')
    end

    it 'creates and binds a dead letter queue' do
      # Initialize the strategy since we won't be listening to anything
      adapter.adapter_options(requeue: { enabled: true, strategy: 'dlx' })
      session = adapter.session
      adapter.send(:strategy).new(session)

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
        adapter.send(:strategy).new(session)

        queue = session.channel.queue('sample_queue', arguments: { 'x-dead-letter-exchange' => 'basquiat.dlx' })
        queue.bind(session.exchange, routing_key: 'sample.message')

        queue.subscribe(manual_ack: true, block: false) do |di, _, _|
          adapter.session.channel.ack(di.delivery_tag)
        end
      end

      it 'process the message if true' do
        sample = 1
        adapter.subscribe_to('sample.message', ->(msg) {
          p sample += 1
          (sample % 2).zero? ? msg.ack : msg.unack
        })

        adapter.listen(block: false)
        adapter.publish('sample.message', key: 'message')

        sleep 5
        expect(sample).to eq(2)
      end

      it 'drops the message if not'
    end
  end

  def remove_queues_and_exchanges
    # Ugly as hell. Probably transform into a proper method in session
    adapter.session.channel.queues.each_pair { |_, queue| queue.delete }
    adapter.session.channel.exchanges.each_pair { |_, ex| ex.delete }
  rescue Bunny::TCPConnectionFailed
    true
  ensure
    adapter.reset_connection
  end
end
