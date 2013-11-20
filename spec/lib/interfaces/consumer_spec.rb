require 'spec_helper'

describe 'a Consumer' do
  it_behaves_like 'Basquiat::Base'
  subject { SimpleClient }

  before(:each) do
    subject.publish('some.event', 'test message')
  end

  after(:each) do
    subject.adapter.events('some.event').clear
  end

  it 'reads a message from the queue' do
    subject.subscribe 'some.event', ->(msg) { msg }
    expect do
      subject.listen(false)
    end.to change { subject.adapter.events('some.event').size }.by(-1)
  end

  it 'runs the proc for each message' do
    subject.subscribe('some.event', ->(msg) { "#{msg} LAMBDA LAMBDA LAMBDA" })
    expect(subject.listen(false)).to match /LAMBDA LAMBDA LAMBDA$/
  end
end
