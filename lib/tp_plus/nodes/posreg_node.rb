module TPPlus
  module Nodes
    class PosregNode
      attr_accessor :comment
      def initialize(id)
        @id = id
        @comment = ""
      end

      def comment_string
        return "" if @comment == ""

        ":#{@comment}"
      end

      def eval(context)
        "PR[#{@id}#{comment_string}]"
      end
    end
  end
end
