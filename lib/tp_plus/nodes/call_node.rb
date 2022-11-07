module TPPlus
  module Nodes
    class CallNode < BaseNode
      attr_reader :args, :program_name, :ret_args, :func_args, :ret, :arg_exp, :contained
      def initialize(program_name, args, options={})
        @program_name = program_name
        @args = args
        @async = options[:async]
        @ret = options[:ret]
        @str_var = options[:str_call]
        @ret_args = []
        @func_args = {}
        @arg_exp = []
        @contained = false

        handle_arg_funcs
      end

      def requires_mixed_logic?(context)
        false
      end

      def async?
        @async
      end

      def set_return(ret)
        @ret = ret
      end

      def set_contained(cont)
        @contained = cont
      end

      def handle_arg_funcs
        @args.each do |a|
          if a.is_a?(CallNode)
            #create local variable
            $dvar_counter += 1
            name = "dvar#{$dvar_counter}"
            a.set_return(VarNode.new(name))

            @func_args[a.program_name.to_sym] = a
            @ret_args << RegDefinitionNode.new(name, LocalDefinitionNode.new('LR', name))
          end

          if a.is_a?(ExpressionNode)
            #create local variable
            $dvar_counter += 1
            name = "dvar#{$dvar_counter}"
            
            # create assignment node with expression
            @arg_exp << TPPlus::Nodes::AssignmentNode.new(VarNode.new(name), a)

            #add local variable to list
            @ret_args << RegDefinitionNode.new(name, LocalDefinitionNode.new('LR', name))
          end
        end
      end

      def args_contain_calls
        @func_args.any? || @arg_exp.any?
      end

      def args_string(context)
        #look for a return arguement. This will be appened to the arguement
        #list as an address
        arg = "" 

        if @ret then
          if @ret.is_a?(Nodes::NamespacedVarNode)
            v =  context.namespaces[@ret.namespaces[0].to_sym].get_var(@ret.identifier)
          elsif @ret.is_a?(Nodes::IndirectNode)
            v = @ret
          else
            v =  context.get_var(@ret.identifier)
          end

          if v.is_a?(PosregNode)
            if @ret.is_a?(VarMethodNode) && @ret.method[:group].is_a?(DigitNode)
              arg = ",#{@ret.method[:group].value.to_s}"
            end
          end

          arg = "#{v.id.to_s}" + arg
        end

        return "" unless @args.any? || arg.length > 0

        arg = "," + arg if @args.any? && @ret

        "(" + @args.map {|a| a.eval(context) }.join(",") + arg + ")"
      end

      def can_be_inlined?
        true
      end

      def eval(context,options={})
        if @str_var
          @program_name = @str_var.eval(context)

          return "#{async? ? "RUN" : "CALL"} #{@program_name}#{args_string(context)}"
        else
          #check if inline function exists
            #split underscor to check for namespace
          name = @program_name.split('_', 2)
          
          #search for functions in interpreter space
          func = context.functions[@program_name.to_sym]
          if name.length > 1
            #search for functions in namespaces
            context.namespaces.each do |k, v|
              if v.functions.key?(name[1].to_sym)
                func = v.functions[name[1].to_sym]
                break
              end
            end
          end

          if func
            if func.inlined
              
              #copy args
              args = @args.clone
              args.append(@ret)
              
              options[:inlined] = true
              #pass arguement registers into function scope
              args.each do |a|
                if a.is_a?(Nodes::VarNode) || a.is_a?(Nodes::VarMethodNode)
                  var = context.get_var_or_const(a.identifier)
                  if var.is_a?(Nodes::ConstNode)
                    func.add_constant(a.identifier, var)
                  else
                    func.add_var(a.identifier, var, options)
                  end
                elsif a.is_a?(Nodes::AddressNode)
                  if a.id.is_a?(Nodes::NamespacedVarNode)
                    var = context.namespaces[a.id.namespaces[0].to_sym].get_var_or_const(a.id.identifier)
                    if var.is_a?(Nodes::ConstNode)
                      func.add_constant(a.id.identifier, var)
                    else
                      func.add_var(a.id.identifier, var, options)
                    end
                  else
                    var = context.get_var_or_const(a.id.identifier)
                    if var.is_a?(Nodes::ConstNode)
                      func.add_constant(a.id.identifier, var)
                    else
                      func.add_var(a.id.identifier, var, options)
                    end
                  end
                end
              end

              #increment number of inlines
              context.number_of_inlines += 1

              func.preinline(self, context)
              return func.inline(context)
            end
          end

          return "#{async? ? "RUN" : "CALL"} #{@program_name.upcase}#{args_string(context)}"
        end

        nil
      end
    end
  end
end
