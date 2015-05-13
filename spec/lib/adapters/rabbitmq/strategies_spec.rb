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

  after(:each) do
    remove_queues_and_exchanges
  end

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

    it 'should unacknowledge the message when told so' do
      adapter.subscribe_to('some.event', ->(msg) { msg.unack })
      adapter.listen(block: false)

      adapter.publish('some.event', data: 'some important but flawed data')
      sleep 2

      expect(adapter.session.queue).to have_n_unacked_messages(1)
    end
  end

  describe 'DeadLetterExchange' do
    before(:each) { adapter.class.register_strategy :dlx, Basquiat::Adapters::RabbitMq::DeadLettering }

    it 'creates the dead letter exchange'
    it 'creates and binds a dead letter queue'

    context 'checks if it was the queue that unacked it' do
      it 'process the message if true'
      it 'drops the message if not'
    end
  end

  def remove_queues_and_exchanges
    adapter.session.queue.delete
    adapter.session.exchange.delete
  rescue Bunny::TCPConnectionFailed
    true
  ensure
    adapter.reset_connection
  end
end
