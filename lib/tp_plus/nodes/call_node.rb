module TPPlus
  module Nodes
    class CallNode < BaseNode
      attr_reader :args
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

      def args_string(context)
        #look for a return arguement. This will be appened to the arguement
        #list as an address
        arg = "" 

        if @ret then
          v =  context.get_var(@ret.identifier)
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
          if context.functions[@program_name.to_sym]
            if context.functions[@program_name.to_sym].inlined

              #copy function so as not to overwrite the original
              func = DeepClone.clone(context.functions[@program_name.to_sym])
              
              #copy args
              args = @args.clone
              args.append(@ret)

              #pass arguement registers into function scope
              args.each do |a|
                func.add_var(a.identifier, context.get_var(a.identifier))
              end

              return func.inline(args)
            end
          end

          return "#{async? ? "RUN" : "CALL"} #{@program_name.upcase}#{args_string(context)}"
        end

        nil
      end
    end
  end
end
