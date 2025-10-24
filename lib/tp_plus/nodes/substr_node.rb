module TPPlus
  module Nodes
    class SubstrNode < BaseNode
      def initialize(string_arg, start_pos, length)
        @string_arg = string_arg
        @start_pos = start_pos
        @length = length
      end

      def requires_mixed_logic?(context)
        false
      end

      def can_be_inlined?
        true
      end

      def eval(context, options={})
        "SUBSTR #{@string_arg.eval(context)},#{@start_pos.eval(context)},#{@length.eval(context)}"
      end
    end
  end
end
