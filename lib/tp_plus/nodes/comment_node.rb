module TPPlus
  module Nodes
    class CommentNode
      def initialize(text)
        @text = text
      end

      def eval(context)
        "!#{@text[1,@text.length]}"
      end
    end
  end
end
