require 'tp_plus/parser'

module TPPlus
  class Interpreter
    attr_accessor :line_count, :nodes
    attr_reader :labels, :variables
    def initialize
      @line_count    = 0
      @nodes         = []
      @labels        = {}
      @variables     = {}
      @current_label = 99
    end

    def next_label
      @current_label += 1
    end

    def add_label(identifier)
      raise "Label @#{identifier} already defined" if @labels[identifier.to_sym]
      @labels[identifier.to_sym] = next_label
    end

    def add_var(identifier, node)
      raise "Variable #{identifier} already defined" if @variables[identifier.to_sym]

      @variables[identifier.to_sym] = node
      node.comment = identifier
    end

    def get_var(identifier)
      raise "Variable (#{identifier}) not defined" if @variables[identifier.to_sym].nil?

      @variables[identifier.to_sym]
    end

    def define_labels
      @nodes.select {|n| n.is_a? Nodes::LabelDefinitionNode}.each do |n|
        add_label(n.identifier)
      end
    end

    def eval
      s = ""
      last_node = nil

      define_labels

      @nodes.each do |n|
        res = n.eval(self)

        # preserve whitespace
        if n.is_a?(Nodes::TerminatorNode) && last_node.is_a?(Nodes::TerminatorNode)
          s += " ;\n"
        end
        last_node = n
        # end preserve whitespace

        next if res.nil?

        s += "#{res} ;\n"
      end
      s
    end
  end
end
