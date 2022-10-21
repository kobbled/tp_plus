module TPPlus
  module Nodes
    class IndirectNode < BaseNode
      def initialize(type, target, method)
        @type   = type
        @target = target
        @method = method || {}
      end

      def requires_mixed_logic?(context)
        return true if @type == :f

        false
      end

      COMPONENTS = {
        "x" => 1,
        "y" => 2,
        "z" => 3,
        "w" => 4,
        "p" => 5,
        "r" => 6,
        "e1" => 7,
        "e2" => 8,
        "e3" => 9
      }

      GROUPS = {
        "gp1" => "GP1",
        "gp2" => "GP2",
        "gp3" => "GP3",
        "gp4" => "GP4",
        "gp5" => "GP5"
      }

      EXP_TYPES = {
        "numreg" => "R",
        "posreg" => "PR",
        "strreg" => "SR",
        "argreg" => "AR"
      }

      def groups(context)
        return "" if context == ""
        "#{GROUPS[context]}:"
      end

      def component(m)
        return "" if m == ""

        ",#{COMPONENTS[m]}"
      end

      def set_type(s)
        if EXP_TYPES[s.to_s]
          return "#{EXP_TYPES[s.to_s]}"
        end
        s
      end

      def component_valid?(c)
        [""].concat(COMPONENTS.keys).include? c
      end

      def component_groups?(c)
        [""].concat(GROUPS.keys).include? c
      end

      def id
        @target.value
      end

      def eval(context,options={})

        @method[:method] ||= ""

        if @method[:group].is_a? DigitNode
          group_string = GROUPS["gp" + @method[:group].eval(context).to_s] + ":" if @method[:group]
        else
          group_string = GROUPS[@method[:group]] + ":" if @method[:group]
        end
        
        s = "#{set_type(@type).upcase}[#{group_string}#{@target.eval(context)}#{component(@method[:method])}]"
        if options[:opposite]
          s = "!#{s}"
        end
        if options[:as_condition]
          s = "(#{s})"
        end
        if options[:disable_mixed_logic]
          s = "#{s}=ON"
        end
        s
      end
    end
  end
end
