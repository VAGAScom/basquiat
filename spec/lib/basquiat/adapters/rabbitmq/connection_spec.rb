# frozen_string_literal: true

require 'basquiat/adapters/rabbitmq_adapter'

RSpec.describe Basquiat::Adapters::RabbitMq::Connection do
  subject(:connection) { Basquiat::Adapters::RabbitMq::Connection }

  let(:hosts) do
    [ENV.fetch('BASQUIAT_RABBITMQ_1_PORT_5672_TCP_ADDR') { 'localhost' }]
  end

  it 'raises an error when the username/password is invalid' do
    conn = connection.new(hosts: hosts, auth: { username: 'guest', password: 'wrong' })
    expect { conn.start }.to raise_error Bunny::AuthenticationFailureError
  end

  it '#connected?' do
    conn = connection.new(hosts: hosts)
    expect(conn.connected?).to be_falsey
    conn.start
    expect(conn.connected?).to_not be_truthy
    conn.disconnect
  end

  context 'failover' do
    let(:failover) do
      { default_timeout: 0.2, max_retries: 2, connection_timeout: 0.3 }
    end

    before(:each) { hosts.unshift('172.168.0.124') }

    it 'tries a reconnection after a few seconds' do
      conn = connection.new(hosts:    ['172.168.0.124'],
                            failover: { default_timeout: 0.2, max_retries: 1 })
      expect { conn.start }.to raise_error(Bunny::TCPConnectionFailed)
      conn.close
    end

    it 'uses another server after all retries on a single one' do
      conn = connection.new(hosts: hosts, failover: failover)
      expect { conn.start }.to_not raise_error
      expect(conn.host).to match(ENV.fetch('BASQUIAT_RABBITMQ_1_PORT_5672_TCP_ADDR') { 'localhost' })
      conn.close
    end
  end
end
