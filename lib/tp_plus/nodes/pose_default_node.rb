module TPPlus
  module Nodes
    class PoseDefaultNode < BaseNode
      def initialize(var, position)
        @var = var
        @position = position
      end

      def eval(context)
        #raise "PoseNode must contain a modifier" unless @var.method
        raise "PoseNode must contain a modifier" unless (@var.keys & Motion::Types::KEYS).any?
        
        #set position type and compnents to a key:value pair
        type = @var[Motion::Types::POSE].to_sym

        options = {}
        options[:components] = @position

        if @var.key?(:group)
          options[:group] = @var[:group].value
        else
          options[:group] = 1
        end

        context.pose_list.set_default(type, options)
        
        nil
      end
    end
  end
end
