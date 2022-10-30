module TPPlus
  module Util
    def to_boolean(str)
      str == 'true'
    end

    def retrieve_calls(node, func_list)
      if node.is_a?(TPPlus::Nodes::ExpressionNode)
        [node.left_op, node.right_op].map.each do |op|
          b = retrieve_calls(op, func_list) if op.is_a?(TPPlus::Nodes::ExpressionNode)
        end
      
        func_list.unshift(node.func_exp) if node.func_exp
        node.func_exp = []
      end
    end

    def retrieve_arg_calls(node, func_list)
      if node.is_a?(TPPlus::Nodes::ExpressionNode)
        [node.left_op, node.right_op].map.each do |op|
          b = retrieve_calls(op, func_list) if op.is_a?(TPPlus::Nodes::ExpressionNode)
        end
      end
      
      if node.is_a?(TPPlus::Nodes::CallNode)
        if node.func_args.any? || node.arg_exp.any?
          node.func_args.each_value do |fa|
            func_list.unshift(fa)
          end

          node.arg_exp.each do |ea|
            if ea.assignable.is_a?(TPPlus::Nodes::ExpressionNode)
              retrieve_arg_calls(ea.assignable, func_list)
            end
            func_list.unshift(ea)
          end
        end
      end
    end

    module_function :retrieve_calls, :retrieve_arg_calls, :to_boolean
  end
end