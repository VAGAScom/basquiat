require 'spec_helper'

describe Basquiat do
  it 'should have a version number' do
    Basquiat::VERSION.should_not be_nil
  end

  context '#configuration' do
    it '#exchange_name' do
      expect(configuration.exchange_name).to eq('vagas')
    end

    it '#exchange_name=' do
      configuration.exchange_name = 'test'
      expect(configuration.exchange_name).to eq('test')
    end
  end
end
