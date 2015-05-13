module Basquiat
  module Adapters
    class RabbitMq
      class Connection < SimpleDelegator
        def initialize(servers:, failover: {}, auth: {})
          @servers  = Array(servers)
          @failover = { default_timeout: 5, max_retries: 5 }.merge(failover)
          @auth     = { user: 'guest', password: 'guest' }.merge(auth)
        end

        def start
          with_network_failure_handler do
            connection.start
            current_server[:retries] = 0
          end
        end

        def connected?
          connection.status == :started
        end

        def disconnect
          connection.close_all_channels
          connection.close
          reset
        end

        def current_server_uri
          "amqp://#{auth[:user]}:#{auth[:password]}@#{current_server[:host]}:#{current_server[:port]}#{current_server[:vhost]}"
        end

        def with_network_failure_handler
          yield if block_given?
        rescue Bunny::ConnectionForced, Bunny::TCPConnectionFailed, Bunny::NetworkFailure => error
          if current_server.fetch(:retries, 0) <= @failover.fetch(:max_retries)
            handle_network_failures
            retry
          else
            raise(error)
          end
        end

        private

        def reset
          @connection = nil
        end

        def handle_network_failures
          Basquiat.logger.warn "Failed to connect to #{current_server_uri}"
          retries                  = current_server.fetch(:retries, 0)
          current_server[:retries] = retries + 1
          if retries < @failover.fetch(:max_retries)
            Basquiat.logger.warn("Retrying connection to #{current_server_uri} in #{@failover.fetch(:default_timeout)} seconds")
            sleep(@failover.fetch(:default_timeout))
          else
            Basquiat.logger.warn("Total number of retries exceeded for #{current_server_uri}")
            rotate
          end
          reset
        end

        def connection
          Basquiat.logger.info("Connecting to #{current_server_uri}")
          @connection ||= Bunny.new(
            current_server_uri,
            automatic_recovery: false,
            threaded:           @failover.fetch(:threaded, true),
            logger:             Basquiat.logger)
          __setobj__(@connection)
        end

        def current_server
          @servers.first
        end

        def auth
          current_server[:auth] || @auth
        end

        def rotate
          @servers.rotate!
        end
      end
    end
  end
end
