module Basquiat
  module HashRefinements
    refine Hash do
      def deep_merge(other_hash)
        other_hash.each_pair do |key, value|
          current = self[key]
          if current.is_a?(Hash) && value.is_a?(Hash)
            current.deep_merge(value)
          else
            self[key] = value
          end
        end
      end

      def symbolize_keys
        each_with_object({}) do |(key, value), new_hash|
          new_key = key.to_sym rescue key
          new_value = if value.is_a? Hash
                        value.symbolize_keys
                      else
                        value
                      end
          new_hash[new_key] = new_value
        end
      end
    end
  end
end
