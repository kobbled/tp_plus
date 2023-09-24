module TPPlus
  class Namespace < BaseBlock
    def initialize(name, block, vars={}, funcs = {}, nspaces = {}, environment = {}, imports = [])
      super()
      
      @name       = name.strip
      @nodes      = block
      @functions  = funcs
      @imports = imports
      @environment = environment

      define!(vars, funcs, nspaces)
    end

    def define!(vars, funcs, namespaces)
      # copy variables & constants to interpreter
      add_parent_nodes(self, vars)
      # copy shared variables in @variables scope
      add_shared_vars(self)
      #copy namespaces to interpreter
      add_namespaces(self, namespaces)
      #copy functions to interpreter
      add_functions(self, funcs)

      @nodes.each_with_index do |n, index|
        if n.is_a?(TPPlus::Nodes::RegDefinitionNode)
          #defer definition of local variables outside of constructor
          unless n.range.is_a?(TPPlus::Nodes::LocalDefinitionNode)
            @nodes[index] = n.eval(self) 
          end
        end
      end

      @nodes.flatten.select {|n| [TPPlus::Nodes::DefinitionNode, TPPlus::Nodes::PoseNode, TPPlus::Nodes::FunctionNode, TPPlus::Nodes::NamespaceNode, TPPlus::Nodes::UsingNode].include? n.class }.each do |node|
        @nd = node
        node.eval(self)
      end
    end

    def reopen!(block, vars={}, funcs = {}, nspaces = {}, imports = [])
      @nodes = block
      #merge imports in
      @imports += imports
      define!(vars, funcs, nspaces)
    end

    def add_constant(identifier, node)
      return unless @constants[identifier.to_sym].nil?

      @constants[identifier.to_sym] = node
    end

    def add_var(identifier, node, options = {})
      return unless @variables[identifier.to_sym].nil? || identifier == RETURN_NAME

      @variables[identifier.to_sym] = node
      if options[:inlined]
        node.comment = "#{identifier}"
      else
        node.comment = "#{@name}_#{identifier}"
      end
    end

    def add_parent_nodes(parent, variables)
      variables.each do |k,v|
        if v.is_a?(Nodes::RegNode)
          parent.add_var(k, v)
        elsif v.is_a?(Nodes::ConstNode)
          parent.add_constant(k, v)
        end
      end

      parent
    end

    def add_shared_vars(parent)

      if defined?($shared)
        $shared.pack.each do |_,s|
          if s.stack[0].any?
            s.stack[0].each do |k, v|
              case s.type
                when "R"
                  parent.add_var(k, TPPlus::Nodes::NumregNode.new(v))
                when "PR"
                  parent.add_var(k, TPPlus::Nodes::PosregNode.new(v))
                when "VR"
                  parent.add_var(k, TPPlus::Nodes::VisionRegisterNode.new(v))
                when "SR"
                  parent.add_var(k, TPPlus::Nodes::StringRegisterNode.new(v))
                else
                  parent.add_var(k, TPPlus::Nodes::IONode.new(s.type, v))
              end
            end
          end
        end
      end

    end

    def add_namespaces(parent, nspaces)

      if nspaces.any?
        nspaces.each do |k,v|
          if v.is_a?(Namespace)
            if @imports.include?(k.to_s)
              parent.append_namespace(k, v)
            else
              parent.add_namespace(k, v.nodes)
            end
          end
        end
      end
    end

    def add_functions(parent, funcs)
      if funcs.any?
        parent.merge_functions(funcs)
      end
    end

    def add_function(name, args, block, ret_type = '', inlined = false)
      identifier = @name + '_' + name

      pass_nodes = get_parent_imports(block)
      pass_nodes[:vars] = pass_nodes[:vars].merge(@variables)
      pass_nodes[:vars] = pass_nodes[:vars].merge(@constants)
      pass_nodes[:namespaces] = pass_nodes[:namespaces].merge(@namespaces)
      pass_nodes[:funcs] = pass_nodes[:funcs].merge(@functions)
      
      if @functions[name.to_sym].nil?
        @functions[name.to_sym] = TPPlus::Function.new(identifier, args, block, ret_type=ret_type, vars=pass_nodes[:vars], funcs=pass_nodes[:funcs], nspaces=pass_nodes[:namespaces], environment=@environment, imports = @imports, inlined=inlined)
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

    def eval
      #use to evaluate imports
      @nodes.flatten.select {|n| [TPPlus::Nodes::DefinitionNode, TPPlus::Nodes::PoseNode, TPPlus::Nodes::NamespaceNode].include? n.class }.each do |node|
        @nd = node
        node.eval(self)
      end
    end

  end
end
