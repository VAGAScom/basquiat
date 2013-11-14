module Basquiat
  module Consumer
    # Need to provide:
    #   Macro:
    #     event_source type, options
    #     subscribe routing_key, with: ->() {}
    # Need to do:
    #   Connect to MQ using the correct adapter
    #   Setup the channels, queues and exchanges needed
    #   Register the callbacks based on routing_key
    #   Prepare the loop
    #   Run the loop
  end
end
