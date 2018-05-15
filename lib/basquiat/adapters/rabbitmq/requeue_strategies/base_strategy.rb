# frozen_string_literal: true

module Basquiat
  module Adapters
    class RabbitMq
      class BaseStrategy
        class << self
          def session_options
            {}
          end

          def setup(options = {})
            @options = options
          end
        end

        def initialize(session)
          @session = session
        end

        def run(_message)
          raise Basquiat::Errors::SubclassResponsibility
        end

        def ack(message)
          @session.channel.ack(message.delivery_tag)
        end

        def nack(message)
          @session.channel.nack(message.delivery_tag, false)
        end

        def requeue(message)
          @session.channel.nack(message.delivery_tag, false, true)
        end

        private

        attr_reader :session
      end
    end
  end
end
