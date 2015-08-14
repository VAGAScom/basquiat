module Basquiat
  module Adapters
    class RabbitMq
      class DelayedDelivery < BaseStrategy
        class << self
          attr_reader :options

          def setup(opts)
            @options = { ddl: { retries: opts.fetch(:retries, 5) } }
          end
        end

        def initialize(session)
          super(session)
          setup_delayed_delivery
        end

        def run(message)
          yield
          public_send(message.action, message)
        end

        def requeue(message)
          @session.channel.nack(message.delivery_info)
          @exchange.publish(message, routing_key: "#{timeout}_#{@session.queue.name}_#{message.routing_key}")
        end

        private
        def options
          self.class.options[:ddl]
        end

        def setup_delayed_delivery
          @exchange = @session.channel.topic('basquiat.dlx')
          options[:retries].times do |iteration|
            timeout = 2 ** iteration
            queue   = @session.channel.queue("basquiat.ddlq_#{timeout}",
                                             arguments: {
                                                 durable:                 true,
                                                 'x-dead-letter-exchange' => @session.exchange.name,
                                                 'x-message-ttl'          => timeout * 1_000 })
            queue.bind(@exchange, routing_key: "#{timeout}.#")
          end
        end
      end
    end
  end
end
