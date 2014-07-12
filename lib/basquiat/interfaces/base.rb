require 'set'

module Basquiat
  # base module extend the classes that will use the event infrastructure
  module Base
    class << self
      def extended(klass)
        descendants.push klass
      end

      def descendants
        @descendants ||= []
      end
    end

    def reload_adapter_from_configuration
      @adapter = Kernel.const_get(Basquiat.configuration.default_adapter).new
      @adapter.adapter_options Basquiat.configuration.adapter_options
    end


    def event_adapter=(adapter)
      @adapter = adapter.new
    end

    def adapter
      @adapter ||= Kernel.const_get(Basquiat.configuration.default_adapter).new
    end

    def adapter_options(opts = Basquiat.configuration.adapter_options)
      adapter.adapter_options(opts)
    end

    def publish(event, message)
      adapter.publish(event, message)
    end

    def subscribe_to(event_name, proc)
      proc = make_callable(proc)
      adapter.subscribe_to(event_name, proc)
    end

    def disconnect
      adapter.disconnect
    end

    def connected?
      adapter.connected?
    end

    def listen(block: true)
      adapter.listen(block: block)
    end

    private

    def make_callable(proc)
      return proc if proc.respond_to? :call
      method(proc)
    end
  end
end
