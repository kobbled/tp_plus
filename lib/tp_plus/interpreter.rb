require_relative 'parser'

module TPPlus
  class Interpreter < BaseBlock
    attr_accessor :line_count, :header_data, :header_appl_data, :number_of_inlines, :current_label
    attr_reader :labels, :source_line_count, :variables
    def initialize
      super
      
      @line_count    = 0
      @source_line_count = 0
      @header_data   = {}
      @header_appl_data   = []
      @labels        = {}
      @current_label = 99
      @case_identifiers = 0
      @warning_identifiers = 0
      @number_of_inlines = 0
      
      @namespace_functions = []
    end

    def next_label
      @current_label += 1
    end

    def set_function_methods(context)
      @ret_type = context.ret_type
    end

    def add_label(identifier)
      if @labels[identifier.to_sym]
        # [!ISSUE]
        # @current_label in namespace functions does not get
        # updated in manual labels are declared. This is a patch
        # for that case. See test -> `test_labelling_for_namespaced_functions` 
        if @current_label < @labels[identifier.to_sym]
          @current_label = @labels[identifier.to_sym]
        end
      else
        @labels[identifier.to_sym] = next_label
      end
    end

    def renumber_labels
      @labels.each do |k, _|
        @labels[k] = next_label
      end
    end

    def label_recur(nodes, labels)
      if nodes.is_a?(Array)
        nodes.each do |node|
          if node.is_a?(Nodes::LabelDefinitionNode)
            labels << node
          else
              label_recur(node, labels)
          end
        end
      end

      if nodes.is_a?(Nodes::RecursiveNode)
        label_recur(nodes.get_block, labels)
      end

      labels

    end

    def increment_case_labels
      @case_identifiers += 1
      add_label("caselbl#{@case_identifiers}")
    end

    def get_case_label
      "caselbl#{@case_identifiers}"
    end

    def increment_warning_labels
      @warning_identifiers += 1
      add_label("warning#{@warning_identifiers}")
    end

    def get_warning_label
      TPPlus::Nodes::LabelDefinitionNode.new("warning#{@warning_identifiers}")
    end

    def define_labels
      label_nodes = []
      label_recur(@nodes, label_nodes).each do |n|
        add_label(n.identifier)
      end
    end

    def find_warnings(nodes, warnings)
      if nodes.is_a?(Array)
        nodes.each do |node|
          if node.is_a?(Nodes::WarningNode)
            warnings << node
          else
            find_warnings(node, warnings)
          end
        end
      end
      
      #loop statements
      if nodes.is_a?(Nodes::RecursiveNode)
        find_warnings(nodes.get_block, warnings)
      end
      
      #if else statements
      if nodes.is_a?(Nodes::ConditionalNode)
        find_warnings(nodes.get_true_block, warnings)
        find_warnings(nodes.get_elsif_block, warnings)
        find_warnings(nodes.get_false_block, warnings)
      end

      #case statements
      if nodes.is_a?(Nodes::CaseNode)
        find_warnings(nodes.get_conditions, warnings)
      end

      warnings
    end

    def list_warnings
      
      s = ""

      warning_nodes = []
      find_warnings(@nodes, warning_nodes).each do |n|
        s += n.block_eval(self)
      end

      if !s.empty?
        s = ";\n! ******** ;\n! WARNINGS ;\n! ******** ;\n" + s
      end

      s
    end

    def output_functions(options)

      s = ""
      @functions.each do |k, v|
        s += v.output_program(options)
      end
      
      return s
    end

    def set_as_main()
      @name = "main"
      #add as root to global graph
      $graph.addNode(@name)
      $graph.setRoot($graph.graph[@name])
    end

    # Call stack functions
    # ----------------

    def collect_namespace_functions(namespaces)
      namespaces.each do |k, ns|
        unless ns.namespaces.empty?
          collect_namespace_functions(ns.namespaces)
        end
        
        ns.functions.each do |key, func|
          @namespace_functions << func.name.to_sym
          @functions[func.name.to_sym] = func
        end
      end

      return nil
    end

    def create_call_stack(n, index, nodes, options)

      if n.is_a?(TPPlus::Nodes::CallNode)
        return if n.is_a?(TPPlus::Nodes::CallNode) && n.program_name.nil?
        
        prog_name = n.program_name

        $graph.addNode(prog_name)
        $graph.addEdge(options[:parent], $graph.graph[prog_name])
        if @functions.key?(prog_name.to_sym)
          traverse_nodes(@functions[prog_name.to_sym].nodes, :create_call_stack, options.merge({parent: prog_name}))
        end
      end

    end

    def set_call_stack_levels
      #bfs to set the level of the function call
      $graph.setBredthLevels
      @functions.each do |k, f|
        if $graph.graph.key?(k.to_s)
          f.level = $graph.graph[k.to_s].level
        end
      end
    end

    def traverse_call_stack
      call_stack_dfs($graph.root)
    end

    def call_stack_dfs(node)
      unless $stacks.pack.empty?()
        if !node.name.empty?
          $stacks.push_all
          if @functions.key?(node.name.to_sym)
            @functions[node.name.to_sym].define_local_vars()
          end
        end

        node.children.each do |child|
          call_stack_dfs(child)
        end

        $stacks.pop_all
      end
    end


    def preprocess_local_variables(node, index, nodes)
      if node.is_a?(TPPlus::Nodes::ExpressionNode)
        node.ret_var.each do |rv|
          if !@variables.has_key?(rv.range.name.to_sym)
            localnode = rv.eval(self)
            localnode[0].eval(self)
          end
        end

        # replace new local variable with function call
        node.replace_function
      end

      if node.is_a?(TPPlus::Nodes::CallNode)
        if node.args_contain_calls
          node.ret_args.each do |rv|
            localnode = rv.eval(self)
            localnode[0].eval(self)
          end

          # replace args with var nodes
          arg_exp_count = 0
          node.args.each_with_index do |a, i|
            if a.is_a?(TPPlus::Nodes::CallNode)
              node.args[i] = TPPlus::Nodes::VarNode.new(a.ret.identifier)
            end
            if a.is_a?(TPPlus::Nodes::ExpressionNode)
              node.args[i] = node.arg_exp[arg_exp_count].identifier
              arg_exp_count += 1
            end
          end
        end
      end

      # ..IMPORTANT:: This is a special case added, as argument expression
      #               were only considered if a return assignment variable
      #               is set. This is a work around when no return is present.
      if node.is_a?(TPPlus::Nodes::CallNode) && !node.contained
        arg_funcs = []
        TPPlus::Util.retrieve_arg_calls(node, arg_funcs)

        arg_funcs.each do |f|
          nodes[index] = [f, nodes[index]]
        end
      end

      #check if expression expansion is needed for condition nodes & assignment nodes
      if node.is_a?(TPPlus::Nodes::AssignmentNode) || node.is_a?(TPPlus::Nodes::RecursiveNode)
        node.add_expression_expansions
      end

      if node.is_a?(TPPlus::Nodes::FunctionReturnNode)
        ret_exp = []
        TPPlus::Util.retrieve_calls(node.expression, ret_exp)

        ret_exp.each do |f|
          nodes[index] = [f, nodes[index]]
        end

        nodes = nodes.flatten!()
      end

      if [TPPlus::Nodes::RegDefinitionNode, TPPlus::Nodes::StackDefinitionNode].include? node.class
        nodes[index] = node.eval(self)
        if nodes[index].is_a?(Array)
          nodes = nodes.flatten!()
        end
        
        return if nodes[index].nil?
        nodes[index].eval(self)
      end
    end

    def preprocess_functions(node, index, nodes)
      if node.is_a?(TPPlus::Nodes::FunctionNode)
        node.eval(self)
      end
    end

    # ----------------

    # pose functions
    # ----------------

    def pos_section
      return "" if @position_data.empty?
      return "" if @position_data[:positions].empty?

      @position_data[:positions].inject("") do |s,p|
        s << %(P[#{p[:id]}:"#{p[:comment]}"]{\n)

        p[:mask].each do |q|
          s << pos_return(q)
          s << %(\n)
        end

        s << %(};\n)
      end
    end

    def pos_return(position_hash)
      s = ""
      if position_hash[:config].is_a?(Hash)
        s << %(   GP#{position_hash[:group]}:
  UF : #{position_hash[:uframe]}, UT : #{position_hash[:utool]},  CONFIG : '#{position_hash[:config][:flip] ? 'F' : 'N'} #{position_hash[:config][:up] ? 'U' : 'D'} #{position_hash[:config][:top] ? 'T' : 'B'}, #{position_hash[:config][:turn_counts].join(', ')}',
  X = #{position_hash[:components][:x]} mm, Y = #{position_hash[:components][:y]} mm, Z = #{position_hash[:components][:z]} mm,
  W = #{position_hash[:components][:w]} deg, P = #{position_hash[:components][:p]} deg, R = #{position_hash[:components][:r]} deg)
      else
        s << %(   GP#{position_hash[:group]}:
  UF : #{position_hash[:uframe]}, UT : #{position_hash[:utool]})
        if position_hash[:components].is_a?(Hash)
          position_hash[:components].each_with_index do |key|
            if key[1].is_a?(Array)
              s << %(, \n)
              s << %(  #{key[0]} = #{key[1][0]} #{key[1][1]})
            else
              s << %(, \n)
              s << %(  #{key[0]} = #{key[1]} deg)
            end
          end
        end
      end

      return s
    end
    # ----------------

    def eval
      
      # first pass
      #---------
      #set a list of declared positions into @pose_list
      #populate_pose_set
      #create definitions from ranges
      traverse_nodes(@nodes, :preprocess_local_variables)

      # second pass
      #----------
      #prepare/allocate functions
      traverse_nodes(@nodes, :preprocess_functions)

      @nodes = @nodes.flatten

      #collect namespace functions to the interpreter for generating a call stack
      collect_namespace_functions(@namespaces)

      #evaluate functions
      @functions.each do |k, v|
        v.interpret(self) if !v.interpretted
      end

      #create call stack graph
       #only perform on main entry. Not on namespace or function level.
      if !@functions.empty? && !defined?(@env_flg) && @name == "main"
        #set parent to connect nodes in graph
        parent = {}
        parent[:parent] = self.name
        #traverse through syntax tree and create call stack
        #enter into calls function if it exists and evaluate the nodes
        # of that function
        traverse_nodes(@nodes, :create_call_stack, parent)
        set_call_stack_levels()
        traverse_call_stack()
      end

      @nodes = @nodes.flatten.compact

      define_labels

      @source_line_count = 0

      s = ""
      last_node = nil

      @nodes.each do |n|
        @source_line_count += 1 unless n.is_a?(Nodes::TerminatorNode) && !last_node.is_a?(Nodes::TerminatorNode)
        raise if n.is_a?(String)

        #import nodes are imported during precompile (1st pass + 2nd pass) stage
        next if n.nil? || n.is_a?(Nodes::ImportNode)

        res = n.eval(self)
        
        last_node = n unless res.nil?

        # preserve whitespace
        if !last_node.nil?
          if n.is_a?(Nodes::TerminatorNode) && last_node.is_a?(Nodes::TerminatorNode)
            s += " ;\n"
          end
        end

        next if res.nil?

        s += "#{res} ;\n"
      end
      s
    rescue RuntimeError => e
      raise "Runtime error on line #{@source_line_count}:\n#{e}"
    end
  end
end
