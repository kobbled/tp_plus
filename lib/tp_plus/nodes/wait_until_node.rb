module TPPlus
  module Nodes
    class WaitUntilNode < BaseNode
      def initialize(expression, timeout_options)
        @expression = expression
        @timeout_options = timeout_options || {}
      end

      def timeout(context)
        return "" if @timeout_options[:label].nil?

        " TIMEOUT,LBL[#{context.labels[@timeout_options[:label].to_sym]}]"
      end

      def val(context)
        value_node = @timeout_options[:timeout][0]
        units = @timeout_options[:timeout][1]

        if value_node.is_a?(VarNode)
          value = value_node.eval(context)

          case units
          when "s"
            value = "#{value}*100"
          when "ms"
            value = "#{value}*.1"
          else
            raise "invalid units"
          end
        else
          value = value_node.eval(context).to_i

          case units
          when "s"
            value = (value * 100).to_i
          when "ms"
            value = (value * 0.1).to_i
          else
            raise "invalid units"
          end
        end

        value
      end

      def wait_timeout(context)
        return "" if @timeout_options[:timeout].nil?

        "$WAITTMOUT=(#{val(context)}) ;\n"
      end

      def string_value(context)
        "(#{@expression.eval(context)})"
      end

      def eval(context)
        "#{wait_timeout(context)}WAIT #{string_value(context)}#{timeout(context)}"
      end
    end
  end
end
