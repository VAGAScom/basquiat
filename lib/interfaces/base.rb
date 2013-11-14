module Basquiat
  module Base

    module ClassMethods
      attr_reader :adapter

      def event_adapter(adapter)
        instance_variable_set(:@adapter, adapter.new)
      end

      def event_source(opts ={})
        #@adapter.initialize_connection(opts)
      end
    end

    def self.included(klass)
      klass.extend(ClassMethods)
      super
    end
    # Need to provide:
    #   Macro:
    #     event_adapter
    #     event_source
    #   Methods:
    #     connection methods
    #     & methods used with the adapter
  end
end
