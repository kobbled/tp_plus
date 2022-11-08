module TPPlus
  module Nodes
    class WhileNode < RecursiveNode
      def initialize(condition_node, block)
        super()
        
        @condition_node = condition_node
        @block = block.flatten.reject {|n| n.is_a?(TerminatorNode) }
      end

      def top_label(context)
        @top_label ||= context.next_label
      end

      def bottom_label(context)
        @bottom_label ||= context.next_label
      end

      def parens(s, context)
        return s unless @condition_node.requires_mixed_logic?(context)

        "(#{s})"
      end

      def if_statement(context)
        "IF #{parens(condition(context), context)},JMP LBL[#{bottom_label(context)}] ;\n"
      end

      def condition(context)
        @condition_node.eval(context, opposite: true)
      end

      def block_each_eval(context)
        @block.inject("") {|s,n| s << "#{n.eval(context)} ;\n" }
      end

      def get_block
        @block
      end

      def eval(context)
        @top_label = nil
        @bottom_label = nil
        
        "LBL[#{top_label(context)}] ;\n#{if_statement(context)}#{block_each_eval(context)}JMP LBL[#{top_label(context)}] ;\nLBL[#{bottom_label(context)}]"
      end
    end
  end
end
