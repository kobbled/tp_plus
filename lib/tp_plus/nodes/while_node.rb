module TPPlus
  module Nodes
    class WhileNode
      def initialize(condition_node, block)
        @condition_node = condition_node
        @block = block.flatten.reject {|n| n.is_a?(TerminatorNode) }
      end

      def top_label(context)
        @top_label ||= context.next_label
      end

      def bottom_label(context)
        @bottom_label ||= context.next_label
      end

      def if_statement(context)
        "IF #{condition(context)},JMP LBL[#{bottom_label(context)}] ;\n"
      end


      def condition(context)
        s = @condition_node.eval(context, opposite: true)

        @condition_node.requires_mixed_logic?(context) ? "(#{s})" : s
      end


      def block(context)
        @block.inject("") {|s,n| s << "#{n.eval(context)} ;\n" }
      end

      def eval(context)
        "LBL[#{top_label(context)}] ;\n#{if_statement(context)}#{block(context)}JMP LBL[#{top_label(context)}] ;\nLBL[#{bottom_label(context)}]"
      end
    end
  end
end
