module TPPlus
  module Nodes
    class CaseNode < BaseNode
      def initialize(var, conditions, else_condition)
        @var = var
        @conditions = conditions
        @else_condition = else_condition
      end

      def final_label(context)
        @final_label ||= context.next_label
      end

      def get_conditions
        conds = @conditions.clone
        return(conds.append(@else_condition))
      end

      def first_condition(context)
        #split off first condition as it is
        #formatted differently than proceeding conditions
        @first_condition ||= @conditions.shift
      end

      def first_cond_statement(context)
        first_condition(context)
        @first_condition.eval(context, no_indent: true)
      end

      def first_cond_block(context)
        first_condition(context)
        @first_condition.block_eval(context, final_label(context))
      end

      def else_condition(context)
        return "" if @else_condition.nil?

        " ;\n#{@else_condition.eval(context)}"
      end

      def else_condition_block(context)
        return "" if @else_condition.nil?

        @else_condition.block_eval(context, final_label(context))
      end

      def other_conditions(context)
        return "" if @conditions.empty?

        s = " ;\n"
        @conditions.append(nil)
        @conditions.reject! {|c| c.nil? }.each do |c|
          s += c.eval(context)
          s += " ;\n" unless c == @conditions.last
        end

        s
      end

      def blocks(context)
        s = " ;\n"
        #first select block
        s += first_cond_block(context)
        
        #all other select blocks
        return s+"LBL[#{final_label(context)}:endcase]" if @conditions.empty?
        @conditions.each do |c|
          s += c.block_eval(context, final_label(context))
        end
        #else select blocks
        s += else_condition_block(context)

        #add end label
        s += "LBL[#{final_label(context)}:endcase]"

        s
      end

      def eval(context)
        #select statment
        s = "SELECT #{@var.eval(context)}#{first_cond_statement(context)}#{other_conditions(context)}#{else_condition(context)} ;\n"
        s += "JMP LBL[#{final_label(context)}]"
        #select blocks
        s += blocks(context)

        s
      end

    end
  end
end
