module TPPlus
  module Nodes
    class ExpressionNode < BaseNode
      attr_reader :left_op, :op, :right_op, :ret_var, :func_exp
      def initialize(left_op, op_string, right_op)
        @left_op  = left_op
        @op       = OperatorNode.new(op_string)
        @right_op = right_op

        @func_exp = []
        contains_call?(@func_exp)
        @ret_var = []
        create_ret_var(@func_exp, @ret_var)
      end

      def grouped?
        return false if @right_op.nil? # this is for NOT (!) operator

        @left_op.is_a?(ParenExpressionNode) || @right_op.is_a?(ParenExpressionNode)
      end

      def requires_mixed_logic?(context)
        contains_expression? ||
          grouped? ||
          [@op, @left_op, @right_op].map { |op|
            next if op.nil?
            op.requires_mixed_logic?(context)
          }.any?
      end

      def contains_expression?
        [@left_op, @right_op].map {|op| op.is_a? ExpressionNode }.any? ||
          [@left_op, @right_op].map { |op| op.is_a? ParenExpressionNode }.any?
      end

      def contains_call?(flist)
        flist << @left_op if @left_op.is_a? CallNode
        flist << @right_op if @right_op.is_a? CallNode
      end

      def boolean_result?
        case @op.string
        when "&&","||","!","==","<>",">",">=","<","<="
          true
        else
          false
        end
      end

      def create_ret_var(flist, rlist)
        flist.each do |fl|
          #create local variable
          $dvar_counter += 1
          name = "dvar#{$dvar_counter}"
          fl.set_return(VarNode.new(name))

          rlist << RegDefinitionNode.new(name, LocalDefinitionNode.new('LR', name))
        end
      end

      def replace_function
        if @left_op.is_a?(CallNode)
          @left_op = VarNode.new(@ret_var[0].range.name)
        end
        if @right_op.is_a?(CallNode)
          @right_op = VarNode.new(@ret_var[-1].range.name)
        end
        
        nil
      end

      def string_val(context, options={})
        if @op.bang?
          # this is for skip conditions, which do not
          # support mixed logic
          if options[:disable_mixed_logic]
            "#{@left_op.eval(context)}=OFF"
          else
            "#{@op.eval(context,options)}#{@left_op.eval(context)}"
          end
        else
          if @op.boolean?
            # if operator is &&, || or !, we flip the operator and the operands
            left = @left_op.eval(context, options)
            op = @op.eval(context, options)
            right = @right_op.eval(context, options)
            [left, op, right].reject(&:empty?).join('')
          else
            "#{@left_op.eval(context, opposite: ((@left_op.is_a?(ExpressionNode) || @left_op.is_a?(UnaryExpressionNode))&& options[:opposite]))}#{@op.eval(context, options)}#{@right_op.eval(context, opposite: ((@right_op.is_a?(ExpressionNode) || @right_op.is_a?(UnaryExpressionNode)) && options[:opposite]))}"
          end
        end
      end

      def eval(context,options={})
        options[:force_parens] = true if grouped?

        string_val(context, options)
      end
    end
  end
end
