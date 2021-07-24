module TPPlus
  module Nodes
    class FunctionReturnNode < BaseNode
      attr_accessor :ret_type, :return_register
      def initialize(expression)
        @expression  = expression
        @ret_type = ''
        @return_register = {}
      end

      RETURN_NAME = 'ret'

      def eval(context)
        if context.ret_type
          @ret_type = context.ret_type
          @return_register = context.get_var(RETURN_NAME)
        end

        if @ret_type
          reg = TPPlus::Nodes::IndirectNode.new(@ret_type, @return_register, nil)
          assign = TPPlus::Nodes::AssignmentNode.new(reg, @expression)
          s = "#{assign.eval(context)} ;\n"
        end
        s += "END"
      end
    end
  end
end
