module TPPlus
  module Nodes
    class WarningNode < BaseNode
      attr_reader :label, :message
      def initialize(message, label)
        @message = message
        @label = label
      end

      def skip_label(context)
        @skip_label ||= context.next_label
      end

      def block_eval(context)
        s = " ;\nJMP LBL[#{skip_label(context)}] ;\n"
        s += "#{@label.eval(context)} ;\nCALL USERCLR ;\n#{@message.eval(context)} ;\nWAIT UI[5]=ON ;\nWAIT UI[5]=OFF ;\n"
        s += "LBL[#{skip_label(context)}] ;\n"
      end

      def eval(context)
        JumpNode.new(@label.identifier).eval(context)
      end
    end
  end
end
