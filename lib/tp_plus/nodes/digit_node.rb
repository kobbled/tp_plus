module TPPlus
  module Nodes
    class DigitNode < ConstNode
      attr_reader :value, :name
      def initialize(value)
        @value = value
        @name = ''
      end

      def requires_mixed_logic?(context)
        false
      end

      def setName(name)
        @name = name
      end

      def eval(context, options={})
        if @value < 0
          "(#{@value})"
        else
          @value.to_s
        end
      end
    end
  end
end
