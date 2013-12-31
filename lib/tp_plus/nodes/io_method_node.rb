module TPPlus
  module Nodes
    class IOMethodNode
      def initialize(method, target)
        @method = method
        @target = target
      end

      def eval(context)
        case @method
        when "turn_on"
          "#{@target.eval(context)}=ON"
        when "turn_off"
          "#{@target.eval(context)}=OFF"
        when "toggle"
          "#{@target.eval(context)}=(!#{@target.eval(context)})"
        end
      end
    end
  end
end
