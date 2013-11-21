require 'spec_helper'

class SampleClass
  extend Basquiat::Base
  self.event_adapter = Basquiat::Adapters::Test
end

describe Basquiat::Base do
  subject { SampleClass }

  it '.event_adapter' do
    expect(subject).to respond_to(:event_adapter=)
  end

  it '.event_source(option_hash)' do
    expect(subject).to respond_to(:event_source)
  end

  it 'set the adapter options' do
    subject.event_source host: 'localhost', port: 5672, durable: true
    expect(subject.adapter.options[:port]).to eq(5672)
    expect(subject.adapter.options[:host]).to eq('localhost')
    expect(subject.adapter.options[:durable]).to be_true
  end

  context 'as a Producer' do
    it '#publish' do
      expect do
        subject.publish('test.message', message: 'useful test message')
      end.to change { subject.adapter.events('test.message').size }.by(1)
    end
  end

  context 'as a Consumer' do
    before(:each) do
      subject.publish('some.event', 'test message')
    end

    after(:each) do
      subject.adapter.events('some.event').clear
    end

    it 'reads a message from the queue' do
      subject.subscribe 'some.event', ->(msg) { msg }
      expect do
        subject.listen(false)
      end.to change { subject.adapter.events('some.event').size }.by(-1)
    end

    it 'runs the proc for each message' do
      subject.subscribe('some.event', ->(msg) { "#{msg} LAMBDA LAMBDA LAMBDA" })
      expect(subject.listen(false)).to match /LAMBDA LAMBDA LAMBDA$/
    end

  end

  it 'trigger an event after processing a message' do
    subject.instance_eval(%|subscribe('some.event', ->(msg) { publish('other.event', "Redirected \#{msg}") })|)
    expect { subject.listen(false) }.to_not raise_error
    expect(subject.adapter.events('other.event')).to have(1).item
  end
end
