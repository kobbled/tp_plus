module TPPlus
  module Nodes
    class AssignmentNode
      attr_reader :identifier, :assignable
      def initialize(identifier,assignable)
        @identifier = identifier
        @assignable = assignable
      end

      def assignable_string(context,options={})
        @assignable_string ||= if options[:mixed_logic]
          "(#{@assignable.eval(context)})"
        else
          @assignable.eval(context)
        end
      end

      def identifier_string(context)
        @identifier.eval(context)
      end

      def eval(context,options={})
        "#{identifier_string(context)}=#{assignable_string(context,options)}"
      end
    end
  end
end
