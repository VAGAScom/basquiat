# frozen_string_literal: true

RSpec.describe Basquiat do
  it 'should have a version number' do
    expect(Basquiat::VERSION).not_to be_nil
  end

  it '#configure yields to a block' do
    expect { |block| Basquiat.configure(&block) }.to yield_control
  end

  context '#configuration' do
    subject(:conf) { Basquiat.configuration }
    %i(exchange_name queue_name rescue_proc logger adapter_options default_adapter).each do |meth|
      it "responds to #{meth}" do
        expect(conf).to respond_to(meth)
      end

      it "responds to #{meth}=" do
        expect(conf).to respond_to("#{meth}=".to_sym)
      end
    end
  end

  it '#reset' do
    config = Basquiat.configuration
    Basquiat.reset
    expect(Basquiat.configuration).not_to equal(config)
  end
end
