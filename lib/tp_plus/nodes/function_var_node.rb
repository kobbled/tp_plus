module TPPlus
  module Nodes
    class FunctionVarNode < BaseNode
      attr_reader :name
      def initialize(name)
        @name = name
      end

      def eval(context)
        arg = TPPlus::Nodes::ArgumentNode.new(context.next_arg)
        var = TPPlus::Nodes::DefinitionNode.new(@name, arg)
        var.eval(context)
      end
    end
  end
end
