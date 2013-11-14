module Basquiat
  module Base

    module ClassMethods
      attr_reader :adapter

      def event_adapter=(adapter)
        @adapter = adapter.new
      end

      def event_source(opts ={})
        @adapter.connection_options(opts)
        @adapter.connect
      end
    end

    def self.included(klass)
      klass.extend(ClassMethods)
      super
    end
  end
end
