module TPPlus
  module Nodes
    class VisionRegisterNode < BaseNode
      attr_accessor :comment
      attr_reader :id
      def initialize(id)
        @id = id
        @comment = ""
      end

      def comment_string
        return "" if @comment == ""

        ":#{@comment}"
      end

      def eval(context,options={})
        "VR[#{@id}#{comment_string}]"
      end
    end
  end
end
