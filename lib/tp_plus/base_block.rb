module TPPlus
    class BaseBlock
      attr_accessor :nodes, :ret_type, :position_data
      attr_reader :variables, :constants, :namespaces, :functions

      def initialize
        @name          = ''
        @nodes         = []
        @namespaces    = {}
        @functions     = {}
        @variables     = {}
        @constants     = {}
        @ret_type      = {}
        @position_data = {}
      end
      
      def add_namespace(identifier, block)
        if @namespaces[identifier.to_sym].nil?
          @namespaces[identifier.to_sym] = TPPlus::Namespace.new("#{@name} #{identifier}", block)
        else
          @namespaces[identifier.to_sym].reopen!(block)
        end
      end

      def add_function(name, args, block, ret_type = '')
        if @functions[name.to_sym].nil?
          @functions[name.to_sym] = TPPlus::Function.new(name, args, block, ret_type=ret_type, vars=@variables, consts=@constants)
          @functions[name.to_sym].eval
        end
      end

      def add_constant(identifier, node)
        raise "Constant #{identifier} already defined" if @constants[identifier.to_sym]
  
        @constants[identifier.to_sym] = node
      end

      def add_var(identifier, node)
        raise "Variable #{identifier} already defined" if @variables[identifier.to_sym]
  
        @variables[identifier.to_sym] = node
        node.comment = identifier
      end
  
      def get_constant(identifier)
        raise "Constant (#{identifier}) not defined" if @constants[identifier.to_sym].nil?
  
        @constants[identifier.to_sym]
      end
  
      def get_var(identifier)
        raise "Variable (#{identifier}) not defined" if @variables[identifier.to_sym].nil?
  
        @variables[identifier.to_sym]
      end
  
      def get_namespace(identifier)
        if ns = @namespaces[identifier.to_sym]
          return ns
        end
  
        false
      end

      def get_function(identifier)
        if df = @functions[identifier.to_sym]
          return df
        end
  
        false
      end


      def eval
        pass
      end

    end
end