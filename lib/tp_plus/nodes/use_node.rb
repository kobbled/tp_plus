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
        s = @value.eval(context)
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
