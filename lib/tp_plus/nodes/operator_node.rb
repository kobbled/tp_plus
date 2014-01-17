module TPPlus
  module Nodes
    class OperatorNode
      def initialize(string)
        @string = string
      end

      def bang?
        @string == "!"
      end

      def requires_mixed_logic?
        case @string
        when "&&", "||", "!"
          true
        else
          false
        end
      end

      def eval(context,options={})
        if options[:opposite]
          case @string
          when "=="
            "<>"
          when "!=", "<>"
            "="
          when ">"
            "<="
          when "<"
            ">="
          when ">="
            "<"
          when "<="
            ">"
          end
        else
          case @string
          when "=="
            "="
          when "!="
            "<>"
          when "&&"
            " AND "
          when "||"
            " OR "
          else
            "#{@string}"
          end
        end
      end
    end
  end
end
