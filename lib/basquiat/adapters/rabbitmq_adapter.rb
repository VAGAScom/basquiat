require 'bunny'
require 'delegate'
require 'byebug'

module Basquiat
  module Adapters
    # The RabbitMQ adapter for Basquiat
    class RabbitMq < Basquiat::Adapters::Base
      using Basquiat::HashRefinements

      # Avoid superclass mismatch errors
      require 'basquiat/adapters/rabbitmq/message'
      require 'basquiat/adapters/rabbitmq/connection'
      require 'basquiat/adapters/rabbitmq/session'
      require 'basquiat/adapters/rabbitmq/strategies/base_strategy'
      require 'basquiat/adapters/rabbitmq/strategies/basic_acknowledge'
      require 'basquiat/adapters/rabbitmq/strategies/dead_lettering'

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
          strategy = BasicAcknowledge.new(session)
          session.subscribe(block) do |routing_key, message|
            strategy.run(message) do
              procs[routing_key].call(message)
            end
          end
        end
      end

      def reset_connection
        connection.disconnect
        @connection = nil
        @session    = nil
      end

      alias_method :disconnect, :reset_connection

      def session
        @session ||= Session.new(connection, formatted_options[:session])
      end

      def formatted_options
        { connection: {
            servers:  options[:servers],
            failover: options[:failover],
            auth:     options[:auth] },
          session:    { exchange:  options[:exchange],
                        publisher: options[:publisher],
                        queue:     options[:queue] }.deep_merge(strategy.session_options)
        }
      end

      private

      def strategy
        return BasicAcknowledge unless options[:requeue][:enabled]
        strategies.fetch(options[:requeue][:strategy].to_sym)
      rescue KeyError
        raise Basquiat::Errors::StrategyNotRegistered.new(options[:requeue][:strategy])
      end

      def connection
        @connection ||= Connection.new(formatted_options[:connection])
      end
    end
  end
end
