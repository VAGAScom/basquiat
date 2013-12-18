module Basquiat
  module Adapters
    class Test
      include Basquiat::Adapters::Base

      class << self
        def events
          @events ||= Hash.new { |hash, key| hash[key] = [] }
        end
      end

      attr_reader :options

      def default_options
        @event_names = []
        { host: '127.0.0.1', port: 123_456, durable: true }
      end

      def publish(event, message, single_message = true)
        self.class.events[event] << Basquiat::Adapters::Base.json_encode(message)
      end

      def events(key)
        self.class.events[key]
      end

      def subscribe_to(event_name, proc)
        @event_names << event_name
        procs[event_name] = proc
      end

      def listen(*)
        event = subscribed_event
        msg   = self.class.events[event].shift
        msg ? procs[event].call(Basquiat::Adapters::Base.json_decode(msg)) : nil
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
