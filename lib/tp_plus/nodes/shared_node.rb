module TPPlus
  module Nodes
    class SharedDefinitionNode < LocalDefinitionNode

      attr_reader :name
      def initialize(type,name=nil)
        @virtualtype = type
        @type = reg_map(type)
        @name = name
      end

      def setName(name)
        @name = name
      end

      def getDefinitions
        definitions = []
        
        raise "#{@type} type shared stack has not been created yet" unless $shared.pack.key?(@type.to_sym)

        #add var to stack
        $shared.pack[@type.to_sym].add(@name)

        #create definition node
        definitions.append(DefinitionNode.new(@name, createNode(@type, $shared.pack[@type.to_sym].getid(@name))))

        return definitions
      end

      def eval(context)
        nil
      end

      private

      def reg_map(type)
        case type
        when "SHR"
          return "R"
        when "SPR"
          return "PR"
        when "SF"
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