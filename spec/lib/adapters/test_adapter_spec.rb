# frozen_string_literal: true
require 'spec_helper'

describe Basquiat::Adapters::Test do
  subject(:adapter) { Basquiat::Adapters::Test.new }

  context 'publisher' do
    it '#publish [enqueue a message]' do
      expect do
        adapter.publish('messages.welcome', value: 'A Nice Welcome Message')
      end.to change { adapter.events('messages.welcome').size }.by(1)
      expect(adapter.events('messages.welcome')[0]).to match(/A Nice Welcome Message/)
    end
  end

  context 'listener' do
    before(:each) do
      adapter.publish('some.event', data: 'some message')
    end

    it '#subscribe_to some event' do
      adapter.subscribe_to('some.event', ->(msg) { msg.values.map(&:upcase) })
      expect(adapter.listen).to eq(['SOME MESSAGE'])
    end

    it '#subscribe_to multiple events' do
      adapter.instance_eval <<-METHCALL
        subscribe_to('some.event', ->(msg) { publish 'some.other', data: msg.values.first.upcase; msg })
      METHCALL
      adapter.subscribe_to('some.other', ->(msg) { msg.values.first.downcase })
      expect(adapter.listen).to eq(data: 'some message')
      expect(adapter.events('some.other')[0]).to match(/SOME MESSAGE/)
      expect(adapter.listen).to eq('some message')
    end
  end

  describe '#clean' do
    context 'when no event has been published' do
      it 'should have no event registered' do
        Basquiat::Adapters::Test.clean
        expect(Basquiat::Adapters::Test.events).to be_empty
      end
    end

    context 'when some events have been published' do
      before do
        adapter.publish('some.message', value: 'A Nice Welcome Message')
        adapter.publish('some.message', value: 'A Nasty Welcome Message')
        adapter.publish('other.message', value: 'A Random Welcome Message')
      end

      it 'should have no event registered' do
        Basquiat::Adapters::Test.clean
        expect(Basquiat::Adapters::Test.events).to be_empty
      end
    end
  end
end
