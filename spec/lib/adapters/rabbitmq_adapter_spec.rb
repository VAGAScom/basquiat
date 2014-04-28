require 'spec_helper'
require 'basquiat/adapters/rabbitmq_adapter'

describe Basquiat::Adapters::RabbitMq do
  subject { Basquiat::Adapters::RabbitMq.new }
  it_behaves_like 'a Basquiat::Adapter'

  after(:each) do
    remove_queues_and_exchanges
  end

  context 'failover' do
    it 'tries a reconnection after a few seconds' do
      subject.adapter_options(servers:  [host: 'localhost', port: 1234],
                              failover: { default_timeout: 0.2, max_retries: 1 })
      expect { subject.connect }.to raise_exception(Bunny::TCPConnectionFailed)
    end

    it 'uses another server after all retries on a single one' do
      subject.adapter_options(servers:  [{ host: 'localhost', port: 1234 },
                                         { host: 'localhost', port: 5672 }],
                              failover: { default_timeout: 0.2, max_retries: 2 })
      expect { subject.connect }.to_not raise_error
      expect(subject.connection_uri).to match(/5672/)
    end
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
      subject.subscribe_to('some.event', lambda do |msg|
        msg[:data].upcase!
        message_received = msg
      end)
      subject.listen(block: false)

      subject.publish('some.event', data: 'coisa')
      sleep 0.1 # Wait for the listening thread.

      expect(message_received).to eq(data: 'COISA')
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
end
