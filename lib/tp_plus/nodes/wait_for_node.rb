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
        return WaitUntilNode.new(expression,nil).eval(context) if @time.is_a?(VarNode)

        "WAIT #{time(context)}(sec)"
      end
    end
  end
end
