# frozen_string_literal: true

RSpec.describe Basquiat::Support::JSON do
  it "returns an empty hash if it can't parse the payload" do
    expect(described_class.decode('Idaho Potato')).to eq({})
  end
end
