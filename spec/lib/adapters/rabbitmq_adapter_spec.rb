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
    Basquiat.configure { |c| c.logger = Logger.new('/tmp/basquiat.log') }
    subject.adapter_options(base_options)
  end

  after(:each) do
    remove_queues_and_exchanges
  end

  context 'failover' do
    let(:failover_settings) do
      base_options[:servers].unshift(host: 'localhost', port: 1234)
      base_options.merge(failover: { default_timeout: 0.2, max_retries: 2 })
    end

    it 'tries a reconnection after a few seconds' do
      subject.adapter_options(servers:  [host: 'localhost', port: 1234],
                              failover: { default_timeout: 0.2, max_retries: 1 })
      expect { subject.connect }.to raise_exception(Bunny::TCPConnectionFailed)
    end

    it 'uses another server after all retries on a single one' do
      subject.adapter_options(failover_settings)
      expect { subject.connect }.to_not raise_error
      expect(subject.connection_uri).to match(/5672/)
    end
  end

  it '#connected?' do
    expect(subject.connected?).to be_nil
    subject.connect
    expect(subject.connected?).to_not be_nil
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
      message_received = ''
      subject.subscribe_to('some.event',
                           lambda do |msg|
                             msg[:data].upcase!
                             message_received = msg
                           end)
      subject.listen(block: false)

      sleep 0.5 # Wait for the listening thread.
      subject.publish('some.event', data: 'coisa')
      sleep 0.5

      expect(message_received).to eq(data: 'COISA')
    end

    it 'should acknowledge the message by default' do
      subject.subscribe_to('some.event', lambda { |_| 'Everything is AWESOME!' })
      subject.listen(block: false)

      sleep 0.5 # Wait for the listening thread.
      subject.publish('some.event', data: 'stupid message')
      sleep 0.5 # Wait for the listening thread.

      expect(subject.send(:queue).message_count).to eq(0)
    end

    it 'should unacknowledge the message when :unack is thrown' do
      subject.subscribe_to('some.event', ->(msg) { throw :thing, :unack })
      subject.listen(block: false)

      sleep 0.5 # Wait for the listening thread.
      subject.publish('some.event', data: 'coisa')
      sleep 0.5 # Wait for the listening thread.

      expect(queue_status[:messages_unacknowledged]).to eq(1)
    end
  end

  def remove_queues_and_exchanges
    subject.send(:queue).delete
    subject.send(:exchange).delete
  rescue Bunny::TCPConnectionFailed
    true
  ensure
    subject.send(:disconnect)
  end

  def queue_status
    message = `curl -sXGET -H 'Accepts: application/json' http://guest:guest@#{ENV.fetch(
        'BASQUIAT_RABBITMQ_1_PORT_25672_TCP_ADDR', 'localhost')}:15672/api/queues/%2f/my.nice_queue`
    MultiJson.load(message, symbolize_keys: true)
  end

end
