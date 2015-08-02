require 'set'

module Basquiat
  module Adapters
    class RabbitMq
      class Events
        def initialize
          @exact    = {}
          @patterns = {}
        end

        def []=(key, value)
          key            = /^#{key.gsub('*', '[^.]+')}$/ if key =~ /\*/
          key            = /^#{key.gsub('#', '.*')}$/ if key =~ /#/
          @patterns[key] = value
        end

        def keys
          @exact.keys
        end

        # # substitutes 1 or more words
        # * substitutes exactly 1 word
        # best matches are used from left to right.
        def [](key)
          @exact.fetch(key) { simple_pattern_match(key) }
        rescue KeyError
          raise KeyError, "No event handler found for #{key}"
          #dismember the key.
          # search alg:
          # 1. exact match
          # 2. search for keys that have # and *
          #   a. see if any of these matches
          #   b. * has higher precedence over #
          #   c.# ~= /.*/ * =~ \w+{1}
        end

        # event.for.the.win, event.for.everyone, event.for.*
        private

        def simple_pattern_match(key)
          match = @patterns.keys.detect(nil) { |pattern| key =~ pattern }
          p match
          @patterns.fetch match
        end
      end
    end
  end
end
