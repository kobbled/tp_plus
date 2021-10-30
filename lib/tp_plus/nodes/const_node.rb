module TPPlus
  module Nodes
    class ConstNode < BaseNode
      attr_reader :value, :name

      def initialize(value)
        @value = value
        @name = ''
      end

      def setName(name)
        @name = name
      end

      def eval(context, options={})
        if @value < 0
          "(#{@value})"
        else
          @value.to_s
        end
      end
    end
  end
end