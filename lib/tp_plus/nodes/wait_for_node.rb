module TPPlus
  module Nodes
    class WaitForNode < BaseNode
      def initialize(time, units)
        @time = time
        @units = units
      end

      def units_valid?
        ["s","ms"].include?(@units)
      end

      # 2 decimal places and remove leading 0s
      def time(context)
        if @time.eval(context).is_a?(String)
          case @units
          when "s"
            @time.eval(context)
          else
            raise "Indirect values can only use seconds ('s') as the units argument"
          end
        else
          ("%.2f" % case @units
          when "s"
            @time.eval(context)
          when "ms"
            @time.eval(context).to_f / 1000
          end).sub(/^0+/, "") + "(sec)"
        end
      end

      def expression
        case @units
        when "s"
          @time
        when "ms"
          e = ExpressionNode.new(@time,"/",DigitNode.new(1000))
          e.grouped = true
          e
        end
      end

      def eval(context)
        raise "Invalid units" unless units_valid?

        "WAIT #{time(context)}"
      end
    end
  end
end
