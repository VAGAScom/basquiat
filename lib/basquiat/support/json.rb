module Basquiat
  # A simple MultiJson wrapper to protect against eventual API changes.
  module Json
    # Serializes an Object into a JSON
    # @see MultiJson.dump
    # @param object [Object] object to be serialized
    # @return [String] JSON representation of the object
    def self.encode(object)
      MultiJson.dump(object)
    end

    # De-serializes a JSON into a Hash
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
