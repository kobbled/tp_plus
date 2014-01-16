module TPPlus
  module Nodes
    class IONode
      attr_accessor :comment
      def initialize(type, id)
        @type = type
        @id = id.to_i
        @comment = ""
      end

      def requires_mixed_logic?
        @type == "F" ? true : false
      end

      def eval(context, options={})
        s = "#{@type}[#{@id}:#{@comment}]"
        if options[:method] == "on?"
          s += "=ON"
        end
        s
      end
    end
  end
end
