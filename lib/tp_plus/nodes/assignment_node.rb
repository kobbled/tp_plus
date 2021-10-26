module TPPlus
  module Nodes
    class AssignmentNode < BaseNode
      attr_reader :identifier, :assignable
      def initialize(identifier,assignable)
        @identifier = identifier
        @assignable = assignable
      end

      def assignable_string(context,options={})
        if @assignable.is_a?(ExpressionNode)
          options[:mixed_logic] = true if @assignable.contains_expression?
          options[:mixed_logic] = true if @assignable.op.requires_mixed_logic?(context)
          options[:mixed_logic] = true if @assignable.op.boolean?
          options[:mixed_logic] = true if @assignable.boolean_result?
          # this is a hack that fixes issue #12
          # PR[a]=PR[b]+PR[c]+PR[d] (no parens)
          if @identifier.is_a? VarNode
            options[:mixed_logic] = false if @identifier.target_node(context).is_a? PosregNode
          end
        elsif @assignable.is_a?(VarNode)
          options[:mixed_logic] = true if @assignable.target_node(context).is_a? IONode
        else
          options[:mixed_logic] = true if @assignable.requires_mixed_logic?(context)
          options[:mixed_logic] = true if @identifier.requires_mixed_logic?(context)
        end

        if options[:mixed_logic]
          "(#{@assignable.eval(context)})"
        else
          @assignable.eval(context)
        end
      end

      def requires_mixed_logic?(context)
        true
      end

      def can_be_inlined?
        true
      end

      def identifier_string(context)
        @identifier.eval(context)
      end

      def eval(context,options={})
        if @identifier.is_a?(VarNode) && @assignable.is_a?(VarNode)
          if @assignable.target_node(context).is_a?(PositionNode) && @identifier.target_node(context).is_a?(PositionNode)
            context.pose_list.copy_pose(@identifier.target_node(context).comment, @assignable.target_node(context).comment)
            return nil
          end
        end

        "#{identifier_string(context)}=#{assignable_string(context,options)}"
      end
    end
  end
end
