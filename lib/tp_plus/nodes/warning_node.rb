module TPPlus
  module Nodes
    class WarningNode < BaseNode
      attr_reader :label, :message
      def initialize(message)
        @message = message
        @label = ''
      end

      def skip_label(context)
        @skip_label = context.next_label
      end

      def block_eval(context)
        s = " ;\nJMP LBL[#{@skip_label}] ;\n"
        s += "#{@label.eval(context)} ;\nCALL USERCLR ;\n#{@message.eval(context)} ;\nWAIT UI[5]=ON ;\nWAIT UI[5]=OFF ;\n"
        s += "LBL[#{@skip_label}] ;\n"
      end

      def eval(context)
        context.increment_warning_labels()
        @label = context.get_warning_label()
        skip_label(context)
        JumpNode.new(@label.identifier).eval(context)
      end
    end
  end
end
