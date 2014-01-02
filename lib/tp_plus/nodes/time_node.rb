module TPPlus
  module Nodes
    class TimeNode
      def initialize(type, time, action)
        @type = type
        @time = time
        @action = action
      end

      def type
        case @type.downcase
        when "time_before"
          "TB"
        when "time_after"
          "TA"
        end
      end

      def eval(context)
        "#{type} #{@time.eval(context)}sec,#{@action.eval(context)}"
      end
    end
  end
end
