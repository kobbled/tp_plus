module TPPlus
  module Nodes
    class LabelDefinitionNode
      def initialize(identifier)
        @identifier = identifier
      end

      def eval(context)
        context.add_label(@identifier)
        "LBL[#{context.labels[@identifier.to_sym]}:#{@identifier}]"
      end
    end
  end
end
