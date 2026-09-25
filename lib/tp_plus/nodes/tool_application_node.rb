module TPPlus
  module Nodes
    class ToolApplNode < BaseNode
      def initialize(type, members = {})
        @type  = type
        @members = members
      end

      def eval(context)
        context.header_appl_data.append(self)
        nil
      end

      def write(context)
        s = "#{@type} ;\n"

        @members.flatten.each do |m|
           s += "  #{m.eval(context)} ;\n"
        end

        s
      end
    end

    class ToolApplMem < BaseNode
      def initialize(type, value)
        @type  = type
        @value = value
      end

      def eval(context, options={})
        value = case @value
                when true then "TRUE"
                when false then "FALSE"
                else @value
                end

        "#{@type} : #{value}"
      end
    end

  end
end
