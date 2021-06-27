module TPPlus
  module Nodes
    class ArguementModifierNode < BaseNode
      def initialize(modifier,value)
        @modifier = modifier
        @value = value
      end

      def mod_type(context)
        case @modifier
          when "cd", "corner_distance"
            "CD"
          when "ap_ld", "approach_ld"
            "AP_LD"
          when "rt_ld", "retract_ld"
            "RT_LD"
          when "indev", "independent_ev"
            "Ind.EV"
          when "ev", "simultaneous_ev"
            "EV"
          when "pspd", "process_speed"
            "PSPD"
          when "ctv", "continuous_rotation_speed"
            "CTV"
          else
            raise "invalid motion modifier " + @modifier 
        end
      end
      
      def postfix(context)
        case @modifier
          when "indev", "independent_ev"
            "%"
          when "ev", "simultaneous_ev"
            "%"
          else
            ""
        end
      end

      def eval(context)
        "#{mod_type(context)}#{@value.eval(context)}#{postfix(context)}"
      end
    end
  end
end
