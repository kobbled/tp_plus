module TPPlus
  class Namespace
    def initialize(name, block)
      @name       = name
      @block      = block
      @namespaces = {}
      @variables  = {}
      @constants  = {}

      define!
    end

    def define!
      @block.flatten.select {|n| n.is_a? TPPlus::Nodes::DefinitionNode }.each do |node|
        node.eval(self)
      end
    end

    def add_var(identifier, node)
      raise "Variable (#{identifier}) already defined within namespace #{@name}" unless @variables[identifier.to_sym].nil?

      @variables[identifier.to_sym] = node
      node.comment = "#{@name} #{identifier}"
    end

    def get_var(identifier)
      raise "Variable (#{identifier}) not defined within namespace #{@name}" if @variables[identifier.to_sym].nil?

      @variables[identifier.to_sym]
    end
  end
end
