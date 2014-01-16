module TPPlus
  module Nodes
    class ArgumentNode
      attr_accessor :comment
      def initialize(id)
        @id = id
        @comment = comment
      end

      def comment_string
        return "" if @comment == ""

        ":#{@comment}"
      end

      def eval(context)
        "AR[#{@id}#{comment_string}]"
      end
    end
  end
end
