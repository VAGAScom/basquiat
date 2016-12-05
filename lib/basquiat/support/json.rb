# frozen_string_literal: true
module Basquiat
  module Support
    # A simple MultiJson wrapper to protect against eventual API changes.
    module JSON
      # Serializes an Object into a JSON
      # @see http://www.rubydoc.info/github/intridea/multi_json/MultiJson%3Adump MultiJson.dump
      # @param object [Object] object to be serialized
      # @return [String] JSON representation of the object
      def self.encode(object)
        MultiJson.dump(object)
      end

      # De-serializes a JSON into a Hash, symbolizing the keys by default.
      # @see http://www.rubydoc.info/github/intridea/multi_json/MultiJson%3Aload MultiJson.load
      # @param object [Object] object to be de-serialized
      # @return [Hash] Hash representing the JSON. In case of an {MultiJson::ParseError} returns an empty Hash.
      def self.decode(object)
        MultiJson.load(object, symbolize_keys: true)
      rescue MultiJson::ParseError
        {}
      end
    end
  end
end
