class String
  def is_i?
     /\A[-+]?\d+\z/ === self
  end

  def is_f?
    Float(self) != nil rescue false
  end

  def is_b?
    self.downcase == "true" || self.downcase == "false"
  end

  def to_b
    self.downcase == "true"
  end

  def to_value
    if self.is_i?
      return self.to_i
    elsif self.is_b?
      return self.to_b
    elsif self.is_f?
      return self.to_f
    end
  end

end


module TPPlus
  module Util
    def to_boolean(str)
      str.downcase == 'true'
    end

    def retrieve_calls(node, func_list)
      if node.is_a?(TPPlus::Nodes::ExpressionNode) || node.is_a?(Nodes::ParenExpressionNode)
        node.left_op.is_a?(Nodes::ParenExpressionNode) ? left = node.left_op.x : left = node.left_op
        node.right_op.is_a?(Nodes::ParenExpressionNode) ? right = node.right_op.x : right = node.right_op
        
        [left, right].map.each do |op|
          b = retrieve_calls(op, func_list) if op.is_a?(TPPlus::Nodes::ExpressionNode)
        end
      
        func_list.unshift(node.func_exp) if node.func_exp
        node.func_exp = []
      end
    end

    def gather_variables(interpreter, vars)
      interpreter.namespaces.each_value do |n|
        gather_variables(n, vars)
      end

      # store in a list as hash keys might conflict
      # from namespace to namespace
      vars << interpreter.variables.values
      vars = vars.flatten!
    end

    def retrieve_arg_calls(node, func_list)
      if node.is_a?(TPPlus::Nodes::ExpressionNode) || node.is_a?(Nodes::ParenExpressionNode)
        node.left_op.is_a?(Nodes::ParenExpressionNode) ? left = node.left_op.x : left = node.left_op
        node.right_op.is_a?(Nodes::ParenExpressionNode) ? right = node.right_op.x : right = node.right_op
        
        # handle nested call statement
        if node.func_exp
          node.func_exp.select {|n|  n.is_a?(TPPlus::Nodes::CallNode)}.each do |n|
            func_list.unshift(n)
          end
        end

        [left, right].map.each do |op|
          b = retrieve_calls(op, func_list) if op.is_a?(TPPlus::Nodes::ExpressionNode)
        end
      end
      
      if node.is_a?(TPPlus::Nodes::CallNode)
        if node.func_args.any? || node.arg_exp.any?
          node.func_args.each_value do |fa|
            func_list.unshift(fa)
          end

          node.arg_exp.each do |ea|
            if ea.assignable.is_a?(TPPlus::Nodes::ExpressionNode) || node.is_a?(Nodes::ParenExpressionNode)
              retrieve_arg_calls(ea.assignable, func_list)
            end
            func_list.unshift(ea)
          end
        end
      end
    end

    module_function :retrieve_calls, :retrieve_arg_calls, :to_boolean, :gather_variables
  end
end