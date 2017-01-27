module TPPlus
  module Nodes
    class ArgumentNode < BaseNode
      attr_accessor :comment
      attr_reader :id
      def initialize(id)
        @id = id
        @comment = comment
      end

      def requires_mixed_logic?(context)
        true
      end

      def eval(context,options={})
        "AR[#{@id}]"
      end
    end
  end
end
