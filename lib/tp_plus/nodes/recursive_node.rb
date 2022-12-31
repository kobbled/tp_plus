module TPPlus
  module Nodes
    class RecursiveNode < BaseNode
      attr_accessor :block, :condition, :contains_call, :expansions
      def initialize(condition = nil)
        @condition   = [condition]
        @block = []
        @expansions = []

        @contains_call = has_call?(@condition[0], false)
      end

      def has_call?(node, b)
        #drill into parens
        b = has_call?(node.x, b) if node.instance_of?(ParenExpressionNode)

        if node.is_a?(ExpressionNode)
          node.left_op.is_a?(ParenExpressionNode) ? left = node.left_op.x : left = node.left_op
          node.right_op.is_a?(ParenExpressionNode) ? right = node.right_op.x : right = node.right_op

          [left, right].map.each do |op|
            b = has_call?(op, b) if op.is_a?(ExpressionNode)
          end
        
          b | node.func_exp.any?
        end
      end

      def add_expression_expansions
        if self.contains_call
          ass_funcs = []
          TPPlus::Util.retrieve_calls(self.condition[0], ass_funcs)

          ass_funcs.each do |f|
            @expansions.append(f)
          end

          @expansions = @expansions.flatten!
        end
      end

      def eval_expression_expansions(context)
        s = ""
        @expansions.each do |f|
          s += f.eval(context) + ";\n"
        end

        s
      end

      def get_block
        @block
      end
    end
  end
end
