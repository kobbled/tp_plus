module TPPlus
  module Nodes
    class SpeedNode
      def initialize(speed)
        @speed = speed
      end

      def speed(context)
        @speed[0].eval(context)
      end

      def units(context)
        @speed[1].eval(context)
      end


      def eval(context)
        return "max_speed" if @speed[0] == :max_speed

        "#{speed(context)}#{units(context)}"
      end
    end
  end
end
