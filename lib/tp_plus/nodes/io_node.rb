module TPPlus
  module Nodes
    class IONode < BaseNode
      attr_accessor :comment
      attr_reader :id
      def initialize(type, id)
        @type    = type
        @id      = id.to_i
        @comment = ""
      end

      def requires_mixed_logic?(context)
        ["F","SO","SI","DI", "AI"].include?(@type) ? true : false
      end

      def result
        "#{@type}[#{@id}:#{@comment}]"
      end

      def eval(context, options={})
        s = result

        if options[:disable_mixed_logic]
          s = "#{s}=ON"
        end

        options[:force_parens] ? "(#{s})" : s
      end
    end
  end
end
