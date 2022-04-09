module TPPlus
  module Nodes
    class DistanceNode < BaseNode
      def initialize(type, distance, action)
        @type = type
        @distance = distance
        @action = action
      end

      def type
        case @type.downcase
        when "distance_before"
          "DB"
        end
      end

      def eval(context)
        "#{type} #{@distance.eval(context,as_string: true)}mm,#{@action.eval(context)}"
      end
    end
  end
end
