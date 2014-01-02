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

      # need a space if speed is indirect
      def optional_space(context)
        " " if @speed[0].is_a? VarNode
      end

      def eval(context)
        "#{speed(context)}#{optional_space(context)}#{units(context)}"
      end
    end
  end
end
