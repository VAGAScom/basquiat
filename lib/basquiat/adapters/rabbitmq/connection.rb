# frozen_string_literal: true

module Basquiat
  module Adapters
    class RabbitMq
      # Control the connection to the RabitMQ server. Delegates calls to {Bunny::Connection}
      class Connection < SimpleDelegator
        # @param hosts: [Array<String>] IPs or FQDN of the RabbitMQ instances
        # @param port [Fixnum] Port that the RabbitMQ instances run
        # @param vhost [String] Virtual host
        # @option tls_options [Boolean] :tls when set to true, will set SSL context up and switch to TLS port (5671)
        # @option tls_options [String] :tls_cert string path to the client certificate (public key) in PEM format
        # @option tls_options [String] :tls_key string path to the client key (private key) in PEM format
        # @option tls_options [Array<String>] :tls_ca_certificates array of string paths to CA certificates in PEM format
        # @option tls_options [Boolean] :verify_peer determines if TLS peer authentication (verification) is performed, true by default
        # @option failover: [Fixnum|Symbol] :heartbeat (:server) Heartbeat timeout to offer to the server
        # @option failover: [Fixnum] :max_retries (5) Maximum number of reconnection retries
        # @option failover: [Fixnum] :default_timeout (5) Interval between to reconnect attempts
        # @option failover: [Fixnum] :connection_timeout (5) Allowed time before a connection attempt timeouts
        # @option failover: [Fixnum] :read_timeout (30) TCP socket read timeout in seconds
        # @option failover: [Fixnum] :write_timeout (30) TCP socket write timeout in seconds
        # @option auth: [String] :user ('guest')
        # @option auth: [String] :password ('guest')
        def initialize(args, **kwargs)
          @hosts       = args[:hosts]
          @port        = args[:port]
          @vhost       = args[:vhost]
          @tls_options = args[:tls_options]
          @failover    = args[:failover]
          @auth        = args[:auth]
        end

        # Creates a channel
        # @return [Bunny::Channel]
        def create_channel
          connection.start unless connected?
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

        def configuration
          { hosts:                     @hosts,
            port:                      @port,
            vhost:                     @vhost,
            username:                  @auth.fetch(:user, 'guest'),
            password:                  @auth.fetch(:password, 'guest'),
            heartbeat:                 set_failover_opt('heartbeat', :server),
            recovery_attempts:         set_failover_opt('max_retries', 5),
            network_recovery_interval: set_failover_opt('default_timeout', 5),
            connection_timeout:        set_failover_opt('connection_timeout', 5),
            read_timeout:              set_failover_opt('read_timeout', 30),
            write_timeout:             set_failover_opt('write_timeout', 30),
            logger:                    Basquiat.logger }.merge(@tls_options)
        end

        def set_failover_opt(key, default_value)
          return default_value if @failover.nil?
          return @failover.fetch(key.to_sym, default_value)
        end

        def connection
          @connection ||= Basquiat.configuration.connection || Bunny.new(
            configuration
          )
          __setobj__(@connection)
        end
      end
    end
  end
end
