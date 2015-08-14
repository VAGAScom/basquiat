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
          fail Basquiat::Errors::SubclassResponsibility
        end

        def ack(message)
          @session.channel.ack(message.delivery_tag)
        end

        def unack(message)
          @session.channel.nack(message.delivery_tag, false)
        end
      end
    end
  end
end
