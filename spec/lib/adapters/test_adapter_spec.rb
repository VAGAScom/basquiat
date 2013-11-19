require 'spec_helper'

describe Basquiat::Adapters::Test do
  subject { Basquiat::Adapters::Test.new }
  it_behaves_like 'a Basquiat::Adapter'

  it 'starts disconnected' do
    expect(subject).to_not be_connected
  end

  it '#publish'
end
