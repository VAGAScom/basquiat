require 'spec_helper'
require 'basquiat/adapters/rabbitmq_adapter'

describe Basquiat::Adapters::RabbitMq::Events do
  subject(:events) { Basquiat::Adapters::RabbitMq::Events.new }

  context 'basic functionality' do

    it 'raises a KeyError when no matching keys are found' do
      expect { events['event'] }.to raise_error KeyError
    end

    it 'stores the key and value of the proc' do
      proc                         = -> { 'equal awesome lambda' }
      events['some.awesome.event'] = proc
      expect(events['some.awesome.event']).to eq proc
    end
  end

  context 'wildcard keys' do
    describe '*' do
      let(:proc) { -> { 'Hello from the lambda! o/' } }
      let(:words) { %w{awesome lame dumb cool} }
      context 'matches any ONE word' do
        it 'at the end' do
          events['some.event.*'] = proc
          words.each do |word|
            expect(events["some.event.#{word}"]).to eq proc
          end
        end

        it 'in the middle of the name' do
          events['some.*.event'] = proc
          words.each do |word|
            expect(events["some.#{word}.event"]).to eq proc
          end
        end

        it 'at the start' do
          events['*.some.event'] = proc
          words.each do |word|
            expect(events["#{word}.some.event"]).to eq proc
          end
        end

        it 'in more than one place' do
          events['some.*.bob.*'] = proc
          words.each do |word|
            expect(events["some.#{word}.bob.#{word}"]).to eq(proc)
          end
        end
      end
      context 'does not match more than ONE word' do
        it 'some.* does not match some.event.dude' do
          events['some.*'] = -> {}
          expect(events['some.event.dude']).to be_nil
        end
      end
    end
  end
end
