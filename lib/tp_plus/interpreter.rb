require 'tp_plus/parser'
module TPPlus
  class Interpreter
    def initialize
      @parser = TPPlus::Parser.new
    end
  end
end
