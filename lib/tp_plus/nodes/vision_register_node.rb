module TPPlus
  module Nodes
    class VisionRegisterNode
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
        "VR[#{@id}#{comment_string}]"
      end
    end
  end
end
