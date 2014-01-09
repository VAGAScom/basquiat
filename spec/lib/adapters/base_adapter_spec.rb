require 'spec_helper'

# Sample class used for testing
class SampleAdapter
  include Basquiat::Adapters::Base
end

describe Basquiat::Adapters::Base do
  subject { SampleAdapter.new }
  it_behaves_like 'a Basquiat::Adapter'

  it "returns an empty hash if it can't parse the payload" do
    expect(Basquiat::Adapters::Base.json_decode('Idaho Potato')).to eq({})
  end
end
