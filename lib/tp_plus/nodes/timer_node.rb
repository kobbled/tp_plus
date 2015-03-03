module TPPlus
  module Nodes
    class TimerNode
      attr_accessor :comment
      attr_reader :id
      def initialize(id)
        @id = id
        @comment = ""
      end

      def eval(context, options={})
        "TIMER[#{@id}]" # FANUC does not like timer comments
      end
    end
  end
end
