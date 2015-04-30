require 'spec_helper'
require 'basquiat/adapters/rabbitmq_adapter'

describe Basquiat::Adapters::RabbitMq::Connection,focus: true do
  subject(:connection) { Basquiat::Adapters::RabbitMq::Connection }

  let(:servers) do
    [{ host: ENV.fetch('BASQUIAT_RABBITMQ_1_PORT_5672_TCP_ADDR') { 'localhost' },
       port: ENV.fetch('BASQUIAT_RABBITMQ_1_PORT_5672_TCP_PORT') { 5672 } }]
  end

  before(:each) do
    Basquiat.configure { |c| c.logger = Logger.new('log/basquiat.log') }
  end

  it '#connected?' do
    conn = connection.new(servers: servers)
    expect(conn.connected?).to be_falsey
    conn.start
    expect(conn.connected?).to_not be_truthy
    conn.disconnect
  end


  context 'failover' do
    let(:failover) do
      { default_timeout: 0.2, max_retries: 2,threaded: false }
    end

    before(:each) { servers.unshift(host: 'localhost', port: 1234) }

    it 'tries a reconnection after a few seconds' do
      conn = connection.new(servers:  [host: 'localhost', port: 1234],
                            failover: { default_timeout: 0.2, max_retries: 1 })
      expect { conn.start }.to raise_error(Bunny::TCPConnectionFailed)
      conn.close
    end

    it 'uses another server after all retries on a single one' do
      conn = connection.new(servers: servers, failover: failover)
      expect { conn.start }.to_not raise_error
      expect(conn.current_server_uri).to match "#{ENV.fetch('BASQUIAT_RABBITMQ_1_PORT_5672_TCP_PORT') { 5672 }}"
      conn.close
    end
  end
end
