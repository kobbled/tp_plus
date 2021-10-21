module TPPlus
  module Nodes
    class FrameNode < RegNode
      attr_accessor :comment
      attr_reader :id
      def initialize(type, id)
        @type  = type
        @id = id
        @comment = ""
      end

      def requires_mixed_logic?(context)
        false
      end

      def comment_string
        return "" if @comment == ""

        ":#{@comment}"
      end

      def eval(context,options={})
        "#{@type}[#{@id}]"
      end
    end
  end
end
