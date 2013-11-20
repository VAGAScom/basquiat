require 'spec_helper'

describe Basquiat::Adapters::Test do
  subject { Basquiat::Adapters::Test.new }
  it_behaves_like 'a Basquiat::Adapter'

  it 'starts disconnected' do
    expect(subject).to_not be_connected
  end

  it '#publish [enqueue a message]' do
    expect do
      subject.publish('messages.welcome', 'A Nice Welcome Message')
    end.to change { subject.events('messages.welcome').size }.by(1)

    expect(subject.events('messages.welcome')).to be_member('A Nice Welcome Message')
  end
end
