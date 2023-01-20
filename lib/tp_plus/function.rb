module TPPlus
  class Function < Namespace
    attr_reader :inlined, :nodes, :name, :interpretted, :lines, :args
    attr_accessor :level

    def initialize(name, args, block, ret_type = '', vars = {}, funcs = {}, nspaces = {}, environment = {}, imports = [], inlined = false)
      super(name, block, vars, funcs, nspaces, environment, imports)

      @args       = args
      @current_arg = 0
      @ret_type = ret_type
      @ret_register = {}
      @print_status = $global_options[:function_print]
      @inlined = inlined
      @level = 0
      @interpretted = false
    end

    def eval
      scanner = TPPlus::Scanner.new
      @parser = TPPlus::Parser.new(scanner)
      
      #raise error if return type or return statements are missing
      if !return? && (!@ret_type)
        raise "function #{@name} requires both a return type and a return statement"
      end
      #create parameter AR's
      set_arguement_registers

      interpreter = @parser.interpreter

      interpreter.nodes = @nodes

      # copy variables & constants to interpreter
      add_parent_nodes(interpreter, @variables)
      add_parent_nodes(interpreter, @constants)
      #copy namespaces to interpreter
      add_namespaces(interpreter, @namespaces)
      #copy namespaces to interpreter
      add_functions(interpreter, @functions)
      #pass environment
      interpreter.environment = @environment

    end
    
    #for appending created nodes into the ast
    def append_node(node)
      @nodes.append(node)
    end

    def define_local_vars()
      @nodes.each_with_index do |n, index|
        if n.is_a?(TPPlus::Nodes::RegDefinitionNode)
          if n.range.is_a?(TPPlus::Nodes::LocalDefinitionNode)
            @nodes[index] = n.eval(self) 
          end
        end
      end

      @nodes = @nodes.flatten
    end

    def set_arguement_registers
      if !@args
        @current_arg = 0
        @args = []
      end

      @ret_register = TPPlus::Nodes::FunctionVarNode.new(RETURN_NAME)
      #add to total arguements to be pushed to the interpreter variables
      if !@args.include?(@ret_register)
        @args.append(@ret_register)
      end

      @args.each do |a|
        a.eval(self)
      end
    end

    def next_arg
      @current_arg += 1
      return @current_arg
    end

    def return?
      @nodes.flatten.select {|n|  n.is_a?(Nodes::FunctionReturnNode)}.each do |n|
        return true
      end
      false
    end

    def mask_var_nodes(n, index, nodes, options)
      if n.is_a?(Nodes::VarNode)
        if options[:map][n.identifier]
          if n.is_a?(Nodes::IndirectNode)
            n.instance_variable_set(:@target, options[:map][n.identifier])
          else
            nodes[index] = options[:map][n.identifier]
          end
        end
      end

      if n.is_a?(Nodes::AssignmentNode)
        if n.identifier.is_a?(Nodes::IndirectNode)
          unless n.identifier.target.is_a?(Nodes::AddressNode)
            if options[:map][n.identifier.target.identifier]
              nodes[index].identifier.instance_variable_set(:@target, options[:map][n.identifier.target.identifier])
            end
          end
        else
          if options[:map][n.identifier]
            nodes[index] = options[:map][n.identifier]
          end
        end
      end

      if n.is_a?(Nodes::FunctionReturnNode)
        nodes[index] = TPPlus::Nodes::AssignmentNode.new(options[:map]["ret"], n.expression)
      end

      if n.is_a?(Nodes::BaseNode)
        n.get_attributes.each do |id, nde|
          if nde.is_a?(Nodes::VarNode)
            if options[:map][nde.identifier]
              nodes[index].instance_variable_set(id, options[:map][nde.identifier])
            end
          end
        end
      end

    end

    def interpret(context)
      #local variable
        # without clone, environment file gets exported
        # on `inline` functions.
      interpreter = @parser.interpreter.clone
      #pass data between function, and interpreter
      interpreter.set_function_methods(self)
      #pass environment
      interpreter.environment = @environment

      @lines = interpreter.eval

      @variables = interpreter.variables

      @interpretted = true
    end

    def preinline(callnode, parent)

      #map call node arguments to the function variables
      #for inlining into the main function
      map = {}
      args = callnode.args.clone
      args.append(callnode.ret)

      @args.each_with_index do |a, i|
        map[a.name] = args[i]
      end

      #replace var nodes and return nodes with associated
      #arguement nodes
      options = {}

      if self.instance_variable_defined?(:@recurse_map)
        @recurse_map.each do |k, v|
          if v
            if v.is_a?(TPPlus::Nodes::AddressNode)
              map[v.id.identifier] = map[k]
            else
              map[v.identifier] = map[k]
            end
          end
        end
      end

      options[:map] = map

      traverse_nodes(self.nodes, :mask_var_nodes, options)

      #check if callnodes in function are also inlined
      @recurse_map = options[:map]
    end

    def inline(parent)
      #local variable
      interpreter = @parser.interpreter.clone
      # ..IMPORTANT:: needed as interpreter.nodes may be different
      #               from function member @nodes, at this point. Reason
      #               unknown, although def interpret does copy the interpretter
      #               before evaluation???
      interpreter.nodes = @nodes
      #set start label from the last parent label
      interpreter.current_label = parent.current_label
      #renumber labels
      interpreter.renumber_labels
      #pass data between function, and interpreter
      interpreter.set_function_methods(self)

      #pass @variables into the interpreter.
      #need to do this again as CallNode may add more variables
      #like the call arguements into the function variables
      add_parent_nodes(interpreter, @variables)
      add_parent_nodes(interpreter, @constants)
      #copy namespaces to interpreter
      add_namespaces(interpreter, @namespaces)
      #copy namespaces to interpreter
      add_functions(interpreter, @functions)
      #pass environment
      interpreter.environment = @environment


      lines = interpreter.eval

      #list warning messages
      lines += interpreter.list_warnings

      #pass back to parent interpreter what label number we left off on
      parent.current_label = interpreter.current_label

      #prepend with a comment stating inlined function
      lines = "! inline #{@name} ;\n" + lines + "! end #{@name} ;\n"

      lines
    end

    def output_program(prog_options)
      #if function is inlined dont output
      return "" if @inlined

      #local variable
      interpreter = @parser.interpreter
      #pass data between function, and interpreter
      interpreter.set_function_methods(self)

      if !defined?(@lines)
        @lines = interpreter.eval
      end

      #list warning messages
      @lines += interpreter.list_warnings

      return output = "" if !@print_status

      if prog_options[:output]
        output = %(/PROG #{@name.upcase}
/ATTR
COMMENT = "#{interpreter.header_data[:comment] || @name.upcase}";
TCD:  STACK_SIZE	= 0,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= #{interpreter.header_data[:ignore_pause] ? "7" : "0"};
DEFAULT_GROUP = #{interpreter.header_data[:group_mask] || "*,*,*,*,*"};
/MN\n)
      else
        output = ": ! ------- ;\n"
        output += ": ! "+ @name + " ;\n"
        output += ": ! ------- ;\n"
      end

      @lines.each_line do |line|
        output += " : " + line
      end

      if (self.pose_list.poses.length > 0)
        output += "/POS\n"
        output += self.pose_list.eval
      end

      if prog_options[:output]
        output += %(/END\n)
      else
        output += ": ! end of " + @name + " ;\n"
        output += ": ! ------- ;\n"
      end

      if prog_options[:output]
        filname = prog_options[:output_folder] +'/' + @name + '.ls'
        File.write(filname, output)
        return ""
      else
        return output
      end
    end

    def contents(filename)
      if !File.exist?(filename)
        puts "File <#{filename}> does not exist"
        exit
      end
      f = File.open(filename,'rb')
      src = f.read
      f.close
      return src
    end
  end
end