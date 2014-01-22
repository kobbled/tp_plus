module TPPlus
  module Nodes
    class TimerNode
      attr_accessor :comment
      def initialize(id)
        @id = id
        @comment = ""
      end

      def comment_string
        return "" if @comment == ""

        ":#{comment}"
      end

      def eval(context, options={})
        "TIMER[#{@id}#{comment_string}]"
      end
    end
  end
end
