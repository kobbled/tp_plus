module TPPlus
  module Nodes
    class UseNode < BaseNode
      def initialize(type, value, group = nil)
        @type = type
        @value = value
        @method = {}
        if group
          @method[:group] = group
        end
      end

      def update_pos_list(context)
        if @value.is_a?(Nodes::VarNode) && !(@value.constant?)
          if @value.constant?
            if @type == "use_uframe"
              context.pose_list.set_frame(context.get_const(@value.identifier).id)
            else
              context.pose_list.set_tool(context.get_const(@value.identifier).id)
            end
          else
            if @type == "use_uframe"
              context.pose_list.set_frame(context.get_var(@value.identifier).id)
            else
              context.pose_list.set_tool(context.get_var(@value.identifier).id)
            end
          end
        elsif  @value.is_a?(Nodes::DigitNode)
          if @type == "use_uframe"
            context.pose_list.set_frame(@value.value)
          else
            context.pose_list.set_tool(@value.value)
          end
        end
      end

      def eval(context)
        s = @value.eval(context)
        if @value.is_a?(Nodes::VarNode) && !(@value.constant?)
          if context.get_var(@value.identifier).is_a?(Nodes::FrameNode)
            s = context.get_var(@value.identifier).id.to_s
          end
        end
        if @method.has_key?(:group)
          s = "GP#{@method[:group].eval(context)}:#{s}"
        end

        case @type
        when "use_uframe"
          update_pos_list(context)
          "UFRAME_NUM=#{s}"
        when "use_utool"
          update_pos_list(context)
          "UTOOL_NUM=#{s}"
        when "use_payload"
          "PAYLOAD[#{s}]"
        when "use_override"
          if @value.is_a?(VarNode)
            "OVERRIDE=#{s}"
          else
            "OVERRIDE=#{s}%"
          end
        end
      end
    end
  end
end
