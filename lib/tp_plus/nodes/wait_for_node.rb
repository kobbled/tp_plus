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
        case @time
        when DigitNode, RealNode
          case @units
          when "s"
            return ("%.2f(sec)" % @time.eval(context)).sub(/^0+/, "")
          when "ms"
            return ("%.2f(sec)" % (@time.eval(context).to_f / 1000)).sub(/^0+/, "")
          end
        when VarNode
          case @units
          when "s"
            if @time.constant?
              return ("%.2f(sec)" % @time.eval(context)).sub(/^0+/, "")
            else
              return @time.eval(context)
            end
          else
            raise "Indirect values can only use seconds ('s') as the units argument"
          end
        else
          raise "PANIC"
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
