module Basquiat
  module Adapters
    class BaseMessage < SimpleDelegator
      attr_reader :action

      def initialize(message)
        @message = Basquiat::Json.decode(message)
        super(@message)
        @action = :ack
      end

      def ack?
        raise SubclassResponsibility
      end

      def unack
        raise SubclassResponsibility
      end

      def requeue
        raise SubclassResponsibility
      end

      def delay_redelivery
        raise SubclassResponsibility
      end
    end
  end
end
