require 'spec_helper'
require 'basquiat/adapters/rabbitmq_adapter'

describe Basquiat::Adapters::RabbitMq::DelayedDelivery do
  let(:adapter) { Basquiat::Adapters::RabbitMq.new }
  let(:base_options) do
    { connection: { hosts: [ENV.fetch('BASQUIAT_RABBITMQ_1_PORT_5672_TCP_ADDR') { 'localhost' }],
                    port:  ENV.fetch('BASQUIAT_RABBITMQ_1_PORT_5672_TCP_PORT') { 5672 } },
      publisher:  { persistent: true } }
  end

  before(:each) do
    adapter.adapter_options(base_options)
    adapter.class.register_strategy :ddl, Basquiat::Adapters::RabbitMq::DelayedDelivery
  end

  after(:each) { remove_queues_and_exchanges(adapter) }

  it 'creates the dead letter exchange' do
    adapter.adapter_options(requeue: { enabled: true, strategy: 'ddl' })
    adapter.strategy # initialize the strategy
    channel = adapter.session.channel
    expect(channel.exchanges.keys).to contain_exactly('my.test_exchange', 'basquiat.dlx')
  end

  it 'creates de timeout queues' do
    adapter.adapter_options(requeue: { enabled: true, strategy: 'ddl' })
    adapter.strategy # initialize the strategy
    channel = adapter.session.channel
    expect(channel.queues.keys).to contain_exactly('basquiat.ddlq_1', 'basquiat.ddlq_2', 'basquiat.ddlq_4',
                                                   'basquiat.ddlq_8', 'basquiat.ddlq_16')
  end

  it 'creates and binds the delayed delivery queues' do
    adapter.adapter_options(requeue: { enabled: true, strategy: 'ddl' })
    adapter.strategy
    session = adapter.session

    channel = session.channel
    expect(channel.queues['basquiat.ddlq_1'].arguments)
        .to match(hash_including('x-dead-letter-exchange' => session.exchange.name, 'x-message-ttl' => 1_000))

    expect do
      channel.exchanges['basquiat.dlx'].publish('some message', routing_key: '1.some.event')
      sleep 0.1
    end.to change { channel.queues['basquiat.ddlq_1'].message_count }.by(1)
  end

  context 'when a message is requeued' do
    before(:each) do
      adapter.adapter_options(requeue: { enabled: true, strategy: 'ddl' })
      adapter.strategy # initialize strategy
    end

    it 'is republished with the appropriate routing key'
    it 'after it expires it is reprocessed by the right queue'
  end
end
