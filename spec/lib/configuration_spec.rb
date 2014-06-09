require 'spec_helper'

describe Basquiat::Configuration do
  subject(:config) { Basquiat::Configuration.new }

  context 'accessors' do
    it '#environment' do
      expect(config.environment).to eq('test')
    end

    it '#environment=' do
      config.environment = 'test'
      expect(config.environment).to eq('test')
    end

    it '#queue_name' do
      expect(config.queue_name).to eq('vagas.queue')
    end

    it '#queue_name=' do
      config.queue_name = 'vagas.test'
      expect(config.queue_name).to eq('vagas.test')

      config.queue_name = nil
      expect(config.queue_name).to eq('vagas.queue')
    end

    it '#exchange_name' do
      expect(config.exchange_name).to eq('vagas.exchange')
    end

    it '#exchange_name=' do
      config.exchange_name = 'test'
      expect(config.exchange_name).to eq('test')

      config.exchange_name = nil
      expect(config.exchange_name).to eq('vagas.exchange')
    end

    it '#logger' do
      expect(config.logger).not_to be_nil
    end

    it '#logger=' do
      config.logger = Logger.new('/dev/null')
      expect(config.logger).to be_a Logger
    end
  end

  it '#config_file=' do
    config.config_file = File.join(File.dirname(__FILE__), '../support/basquiat.yml')

    expect(config.queue_name).to eq('my.nice_queue')
    expect(config.exchange_name).to eq('my.test_exchange')
    expect(config.default_adapter).to eq('Basquiat::Adapters::Test')
    expect(config.adapter_options).to have_key(:servers)
  end

  it 'settings provided on the config file have lower precedence' do
    config.exchange_name = 'super.nice_exchange'
    config.config_file = File.join(File.dirname(__FILE__), '../support/basquiat.yml')

    expect(config.exchange_name).to eq('super.nice_exchange')
  end

  xit '#reload_classes' do
    require 'basquiat/adapters/rabbitmq_adapter'

    class ReloadedClass
      extend Basquiat::Base

      self.event_adapter = Basquiat::Adapters::RabbitMq
    end

    config.config_file = File.join(File.dirname(__FILE__), '../support/basquiat.yml')
    config.reload_classes

    expect(ReloadedClass.adapter).to be_a Basquiat::Adapters::Test
  end
end
