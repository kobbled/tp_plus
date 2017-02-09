module TPPlus
  module Nodes
    class AccNode < BaseNode
      def initialize(value)
        @value = value
      end

      def eval(context)
        case @value
        when DigitNode
          "ACC#{@value.eval(context)}"
        when VarNode
          if @value.constant?
            "ACC#{@value.eval(context)}"
          else
            "ACC #{@value.eval(context)}"
          end
        else
          raise "invalid acc"
        end
      end
    end
  end
end
