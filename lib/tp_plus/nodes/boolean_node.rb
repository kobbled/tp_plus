module TPPlus
  module Nodes
    class BooleanNode < BaseNode
      def initialize(bool)
        @bool = bool.to_sym
      end

      def requires_mixed_logic?(context)
        false
      end

      def eval(context, options= {})
        case @bool
        when :true
          return @bool
        when :false
          return @bool
        when :on
          return "ON"
        when :off
          return "OFF"
        end

        raise "Could not convert Boolean Node"

      end
    end
  end
end
