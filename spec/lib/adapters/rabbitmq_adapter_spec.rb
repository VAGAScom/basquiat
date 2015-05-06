require 'spec_helper'
require 'basquiat/adapters/rabbitmq_adapter'

describe Basquiat::Adapters::RabbitMq do
  subject { Basquiat::Adapters::RabbitMq.new }

  it_behaves_like 'a Basquiat::Adapter'

  let(:base_options) do
    { servers:   [{ host: ENV.fetch('BASQUIAT_RABBITMQ_1_PORT_5672_TCP_ADDR') { 'localhost' },
                    port: ENV.fetch('BASQUIAT_RABBITMQ_1_PORT_5672_TCP_PORT') { 5672 } }],
      publisher: { persistent: true } }
  end

  before(:each) do
    subject.adapter_options(base_options)
    subject.send(:reset_connection)
  end

  after(:each) do
    remove_queues_and_exchanges
  end

  context 'publisher' do
    it '#publish [enqueue a message]' do
      expect do
        subject.publish('messages.welcome', data: 'A Nice Welcome Message')
      end.to_not raise_error
    end
  end

  context 'listener' do
    it '#subscribe_to some event' do
      message = ''
      subject.subscribe_to('some.event',
                           ->(msg) { message << msg[:data].upcase! })
      subject.listen(block: false)
      subject.publish('some.event', data: 'coisa')
      sleep 0.7 # Wait for the listening thread.

      expect(message).to eq('COISA')
    end

    it 'should acknowledge the message by default' do
      subject.subscribe_to('some.event', ->(_) { 'Everything is AWESOME!' })
      subject.listen(block: false)

      subject.publish('some.event', data: 'stupid message')
      sleep 0.7 # Wait for the listening thread.

      expect(subject.session.queue.message_count).to eq(0)
    end

    it 'support declared acks' do
      subject.subscribe_to('some.event', ->(msg) { msg.ack })
      subject.listen(block: false)

      subject.publish('some.event', data: 'stupid message')
      sleep 0.7 # Wait for the listening thread.

      expect(subject.session.queue.message_count).to eq(0)
    end

    it 'should unacknowledge the message when told so' do
      subject.subscribe_to('some.event', ->(msg) { msg.unack })
      subject.listen(block: false)

      subject.publish('some.event', data: 'some important but flawed data')
      sleep 2

      expect(queue_status[:messages_unacknowledged]).to eq(1)
    end
  end

  def remove_queues_and_exchanges
    subject.session.queue.delete
    subject.session.exchange.delete
  rescue Bunny::TCPConnectionFailed
    true
  ensure
    subject.send(:disconnect)
  end

  def queue_status
    message = `curl -sXGET -H 'Accepts: application/json' http://guest:guest@#{ENV.fetch(
      'BASQUIAT_RABBITMQ_1_PORT_25672_TCP_ADDR', 'localhost')}:15672/api/queues/%2F/my.nice_queue`
    MultiJson.load(message, symbolize_keys: true)
  end
end
