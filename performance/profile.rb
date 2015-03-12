$:.unshift File.join(File.expand_path(File.dirname(__FILE__)),'..','lib')
require 'tp_plus'
require 'ruby-prof'

test_file = File.open(File.join(File.dirname(__FILE__),'test.tpp'), 'rb')
src = test_file.read
test_file.close

scanner = TPPlus::Scanner.new

RubyProf.start
1000.times do
  scanner.scan_setup(src)
  while scanner.next_token != nil ; end
end
result = RubyProf.stop

# Print a flat profile to text
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)

# Print a graph profile to text
#printer = RubyProf::GraphPrinter.new(result)
#printer.print(STDOUT, {})
