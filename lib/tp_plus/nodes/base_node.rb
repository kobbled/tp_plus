module TPPlus
  module Nodes
    class BaseNode
      def can_be_inlined?
        false
      end

      def get_attributes
        return self.instance_variables.map {|n| self.instance_variable_get(n)}
      end
    end
  end
end
