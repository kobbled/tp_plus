module TPPlus
  module Nodes
    class FunctionNode < BaseNode
      attr_reader :block, :args
      def initialize(name, args, block, ret_type = '')
        @name = name
        @block = block
        @args = args
        @ret_type = ret_type
      end

      def eval(context)
        context.add_function(@name, @args, @block, @ret_type)
        nil
      end
    end
  end
end
