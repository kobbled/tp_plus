module TPPlus
  module Nodes
    class TerminationNode < BaseNode
      def initialize(term_type,valuex,valuey={})
        @term_type = term_type
        @valuex = valuex
        @valuey = valuey
      end

      def eval(context)

        case @term_type
        when "cr", "corner_region"
          s = "CR"
        else
          s = "CNT"
        end

        case @valuex
        when DigitNode
          s += "#{@valuex.eval(context)}"
        when VarNode
          if @valuex.constant?
            val = @valuex.eval(context)
            if val[0] == "(" # negative
               s = "FINE"
            else
              s += "#{val}"
            end
          else
            s += " #{@valuex.eval(context)}"
          end
        else
          raise "invalid term"
        end

        if @valuey.is_a?(DigitNode)
          s += ",#{@valuey.eval(context)}"
        end

        return s
      end
    end
  end
end
