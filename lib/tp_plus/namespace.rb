module TPPlus
  class Namespace < BaseBlock
    def initialize(name, block)
      super()

      @name       = name.strip
      @nodes      = block

      define!
    end

    def define!
      @nodes.flatten.select {|n| [TPPlus::Nodes::DefinitionNode, TPPlus::Nodes::FunctionNode, TPPlus::Nodes::NamespaceNode].include? n.class }.each do |node|
        node.eval(self)
      end
    end

    def reopen!(block)
      @nodes = block
      define!
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

    def add_function(name, args, block, ret_type = '')
      identifier = @name + '_' + name
      
      if @functions[name.to_sym].nil?
        @functions[name.to_sym] = TPPlus::Function.new(identifier, args, block, ret_type=ret_type, vars=@variables, consts=@constants)
        @functions[name.to_sym].eval
      end
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
