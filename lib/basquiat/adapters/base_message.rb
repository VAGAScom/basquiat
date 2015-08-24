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
        fail Basquiat::Errors::SubclassResponsibility
      end

      def nack
        fail Basquiat::Errors::SubclassResponsibility
      end

      def requeue
        fail Basquiat::Errors::SubclassResponsibility
      end

      def delay_redelivery
        fail Basquiat::Errors::SubclassResponsibility
      end
    end
  end
end
