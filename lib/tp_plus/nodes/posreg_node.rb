module TPPlus
  module Nodes
    class PosregNode

      COMPONENTS = {
        "x" => 1,
        "y" => 2,
        "z" => 3,
        "w" => 4,
        "p" => 5,
        "r" => 6
      }

      attr_accessor :comment
      def initialize(id)
        @id = id
        @comment = ""
      end

      def comment_string
        return "" if @comment == ""

        ":#{@comment}"
      end

      def component(m)
        return "" if m == ""

        ",#{COMPONENTS[m]}"
      end

      def component_valid?(c)
        [""].concat(COMPONENTS.keys).include? c
      end

      def requires_mixed_logic?(context)
        false
      end

      def eval(context,options={})
        options[:method] ||= ""
        raise "Invalid component" unless component_valid?(options[:method])

        "PR[#{@id}#{component(options[:method])}#{comment_string}]"
      end
    end
  end
end
