module TPPlus
  module Nodes
    class WhileNode < RecursiveNode
      def initialize(condition, block)
        super(condition)
        
        @block = block.flatten.reject {|n| n.is_a?(TerminatorNode) }
      end

      def top_label(context)
        @top_label ||= context.next_label
      end

      def bottom_label(context)
        @bottom_label ||= context.next_label
      end

      def parens(s, context)
        return s unless @condition[0].requires_mixed_logic?(context)

        "(#{s})"
      end

      def if_statement(context)
        "IF #{parens(eval_condition(context), context)},JMP LBL[#{bottom_label(context)}] ;\n"
      end

      def eval_condition(context)
        @condition[0].eval(context, opposite: true)
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

        #evaluate expression expansions
        exp_str = eval_expression_expansions(context)
        
        #add expression expansions after top label
        "LBL[#{top_label(context)}] ;\n#{exp_str}#{if_statement(context)}#{block_each_eval(context)}JMP LBL[#{top_label(context)}] ;\nLBL[#{bottom_label(context)}]"
      end
    end
  end
end
