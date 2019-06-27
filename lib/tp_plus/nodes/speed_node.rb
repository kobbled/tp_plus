module TPPlus
  module Nodes
    class SpeedNode < BaseNode
      def initialize(speed_hash)
        @speed_hash = speed_hash
      end

      def speed(context)
        @speed_hash[:speed].eval(context)
      end

      def units
        case @speed_hash[:units]
        when "mm/s"
          "mm/sec"
        when "deg/s"
          "deg/sec"
        when "s"
          "sec"
        else
          @speed_hash[:units]
        end
      end


      def eval(context)
        return @speed_hash[:speed] if @speed_hash[:units].nil?

        "#{speed(context)}#{units}"
      end
    end
  end
end
