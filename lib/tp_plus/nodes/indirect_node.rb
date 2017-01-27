module TPPlus
  module Nodes
    class IndirectNode < BaseNode
      def initialize(type, target)
        @type = type
        @target = target
      end

      def string
        case @type
        when :position
          "P"
        when :position_register
          "PR"
        when :flag
          "F"
        when :timer
          "TIMER"
        when :register
          "R"
        when :user_alarm
          "UALM"
        when :user_frame
          "UFRAME"
        else
          raise "Invalid indirect type"
        end
      end

      def requires_mixed_logic?(context)
        case @type
        when :flag#, :timer
          true
        else
          false
        end
      end

      def eval(context,options={})
        s = "#{string}[#{@target.eval(context)}]"
        if options[:opposite]
          s = "!#{s}"
        end
        if options[:as_condition]
          s = "(#{s})"
        end
        s
      end
    end
  end
end
