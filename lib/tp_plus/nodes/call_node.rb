module TPPlus
  module Nodes
    class CallNode < BaseNode
      attr_reader :args, :program_name
      def initialize(program_name, args, options={})
        @program_name = program_name
        @args = args
        @async = options[:async]
        @ret = options[:ret]
        @str_var = options[:str_call]
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

              #copy function so as not to overwrite the original
              func = DeepClone.clone(func)
              
              #copy args
              args = @args.clone
              args.append(@ret)

              #pass arguement registers into function scope
              args.each do |a|
                if a.is_a?(Nodes::VarNode) || a.is_a?(Nodes::VarMethodNode)
                  func.add_var(a.identifier, context.get_var(a.identifier))
                elsif a.is_a?(Nodes::AddressNode)
                  if a.id.is_a?(Nodes::NamespacedVarNode)
                    func.add_var(a.id.identifier, context.namespaces[a.id.namespaces[0].to_sym].get_var(a.id.identifier))
                  else
                    func.add_var(a.id.identifier, context.get_var(a.id.identifier))
                  end
                end
              end

              #increment number of inlines
              context.number_of_inlines += 1

              return func.inline(args, context)
            end
          end

          return "#{async? ? "RUN" : "CALL"} #{@program_name.upcase}#{args_string(context)}"
        end

        nil
      end
    end
  end
end
