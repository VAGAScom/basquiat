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
    let(:proc) { -> { 'Hello from the lambda! o/' } }

    describe '*' do
      let(:words) { %w(awesome lame dumb cool) }

      it 'event.* does not match event_some_word' do
        events['event.*'] = proc
        expect { events['event_some_word'] }.to raise_error KeyError
      end

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
          expect { events['some.event.dude'] }.to raise_error KeyError
        end
      end
    end
    describe '#' do
      context 'matches any number of words' do
        it '# matches all events' do
          events['#'] = proc
          %w(some.cool.event event cool.event).each do |event|
            expect(events[event]).to eq(proc)
          end
        end

        it 'matches specific events' do
          events['#.event'] = proc
          %w(some.cool.event cool.event).each do |event|
            expect(events[event]).to eq(proc)
          end
          expect { events['event'] }.to raise_error KeyError
        end
      end
    end
  end
end
