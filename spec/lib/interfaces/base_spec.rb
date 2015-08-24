require 'spec_helper'


describe Basquiat::Base do
  # Sample class used for testing
  class SampleClass
    extend Basquiat::Base
    self.adapter = Basquiat::Adapters::Test
  end

  subject { SampleClass }

  it '.event_adapter= / .adapter=' do
    expect(subject).to respond_to(:event_adapter=)
    expect(subject).to respond_to(:adapter=)
  end

  it '.adapter_options(option_hash)' do
    expect(subject).to respond_to(:adapter_options)
  end

  it 'set the adapter options' do
    subject.adapter_options host: 'localhost', port: 5672, durable: true
    expect(subject.adapter.options[:port]).to eq(5672)
    expect(subject.adapter.options[:host]).to eq('localhost')
    expect(subject.adapter.options[:durable]).to be_truthy
  end

  it 'delegates disconnect and connected? to the adapter' do
    expect(subject.adapter).to receive(:connected?)
    subject.connected?

    expect(subject.adapter).to receive(:disconnect)
    subject.disconnect
  end

  context 'using the defaults' do
    class DefaultClass
      extend Basquiat::Base
    end

    subject(:defaults) { DefaultClass }

    it 'has an event_adapter' do
      expect(defaults.adapter).to be_a(Basquiat::Adapters::Test)
    end

    it 'publishes to the configured queue and exchanges' do
      expect do
        defaults.publish('test.message', message: 'useful test message')
      end.to change { defaults.adapter.events('test.message').size }.by(1)
    end
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
end
