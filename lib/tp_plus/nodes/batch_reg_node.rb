module TPPlus
  module Nodes

    def batch_define(name, reg_nodes)
      if reg_nodes.is_a?(Array)
        if reg_nodes.length == 1
          nodes = DefinitionNode.new(name, reg_nodes[0])
        else
          nodes = []
          reg_nodes.each do |n|
            nodes.append(DefinitionNode.new("#{name}#{n.id}", n))
          end
        end
        return nodes
      else
        return DefinitionNode.new(name, reg_nodes)
      end
    end

    def batch_create_nodes(type, id)
      if !id.is_a?(Array)
        id = [id]
      end

      nodes = []
      id.each do |i|
        nodes.append(createNode(type, i))
      end

      nodes
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