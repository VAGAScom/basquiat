module Basquiat
  module Adapters
    class Test
      include Basquiat::Adapters::Base

      @@events = Hash.new { |hash, key| hash[key] = [] }
      attr_reader :options

      def default_options
        @event_names = []
        { host: '127.0.0.1', port: 123_456, durable: true }
      end

      def publish(event, message, single_message = true)
        @@events[event] << json_encode(message)
      end

      def events(key)
        @@events[key]
      end

      def subscribe_to(event_name, proc)
        @event_names << event_name
        procs[event_name] = proc
      end

      def listen(*)
        event = subscribed_event
        msg = @@events[event].shift
        msg ? procs[event].call(MultiJson.load(msg, symbolize_keys: true)) : nil
      end

      private
      def subscribed_event
        event = @event_names.first
        @event_names.rotate!
        event
      end
    end
  end
end
