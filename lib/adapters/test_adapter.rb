module Basquiat
  module Adapters
    class Test
      include Basquiat::Adapters::Base

      @@events = Hash.new(Array.new)
      attr_reader :options

      def default_options
        { host: '127.0.0.1', port: 123_456, durable: true }
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
