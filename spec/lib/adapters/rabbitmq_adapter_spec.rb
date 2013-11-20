require 'spec_helper'
require 'basquiat/adapters/rabbitmq_adapter'

describe Basquiat::Adapters::RabbitMq do
  subject { Basquiat::Adapters::RabbitMq.new }
  it_behaves_like 'a Basquiat::Adapter'

  before(:all) do
    Basquiat.configuration.exchange_name = 'basquiat.test'
    Basquiat.configuration.queue_name = 'basquiat.queue'
  end

  after(:all) do
    Basquiat.configuration.exchange_name = nil
    Basquiat.configuration.queue_name = nil
  end

  context 'publisher' do
    it '#publish [enqueue a message]' do
      expect do
        subject.publish('messages.welcome', 'A Nice Welcome Message')
      end.to_not raise_error
    end
  end

  context 'listener' do
    before(:each) do
      subject.publish('some.event', 'some message')
    end

    it '#subscribe_to some event' do
      subject.subscribe_to('some.event', ->(msg) { yield msg.upcase })
      subject.listen(false) do |msg|
        expect(msg).to eq('SOME MESSAGE')
      end
    end
  end
end
