# frozen_string_literal: true
require 'basquiat/adapters/rabbitmq_adapter'

class AwesomeStrategy < Basquiat::Adapters::RabbitMq::BaseStrategy
  def self.session_options
    { exchange: { options: { some_setting: 'awesomesauce' } } }
  end
end

RSpec.describe Basquiat::Adapters::RabbitMq::Configuration do
  subject(:config) { Basquiat::Adapters::RabbitMq::Configuration.new }

  # used by the Adapter::Base class
  describe '#merge_user_options' do
    it 'merges the user supplied options with the default ones' do
      config.merge_user_options(queue: { name: 'config.test.queue' })
      expect(config.base_options[:queue][:name]).to eq('config.test.queue')
    end
  end

  it '#connection_options' do
    expect(config.connection_options.keys).to contain_exactly(:hosts, :auth, :port)
  end

  it '#session_options' do
    expect(config.session_options.keys).to contain_exactly(:exchange, :queue, :publisher, :consumer)
  end

  context 'Strategies' do
    it 'merges the strategy options with the session ones' do
      Basquiat::Adapters::RabbitMq.register_strategy(:awesome, AwesomeStrategy)
      config.merge_user_options(requeue: { enabled: true, strategy: 'awesome' })
      expect(config.session_options[:exchange][:options]).to have_key(:some_setting)
    end

    it 'raises an error if trying to use a non-registered strategy' do
      config.merge_user_options(requeue: { enabled: true, strategy: 'perfect' })
      expect { config.strategy }.to raise_error Basquiat::Errors::StrategyNotRegistered
    end

    it 'deals with the requeue strategy options' do
      Basquiat::Adapters::RabbitMq.register_strategy :dlx, Basquiat::Adapters::RabbitMq::DeadLettering
      config.merge_user_options(requeue: { enabled: true, strategy: 'dlx', options: { exchange: 'dlx.topic' } })
      expect(config.session_options[:queue][:options]).to include('x-dead-letter-exchange' => 'dlx.topic')
    end
  end
end
