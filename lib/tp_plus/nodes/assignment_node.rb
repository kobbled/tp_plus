module TPPlus
  module Nodes
    class AssignmentNode
      attr_reader :identifier, :assignable
      def initialize(identifier,assignable)
        @identifier = identifier
        @assignable = assignable
      end

      def assignable_string(context,options={})
        if @assignable.is_a?(ExpressionNode)
          options[:mixed_logic] = true if @assignable.contains_expression?
          options[:mixed_logic] = true if @assignable.op.requires_mixed_logic?
          options[:mixed_logic] = true if @assignable.op.boolean?
        end

        if options[:mixed_logic]
          "(#{@assignable.eval(context)})"
        else
          @assignable.eval(context)
        end
      end

      def identifier_string(context)
        @identifier.eval(context)
      end

      def eval(context,options={})
        "#{identifier_string(context)}=#{assignable_string(context,options)}"
      end
    end
  end
end
