module Basquiat
  module Base
    attr_reader :adapter

    def event_adapter=(adapter)
      @adapter = adapter.new
    end

    def event_source(opts ={})
      adapter.adapter_options(opts)
    end

    def subscribe(event_name, proc)
      adapter.subscribe_to(event_name, &proc)
    end

    def publish(event, message)
      adapter.publish(event, message)
    end

    def listen(lock = true)
      adapter.listen(lock)
    end
  end
end
