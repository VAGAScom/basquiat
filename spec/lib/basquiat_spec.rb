require 'spec_helper'

describe Basquiat do
  it 'should have a version number' do
    Basquiat::VERSION.should_not be_nil
  end

  context '#configuration' do
    before(:each) { Basquiat.reset }
    it '#queue_name' do
      expect(Basquiat.configuration.queue_name).to eq('vagas.queue')
    end

    it '#queue_name=' do
      Basquiat.configuration.queue_name = 'vagas.test'
      expect(Basquiat.configuration.queue_name).to eq('vagas.test')

      Basquiat.configure { |config| config.queue_name = 'vagas.block_config' }
      expect(Basquiat.configuration.queue_name).to eq('vagas.block_config')

      Basquiat.configuration.queue_name = nil
      expect(Basquiat.configuration.queue_name).to eq('vagas.queue')
    end

    it '#exchange_name' do
      expect(Basquiat.configuration.exchange_name).to eq('vagas.exchange')
    end

    it '#exchange_name=' do
      Basquiat.configuration.exchange_name = 'test'
      expect(Basquiat.configuration.exchange_name).to eq('test')

      Basquiat.configuration.exchange_name = nil
      expect(Basquiat.configuration.exchange_name).to eq('vagas.exchange')
    end
  end
end
