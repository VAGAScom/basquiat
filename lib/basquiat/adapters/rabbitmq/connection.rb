# frozen_string_literal: true
module Basquiat
  module Adapters
    class RabbitMq
      # Control the connection to the RabitMQ server. Delegates calls to {Bunny::Connection}
      class Connection < SimpleDelegator
        # @param hosts: [Array<String>] IPs or FQDN of the RabbitMQ instances
        # @param port [Fixnum] Port that the RabbitMQ instances run
        # @option failover: [Fixnum] :max_retries (5) Maximum number of reconnection retries
        # @option failover: [Fixnum] :default_timeout (5) Interval between to reconnect attempts
        # @option failover: [Fixnum] :connection_timeout (5) Allowed time before a connection attempt timeouts
        # @option auth: [String] :user ('guest')
        # @option auth: [String] :password ('guest')
        def initialize(hosts:, port: 5672, failover: {}, auth: {})
          @hosts    = hosts
          @port     = port
          @failover = failover
          @auth     = auth
        end

        # Creates a channel
        # @return [Bunny::Channel]
        def create_channel
          connection.start
          Basquiat.logger.debug 'Creating a new channel'
          connection.create_channel
        end

        # Starts the connection if needed
        def start
          Basquiat.logger.debug 'Connecting to RabbitMQ'
          connection.start unless connection.connected?
        end

        # checks if the connection is started
        def connected?
          connection.status == :started
        end

        # Closes all channels and then the connection.
        def disconnect
          connection.close_all_channels
          connection.close
          reset
        end

        private

        def reset
          @connection = nil
          __setobj__(nil)
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
