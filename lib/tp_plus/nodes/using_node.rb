module TPPlus
  module Nodes
    class UsingNode < BaseNode
      attr_accessor :mods
      def initialize(mods)
        @mods = mods
      end

      def eval(context)
        @mods.each do |m|
          #if m.match("((?:[^/]*/)*)(env)(/*)")
          if m == "env"
            context.load_environment($global_options[:environment])
          end
        end

        nil
      end
      
    end
  end
end
