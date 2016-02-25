# frozen_string_literal: true
require 'spec_helper'

describe Basquiat::Adapters::BaseMessage do
  subject(:message) { Basquiat::Adapters::BaseMessage.new({ data: 'everything is AWESOME!' }.to_json) }

  it 'delegates calls to the JSON' do
    expect(message.fetch(:data)).to eq('everything is AWESOME!')
    expect { message.fetch(:error) }.to raise_error KeyError
  end
end
