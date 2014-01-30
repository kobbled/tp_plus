module TPPlus
  module Nodes
    class HeaderNode
      def initialize(type, value)
        @type  = type
        @value = value
      end

      def eval(context, options={})
        case @type
        when "TP_IGNORE_PAUSE"
          context.header_data[:ignore_pause] = @value
        when "TP_COMMENT"
          context.header_data[:comment] = @value
        when "TP_GROUPMASK"
          context.header_data[:group_mask] = @value
        else
          raise "Unsupported TP Header value (#{@type})"
        end

        nil
      end
    end
  end
end
