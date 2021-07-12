module TPPlus
  module Nodes
    class ColGuard < BaseNode
      attr_reader :type, :value
      def initialize(type, value={})
        @type = type
        @value = value
      end

      def eval(context)
        case @type
        when "colguard_on"
          "COL DETECT ON"
        when "adjust_colguard"
          if @value == nil
            "COL GUARD ADJUST"
          else
            "COL GUARD ADJUST #{@value.eval(context)}"
          end
        when "colguard_off"
          "COL DETECT OFF"
        end	
      end
    end
  end
end
