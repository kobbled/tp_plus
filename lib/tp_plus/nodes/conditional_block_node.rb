module TPPlus
  module Nodes
    class ConditionalBlockNode < BaseNode
      def initialize(condition,true_block,elsif_block,false_block)
        @condition   = condition
        @true_block  = true_block.flatten.reject  {|n| n.is_a? TerminatorNode }
        @elsif_block = elsif_block
        @false_block = false_block.flatten.reject {|n| n.is_a? TerminatorNode }
      end

      def true_block(context)
        @t ||= string_for(@true_block,context)
      end

      def false_block(context)
        @f ||= string_for(@false_block,context)
      end

      def get_true_block
        @true_block
      end

      def get_false_block
        @false_block
      end

      def elsif_block(context)
        s = ""
        
        len = @elsif_block.reject {|c| c.nil? }.length
        @elsif_block.reject {|c| c.nil? }.each_with_index do |c, index|
          s += c.eval(context, recursive: true)
          if (index < len-1)
            s += "ELSE ;\n"
          end
          @endif += "ENDIF ;\n"
        end

        s
      end

      def string_for(block,context)
        block.inject("") {|s,n| s << "#{n.eval(context)} ;\n" }
      end

      def requires_mixed_logic?(context)
        false
      end

      def can_be_inlined?
        false
        # @true_block.first.can_be_inlined?
      end

      def parens(s, context)
        "(#{s})"
      end

      def eval(context, options={})

        s = "IF #{parens(@condition.eval(context), context)} THEN ;\n#{true_block(context)}"
        
        return s if options[:recursive]

        if @elsif_block.empty?
          if @false_block.empty?
            s += "ENDIF ;"
          else
            # could be if-else or unless-else
            s += "ELSE ;\n#{false_block(context)}ENDIF"
          end
        else
          @endif = "ENDIF ;\n"
          if @false_block.empty?
            s += "ELSE ;\n#{elsif_block(context)}#{@endif}"
          else
            s += "ELSE ;\n#{elsif_block(context)}ELSE ;\n#{false_block(context)}#{@endif}"
          end
        end
      end
    end
  end
end
