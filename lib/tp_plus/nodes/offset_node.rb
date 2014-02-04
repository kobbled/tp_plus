module TPPlus
  module Nodes
    class OffsetNode
      def initialize(type, var)
        @type = type
        @var = var
      end

      def name
        case @type.downcase
        when "offset"
          "Offset"
        when "tool_offset"
          "Tool_Offset"
        when "vision_offset"
          "VOFFSET"
        else
          raise "Invalid type"
        end
      end

      def eval(context)
        "#{name},#{@var.eval(context)}"
      end
    end
  end
end
