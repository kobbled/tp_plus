module TPPlus
  module Nodes
    class CaseConditionNode < BaseNode
      def initialize(condition, label, jump_label, block)
        @condition  = condition
        @label      = label
        @jump_label = jump_label
        @block      = block.flatten.reject {|n| n.is_a?(TerminatorNode) }
      end

      def block(context)
        @s ||= @block.inject("") {|s,n| s << "#{n.eval(context)} ;\n" }
      end

      def block_eval(context, end_label)
        "#{@label.eval(context)} ;\n#{block(context)}JMP LBL[#{end_label}] ;\n"
      end

      def is_jump_label(context)
        if @block[0].is_a?(Nodes::JumpNode)
          return @block[0].eval(context)
        else
          return @jump_label.eval(context)
        end
      end

      def eval(context, options={})
        options[:no_indent] ||= false

        s = ""
        if !options[:no_indent]
          s += "       "
        end

        if @condition
          s += "=#{@condition.eval(context)},#{is_jump_label(context)}"
        else
          s += "ELSE,#{is_jump_label(context)}"
        end

        s
      end
    end
  end
end
