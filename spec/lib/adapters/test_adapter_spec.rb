require 'spec_helper'

describe Basquiat::Adapters::Test do
  subject { Basquiat::Adapters::Test.new }
  it_behaves_like 'a Basquiat::Adapter'

  context 'publisher' do
    it '#publish [enqueue a message]' do
      expect do
        subject.publish('messages.welcome', { value: 'A Nice Welcome Message' })
      end.to change { subject.events('messages.welcome').size }.by(1)
      expect(subject.events('messages.welcome')[0]).to match(/A Nice Welcome Message/)
    end
  end

  context 'listener' do
    before(:each) do
      subject.publish('some.event', data: 'some message')
    end

    it '#subscribe_to some event' do
      subject.subscribe_to('some.event', ->(msg) { msg.values.map(&:upcase) })
      expect(subject.listen).to eq(['SOME MESSAGE'])
    end

    it '#subscribe_to multiple events' do
      subject.instance_eval <<-METHCALL
        subscribe_to('some.event', ->(msg) { publish 'some.other', data: msg.values.first.upcase; msg })
      METHCALL
      subject.subscribe_to('some.other', ->(msg) { msg.values.first.downcase })
      expect(subject.listen).to eq(data: 'some message')
      expect(subject.events('some.other')[0]).to match(/SOME MESSAGE/)
      expect(subject.listen).to eq('some message')
    end
  end
end
