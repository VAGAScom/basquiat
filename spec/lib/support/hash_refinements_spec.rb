require 'spec_helper'

describe Basquiat::HashRefinements do
  using Basquiat::HashRefinements

  subject(:hash) do
    { 'key' => 1, 'another_key' => 2, 3 => 3, 'array' => [1, 3, 5], 'hash' => { 'inner_key' => 6 } }
  end

  it '#deep_merge' do
    hash.deep_merge('hash' => { 'inner_key' => 7, 'other_inner_key' => 10 })
    expect(hash['hash']).to have_key('other_inner_key')
    expect(hash['hash']['inner_key']).to eq(7)
  end

  it '#deep_merge with nested different hashes' do
    base  = { queue: { options: { some: 'value' } } }
    other = { queue: { options: { another: 'setting' } } }
    result = base.deep_merge(other)
    expect(base[:queue][:options].keys).to contain_exactly(:some, :another)
  end

  it '#symbolize_keys' do
    symbol_hash = hash.symbolize_keys
    expect(symbol_hash).to have_key(:array)
    expect(symbol_hash).to have_key(3)
    expect(symbol_hash).to have_key(:hash)
    expect(symbol_hash[:hash]).to have_key(:inner_key)
  end
end
