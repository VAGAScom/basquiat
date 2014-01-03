require 'bunny'

module Basquiat
  module Adapters
    # The RabbitMQ adapter for Basquiat
    class RabbitMq
      include Basquiat::Adapters::Base

      def default_options
        { failover: { default_timeout: 5, max_retries: 5 },
          servers:  [{ host: 'localhost', port: 5672 }],
          queue:    { name: Basquiat.configuration.queue_name, options: { durable: true } },
          exchange: { name: Basquiat.configuration.exchange_name, options: { durable: true } } }
      end

      def subscribe_to(event_name, proc)
        procs[event_name] = proc
      end

      # TODO: Publisher Confirms
      # TODO: Channel Level Errors
      def publish(event, message, single_message = true)
        exchange.publish(Basquiat::Adapters::Base.json_encode(message), routing_key: event)
        disconnect if single_message
      rescue # channel errors / disconnections
        handle_network_failures
        retry
      end

      # TODO: Manual ACK and Requeue
      def listen(lock = true)
        procs.keys.each { |key| bind_queue(key) }
        queue.subscribe(block: lock) do |di, _, msg|
          message = Basquiat::Adapters::Base.json_decode(msg)
          procs[di.routing_key].call(message)
        end
      end

      def connect
        connection.start
      end

      private

      def handle_network_failures
        @retries += 1
        if @retries <= failover_opts[:max_retries]
          warn("[WARN]: Connection failed retrying in #{failover_opts[:default_timeout]} seconds")
          sleep(failover_opts[:default_timeout])
        else
          #disconnect if connection && connection.started?
          p options[:servers]
          options[:servers].rotate! if can_failover?
          p options[:servers]
          @retries = 0
        end

      end

      def failover_opts
        options[:failover]
      end

      def bind_queue(event_name)
        queue.bind(exchange, routing_key: event_name)
      end

      def disconnect
        connection.close_all_channels
        connection.close
        @connection, @channel, @exchange = nil, nil, nil
      end

      def connection
        @connection ||= Bunny.new(current_server)
        @retries    = 0
      rescue Bunny::TCPConnectionFailed => error # Try to connect to another server or fail
        handle_network_failures
        if @retries >= failover_opts[:max_retries]
          raise(error)
        else
          retry
        end
      end

      def channel
        connect
        @channel ||= connection.create_channel
      end

      def queue
        @queue ||= channel.queue(options[:queue][:name], options[:queue][:options])
      end

      def exchange
        @exchange ||= channel.topic(options[:exchange][:name], options[:exchange][:options])
      end

      def current_server
        options[:servers].first
      end

      def can_failover?
        options[:servers].size > 1
      end
    end
  end
end
