# frozen_string_literal: true

require 'basquiat/adapters/rabbitmq_adapter'

RSpec.describe Basquiat::Adapters::RabbitMq::BaseStrategy do
  subject(:strategy) { Basquiat::Adapters::RabbitMq::BaseStrategy.new(Object.new) }

  it 'needs to be extended' do
    expect { strategy.run('messages') }.to raise_error Basquiat::Errors::SubclassResponsibility
  end
end
