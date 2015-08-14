module Basquiat
  module Adapters
    class RabbitMq
      class Connection < SimpleDelegator
        def initialize(hosts:, port: 5672, failover: {}, auth: {})
          @hosts    = hosts
          @port     = port
          @failover = failover
          @auth     = auth
        end

        def create_channel
          connection.start
          connection.create_channel
        end

        def start
          connection.start unless connection.connected?
        end

        def connected?
          connection.status == :started
        end

        def disconnect
          connection.close_all_channels
          connection.close
          reset
        end

        private

        def reset
          @connection = nil
        end

        def connection
          @connection ||= Bunny.new(
              hosts:                     @hosts,
              port:                      @port,
              username:                  @auth.fetch(:user, 'guest'),
              password:                  @auth.fetch(:password, 'guest'),
              recovery_attempts:         @failover.fetch(:max_retries, 5),
              network_recovery_interval: @failover.fetch(:default_timeout, 5),
              connection_timeout:        @failover.fetch(:connection_timeout, 5),
              logger:                    Basquiat.logger)
          __setobj__(@connection)
        end
      end
    end
  end
end
