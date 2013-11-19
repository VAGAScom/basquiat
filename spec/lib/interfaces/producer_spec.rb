require 'spec_helper'

describe Basquiat::Producer do
  # Behaves like Basquiat::Base
  subject { DummyProducer }
  it_behaves_like 'Basquiat::Base'

  it '#publish' do
    expect do
      subject.publish('test.message', message: 'useful test message')
    end.to change { DummyProducer.adapter.events('test.message').size }.by(1)
  end

  it 'set the adapter options to host: localhost and port: 5672' do
    expect(subject.adapter.options[:port]).to eq(5672)
    expect(subject.adapter.options[:host]).to eq('localhost')
    expect(subject.adapter.options[:durable]).to be_true
  end
end
