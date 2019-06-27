module TPPlus
  module Nodes
    class CoordNode < BaseNode
      def initialize(coord)
        @coord = coord
      end

      def eval(context)
        "#{@coord.upcase}"
      end
    end
  end
end
