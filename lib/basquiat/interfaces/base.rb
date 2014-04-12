module Basquiat
  # base module extend the classes that will use the event infrastructure
  module Base
    attr_reader :adapter

    def event_adapter=(adapter)
      @adapter = adapter.new
    end

    def adapter_options(opts = {})
      adapter.adapter_options(opts)
    end

    def publish(event, message)
      adapter.publish(event, message)
    end

    def subscribe_to(event_name, proc)
      proc = make_callable(proc)
      adapter.subscribe_to(event_name, proc)
    end

    def listen(lock = true)
      adapter.listen(lock)
    end

    private

    def make_callable(proc)
      return proc if proc.respond_to? :call
      method(proc)
    end
  end
end
