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
    end
  end
end
