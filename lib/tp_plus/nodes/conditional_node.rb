module TPPlus
  module Nodes
    class ConditionalNode < BaseNode
      def initialize(type,condition,true_block,elsif_block,false_block)
        @type        = type
        @condition   = condition
        @true_block  = true_block.flatten.reject  {|n| n.is_a? TerminatorNode }
        @elsif_block = elsif_block
        @false_block = false_block.flatten.reject {|n| n.is_a? TerminatorNode }
      end

      def true_label(context)
        @true_label ||= context.next_label
      end

      def end_label(context)
        @end_label ||= context.next_label
      end

      def true_block(context)
        @t ||= string_for(@true_block,context)
      end

      def get_true_block
        @true_block
      end

      def get_false_block
        @false_block
      end

      def false_block(context)
        @f ||= string_for(@false_block,context)
      end

      def elsif_block(context)
        s = ""

        @elsif_block.reject {|c| c.nil? }.each do |c, i|
          s += c.eval(context, inlined: false, recursive: true)
          s += "JMP LBL[#{end_label(context)}] ;\n"
          s += "LBL[#{c.true_label(context)}] ;\n"

        end

        s
      end

      def string_for(block,context)
        block.inject("") {|s,n| s << "#{n.eval(context)} ;\n" }
      end

      def can_be_inlined?
        return false unless @false_block.empty?
        return false unless @true_block.length == 1

        @true_block.first.can_be_inlined?
      end

      def opposite?
        @type == "if"
      end

      def parens(s, context)
        return s unless @condition.requires_mixed_logic?(context) || !@condition.is_a?(ExpressionNode)

        "(#{s})"
      end

      def eval(context, options={inlined: can_be_inlined?})
        return InlineConditionalNode.new(@type,@condition,@true_block.first).eval(context) if options[:inlined]

        s = "IF #{parens(@condition.eval(context,opposite: opposite?), context)},JMP LBL[#{true_label(context)}] ;\n#{true_block(context)}"
        
        return s if options[:recursive]

        if @elsif_block.empty?
          if @false_block.empty?
            s += "LBL[#{true_label(context)}]"
          else
            # could be if-else or unless-else
            s += "JMP LBL[#{end_label(context)}] ;\nLBL[#{true_label(context)}] ;\n#{false_block(context)}LBL[#{end_label(context)}]"
          end
        else
          if @false_block.empty?
            s += "LBL[#{true_label(context)}] ;\n#{elsif_block(context)}"
          else
            s += "JMP LBL[#{end_label(context)}] ;\nLBL[#{true_label(context)}] ;\n#{elsif_block(context)} ;\n#{false_block(context)}LBL[#{end_label(context)}]"
          end
        end
      end
    end
  end
end
