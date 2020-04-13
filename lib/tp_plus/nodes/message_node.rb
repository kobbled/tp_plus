module TPPlus
  module Nodes
    class MessageNode < BaseNode
      def initialize(text)
        @text = text
      end

      def eval(context)
        s = ""
        width = 23
        @text.scan(/\S.{0,#{width}}\S(?=\s|$)|\S+/).each do |piece|
          s += "MESSAGE[#{piece}] ;\n"
        end
        s[0,s.length-3]
      end
    end
  end
end
