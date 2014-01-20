module TPPlus
  module Nodes
    class ArgumentNode
      attr_accessor :comment
      def initialize(id)
        @id = id
        @comment = comment
      end

      def requires_mixed_logic?(context)
        true
      end

      def eval(context)
        "AR[#{@id}]"
      end
    end
  end
end
