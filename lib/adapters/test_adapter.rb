module Basquiat
  module Adapters
    class TestAdapter
      @@events = Hash.new(Array.new)

      def connection_options(opts)
        @options = opts
      end

      def connect
        @connection = Object.new
      end

      def connected?
        @connection
      end

      def publish(event, message)
        @@events[event] << message
        "Received #{event}: #{message.to_s}"
      end

      def events(key)
        @@events[key]
      end
    end
  end
end
