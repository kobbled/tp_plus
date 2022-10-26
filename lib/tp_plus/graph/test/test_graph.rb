#!/usr/bin/ruby

require_relative '../graph'


g = Graph::Graph.new()

g.addNode("A")
g.setRoot(g.graph["A"])

g.addNode("B")
g.addNode("C")
g.addEdge("A", g.graph["B"])
g.addEdge("A", g.graph["C"])

g.addNode("D")
g.addNode("E")
g.addNode("F")
g.addEdge("B", g.graph["D"])
g.addEdge("B", g.graph["E"])
g.addEdge("B", g.graph["F"])

g.addNode("G")
g.addNode("H")
g.addEdge("F", g.graph["G"])
g.addEdge("F", g.graph["H"])

g.addNode("I")
g.addEdge("C", g.graph["I"])

g.setBredthLevels

stack = g.dfs(g.graph["A"])

stack.each do |s|
  p [s.name, s.level]
end






