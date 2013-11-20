module Basquiat
  module Adapters
    class Test
      include Basquiat::Adapters::Base

      @@events = Hash.new(Array.new)
      attr_reader :options

      def initialize(*)
        super
        @event_names = Set.new
        @procs = {}
      end

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

      def subscribe_to(event_name, &proc)
        @event_names.add(event_name)
        @procs[event_name] = proc
      end

      def listen(*)
        event = subscribed_event
        @procs[event].call(@@events[event].shift)
      end

      private
      def subscribed_event
        name = @event_names.first
        @event_names.delete(name).add(name)
        name
      end

      def connect
        @connection = Object.new
      end
    end
  end
end
