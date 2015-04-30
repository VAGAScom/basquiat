require 'spec_helper'
require 'basquiat/adapters/rabbitmq_adapter'

describe Basquiat::Adapters::RabbitMq::Message do
  subject(:message) { Basquiat::Adapters::RabbitMq::Message.new(key: 'value', date: Date.new.iso8601) }

  it 'delegates all calls to message hash' do
    expect(message[:key]).to eq('value')
  end

  it 'can be JSONified' do
    expect(MultiJson.dump(message)).to eq(MultiJson.dump(key: 'value', date: Date.new.iso8601))
  end

  it 'exposes the delivery information' do
    expect { message.di }.to_not raise_error
    expect { message.delivery_info }.to_not raise_error
  end

  it 'exposes the properties of the message' do
    expect { message.props }.to_not raise_error
  end
end
