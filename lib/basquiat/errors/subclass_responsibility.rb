module Basquiat
  module Errors
    class SubclassResponsibility < NoMethodError
      def message
        'This method should be implemented by a subclass tailored to the adapter'
      end
    end
  end
end
