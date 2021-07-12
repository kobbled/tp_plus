module TPPlus
  module Nodes
    class UseNode < BaseNode
      def initialize(type, value)
        @type = type
        @value = value
      end

      def eval(context)
        case @type
        when "use_uframe"
          "UFRAME_NUM=#{@value.eval(context)}"
        when "use_utool"
          "UTOOL_NUM=#{@value.eval(context)}"
        when "use_payload"
          "PAYLOAD[#{@value.eval(context)}]"
        when "use_override"
          "OVERRIDE=#{@value.eval(context)}"
        when "use_colguard"
          "COL GUARD ADJUST #{@value.eval(context)}"
        end	
      end
    end
  end
end
