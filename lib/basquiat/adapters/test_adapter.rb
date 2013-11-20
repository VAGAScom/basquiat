module Basquiat
  module Adapters
    class Test
      include Basquiat::Adapters::Base

      @@events = Hash.new { |hash, key| hash[key] = [] }
      attr_reader :options

      def default_options
        { host: '127.0.0.1', port: 123_456, durable: true }
      end

      def publish(event, message)
        @@events[event] << message
      end

      def events(key)
        @@events[key]
      end

      def subscribe_to(event_name, proc)
        @event_name       = event_name
        procs[event_name] = proc
      end

      def listen(*)
        procs[subscribed_event].
            call(@@events[subscribed_event].shift)
      end

      private
      def subscribed_event
        @event_name
      end
    end
  end
end
