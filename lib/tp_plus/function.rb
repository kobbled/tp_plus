module TPPlus
  class Function < Namespace
    attr_reader :inlined

    def initialize(name, args, block, ret_type = '', vars = {}, inlined = false)
      super(name, block)

      @args       = args
      #passing by ref will expose local scope of the function to global
      @variables = vars.clone
      @current_arg = 0
      @ret_type = ret_type
      @ret_register = {}
      @print_status = $global_options[:function_print]
      @inlined = inlined
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

      # copy variables & constants to interpreter
      add_parent_nodes(interpreter)

      interpreter.nodes = @nodes
    end
    
    #for appending created nodes into the ast
    def append_node(node)
      @nodes.append(node)
    end

    def set_arguement_registers
      if !@args
        @current_arg = 0
        @args = []
      end

      @ret_register = TPPlus::Nodes::FunctionVarNode.new(RETURN_NAME)
      #add to total arguements to be pushed to the interpreter variables
      if @args.select {|a|  a.name == RETURN_NAME}.empty?
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

    def mask_var_nodes(nodes, map)
      if nodes.is_a?(Array)
        nodes.each_with_index do |n, i|
          if n.is_a?(Nodes::VarNode)
            if map[n.identifier]
              if nodes.is_a?(Nodes::IndirectNode)
                nodes.instance_variable_set(:@target, map[n.identifier])
              else
                nodes[i] = map[n.identifier]
              end
            end
            next
          end

          if n.is_a?(Nodes::FunctionReturnNode)
            nodes[i] = TPPlus::Nodes::AssignmentNode.new(map["ret"], n.expression)
            mask_var_nodes(n, map)
            next
          end

          if n.is_a?(Array) || n.is_a?(Nodes::BaseNode)
            mask_var_nodes(n, map)
            next
          end
        end
      end

      if nodes.is_a?(Nodes::BaseNode)
        nodes.get_attributes.each do |id, n|
          if n.is_a?(Nodes::VarNode)
            if map[n.identifier]
              nodes.instance_variable_set(id, map[n.identifier])
            end
            next
          end

          if n.is_a?(Array) || n.is_a?(Nodes::BaseNode)
            mask_var_nodes(n, map)
            next
          end
        end
      end


    end

    def inline(args, parent)
      #local variable
      interpreter = @parser.interpreter.clone
      #set start label from the last parent label
      interpreter.current_label = parent.current_label + 1
      #pass data between function, and interpreter
      interpreter.set_function_methods(self)

      #pass @variables into the interpreter.
      #need to do this again as CallNode may add more variables
      #like the call arguements into the function variables
      add_parent_nodes(interpreter) 


      #map call node arguments to the function variables
      #for inlining into the main function
      map = {}
      @args.each_with_index do |a, i|
        map[a.name] = args[i]
      end

      #replace var nodes and return nodes with associated
      #arguement nodes
      mask_var_nodes(interpreter.nodes, map)

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

      lines = interpreter.eval

      #list warning messages
      lines += interpreter.list_warnings

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

      lines.each_line do |line|
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