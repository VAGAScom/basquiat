require 'set'

module Basquiat
  module Adapters
    class RabbitMq
      class Events
        attr_reader :keys

        def initialize
          @keys     = []
          @exact    = {}
          @patterns = {}
        end

        def []=(key, value)
          if key =~ /\*|\#/
            set_pattern_key(key, value)
          else
            @exact[key] = value
          end
          @keys.push key
        end

        def [](key)
          @exact.fetch(key) { simple_pattern_match(key) }
        rescue KeyError
          raise KeyError, "No event handler found for #{key}"
        end

        private

        def set_pattern_key(key, value)
          key            = key.gsub('.', '\.')
          key            = if key =~ /\*/
                             /^#{key.gsub('*', '[^.]+')}$/
                           else
                             /^#{key.gsub(/\#/, '.*')}$/
                           end
          @patterns[key] = value
        end

        def simple_pattern_match(key)
          match = @patterns.keys.detect(nil) { |pattern| key =~ pattern }
          @patterns.fetch match
        end
      end
    end
  end
end
