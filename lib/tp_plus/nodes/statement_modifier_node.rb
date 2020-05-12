module TPPlus
  module Nodes
    class StatementModifierNode < BaseNode
      def initialize(option)
        @option = option
      end

      def eval(context)
        if @option == "wjnt" || @option == "wrist_joint"
          "Wjnt"
        elsif @option == "minimal_rotation"
          "MROT"
        elsif @option == "increment"
          "INC"
        else
          "#{@option.upcase}"
        end
      end
    end
  end
end
