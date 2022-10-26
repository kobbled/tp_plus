module TPPlus
  
    class Stacks
      attr_accessor :pack

      def initialize
        @pack = {}
      end

      def push_all
        @pack.each do |k, v|
          v.push
        end
      end

      def pop_all
        @pack.each do |k, v|
          v.pop
        end
      end
    end

    class Stack
      attr_reader :type, :length

      def initialize(registerArray, type)
        @stack = []
        @registers = registerArray
        @stack_pointer = registerArray[0]
        @type = type
        @length = 0
      end

      def push
        @stack.unshift({})
      end

      def pop
        return nil if @length == 0

        @stack_pointer -= @stack[0].size
        @length -= @stack[0].size

        @stack.shift
      end

      def add(name)
        raise "Stack overflow in #{self}" if @length >= @registers.length
        unless @stack[0].key?(name)
          @stack[0][name.to_sym] = @stack_pointer
          @stack_pointer += 1
          @length += 1
        end
      end

      def del(name)
        if @stack[0].key?(name)
          @stack[0].delete(name.to_sym)
        end
      end

      def getid(name)
        if @stack[0].key?(name)
          raise "#{name} was not found in #{@type} stack"
        end

        @stack[0][name.to_sym]
      end

      def empty?
        @length == 0
      end

      def full?
        @length == @registers.length
      end

    end
end