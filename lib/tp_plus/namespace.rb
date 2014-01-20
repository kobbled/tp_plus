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
      @block.flatten.select {|n| [TPPlus::Nodes::DefinitionNode, TPPlus::Nodes::NamespaceNode].include? n.class }.each do |node|
        node.eval(self)
      end
    end

    def reopen!(block)
      @block = block
      define!
    end

    def add_constant(identifier, node)
      raise "Constant (#{identifier}) already defined within namespace #{@name}" unless @constants[identifier.to_sym].nil?

      @constants[identifier.to_sym] = node
    end

    def add_namespace(identifier, block)
      if @namespaces[identifier.to_sym].nil?
        @namespaces[identifier.to_sym] = TPPlus::Namespace.new("#{@name} #{identifier}", block)
      else
        @namespaces[identifier.to_sym].reopen!(block)
      end
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

    def get_namespace(identifier)
      if ns = @namespaces[identifier.to_sym]
        return ns
      end

      false
    end
  end
end
