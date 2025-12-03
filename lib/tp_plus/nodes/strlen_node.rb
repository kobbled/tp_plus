module TPPlus
  module Nodes
    class StrlenNode < BaseNode
      def initialize(string_arg)
        @string_arg = string_arg
      end

      def requires_mixed_logic?(context)
        false
      end

      def can_be_inlined?
        true
      end

      def eval(context, options={})
        "STRLEN #{@string_arg.eval(context)}"
      end
    end
  end
end
