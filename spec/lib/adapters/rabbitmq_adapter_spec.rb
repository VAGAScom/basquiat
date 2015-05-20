require 'spec_helper'
require 'basquiat/adapters/rabbitmq_adapter'

describe Basquiat::Adapters::RabbitMq do
  subject(:adapter) { Basquiat::Adapters::RabbitMq.new }

  let(:base_options) do
    { servers:   [{ host: ENV.fetch('BASQUIAT_RABBITMQ_1_PORT_5672_TCP_ADDR') { 'localhost' },
                    port: ENV.fetch('BASQUIAT_RABBITMQ_1_PORT_5672_TCP_PORT') { 5672 } }],
      publisher: { persistent: true } }
  end

  context 'RabbitMQ interactions' do
    before(:each) do
      adapter.adapter_options(base_options)
      adapter.reset_connection
    end

    after(:each) do
      remove_queues_and_exchanges
    end

    context 'publisher' do
      it '#publish [enqueue a message]' do
        expect do
          adapter.publish('messages.welcome', data: 'A Nice Welcome Message')
        end.to_not raise_error
      end
    end

    context 'listener' do
      it '#subscribe_to some event' do
        message = ''
        adapter.subscribe_to('some.event',
                             ->(msg) { message << msg[:data].upcase! })
        adapter.listen(block: false)
        adapter.publish('some.event', data: 'coisa')
        sleep 0.7 # Wait for the listening thread

        expect(message).to eq('COISA')
      end
    end
  end

  def remove_queues_and_exchanges
    adapter.session.queue.delete
    adapter.session.exchange.delete
  rescue Bunny::TCPConnectionFailed
    true
  ensure
    adapter.send(:disconnect)
  end
end
