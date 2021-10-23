module TPPlus
  module Nodes
    class DefinitionNode < BaseNode
      attr_reader :identifier, :assignable
      def initialize(identifier,assignable)
        @identifier = identifier
        @assignable = assignable
      end

      def eval(context)
        if @assignable.is_a?(ConstNode) || @assignable.is_a?(StringNode)
          raise "Constants must be defined with all CAPS" unless @identifier.upcase == @identifier

          context.add_constant(@identifier, @assignable)
        else
          context.add_var(@identifier, @assignable)
        end
        nil
      end
    end
  end
end
