module TPPlus
  module Nodes
    class RangeNode < BaseNode

      attr_reader :range, :length, :name_range
      def initialize(startIndex, endIndex, type = '', baseName ='')

        @baseName = baseName
        @type = type

        #handle digit range      
        if startIndex.is_a?(Integer) && endIndex.is_a?(Integer)
          @range = *(startIndex..endIndex)
        end
        
        #handle string range
        if startIndex.is_a?(Nodes::VarNode) && endIndex.is_a?(Nodes::VarNode)
          raise "Start and end identifers for an array must have the same prefix" unless getBaseName(startIndex.identifier) == getBaseName(endIndex.identifier)
          @baseName = getBaseName(startIndex.identifier)

          strti = /\d+/.match(startIndex.identifier)
          endi =  /\d+/.match(endIndex.identifier)

          @range = *(strti[0].to_i..endi[0].to_i)

          #create named array
          @name_range = namedArray

        end

        @length = @range.length
      end

      def setName(name)
        @baseName = name
      end

      def setType(type)
        @type = type
      end

      def getName(i)
        if @range[0].is_a?(Integer)
          return "#{@baseName}#{@range[i]}"
        else
          return @range[i]
        end
      end

      def getDefinitions
        definitions = []

        @range.each_with_index do |e, i|
          if @length > 1
            definitions.append(DefinitionNode.new("#{@baseName}#{i+1}", createNode(@type, e)))
          else
            definitions.append(DefinitionNode.new(@baseName, createNode(@type, e)))
          end
        end

        return definitions
      end

      def eval(context)
        if @self.methods.include?(:name_range)
          @name_range.each do |r|
            context.add_var(r, node)
            r.target_node(context)
          end
        end
        nil
      end

      private

      def getBaseName(name)
        #remove numbers from end of string
        name.gsub(/ *\d+$/, '')
      end

      def createNameArray(startId, endId, context)
        #turn an array of numbers into an array of strings with a prefix in front of the number
        arr = *(startId.target_node(context).id..endId.target_node(context).id)
        
        prefix = getBaseName(startId, context)
        arr.each_with_index do |p, index|
          arr[index] = prefix + p.to_s
        end

        arr
      end

      def namedArray
        arr = []
        @range.each do |p|
          arr.append(@baseName + p.to_s)
        end

        arr
      end

      def createNode(type, id)
        case type
        when "R"
          return NumregNode.new(id)
        when "P"
          return PositionNode.new(id)
        when "PR"
          return PosregNode.new(id)
        when "VR"
          return VisionRegisterNode.new(id)
        when "SR"
          return StringRegisterNode.new(id)
        when "AR"
          return ArgumentNode.new(id)
        when "TIMER"
          return TimerNode.new(id)
        when "UALM"
          return UserAlarmNode.new(id)
        else
          return IONode.new(type, id)
        end
      end

    end
  end
end
