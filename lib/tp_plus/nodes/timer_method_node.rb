module TPPlus
  module Nodes
    class TimerMethodNode < BaseNode
      def initialize(method, target)
        @method = method
        @target = target
      end

      def requires_mixed_logic?(context)
        true
      end

      def timer(context)
        @timer ||= @target.eval(context)
      end

      def eval(context,options={})
        case @method
        when "start"
          "#{timer(context)}=START"
        when "stop"
          "#{timer(context)}=STOP"
        when "reset"
          "#{timer(context)}=RESET"
        when "restart"
          "#{timer(context)}=STOP ;\n#{timer(context)}=RESET ;\n#{timer(context)}=START"
        else
          raise "Invalid timer method (#{@method})"
        end
      end
    end
  end
end
