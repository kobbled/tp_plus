module TPPlus
  module Nodes
    class CommentNode < BaseNode
      def initialize(text)
        @text = text[1,text.length]
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
