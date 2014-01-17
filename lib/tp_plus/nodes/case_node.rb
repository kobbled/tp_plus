module TPPlus
  module Nodes
    class CaseNode
      def initialize(var, conditions, else_condition)
        @var = var
        @conditions = conditions
        @else_condition = else_condition
      end

      def else_condition(context)
        return "" if @else_condition.nil?

        " ;\n#{@else_condition.eval(context)}"
      end

      def other_conditions(context)
        return "" if @conditions.empty?

        s = " ;\n"
        @conditions.reject! {|c| c.nil? }.each do |c|
          s += c.eval(context)
          s += " ;\n" unless c == @conditions.last
        end

        s
      end

      def eval(context)
        "SELECT #{@var.eval(context)}#{@conditions.shift.eval(context, no_indent: true)}#{other_conditions(context)}#{else_condition(context)}"
      end
    end
  end
end
