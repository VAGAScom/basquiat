module Basquiat
  module Adapters

    # The simplest Message class. It's encouraged to tailor it to your adapter needs (hence BaseMessage).
    class BaseMessage < SimpleDelegator
      attr_reader :action

      # @param message [Object] It's assumed that message is some kind of JSON
      # @note All unknown messages will be delegated to the resulting Hash
      def initialize(message)
        @message = Basquiat::Json.decode(message)
        super(@message)
        @action = :ack
      end

      #@!group Action Setters
      # Sets the action to be taken after processing to be an ack.
      # Here just in case as the default is to acknowledge the message.
      def ack
        @action = :ack
      end

      # Sets the action to be taken after processing to be an nack / reject
      def nack
        @action = :nack
      end

      # Sets the action to be taken after processing to be a requeue
      def requeue
        @action = :requeue
      end
      #@!endgroup
    end
  end
end
