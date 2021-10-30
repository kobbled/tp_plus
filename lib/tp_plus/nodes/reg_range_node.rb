module TPPlus
  module Nodes
    class RegDefinitionNode < BaseNode
      attr_accessor :range

      def initialize(type, range)
        @range = range
        @range.setName(type)
      end

      def eval(context)
        
        if @range.is_a?(RangeNode)
          @definitions = @range.getDefinitions
          
          @definitions.each do |d|
            #add to pose list
            context.add_pose(d)
          end
        else
          if @range.methods.include?(:name)
            name = @range.name
          else
            name = @range.comment
          end

          @definitions = DefinitionNode.new(name, @range)
        end

        @definitions
      end

      private

    end
  end
end