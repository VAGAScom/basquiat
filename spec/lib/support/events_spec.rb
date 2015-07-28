describe Basquiat::Events do

  it 'add a key with # and retrive like a wildcard' do
    events = Basquiat::Events.new

    events['one.key.#'] = 'some'
    expect(events['one.key.extra']).to eql('some')
  end
end
