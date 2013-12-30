require 'tp_plus/parser'

module TPPlus
  class Interpreter
    attr_accessor :line_count, :nodes
    def initialize
      @line_count = 0
      @nodes = []
    end
  end
end
