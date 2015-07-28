module Basquiat
  class Events
    extend Forwardable

    attr_reader :internal_events

    def_delegator :internal_events, :keys

    def initialize
      @internal_events = {}
    end

    def []=(key, value)
      internal_events[key] = value
    end

    def [](key)
      unless internal_events.key?(key)
        key = internal_events.keys.select { |event| Regexp.new(event.gsub('#', '*')).match(key) }.first
      end
      internal_events[key]
    end
  end
end
