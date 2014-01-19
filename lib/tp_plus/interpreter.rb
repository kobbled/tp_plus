require 'tp_plus/parser'

module TPPlus
  class Interpreter
    attr_accessor :line_count, :nodes
    attr_reader :labels, :variables
    def initialize
      @line_count    = 0
      @nodes         = []
      @labels        = {}
      @namespaces    = {}
      @variables     = {}
      @constants     = {}
      @current_label = 99
    end

    def next_label
      @current_label += 1
    end

    def add_namespace(name, block)
      raise "Namespace (#{@name}) already defined" unless @namespaces[name.to_sym].nil?

      @namespaces[name.to_sym] = TPPlus::Namespace.new(name, block)
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

    def add_constant(identifier, node)
      raise "Constant #{identifier} already defined" if @constants[identifier.to_sym]

      @constants[identifier.to_sym] = node
    end

    def get_namespace(identifier)
      if ns = @namespaces[identifier.to_sym]
        return ns
      end

      false
    end

    def get_var(identifier)
      raise "Variable (#{identifier}) not defined" if @variables[identifier.to_sym].nil?

      @variables[identifier.to_sym]
    end

    def get_constant(identifier)
      raise "Constant (#{identifier}) not defined" if @constants[identifier.to_sym].nil?

      @constants[identifier.to_sym]
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

      @source_line_count = 0

      @nodes.each do |n|
        @source_line_count += 1 unless n.is_a?(Nodes::TerminatorNode) && !last_node.is_a?(Nodes::TerminatorNode)
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
    rescue RuntimeError => e
      raise "Runtime error on line #{@source_line_count}:\n#{e}"
    end
  end
end
