module Basquiat
  module Adapters
    class Test
      @@events = Hash.new(Array.new)

      def connection_options(opts)
        @options = opts
      end

      def publish(event, message)
        @@events[event] << message
        "Received #{event}: #{message.to_s}"
      end

      def events(key)
        @@events[key]
      end

      def connected?
        @connection
      end

      private
      def connect
        @connection = Object.new
      end
    end
  end
end
