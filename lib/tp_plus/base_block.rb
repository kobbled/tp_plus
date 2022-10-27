module TPPlus
    class BaseBlock
      attr_accessor :line_count, :nodes, :ret_type, :position_data, :pose_list, :functions
      attr_reader :variables, :constants, :namespaces

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

        @pose_list = Motion::Factory::Pose.new
      end

      def load_environment(string)
        # if string is a file name, get the contents of the file
        # otherwise assume the string is the contents
        if string.match('((?:[^/]*/)*)(.tpp)')
          file = contents(string)
        else
          file = string
        end

        if self.is_a?(Function)
          eval
        else
          scanner = TPPlus::Scanner.new
          parser = TPPlus::Parser.new(scanner, self)
          scanner.scan_setup(file)
          parser.parse
          eval
        end
      rescue RuntimeError => e
        raise "Runtime error in environment on line #{@source_line_count}:\n#{e}"
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

        scanner.scan_setup(file)

        parser.parse
        # eval
        
        #restore global function_print status
        $global_options[:function_print] = swap_flag

        return interpreter.nodes
      rescue RuntimeError => e
        raise "Could not load import #{filepath}:\n#{e}"
      end

      def get_parent_imports(nodes)
        parent_nodes = {}
        nodes.each do |n|
          if n.is_a?(TPPlus::Nodes::UsingNode)
            n.mods.each do |m|
              if m == "env"
                next
              elsif get_namespace(m)
                parent_nodes[m.to_sym] = get_namespace(m)
              elsif get_function(m)
                parent_nodes[m.to_sym] = get_function(m)
              elsif get_var_or_const(m)
                parent_nodes[m.to_sym] = get_var_or_const(m)
              end
            end
          end
        end

        parent_nodes
      end
      
      def add_namespace(identifier, block)
        pass_nodes = get_parent_imports(block)

        if @namespaces[identifier.to_sym].nil?
          name = @name.empty? ? "#{identifier}" : "#{@name}_#{identifier}"
          @namespaces[identifier.to_sym] = TPPlus::Namespace.new(name, block, vars=pass_nodes)
        else
          @namespaces[identifier.to_sym].reopen!(block)
        end
      end

      def add_function(name, args, block, ret_type = '', inlined = false)
        pass_nodes = get_parent_imports(block)

        if @functions[name.to_sym].nil?
          @functions[name.to_sym] = TPPlus::Function.new(name, args, block, ret_type=ret_type, vars=pass_nodes, inlined=inlined)
          @functions[name.to_sym].eval
        end
      end

      def add_constant(identifier, node)
        return if @constants[identifier.to_sym]
  
        @constants[identifier.to_sym] = node
      end

      def add_var(identifier, node)
        return if @variables[identifier.to_sym]
  
        @variables[identifier.to_sym] = node
        node.comment = identifier
      end
  
      def get_constant(identifier)
        raise "Constant (#{identifier}) not defined" if @constants[identifier.to_sym].nil?
  
        @constants[identifier.to_sym]
      end
  
      def get_var(identifier)
        raise "Variable (#{identifier}) not defined" if @variables[identifier.to_sym].nil?
  
        @variables[identifier.to_sym]
      end

      def get_var_or_const(identifier)
        raise "Variable (#{identifier}) not defined" if @variables[identifier.to_sym].nil? && @constants[identifier.to_sym].nil?
        
        if @variables[identifier.to_sym]
          return @variables[identifier.to_sym]
        end

        return @constants[identifier.to_sym]
      end

      def check_constant(identifier)
        return false if @constants[identifier.to_sym].nil?
  
        true
      end
  
      def check_var(identifier)
        return false if @variables[identifier.to_sym].nil?
  
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

      def traverse_nodes(nodes, lambda)
        if nodes.is_a?(Array)
          nodes.each_with_index do |n, index|
            #loop statements
            if n.is_a?(Nodes::RecursiveNode)
              traverse_nodes(n.get_block, lambda)
            end
    
            #if statements
            if n.is_a?(Nodes::ConditionalNode)
              traverse_nodes(n.get_true_block, lambda)
              traverse_nodes(n.get_elsif_block, lambda)
              traverse_nodes(n.get_false_block, lambda)
            end
    
            #case statments
            if n.is_a?(Nodes::CaseNode)
              traverse_nodes(n.get_conditions, lambda)
            end

            #namespace
            if n.is_a?(Nodes::NamespaceNode)
              n.eval(self)
            end

            #imports
            if n.is_a?(Nodes::ImportNode)
              import_nodes = n.eval(self)
              import_nodes.each do |n_import|
                traverse_nodes(n_import, lambda)
              end
            end

            #look through expressions to find functions
            if n.is_a?(Nodes::AssignmentNode)
              traverse_nodes([n.assignable], lambda)
            end

            if n.is_a?(Nodes::ExpressionNode)
              traverse_nodes([n.left_op, n.right_op], lambda) if n.contains_expression?
            end

            if n.is_a?(TPPlus::Nodes::CallNode)
              if n.args_contain_calls
                args = n.args.select {|a| a.is_a?(TPPlus::Nodes::ExpressionNode) }
                
                traverse_nodes(args, lambda)
              end
            end
            
            #run lambda function
            lambda.call(n, index, nodes)
          end
        end
  
      end

      def eval
        pass
      end

    end
end