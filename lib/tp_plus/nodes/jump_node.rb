module TPPlus
  module Nodes
    class JumpNode 
      def initialize(identifier)
        @identifier = identifier
      end

      def eval(context,options={})
        raise "Label (#{@identifier}) not found" if context.labels[@identifier.to_sym].nil?

        "JMP LBL[#{context.labels[@identifier.to_sym]}:#{@identifier}]"
      end
    end
  end
end
