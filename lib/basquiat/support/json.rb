# frozen_string_literal: true
module Basquiat
  module Support
    # A simple MultiJson wrapper to protect against eventual API changes.
    module JSON
      # Serializes an Object into a JSON
      # @see MultiJson.dump
      # @param object [Object] object to be serialized
      # @return [String] JSON representation of the object
      def self.encode(object)
        MultiJson.dump(object)
      end

      # De-serializes a JSON into a Hash. In case of an ParseError returns an empty Hash.
      # @see MultiJson.load
      # @param object [Object] object to be de-serialized
      # @return [Hash] Hash representing the JSON. The keys are symbolized by default
      def self.decode(object)
        MultiJson.load(object, symbolize_keys: true)
      rescue MultiJson::ParseError
        {}
      end
    end
  end
end
