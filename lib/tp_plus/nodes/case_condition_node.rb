module TPPlus
  module Nodes
    class CaseConditionNode < BaseNode
      def initialize(condition, block)
        @condition = condition
        @block = block
      end

      def eval(context, options={})
        options[:no_indent] ||= false

        s = ""
        if !options[:no_indent]
          s += "       "
        end

        if @condition
          s += "=#{@condition.eval(context)},#{@block.eval(context)}"
        else
          s += "ELSE,#{@block.eval(context)}"
        end
        s
      end
    end
  end
end
