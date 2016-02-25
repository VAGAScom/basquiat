# frozen_string_literal: true
module Basquiat
  module Adapters
    class RabbitMq
      class DelayedDelivery < BaseStrategy
        class << self
          using HashRefinements
          attr_reader :options

          def setup(opts)
            @options = { ddl: { retries: 5,
                                exchange_name: 'basquiat.dlx',
                                queue_name_preffix: 'basquiat.ddlq' } }.deep_merge(opts)
          end
        end

        def initialize(session)
          super
          setup_delayed_delivery
        end

        def run(message)
          message.routing_key = extract_event_info(message.routing_key)[0]
          yield
          public_send(message.action, message)
        end

        # @param [Message] message the, well, message to be requeued
        def requeue(message)
          @exchange.publish(Basquiat::Json.encode(message), routing_key: requeue_route_for(message.di.routing_key))
          ack(message)
        end

        private

        # @param [#match] key the current routing key of the message
        # @return [String] the calculated routing key for a republish / requeue
        def requeue_route_for(key)
          event_name, timeout = extract_event_info(key)
          if timeout == 2**options[:retries] * 1_000
            "rejected.#{session.queue.name}.#{event_name}"
          else
            "#{timeout * 2}.#{session.queue.name}.#{event_name}"
          end
        end

        # @param [#match] key the current routing key of the message
        # @return [Array<String, Integer>] a 2 item array composed of the event.name (aka original routing_key) and
        #   the current timeout
        def extract_event_info(key)
          md = key.match(/^(\d+)\.#{session.queue.name}\.(.+)$/)
          if md
            [md.captures[1], md.captures[0].to_i]
          else
            # So timeout can turn into 1 second, weird but spares some checking
            [key, 500]
          end
        end

        def options
          self.class.options[:ddl]
        end

        def setup_delayed_delivery
          @exchange = session.channel.topic(options[:exchange_name], durable: true)
          session.bind_queue("*.#{session.queue.name}.#")
          prepare_timeout_queues
          queue = session.channel.queue("#{options[:queue_name_preffix]}_rejected", durable: true)
          queue.bind(@exchange, routing_key: 'rejected.#')
        end

        def prepare_timeout_queues
          (0..options[:retries] - 1).each do |iteration|
            timeout = 2 ** iteration
            queue = session.channel.queue("#{options[:queue_name_preffix]}_#{timeout}",
                                          durable: true,
                                          arguments: {
                                            'x-dead-letter-exchange' => session.exchange.name,
                                            'x-message-ttl' => timeout * 1_000 })
            queue.bind(@exchange, routing_key: "#{timeout * 1_000}.#")
          end
        end
      end
    end
  end
end
