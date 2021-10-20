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

      def eval(context)
        if @value.is_a?(Nodes::FrameNode)
          s = context.get_var(@value.identifier).id.to_s
        else
          s = @value.eval(context)
        end
        if @method.has_key?(:group)
          s = "GP#{@method[:group].eval(context)}:#{s}"
        end

        case @type
        when "use_uframe"
          "UFRAME_NUM=#{s}"
        when "use_utool"
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
