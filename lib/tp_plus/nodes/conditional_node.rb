module TPPlus
  module Nodes
    class ConditionalNode
      def initialize(type,condition,true_block,false_block)
        @type        = type
        @condition   = condition
        @true_block  = true_block.flatten.reject  {|n| n.is_a? TerminatorNode }
        @false_block = false_block.flatten.reject {|n| n.is_a? TerminatorNode }
      end

      def true_label(context)
        @true_label ||= context.next_label
      end

      def end_label(context)
        @end_label ||= context.next_label
      end

      def true_block(context)
        @t ||= string_for(@true_block,context)
      end

      def false_block(context)
        @f ||= string_for(@false_block,context)
      end

      def string_for(block,context)
        block.inject("") {|s,n| s << "#{n.eval(context)} ;\n" }
      end

      def can_be_inlined?
        return false unless @false_block.empty?
        return false unless @true_block.length == 1

        @true_block.first.can_be_inlined?
      end

      def opposite?
        @type == "if"
      end

      def eval(context)
        return InlineConditionalNode.new(@type,@condition,@true_block.first).eval(context) if can_be_inlined?

        if @false_block.empty?
          "IF #{@condition.eval(context,opposite: opposite?, as_condition: true)},JMP LBL[#{true_label(context)}] ;\n#{true_block(context)}LBL[#{true_label(context)}]"
        else
          # could be if-else or unless-else
          "IF #{@condition.eval(context,opposite: opposite?, as_condition: true)},JMP LBL[#{true_label(context)}] ;\n#{true_block(context)}JMP LBL[#{end_label(context)}] ;\nLBL[#{true_label(context)}] ;\n#{false_block(context)}LBL[#{end_label(context)}]"
        end
      end
    end
  end
end
