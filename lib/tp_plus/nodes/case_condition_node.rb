# frozen_string_literal: true
module TPPlus
  module Nodes
    class CaseConditionNode < RecursiveNode
      def initialize(condition, block)
        super(condition)
        
        @label      = {}
        @block      = block.flatten.reject {|n| n.is_a?(TerminatorNode) }
      end

      def block_each_eval(context)
        @s = @block.inject(String.new) {|s,n| s << "#{n.eval(context)} ;\n" }
      end

      def block_eval(context, end_label)
        "#{@label.eval(context)} ;\n#{block_each_eval(context)}JMP LBL[#{end_label}] ;\n"
      end

      def get_block
        @block
      end

      def is_jump_label(context)
        if @block[0].is_a?(Nodes::JumpNode)
          return @block[0].eval(context)
        else
          return JumpNode.new(@label.identifier).eval(context)
        end
      end

      def eval(context, options={})
        options[:no_indent] ||= false

        s = String.new
        unless options[:no_indent]
          s << "       "
        end

        #set label
        context.increment_case_labels()
        @label = LabelDefinitionNode.new(context.get_case_label())

        if @condition[0]
          s << "=#{@condition[0].eval(context)},#{is_jump_label(context)}"
        else
          s << "ELSE,#{is_jump_label(context)}"
        end

        s
      end
    end
  end
end
