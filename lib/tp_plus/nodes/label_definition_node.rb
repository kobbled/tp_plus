module TPPlus
  module Nodes
    class LabelDefinitionNode
      attr_reader :identifier
      def initialize(identifier)
        @identifier = identifier
      end

      def long_identifier_comment(context)
        return "" unless @identifier.length > 16

        " ;\n! #{@identifier}"
      end

      def eval(context)
        #context.add_label(@identifier)
        "LBL[#{context.labels[@identifier.to_sym]}:#{@identifier[0,16]}]#{long_identifier_comment(context)}"
      end
    end
  end
end
