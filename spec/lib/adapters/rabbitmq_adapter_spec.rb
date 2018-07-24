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
      context 'main process' do
        it '#publish [enqueue a message]' do
          expect do
            adapter.publish('messages.welcome', data: 'A Nice Welcome Message')
          end.to_not raise_error
        end
      end

      context 'multiple threads' do
        let(:base_options) do
          { connection: { hosts: [ENV.fetch('BASQUIAT_RABBITMQ_1_PORT_5672_TCP_ADDR') { 'localhost' }],
                          port:  ENV.fetch('BASQUIAT_RABBITMQ_1_PORT_5672_TCP_PORT') { 5672 } },
            publisher: { persistent: true, session_pool: { size: 10 } } }
        end

        before { Basquiat.configure { |c| c.connection = Bunny.new.tap(&:start) } }

        it '#publish [enqueue a message 10 times concurrently]' do
          expect do
            threads = []

            10.times do
              threads << Thread.new { adapter.publish('messages.welcome', data: 'A Nice Welcome Message') }
            end

            threads.each(&:join)
          end.not_to raise_error
        end

        after { Basquiat.configure { |c| c.connection = nil } }
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
