module TPPlus
  module Nodes
    class JumpNode < BaseNode
      def initialize(identifier)
        @identifier = identifier
      end

      def requires_mixed_logic?(context)
        false
      end

      def can_be_inlined?
        true
      end

      def eval(context,options={})
        context.add_label(@identifier.to_sym) if context.labels[@identifier.to_sym].nil?

        "JMP LBL[#{context.labels[@identifier.to_sym]}]"
      end
    end
  end
end
