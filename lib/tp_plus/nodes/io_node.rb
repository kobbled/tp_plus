module TPPlus
  module Nodes
    class IONode
      attr_accessor :comment
      def initialize(type, id)
        @type = type
        @id = id.to_i
        @comment = ""
      end

      def eval(context)
        "#{@type}[#{@id}:#{@comment}]"
      end
    end
  end
end
