require 'spec_helper'

describe Basquiat::Producer do
  # Behaves like Basquiat::Base
  subject { DummyProducer }

  it '#publish' do
    DummyProducer.adapter.should_receive(:publish)
    subject.publish('test.message', message: 'useful test message')
  end
end
