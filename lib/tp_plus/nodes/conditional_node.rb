module TPPlus
  module Nodes
    class ConditionalNode
      def initialize(type,condition,true_block,false_block)
        @type = type
        @condition = condition
        @true_block = true_block
        @false_block = false_block
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
        s= ""
        block.flatten.each do |node|
          res = node.eval(context)
          next if res.nil?

          s += "#{res} ;\n"
        end
        s
      end

      def can_be_inlined?
        return false unless @false_block.nil?

        @true_block.flatten.reject {|n| n.is_a? TerminatorNode}.length == 1
      end

      def eval(context)
        return InlineConditionalNode.new(@type,@condition,@true_block.flatten.reject {|n| n.is_a? TerminatorNode }.first).eval(context) if can_be_inlined?

        if !@false_block
          if @type == "if"
          # simple if
          "IF #{@condition.eval(context,opposite:true)},JMP LBL[#{true_label(context)}] ;\n#{true_block(context)}LBL[#{true_label(context)}]"
          else
            # simple unless
            "IF #{@condition.eval(context)},JMP LBL[#{true_label(context)}] ;\n#{true_block(context)}LBL[#{true_label(context)}]"

          end
        else
          # could be if-else or unless-else
          "IF #{@condition.eval(context,opposite:(@type == "if"))},JMP LBL[#{true_label(context)}] ;\n#{true_block(context)}JMP LBL[#{end_label(context)}] ;\nLBL[#{true_label(context)}] ;\n#{false_block(context)}LBL[#{end_label(context)}]"
        end
      end
    end
  end
end
