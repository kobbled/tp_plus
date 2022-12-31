require 'ppr'

module TPPlus
    Struct.new("Dummy", :variables, :constants)
    
    class BaseBlock
      attr_accessor :line_count, :nodes, :ret_type, :position_data, :pose_list, :functions, :environment, :ppr
      attr_reader :variables, :constants, :namespaces, :name

      def initialize
        @name          = ''
        @nodes         = []
        @namespaces    = {}
        @functions     = {}
        @variables     = {}
        @constants     = {}
        @ret_type      = {}
        @position_data = {}
        @line_count    = 0
        @imports = []
        #need to set :variables, and :constants members for when
        #an environment file is not used. (see `get_const`, `get_var`)
        @environment = Struct::Dummy.new({}, {})
        #dummy preprocessor for when it is not initialized
        @ppr = Ppr::Preprocessor.new()

        @pose_list = Motion::Factory::Pose.new
      end

      def load_preprocessor(ppr)
        @ppr = ppr
      end

      def load_environment(string)
        # if string is a file name, get the contents of the file
        # otherwise assume the string is the contents
        if string.match('((?:[^/]*/)*)(.tpp)')
          file = contents(string)
        else
          file = string
        end

        scanner = TPPlus::Scanner.new
        parser = TPPlus::Parser.new(scanner)

        #preprocess main file
        ppr_file = ""
        @ppr.preprocess(file,ppr_file)
        # ***** end preproccessor *******

        scanner.scan_setup(ppr_file)
        parser.parse
        #evaluate environment
        @environment = parser.interpreter
        @environment.environment_file?
        @environment.eval

        #merge namespaces into main scope. These need to be passed
        #into scope of namespaces, or functions
        merge_namespaces(@environment.namespaces)
        
      rescue RuntimeError => e
        raise "Runtime error in environment on line #{@source_line_count}:\n#{e}"
      end

      def environment_file?
        @env_flg = true
      end

      def load_import(filepath, compileTF)
        #get contents of file
        file = contents(filepath)
        
        #turn off function_print flag. This gets taged in each function
        #constructor as whether or not to print the function
        swap_flag = $global_options[:function_print]
        $global_options[:function_print] = compileTF
        
        scanner = TPPlus::Scanner.new
        parser = TPPlus::Parser.new(scanner)
        interpreter = parser.interpreter
        
        #preprocess main file
        ppr_file = ""
        @ppr.preprocess(file,ppr_file)
        # ***** end preproccessor *******

        #pass preprocessor into interpeter
        interpreter.load_preprocessor(@ppr)
      
        scanner.scan_setup(ppr_file)

        parser.parse
        # eval
        
        #restore global function_print status
        $global_options[:function_print] = swap_flag

        return interpreter.nodes
      rescue RuntimeError => e
        raise "Could not load import #{filepath}:\n#{e}"
      end

      def get_parent_imports(nodes)
        parent_nodes = {:vars => {}, :funcs => {}, :namespaces => {}}
        nodes.each do |n|
          if n.is_a?(TPPlus::Nodes::UsingNode)
            n.mods.each do |m|
              if m == "env"
                next
              elsif get_namespace(m)
                @imports << m
                parent_nodes[:namespaces][m.to_sym] = get_namespace(m)
              elsif get_function(m)
                parent_nodes[:funcs][m.to_sym] = get_function(m)
              elsif get_var_or_const(m)
                parent_nodes[:vars][m.to_sym] = get_var_or_const(m)
              end
            end
          end
        end
        parent_nodes
      end
      
      def add_namespace(identifier, block)
        pass_nodes = get_parent_imports(block)

        if @namespaces[identifier.to_sym].nil? && !@imports.include?(identifier.to_s)
          name = @name.empty? ? "#{identifier}" : "#{@name}_#{identifier}"
          @namespaces[identifier.to_sym] = TPPlus::Namespace.new(name, block, vars=pass_nodes[:vars], funcs=pass_nodes[:funcs], nspaces=pass_nodes[:namespaces], environment = @environment, imports = @imports)
        else
          @namespaces[identifier.to_sym].environment = @environment
          @namespaces[identifier.to_sym].reopen!(block, vars=pass_nodes[:vars], funcs=pass_nodes[:funcs], nspaces=pass_nodes[:namespaces], imports = @imports)
        end
      end

      def add_function(name, args, block, ret_type = '', inlined = false)
        pass_nodes = get_parent_imports(block)

        if @functions[name.to_sym].nil?
          @functions[name.to_sym] = TPPlus::Function.new(name, args, block, ret_type=ret_type, vars=pass_nodes[:vars], funcs=pass_nodes[:funcs], nspaces=pass_nodes[:namespaces], environment = @environment, imports = @imports, inlined=inlined)
          @functions[name.to_sym].eval
        end
      end

      def append_namespace(key, namespace)
        @namespaces[key] = namespace
      end

      def merge_functions(funcs)
        @functions = @functions.merge!(funcs)
      end

      def merge_namespaces(namespaces)
        @namespaces = @namespaces.merge!(namespaces)
      end

      def merge_constants(consts)
        @constants = @constants.merge!(consts)
      end

      def merge_vars(vars)
        @variables = @variables.merge!(vars)
      end

      def add_constant(identifier, node)
        return if @constants[identifier.to_sym]
  
        @constants[identifier.to_sym] = node
      end

      def add_var(identifier, node, options = {})
        return if @variables[identifier.to_sym]
  
        @variables[identifier.to_sym] = node
        node.comment = identifier
      end
  
      def get_constant(identifier)
        raise "Constant (#{identifier}) not defined" if @constants[identifier.to_sym].nil? && @environment.constants[identifier.to_sym].nil?
  
        @constants[identifier.to_sym] || @environment.constants[identifier.to_sym]
      end
  
      def get_var(identifier)
        raise "Variable (#{identifier}) not defined" if @variables[identifier.to_sym].nil? && @environment.variables[identifier.to_sym].nil?
  
        @variables[identifier.to_sym] || @environment.variables[identifier.to_sym]
      end

      def get_var_or_const(identifier)
        raise "Variable (#{identifier}) not defined" if (@variables[identifier.to_sym].nil? && @environment.variables[identifier.to_sym].nil?) && (@constants[identifier.to_sym].nil? && @environment.constants[identifier.to_sym].nil?)
        
        if @variables[identifier.to_sym]
          return @variables[identifier.to_sym]
        elsif @environment.variables[identifier.to_sym]
          return @environment.variables[identifier.to_sym]
        elsif @constants[identifier.to_sym]
          return @constants[identifier.to_sym]
        else
          @environment.constants[identifier.to_sym]
        end
      end

      def check_constant(identifier)
        return false if @constants[identifier.to_sym].nil? && @environment.constants[identifier.to_sym].nil?
  
        true
      end
  
      def check_var(identifier)
        return false if @variables[identifier.to_sym].nil? && @environment.variables[identifier.to_sym].nil?
  
        true
      end
  
      def get_namespace(identifier)
        if ns = @namespaces[identifier.to_sym]
          return ns
        end
  
        false
      end

      def get_function(identifier)
        if df = @functions[identifier.to_sym]
          return df
        end
  
        false
      end

      def add_pose(node)
        if node.assignable.is_a?(Nodes::PositionNode)
          @pose_list.add(node.identifier.to_sym, node.get_number)
        end
      end

      def traverse_nodes(nodes, lambda, options = {})
        if nodes.is_a?(Array)
          nodes.each_with_index do |n, index|
            #loop statements
            if n.is_a?(Nodes::RecursiveNode)
              traverse_nodes(n.block, lambda, options)
              #recursive/condition nodes
              traverse_nodes(n.condition, lambda, options)
            end
    
            #if statements
            if n.is_a?(Nodes::ConditionalNode)
              traverse_nodes(n.get_true_block, lambda, options)
              traverse_nodes(n.get_elsif_block, lambda, options)
              traverse_nodes(n.get_false_block, lambda, options)
            end
    
            #case statments
            if n.is_a?(Nodes::CaseNode)
              traverse_nodes(n.conditions, lambda, options)
              traverse_nodes(n.else_condition, lambda, options)
            end

            #namespace
            if n.is_a?(Nodes::NamespaceNode)
              n.eval(self)
            end

            #imports
            if n.is_a?(Nodes::ImportNode)
              import_nodes = n.eval(self)
              import_nodes.each do |n_import|
                traverse_nodes(n_import, lambda, options)
              end
            end

            #look through expressions to find functions
            if n.is_a?(Nodes::AssignmentNode)
              n.assignable.set_contained(true) if n.assignable.is_a?(TPPlus::Nodes::CallNode)
              
              traverse_nodes([n.assignable], lambda, options)
            end
            
            if n.instance_of?(Nodes::ParenExpressionNode)
              traverse_nodes([n.x], lambda, options)
              
              #copy ret_var to parens expression
              if n.x.respond_to?(:ret_var)
                n.ret_var = n.x.ret_var if n.x.ret_var
              end
            end

            if n.is_a?(Nodes::ExpressionNode)
              n.left_op.is_a?(Nodes::ParenExpressionNode) ? left = n.left_op.x : left = n.left_op
              n.right_op.is_a?(Nodes::ParenExpressionNode) ? right = n.right_op.x : right = n.right_op
              
              left.set_contained(true) if left.is_a?(TPPlus::Nodes::CallNode)
              right.set_contained(true) if right.is_a?(TPPlus::Nodes::CallNode)

              traverse_nodes([left, right], lambda, options) if n.contains_expression?
            end

            if n.is_a?(TPPlus::Nodes::CallNode)
              # if n.args_contain_calls
              #   args = n.args.select {|a| [TPPlus::Nodes::ExpressionNode, Nodes::ParenExpressionNode].include? a.class }
              #   traverse_nodes(args, lambda, options)
              # end

              traverse_nodes(n.args, lambda, options)
            end

            if n.is_a?(TPPlus::Nodes::FunctionReturnNode)
              traverse_nodes([n.expression], lambda, options)
            end
            
            #run lambda function
            case lambda
            when :mask_var_nodes
              method(lambda).call(n, index, nodes, options)
            else
              method(lambda).call(n, index, nodes)
            end
          end
        end
  
      end

      def eval
        pass
      end

    end
end