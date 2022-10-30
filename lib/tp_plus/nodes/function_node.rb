module TPPlus
  module Nodes
    class FunctionNode < BaseNode
      attr_reader :name, :block, :args
      def initialize(name, args, block, ret_type = '', inlined = false)
        @name = name
        @block = block
        @args = args
        @ret_type = ret_type
        @inlined = inlined
      end

      def eval(context)
        context.add_function(@name, @args, @block, @ret_type, @inlined)
        nil
      end
    end
  end
end
