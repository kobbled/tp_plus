module TPPlus
  module Nodes
    class ConditionalNode
      def initialize(condition,true_block,false_block)
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

      def eval(context)
        if !@false_block
          "IF #{@condition.eval(context,opposite:true)},JMP LBL[#{true_label(context)}] ;\n#{true_block(context)}LBL[#{true_label(context)}]"
        else
          "IF #{@condition.eval(context,opposite:true)},JMP LBL[#{true_label(context)}] ;\n#{true_block(context)}JMP LBL[#{end_label(context)}] ;\nLBL[#{true_label(context)}] ;\n#{false_block(context)}LBL[#{end_label(context)}]"
        end
      end
    end
  end
end
