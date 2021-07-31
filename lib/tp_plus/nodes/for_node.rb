module TPPlus
  module Nodes
    class ForNode < BaseNode
      def initialize(var_node, initial_value_node, final_value_node, block, range = 'TO')
        @var_node           = var_node
        @initial_value_node = initial_value_node
        @final_value_node   = final_value_node
        @block              = block.flatten.reject {|n| n.is_a?(TerminatorNode) }
        @range_specifier    = range
      end

      def block(context)
        @s ||= @block.inject("") {|s,n| s << "#{n.eval(context)} ;\n" }
      end

      def get_block
        @block
      end

      def eval(context)
        "FOR #{@var_node.eval(context)}=#{@initial_value_node.eval(context)} #{@range_specifier.upcase} #{@final_value_node.eval(context)} ;\n#{block(context)}ENDFOR"
      end
    end
  end
end
