module TPPlus
  module Nodes
    class UsingNode < BaseNode
      attr_accessor :mods
      def initialize(mods)
        @mods = mods
      end

      def eval(context)
        nil
      end
      
    end
  end
end
