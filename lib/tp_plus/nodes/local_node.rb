module TPPlus
  module Nodes
    class LocalDefinitionNode < BaseNode

      def initialize(type)
        @virtualtype = type
        @type = reg_map(type)
      end

      def setName(name)
        @name = name
      end

      def getDefinitions
        definitions = []
        
        raise "#{@type} type local stack has not been created yet" unless $stacks.pack.key?(@type.to_sym)

        #add var to stack
        $stacks.pack[@type.to_sym].add(@name)

        #create definition node
        definitions.append(DefinitionNode.new(@name, createNode(@type, $stacks.pack[@type.to_sym].getid(@name))))

        return definitions
      end

      def eval(context)
        nil
      end

      private

      def reg_map(type)
        case type
        when "LR"
          return "R"
        when "LPR"
          return "PR"
        when "LF"
          return "F"
        else
          raise "virtual register type #{type} is not implemented yet"
        end
      end 

      def createNode(type, id)
        case type
          when "R"
            return NumregNode.new(id)
          when "PR"
            return PosregNode.new(id)
          when "VR"
            return VisionRegisterNode.new(id)
          when "SR"
            return StringRegisterNode.new(id)
          else
            return IONode.new(type, id)
        end
      end

    end
  end
end