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

    def add_constant(identifier, node)
      raise "Constant (#{identifier}) already defined within namespace #{@name}" unless @constants[identifier.to_sym].nil?

      @constants[identifier.to_sym] = node
    end

    def add_var(identifier, node)
      raise "Variable (#{identifier}) already defined within namespace #{@name}" unless @variables[identifier.to_sym].nil?

      @variables[identifier.to_sym] = node
      node.comment = "#{@name} #{identifier}"
    end

    def get_constant(identifier)
      raise "Constant (#{identifier}) not defined within namespace #{@name}" if @constants[identifier.to_sym].nil?

      @constants[identifier.to_sym]
    end

    def get_var(identifier)
      return get_constant(identifier) if identifier.upcase == identifier
      raise "Variable (#{identifier}) not defined within namespace #{@name}" if @variables[identifier.to_sym].nil?

      @variables[identifier.to_sym]
    end
  end
end
