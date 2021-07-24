module TPPlus
  module Nodes
    class CallNode < BaseNode
      attr_reader :args
      def initialize(program_name, args, options={})
        @program_name = program_name
        @args = args
        @async = options[:async]
        @ret = options[:ret]
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
        if @ret then arg = ",#{context.get_var(@ret.identifier).id.to_s}" else arg = "" end

        return "" unless @args.any?

        "(" + @args.map {|a| a.eval(context) }.join(",") + arg + ")"
      end

      def can_be_inlined?
        true
      end

      def eval(context,options={})
        "#{async? ? "RUN" : "CALL"} #{@program_name.upcase}#{args_string(context)}"
      end
    end
  end
end
