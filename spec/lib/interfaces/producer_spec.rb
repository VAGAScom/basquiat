require 'spec_helper'

describe Basquiat::Producer do
  # Behaves like Basquiat::Base
  subject { DummyProducer }

  it '#publish' do
    expect do
      subject.publish('test.message', message: 'useful test message')
    end.to change { DummyProducer.adapter.events('test.message').size }.by(1)
  end
end
