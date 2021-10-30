module TPPlus
  module Nodes
    class PoseAssignNode < BaseNode

      def initialize(range1, range2, options = {})
        @range1 = range1
        @range2 = range2
        @options = options
      end

      def eval(context)
        
        array1 = @range1.name_range
        array2 = @range2.name_range

        if @options
          if @options[:mod] == 'reverse'
            array2 = array2.reverse()
          end
        end

        comb = array1.zip(array2)
        
        comb.each do |pair|
          context.pose_list.copy_pose(context.get_var(pair[0]).comment, context.get_var(pair[1]).comment)
        end

        nil
      end
    end
  end
end
