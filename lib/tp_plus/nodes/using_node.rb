module TPPlus
  module Nodes
    class UsingNode < BaseNode
      def initialize(mods)
        @mods = mods
      end

      def eval(context)
        @mods.each do |m|
          #if m.match("((?:[^/]*/)*)(env)(/*)")
          if m == "env"
            context.load_environment($global_options[:environment])
          else
            raise "need to implement importing another file"
          end
        end
      end
      
    end
  end
end
