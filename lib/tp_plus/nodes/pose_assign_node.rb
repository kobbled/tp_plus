module TPPlus
  module Nodes
    class PoseAssignNode < BaseNode

      def initialize(range1, range2, options = {})
        @range1 = range1
        @range2 = range2
        @options = options
      end

      def getBaseName(name, context)
        #remove numebrs from end of string
        name.target_node(context).comment.gsub(/ *\d+$/, '')
      end

      def createNameArray(startId, endId, context)
        raise "Start and end identifers for an array must have the same prefix" unless getBaseName(startId, context) == getBaseName(endId, context)
        #turn an array of numbers into an array of strings with a prefix in front of the number
        arr = *(startId.target_node(context).id..endId.target_node(context).id)
        
        prefix = getBaseName(startId, context)
        arr.each_with_index do |p, index|
          arr[index] = prefix + p.to_s
        end

        arr
      end

      def eval(context)
        
        array1 = createNameArray(@range1[:start], @range1[:end], context)
        array2 = createNameArray(@range2[:start], @range2[:end], context)

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
