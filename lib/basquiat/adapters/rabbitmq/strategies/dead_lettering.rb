module Basquiat
  module Adapters
    class RabbitMq
      class DeadLettering < BaseStrategy
        def initialize(session)
          super
          setup_dead_lettering
        end

        def self.session_options
          { queue: { options: { dead_letter_exchange: 'basquiat.dlx' } }, exchange: {} }
        end

        def run(message)
          catch :skip_processing do
            check_incoming_messages
            yield
            send(message.di.delivery_tag, message.action)
          end
        end

        private

        def check_incoming_messages
          fail
        end

        def setup_dead_lettering
          dlx   = @session.channel.topic('basquiat.dlx')
          queue = @session.channel.queue('basquiat.dlq', ttl: 5 * 60 * 1000, arguments: { dead_letter_exchange: @session.exchange.name, 'x-message-ttl' => 1000 })
          queue.bind(dlx, routing_key: '#')
        end
      end
    end
  end
end
