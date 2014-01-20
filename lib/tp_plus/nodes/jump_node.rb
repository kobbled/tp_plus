module TPPlus
  module Nodes
    class JumpNode 
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
        raise "Label (#{@identifier}) not found" if context.labels[@identifier.to_sym].nil?

        "JMP LBL[#{context.labels[@identifier.to_sym]}]"
      end
    end
  end
end
