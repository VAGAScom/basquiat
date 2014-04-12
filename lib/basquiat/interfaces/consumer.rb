module Basquiat
  # para ser usado como Consumer
  module Consumer
    include Basquiat::Base

    def subscribe_to(event_name, proc)
      proc = make_callable(proc)
      adapter.subscribe_to(event_name, proc)
    end

    def listen(lock = true)
      adapter.listen(lock)
    end
  end
end
