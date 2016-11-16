# frozen_string_literal: true
require 'basquiat/adapters/rabbitmq_adapter'

RSpec.describe Basquiat::Adapters::RabbitMq do
  subject(:adapter) { Basquiat::Adapters::RabbitMq.new }

  let(:base_options) do
    { connection: { hosts: [ENV.fetch('BASQUIAT_RABBITMQ_1_PORT_5672_TCP_ADDR') { 'localhost' }],
                    port:  ENV.fetch('BASQUIAT_RABBITMQ_1_PORT_5672_TCP_PORT') { 5672 } },
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
      it 'runs the rescue block when an exception happens' do
        coisa = ''
        adapter.subscribe_to('some.event', ->(_msg) { raise ArgumentError })
        adapter.listen(block: false, rescue_proc: ->(ex, _msg) { coisa = ex.class.to_s })
        adapter.publish('some.event', data: 'coisa')
        sleep 0.3

        expect(coisa).to eq('ArgumentError')
      end

      it '#subscribe_to some event' do
        message = ''
        adapter.subscribe_to('some.event', ->(msg) { message = msg[:data].upcase })
        adapter.listen(block: false)
        adapter.publish('some.event', data: 'message')
        sleep 0.3

        expect(message).to eq('MESSAGE')
      end
    end

    it '#subscribe_to other.event with #' do
      message_received = ''
      subject.subscribe_to('other.event.#', ->(msg) { message_received = msg[:data].upcase })
      subject.listen(block: false)

      subject.publish('other.event.test', data: 'some stuff')
      sleep 0.3

      expect(message_received).to eq('SOME STUFF')
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
