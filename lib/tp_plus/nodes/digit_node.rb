module TPPlus
  module Nodes
    class DigitNode < BaseNode
      attr_reader :value
      def initialize(value)
        @value = value
      end

      def requires_mixed_logic?(context)
        false
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
