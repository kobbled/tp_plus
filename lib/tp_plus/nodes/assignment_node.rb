module TPPlus
  module Nodes
    class AssignmentNode
      attr_reader :identifier, :assignable
      def initialize(identifier,assignable)
        @identifier = identifier
        @assignable = assignable
      end

      def eval(context)
        "#{@identifier.eval(context)}=#{@assignable.eval(context)}"
      end
    end
  end
end
