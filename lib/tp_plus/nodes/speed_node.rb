module TPPlus
  module Nodes
    class SpeedNode
      def initialize(speed)
        @speed = speed
      end

      # TODO: better implementation
      def eval(context)
        "#{@speed.first.eval(context)}#{@speed.last.eval(context)}"
      end
    end
  end
end
