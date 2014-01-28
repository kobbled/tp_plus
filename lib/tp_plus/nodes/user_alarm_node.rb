module TPPlus
  module Nodes
    class UserAlarmNode
      attr_accessor :comment
      def initialize(id)
        @id = id
        @comment = ""
      end

      def eval(context, options={})
        "UALM[#{@id}]"
      end
    end
  end
end
