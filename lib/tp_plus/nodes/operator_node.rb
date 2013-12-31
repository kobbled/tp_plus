module TPPlus
  module Nodes
    class OperatorNode
      def initialize(string)
        @string = string
      end

      def eval(context,options={})
        if options[:opposite]
          case @string
          when "=="
            "<>"
          when "!="
            "="
          end
        else
          case @string
          when "=="
            "="
          when "!="
            "<>"
          else
            "#{@string}"
          end
        end
      end
    end
  end
end
