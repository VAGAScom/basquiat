# frozen_string_literal: true

RSpec.describe Basquiat do
  after(:each) { Basquiat.reset }

  it 'should have a version number' do
    expect(Basquiat::VERSION).not_to be_nil
  end

  it '#configure yields to a block' do
    expect { |block| Basquiat.configure(&block) }.to yield_control
  end

  context '#configuration' do
    subject(:conf) { Basquiat.configuration }
    %i[exchange_name queue_name rescue_proc logger adapter_options default_adapter].each do |meth|
      it "responds to #{meth}" do
        expect(conf).to respond_to(meth)
      end

      it "responds to #{meth}=" do
        expect(conf).to respond_to("#{meth}=".to_sym)
      end
    end
  end

  context '.load_configuration' do
    it 'reads a configuration file' do
      Basquiat.load_configuration File.join(File.dirname(__FILE__), '../support/basquiat.yml')
      expect(Basquiat.configuration.exchange_name).to eq('my.test_exchange')
    end

    it 'sets up the configuration per YAML file' do
      Basquiat.load_configuration File.join(File.dirname(__FILE__), '../support/basquiat.yml')
      config = Basquiat.configuration
      expect(config.queue_name).to eq('my.nice_queue')
      expect(config.exchange_name).to eq('my.test_exchange')
      expect(config.default_adapter).to eq('Basquiat::Adapters::Test')
      expect(config.adapter_options).to have_key('servers')
    end
  end

  it '#reset' do
    config = Basquiat.configuration
    Basquiat.reset
    expect(Basquiat.configuration).not_to equal(config)
  end
end
