# frozen_string_literal: true
describe Basquiat::Json do
  it "returns an empty hash if it can't parse the payload" do
    expect(Basquiat::Json.decode('Idaho Potato')).to eq({})
  end
end
