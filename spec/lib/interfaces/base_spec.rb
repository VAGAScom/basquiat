require 'spec_helper'

# Sample class used for testing
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
    expect(subject).to respond_to(:adapter_options)
  end

  it 'set the adapter options' do
    subject.adapter_options host: 'localhost', port: 5672, durable: true
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
      subject.subscribe_to 'some.event', ->(msg) { msg }
      expect do
        subject.listen(block: false)
      end.to change { subject.adapter.events('some.event').size }.by(-1)
    end

    it 'runs the proc for each message' do
      subject.subscribe_to('some.event', ->(msg) { "#{msg} LAMBDA LAMBDA LAMBDA" })
      expect(subject.listen(block: false)).to match(/LAMBDA LAMBDA LAMBDA$/)
    end

    it 'can receive a symbol that will point to a method' do
      def subject.test_method(msg)
        msg.scan(/e/)
      end

      subject.subscribe_to('some.event', :test_method)
      expect(subject.listen(block: false)).to eq(%w(e e e))
    end
  end

  it 'trigger an event after processing a message' do
    subject.publish('some.event', 'some message')
    subject.instance_eval <<-METHCALL
      subscribe_to 'some.event', ->(msg) { publish('other.event', "Redirected \#{msg}") }
    METHCALL
    expect { subject.listen(block: false) }.to_not raise_error
    expect(subject.adapter.events('other.event')).to have(1).item
  end
end
