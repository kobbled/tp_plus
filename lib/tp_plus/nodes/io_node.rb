module TPPlus
  module Nodes
    class IONode
      attr_accessor :comment
      def initialize(type, id)
        @type = type
        @id = id.to_i
        @comment = ""
      end

      def requires_mixed_logic?(context)
        @type == "F" ? true : false
      end

      def result
        "#{@type}[#{@id}:#{@comment}]"
      end

      def with_parens(s, options)
        return s unless options[:as_condition]

        "(#{s})"
      end

      def method_for(string, options)
        case string
        when "on?"
          options[:opposite] ? "OFF" : "ON"
        when "off?"
          options[:opposite] ? "ON" : "OFF"
        else
          raise "Invalid method (#{string})"
        end
      end

      def eval(context, options={})
        s = result
        if options[:method]
          s += "=#{method_for(options[:method], options)}"
        elsif options[:opposite]
          options[:as_condition] = true
          s = "!#{s}"
        end
        with_parens(s, options)
      end
    end
  end
end
