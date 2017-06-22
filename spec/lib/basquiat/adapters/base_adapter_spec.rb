# frozen_string_literal: true

# Sample class used for testing
RSpec.describe Basquiat::Adapters::Base do
  subject(:adapter) { Basquiat::Adapters::Base.new }

  %i[disconnect subscribe_to publish].each do |meth|
    it "raise a SubclassResponsibility error if #{meth} isn't implemented" do
      expect { adapter.public_send(meth) }.to raise_error Basquiat::Errors::SubclassResponsibility
    end
  end

  it 'raise error when using an unregistered strategy' do
    expect { adapter.class.strategy(:not_here) }.to raise_error Basquiat::Errors::StrategyNotRegistered
  end

  it 'register a requeue strategy' do
    class CoolStuff
    end
    adapter.class.register_strategy :cool_stuff, CoolStuff
    expect(adapter.strategies).to have_key :cool_stuff
  end

  it 'merges the options with the default ones' do
    opts = adapter.instance_variable_get(:@options)
    adapter.adapter_options(nice_option: '127.0.0.2')
    expect(opts[:nice_option]).to eq('127.0.0.2')
  end
end
