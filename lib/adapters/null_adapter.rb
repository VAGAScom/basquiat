module Basquiat
  module Adapters
    class NullAdapter

      def publish(event, message)
        puts "Received #{event}: #{message.to_s}"
      end
    end
  end
end
