module TPPlus
  module Nodes
    class AssignmentNode < BaseNode
      attr_reader :identifier, :assignable, :contains_call, :contains_arg_call
      def initialize(identifier,assignable)
        @identifier = identifier
        @assignable = assignable
        @contains_call = has_call?(assignable, false)
        @contains_arg_call = has_arg_call?(assignable, false)
      end

      def assignable_string(context,options={})
        if @assignable.instance_of?(ExpressionNode)
          options[:mixed_logic] = true if @assignable.contains_expression?
          options[:mixed_logic] = true if @assignable.op.requires_mixed_logic?(context)
          options[:mixed_logic] = true if @assignable.op.boolean?
          options[:mixed_logic] = true if @assignable.boolean_result?
          # this is a hack that fixes issue #12
          # PR[a]=PR[b]+PR[c]+PR[d] (no parens)
          if @identifier.is_a? VarNode
            if @identifier.target_node(context).is_a? PosregNode
              options[:mixed_logic] = false if !@identifier.target_node(context).has_method?(options)
            end
          end
        elsif @assignable.is_a?(VarNode)
          options[:mixed_logic] = true if @assignable.target_node(context).is_a? IONode
        elsif @assignable.is_a?(CallNode)
          options[:mixed_logic] = false
          @assignable.set_return(@identifier)
        else
          options[:mixed_logic] = true if @assignable.requires_mixed_logic?(context)
          options[:mixed_logic] = true if @identifier.requires_mixed_logic?(context)
        end

        if options[:mixed_logic]
          s = @assignable.eval(context)
          if !check_balance(s)
            "(#{s})"
          else
            s
          end
        else
          @assignable.eval(context)
        end
      end

      def requires_mixed_logic?(context)
        true
      end

      def can_be_inlined?
        true
      end

      def check_balance(s)
        if s[0] == '(' && s[-1] == ')'
          #check if first and last character are encompassing parentheses
           # include new line (-2)
          if TPPlus::Util.balanced_parentheses?(s[1..-2])
            return true
          else
            return false
          end
        else
          return false
        end
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

      def has_arg_call?(node, b)
        #drill into parens
        b = has_call?(node.x, b) if node.instance_of?(ParenExpressionNode)

        if node.is_a?(ExpressionNode)
          node.left_op.is_a?(ParenExpressionNode) ? left = node.left_op.x : left = node.left_op
          node.right_op.is_a?(ParenExpressionNode) ? right = node.right_op.x : right = node.right_op

          [left, right].map.each do |op|
            b = has_arg_call?(op, b) if op.is_a?(ExpressionNode)
          end
        end
        
        if node.is_a?(CallNode)
          b | node.args_contain_calls
        end
      end

      def identifier_string(context)
        @identifier.eval(context)
      end

      def eval(context,options={})
        if @identifier.is_a?(VarNode) && @assignable.is_a?(VarNode)
          if @assignable.target_node(context).is_a?(PositionNode) && @identifier.target_node(context).is_a?(PositionNode)
            context.pose_list.copy_pose(@identifier.target_node(context).comment, @assignable.target_node(context).comment)
            return nil
          end
        end
        if @assignable.is_a?(CallNode)
          return "#{assignable_string(context,options)}"
        else
          return "#{identifier_string(context)}=#{assignable_string(context,options)}"
        end
      end
    end
  end
end
