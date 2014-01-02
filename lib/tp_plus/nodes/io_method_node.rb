module TPPlus
  module Nodes
    class IOMethodNode
      def initialize(method, target)
        @method = method
        @target = target
      end

      def on_off(value,options={})
        options[:mixed_logic] ? "(#{value})" : value
      end

      def eval(context,options={})
        case @method
        when "turn_on"
          "#{@target.eval(context)}=#{on_off("ON",options)}"
        when "turn_off"
          "#{@target.eval(context)}=#{on_off("OFF",options)}"
        when "toggle"
          "#{@target.eval(context)}=(!#{@target.eval(context)})"
        end
      end
    end
  end
end
