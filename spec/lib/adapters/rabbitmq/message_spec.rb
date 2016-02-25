# frozen_string_literal: true
require 'spec_helper'
require 'basquiat/adapters/rabbitmq_adapter'

describe Basquiat::Adapters::RabbitMq::Message do
  let(:json) do
    { key: 'value', date: Date.new.iso8601 }.to_json
  end
  subject(:message) { Basquiat::Adapters::RabbitMq::Message.new(json) }

  it 'delegates all calls to message hash' do
    expect(message[:key]).to eq('value')
  end

  it 'can be JSONified' do
    expect(MultiJson.dump(message)).to eq(json)
  end

  it 'exposes the delivery information' do
    expect { message.di }.to_not raise_error
    expect { message.delivery_info }.to_not raise_error
  end

  it 'exposes the properties of the message' do
    expect { message.props }.to_not raise_error
  end
end
