module Basquiat
  module Adapters
    class RabbitMq
      class BaseStrategy
        def initialize(session)
          @session = session
        end

        def self.session_options
          {}
        end

        def run(_message)
          fail Basquiat::Errors::SubclassResponsibility
        end

        private

        def ack(delivery_tag)
          @session.channel.ack(delivery_tag)
        end

        def unack(delivery_tag)
          @session.channel.unack(delivery_tag, false)
        end
      end
    end
  end
end
