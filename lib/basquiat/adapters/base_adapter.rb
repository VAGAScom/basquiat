module Basquiat
  module Adapters
    module Base
      def initialize
        @options = default_options
        @procs = {}
      end

      # Used to set the options for the adapter. It is merged in
      # to the default_options hash.
      # @param [Hash] opts an adapter dependant hash of options
      def adapter_options(opts)
        options.merge! opts
      end

      # Default options for the adapter
      # @return [Hash]
      def default_options
        {}
      end

      def publish; end

      def subscribe_to; end

      private

      attr_reader :procs, :options

      def self.json_encode(object)
        MultiJson.dump(object)
      rescue
        MultiJson.dump({})
      end

      def self.json_decode(object)
        MultiJson.load(object, symbolize_keys: true)
      rescue
        {}
      end
    end
  end
end

# def underscore(camel_cased_word)
#   word = camel_cased_word.to_s.dup
#   word.gsub!('::', '/')
#   word.gsub!(/(?:([A-Za-z\d])|^)
#             (#{inflections.acronym_regex})(?=\b|[^a-z])/)
#              { "#{$1}#{$1 && '_'}#{$2.downcase}" }
#   word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
#   word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
#   word.tr!("-", "_")
#   word.downcase!
#   word
# end
