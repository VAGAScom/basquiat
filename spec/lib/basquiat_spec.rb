# frozen_string_literal: true

RSpec.describe Basquiat do
  it 'should have a version number' do
    expect(Basquiat::VERSION).not_to be_nil
  end

  it '#configure yields to a block' do
    expect { |block| Basquiat.configure(&block) }.to yield_control
  end

  it '#configuration' do
    expect(Basquiat.configuration).to respond_to(:exchange_name, :queue_name)
  end

  it '#reset' do
    config = Basquiat.configuration
    Basquiat.reset
    expect(Basquiat.configuration).not_to equal(config)
  end
end
