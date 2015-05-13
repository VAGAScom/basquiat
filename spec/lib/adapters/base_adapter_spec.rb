require 'spec_helper'

# Sample class used for testing
describe Basquiat::Adapters::Base do
  subject(:adapter) { Basquiat::Adapters::Base.new }

  [:disconnect, :subscribe_to, :publish].each do |meth|
    it "raise a SubclassResponsibility error if #{meth} isn't implemented" do
      expect { adapter.public_send(meth) }.to raise_error Basquiat::Errors::SubclassResponsibility
    end
  end

  it 'raise error when using an unregistered strategy' do
    # expect(adapter.use_strategy(:not_here)).to raise_error StrategyNotRegistered
  end

  it 'register a requeue strategy' do
    class CoolStuff ; end
    adapter.class.register_strategy :cool_stuff, CoolStuff
    expect(adapter.class::STRATEGIES).to have_key :cool_stuff
  end

  it 'merges the options with the default ones' do
    opts = adapter.instance_variable_get(:@options)
    adapter.adapter_options(nice_option: '127.0.0.2')
    expect(opts[:nice_option]).to eq('127.0.0.2')
  end
end
