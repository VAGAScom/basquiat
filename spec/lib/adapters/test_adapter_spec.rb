require 'spec_helper'

describe Basquiat::Adapters::TestAdapter do
  it 'connects to the message broker when needed and disconnect afterwards' do
    adapter = DummyProducer.instance_variable_get(:@adapter)
    expect(adapter).to_not be_connected
    adapter.connect
    expect(adapter).to be_connected
  end

  it '#connect'
  it '#connected?'
  it '#connection_options'
  it '#publish'
end
