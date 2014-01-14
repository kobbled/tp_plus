module TPPlus
  module Nodes
    class WaitForNode
      def initialize(time, units)
        @time = time
        @units = units
      end

      def units_valid?
        ["s","ms"].include? @units
      end

      # 2 decimal places and remove leading 0s
      def time(context)
        ("%.2f" % case @units
        when "s"
          @time.eval(context)
        when "ms"
          @time.eval(context).to_f / 1000
        end).sub(/^0+/, "")
      end

      def eval(context)
        raise "Invalid units" unless units_valid?

        "WAIT #{time(context)}(sec)"
      end
    end
  end
end
