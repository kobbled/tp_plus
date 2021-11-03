module TPPlus
  module Nodes
    class PoseNode < BaseNode
      def initialize(var, position)
        @var = var
        @position = position
      end

      def eval(context)
        raise "PoseNode must contain a modifier" unless @var.method
        raise "PoseNode must contain a modifier" unless (@var.method.keys & Motion::Types::KEYS).any?

        #set position type and compnents to a key:value pair
        type = @var.method[Motion::Types::POSE].to_sym

        options = {}
        options = @var.method.clone
        options.delete(:pose)

        if @var.method.key?(:group)
          options[:group] = @var.method[:group].value
        else
          options[:group] = 1
        end

        options[:components] = @position

        if context.pose_list.poses.length > 0
          context.pose_list.set_pose(@var.identifier.to_sym, type, options)
        end
        
        nil
      end
    end
  end
end
