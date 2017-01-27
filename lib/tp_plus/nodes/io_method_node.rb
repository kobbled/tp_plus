module TPPlus
  module Nodes
    class IOMethodNode < BaseNode
      def initialize(method, target,options={})
        @method = method
        @target = target
        @init_options = options
      end

      def requires_mixed_logic?(context)
        true
      end

      def can_be_inlined?
        true
      end

      def on_off(value,options={})
        options[:mixed_logic] ? "(#{value})" : value
      end

      def pulse_time(context)
        "%.1f" % case @init_options[:pulse_units]
        when "s"
          @init_options[:pulse_time].eval(context)
        when "ms"
          @init_options[:pulse_time].eval(context).to_f / 1000
        else
          raise "Invalid pulse units"
        end
      end

      def pulse_extra(context)
        return "" if @init_options[:pulse_time].nil?

        ",#{pulse_time(context)}sec"
      end

      def eval(context,options={})
        options[:mixed_logic] = true if @target.requires_mixed_logic?(context)

        case @method
        when "turn_on"
          "#{@target.eval(context)}=#{on_off("ON",options)}"
        when "turn_off"
          "#{@target.eval(context)}=#{on_off("OFF",options)}"
        when "toggle"
          "#{@target.eval(context)}=(!#{@target.eval(context)})"
        when "pulse"
          "#{@target.eval(context)}=PULSE#{pulse_extra(context)}"
        end
      end
    end
  end
end
