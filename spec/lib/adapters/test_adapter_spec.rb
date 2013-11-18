require 'spec_helper'

describe Basquiat::Adapters::Test do
  subject { DummyProducer.instance_variable_get(:@adapter) }

  it 'starts disconnected' do
    expect(subject).to_not be_connected
  end

  it '#publish'
end
