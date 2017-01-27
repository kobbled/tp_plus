module TPPlus
  module Nodes
    class RealNode < BaseNode
      def initialize(value)
        @value = value
      end

      def requires_mixed_logic?(context)
        false
      end

      def eval(context,options={})
        val = if options[:as_string]
          ("%.2f" % @value).sub(/^0/,'')
        else
          @value
        end

        if @value < 0
          "(#{val})"
        else
          val
        end
      end
    end
  end
end
