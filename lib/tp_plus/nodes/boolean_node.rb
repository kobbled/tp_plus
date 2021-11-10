module TPPlus
  module Nodes
    class BooleanNode < BaseNode
      attr_reader :value, :name

      def initialize(bool)
        @value = bool.to_sym
        @name = ''
      end

      def setName(name)
        @name = name
      end

      def requires_mixed_logic?(context)
        false
      end

      def eval(context, options= {})
        case @value
        when :true
          return "ON"
        when :false
          return "OFF"
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
