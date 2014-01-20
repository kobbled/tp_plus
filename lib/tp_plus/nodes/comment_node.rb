module TPPlus
  module Nodes
    class CommentNode
      def initialize(text)
        @text = text[1,text.length]
      end

      def can_be_inlined?
        false
      end

      def eval(context)
        s = ""
        width = 29
        @text.scan(/\S.{0,#{width}}\S(?=\s|$)|\S+/).each do |piece|
          s += "! #{piece} ;\n"
        end
        s[0,s.length-3]
      end
    end
  end
end
