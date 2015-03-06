$:.unshift File.join(File.expand_path(File.dirname(__FILE__)),'..','lib')
require 'tp_plus'
require 'benchmark/ips'


test_file = File.open('test.tpp', 'rb')
src = test_file.read
test_file.close

Benchmark.ips do |x|
  x.time = 60
  x.warmup = 5

  puts
  puts "Running benchmark for #{x.time} seconds (with #{x.warmup} seconds warmup.)"
  puts

  x.report("parse:") {
    scanner = TPPlus::Scanner.new
    parser = TPPlus::Parser.new(scanner)
    scanner.scan_setup(src)
    parser.parse
  }
end
