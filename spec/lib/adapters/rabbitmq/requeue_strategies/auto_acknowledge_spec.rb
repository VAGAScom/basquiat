# frozen_string_literal: true
require 'spec_helper'
require 'basquiat/adapters/rabbitmq_adapter'

describe Basquiat::Adapters::RabbitMq::AutoAcknowledge do
  let(:adapter) { Basquiat::Adapters::RabbitMq.new }
  let(:base_options) do
    { connection: { hosts: [ENV.fetch('BASQUIAT_RABBITMQ_1_PORT_5672_TCP_ADDR') { 'localhost' }],
                    port:  ENV.fetch('BASQUIAT_RABBITMQ_1_PORT_5672_TCP_PORT') { 5672 } },
      publisher:  { persistent: true },
      requeue:    { enabled: false } }
  end

  before(:each) do
    adapter.adapter_options(base_options)
  end

  after(:each) { remove_queues_and_exchanges(adapter) }

  it 'set manual_ack to false' do
    # Setup the strategy
    adapter.strategy
    expect(adapter.send(:options)[:consumer][:manual_ack]).to be_falsey
  end
end
