require 'tp_plus/parser'

module TPPlus
  class Interpreter
    attr_accessor :line_count, :nodes, :position_data, :header_data
    attr_reader :labels, :variables, :constants, :namespaces, :source_line_count
    def initialize
      @line_count    = 0
      @nodes         = []
      @labels        = {}
      @namespaces    = {}
      @variables     = {}
      @constants     = {}
      @position_data = {}
      @header_data   = {}
      @current_label = 99
    end

    def load_environment(string)
      scanner = TPPlus::NewScanner.new
      parser = TPPlus::Parser.new(scanner, self)
      scanner.scan_setup(string)
      parser.parse
      eval
    rescue RuntimeError => e
      raise "Runtime error in environment on line #{@source_line_count}:\n#{e}"
    end

    def next_label
      @current_label += 1
    end

    def add_namespace(name, block)
      if @namespaces[name.to_sym].nil?
        @namespaces[name.to_sym] = TPPlus::Namespace.new(name, block)
      else
        @namespaces[name.to_sym].reopen!(block)
      end
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

    def pos_section
      return "" if @position_data.empty?
      return "" if @position_data[:positions].empty?

      @position_data[:positions].inject("") do |s,p|
        s << %(P[#{p[:id]}:"#{p[:comment]}"]{
   GP#{p[:group]}:
  UF : #{p[:uframe]}, UT : #{p[:utool]},  CONFIG : '#{p[:config][:flip] ? 'F' : 'N'} #{p[:config][:up] ? 'U' : 'D'} #{p[:config][:top] ? 'T' : 'B'}, #{p[:config][:turn_counts].join(', ')}',
  X = #{p[:components][:x]} mm, Y = #{p[:components][:y]} mm, Z = #{p[:components][:z]} mm,
  W = #{p[:components][:w]} deg, P = #{p[:components][:p]} deg, R = #{p[:components][:r]} deg
};\n)
      end
    end

    def eval
      s = ""
      last_node = nil

      define_labels

      @source_line_count = 0

      @nodes.each do |n|
        @source_line_count += 1 unless n.is_a?(Nodes::TerminatorNode) && !last_node.is_a?(Nodes::TerminatorNode)
        raise if n.is_a?(String)

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
