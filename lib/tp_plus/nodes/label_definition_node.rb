module TPPlus
  module Nodes
    class LabelDefinitionNode < BaseNode
      attr_reader :identifier, :type, :number
      def initialize(identifier)
        if identifier.kind_of?(Array)
          number = identifier[1]
          identifier = identifier[0]

          #set global for later pop method
          $last_label_number = number
        end

        @type = Types::ID
        @type = Types::SET if identifier == 'set_label'
        @type = Types::POP if identifier == 'pop_label'
        
        if @type == Types::ID
          @identifier = identifier
        else
          @identifier = identifier
          @number = $last_label_number
        end
      end

      module Types
        ID  = 1
        SET = 2
        POP = 3
      end

      def long_identifier_comment(context)
        return "" unless @identifier.length > 16

        " ;\n! #{@identifier}"
      end

      def eval(context)
        #context.add_label(@identifier)
        if @type == Types::ID
          "LBL[#{context.labels[@identifier.to_sym]}:#{@identifier[0,16]}]#{long_identifier_comment(context)}"
        end
      end
    end
  end
end
