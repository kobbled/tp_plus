module TPPlus
  module Nodes
    class UserAlarmNode < BaseNode
      attr_accessor :comment
      attr_reader :id
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
