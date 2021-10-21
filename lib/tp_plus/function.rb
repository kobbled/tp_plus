module TPPlus
  class Function < Namespace
    def initialize(name, args, block, ret_type = '', vars = {}, consts = {})

      super(name, block)

      @args       = args
      #passing by ref will expose local scope of the function to global
      @variables  = vars.clone
      @constants  = consts.clone
      @current_arg = 0
      @ret_type = ret_type
      @ret_register = {}
    end

    RETURN_NAME = 'ret'

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
      @variables.each do |k,v|
        interpreter.add_var(k, v)
      end
      @constants.each do |k,v|
        interpreter.add_constant(k, v)
      end

      interpreter.nodes = @nodes
    end
    
    #for appending created nodes into the ast
    def append_node(node)
      @nodes.append(node)
    end

    def set_arguement_registers
      if return?
        @ret_register = TPPlus::Nodes::FunctionVarNode.new(RETURN_NAME)
        #add to total arguements to be pushed to the interpreter variables
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

    def output_program(prog_options)
      #local variable
      interpreter = @parser.interpreter
      #pass data between function, and interpreter
      interpreter.set_function_methods(self)

      lines = interpreter.eval

      #list warning messages
      lines += interpreter.list_warnings

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

      if interpreter.pos_section != ""
        output += "/POS\n"
        output += interpreter.pos_section
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