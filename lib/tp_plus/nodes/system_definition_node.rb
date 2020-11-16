module TPPlus
  module Nodes
    class SystemDefinitionNode < BaseNode
      attr_reader :identifier, :index
      def initialize(identifier, index={}, modifier={})
        @identifier = identifier
        @index = index
        @modifier = modifier
      end
      
      def requires_mixed_logic?(context)
        false
      end

      def can_be_inlined?
        false
      end

      def modifier_string(context)
        return "" unless @modifier

        strings_array = [""] << @modifier.map { |m| m.eval(context) }
        @modifiers_string = strings_array.join(".")
      end

      def with_bracks?(context)
        return "$#{@identifier}" unless @index
        "$#{@identifier}[#{@index.eval(context)}]"
      end

      def eval(context)
        "#{with_bracks?(context)}#{modifier_string(context)}"
      end
    end
  end
end
