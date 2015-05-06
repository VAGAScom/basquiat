require 'bunny'
require 'delegate'

module Basquiat
  module Adapters
    # The RabbitMQ adapter for Basquiat
    class RabbitMq < Basquiat::Adapters::Base

      # Avoid superclass mismatch errors
      require 'basquiat/adapters/rabbitmq/message'
      require 'basquiat/adapters/rabbitmq/connection'
      require 'basquiat/adapters/rabbitmq/session'


      def default_options
        { failover:  { default_timeout: 5, max_retries: 5 },
          servers:   [{ host: 'localhost', port: 5672 }],
          queue:     { name: Basquiat.configuration.queue_name, options: { durable: true } },
          exchange:  { name: Basquiat.configuration.exchange_name, options: { durable: true } },
          publisher: { confirm: true, persistent: false },
          auth:      { user: 'guest', password: 'guest' },
          requeue:   { enabled: false } }
      end

      def subscribe_to(event_name, proc)
        procs[event_name] = proc
      end

      def publish(event, message, persistent: options[:publisher][:persistent], props: {})
        connection.with_network_failure_handler do
          session.publish(event, message, props)
          disconnect unless persistent
        end
      end

      def listen(block: true)
        connection.with_network_failure_handler do
          procs.keys.each { |key| session.bind_queue(key) }
          session.subscribe(block) { |key, message| procs[key].call(message) }
        end
      end

      def reset_connection
        connection.disconnect
        @connection, @session = nil, nil
      end

      alias_method :disconnect, :reset_connection

      def session
        @session ||= Session.new(connection, formatted_options[:session])
      end

      private
      def connection
        @connection ||= Connection.new(formatted_options[:connection])
      end

      def formatted_options
        { connection: {
            servers:  options[:servers],
            failover: options[:failover],
            auth:     options[:auth] },
          session:    {
              exchange:  options[:exchange],
              publisher: options[:publisher],
              queue:     options[:queue],
              requeue:   options[:requeue]
          } }
      end
    end
  end
end
