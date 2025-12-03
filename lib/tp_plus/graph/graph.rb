module Graph
  class Node
    attr_accessor :name, :children, :level
    def initialize(name)
      @name = name
      @children = []
      @level = 0
    end
  end

  class Graph
    attr_accessor :graph, :root

    def initialize(root=nil)
      @root = nil
      @graph = {}
      unless root == nil
        @root = Node.new(root)
      end
    end

    def setRoot(node)
      @root = node
    end

    def addNode(name)
      @graph[name] = Node.new(name)
    end

    def addEdge(parent, child)
      @graph[parent].children.append(child)
    end

    def dfs(node,stack=nil)
      if stack == nil
        stack = []
      end

      stack.append(node)

      node.children.each do |child|
        dfs(child, stack)
      end

      return stack
    end

    def bfs(node)
      stack = []
      queue = []

      queue.push(node)

      while(queue.size != 0)
        node = queue.shift

        stack.append(node)

        node.children.each_with_index do |child, i|
          queue.push(child)
        end
      end

      return stack
    end

    #dfs search labelling the level
    def setDepthLevels(node=@root,stack=nil,level=0)
      if stack == nil
        stack = []
      end

      stack.append([node.name, node.level])

      node.children.each do |child|
        child.level = level + 1
        setDepthLevels(child, stack, level+1)
      end

      nil
    end

    #bfs search labelling levels
    def setBredthLevels
      stack = []
      queue = []
      level = 0

      queue.push(@root)

      while(queue.size != 0)
        node = queue.shift

        stack.append([node.name, node.level])

        node.children.each_with_index do |child, i|
          level += 1 if i == 0
          child.level = level
          queue.push(child)
        end
      end

      return stack
    end


  end

end