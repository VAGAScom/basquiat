require 'spec_helper'
require 'basquiat/adapters/rabbitmq_adapter'

describe 'Requeue Strategies' do
  let(:adapter) { Basquiat::Adapters::RabbitMq.new }
  let(:base_options) do
    { connection: { hosts: [ENV.fetch('BASQUIAT_RABBITMQ_1_PORT_5672_TCP_ADDR') { 'localhost' }],
                    port:  ENV.fetch('BASQUIAT_RABBITMQ_1_PORT_5672_TCP_PORT') { 5672 } },
      publisher:  { persistent: true } }
  end

  before(:each) { adapter.adapter_options(base_options) }
  after(:each) { remove_queues_and_exchanges(adapter) }

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
end
