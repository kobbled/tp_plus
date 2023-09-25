module TPPlus
  module Nodes
    class LabelDefinitionNode < BaseNode
      attr_reader :identifier, :type, :number
      def initialize(identifier)
        if identifier.kind_of?(Array)
          @number = identifier[1]
          @identifier = identifier[0]

          #set global for later pop method
          $last_label_number = identifier[1]
        else
          @identifier = identifier
        end

        @type = Types::ID
        @type = Types::SET if @identifier == 'set_label'
        @type = Types::POP if @identifier == 'pop_label'
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

      def set_label_number(context)
        context.previous_set_label[context.previous_set_label_index] = context.current_label
        context.previous_set_label_index += 1
  
        context.previous_set_label.append(number.eval(context).to_i)
        context.current_label = (number.eval(context).to_i - 1)
  
        nil
      end

      def return_label_number(context)
        context.previous_set_label[context.previous_set_label_index] = context.current_label
        context.previous_set_label_index -= 1
  
        context.current_label = context.previous_set_label[context.previous_set_label_index]
  
        nil
      end

      def eval(context)
        #context.add_label(@identifier)
        case @type
        when Types::ID
          if defined?(@number)
            context.add_label(identifier, @number.eval(context))
          else
            context.add_label(identifier)
          end
          "LBL[#{context.labels[@identifier.to_sym]}:#{@identifier[0,16]}]#{long_identifier_comment(context)}"
        when Types::SET
          set_label_number(context)
        when Types::POP
          return_label_number(context)
        end
      end
    end
  end
end
