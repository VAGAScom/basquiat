require 'spec_helper'

describe Basquiat::Adapters::Test do
  subject { Basquiat::Adapters::Test.new }
  it_behaves_like 'a Basquiat::Adapter'

  context 'publisher' do
    it '#publish [enqueue a message]' do
      expect do
        subject.publish('messages.welcome', 'A Nice Welcome Message')
      end.to change { subject.events('messages.welcome').size }.by(1)

      expect(subject.events('messages.welcome')).to be_member('A Nice Welcome Message')
    end
  end

  context 'listener' do
    before(:each) do
      subject.publish('some.event', 'some message')
    end

    it '#subscribe_to some event' do
      subject.subscribe_to('some.event', ->(msg) { msg.upcase })
      expect(subject.listen).to eq('SOME MESSAGE')
    end
  end
end
