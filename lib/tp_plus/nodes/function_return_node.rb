module TPPlus
  module Nodes
    class FunctionReturnNode < BaseNode
      attr_accessor :ret_type, :return_register, :expression
      def initialize(expression)
        @expression  = expression
        @ret_type = ''
        @return_register = {}
      end

      def eval(context)
        s = ""
        if context.ret_type
          @ret_type = context.ret_type
          if context.check_var(RETURN_NAME)
            @return_register = context.get_var(RETURN_NAME)
            #make indirect register to return data back into
            reg = TPPlus::Nodes::IndirectNode.new(@ret_type, @return_register, nil)
            #create assignment mode to assign expression in return statment into the
            #return register
            assign = TPPlus::Nodes::AssignmentNode.new(reg, @expression)
            s += "#{assign.eval(context)} ;\n"
          end
        end
        s += "END"
      end
    end
  end
end
