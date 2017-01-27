module TPPlus
  module Nodes
    class RaiseNode < BaseNode
      def initialize(target)
        @target = target
      end

      def eval(context, options={})
        "#{@target.eval(context)}"
      end
    end
  end
end
