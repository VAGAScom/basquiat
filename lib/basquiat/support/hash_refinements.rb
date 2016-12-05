# frozen_string_literal: true
module Basquiat
  module Support
    # Refinements for hashes used on the library's internals
    module HashRefinements
      refine Hash do
        # Merges self with other_hash recursively
        # @param other_hash [Hash] hash to be merged into self
        # @return [self]
        def deep_merge(other_hash)
          other_hash.each_pair do |key, value|
            current = self[key]
            if current.is_a?(Hash) && value.is_a?(Hash)
              current.deep_merge(value)
            else
              self[key] = value
            end
          end
          self
        end

        # Symbolize all the keys in a given hash. Works with nested hashes
        # @return [Hash] return other hash with the symbolized keys
        def symbolize_keys
          each_with_object({}) do |(key, value), new_hash|
            new_key           = begin
              key.to_sym
            rescue
              key
            end
            new_value         = value.is_a?(Hash) ? value.symbolize_keys : value
            new_hash[new_key] = new_value
          end
        end
      end
    end
  end
end
