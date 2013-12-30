require 'tp_plus/parser'

module TPPlus
  class Interpreter
    attr_accessor :line_count, :nodes
    attr_reader :labels
    def initialize
      @line_count = 0
      @nodes = []
      @labels = {}
      @current_label = 100
    end

    def next_label
      @current_label += 1
    end

    def add_label(identifier)
      raise "Label @#{identifier} already defined" if @labels[identifier.to_sym]
      @labels[identifier.to_sym] = next_label
    end
  end
end
