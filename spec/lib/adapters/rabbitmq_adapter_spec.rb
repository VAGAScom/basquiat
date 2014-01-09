require 'spec_helper'
require 'basquiat/adapters/rabbitmq_adapter'

describe Basquiat::Adapters::RabbitMq do
  subject { Basquiat::Adapters::RabbitMq.new }
  it_behaves_like 'a Basquiat::Adapter'

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
      expect(subject.connect.port).to eq(5672)
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
    before(:each) do
      subject.publish('some.event', data: 'some message')
    end

    it '#subscribe_to some event' do
      message_received = ''
      subject.subscribe_to('some.event', lambda do |msg|
        msg[:data].upcase!
        message_received = msg
      end)
      subject.listen(false)
      sleep 0.1 # Wait for the listening thread to join.
      expect(message_received).to eq(data: 'SOME MESSAGE')
    end
  end
end
