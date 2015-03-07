$:.unshift File.join(File.expand_path(File.dirname(__FILE__)),'..','lib')
require 'tp_plus'
require 'benchmark/ips'


test_file = File.open(File.join(File.dirname(__FILE__),'test.tpp'), 'rb')
src = test_file.read
test_file.close

scanner = TPPlus::NewScanner.new

Benchmark.ips do |x|
  x.time = 60
  x.warmup = 5

  puts
  puts "Running benchmark for #{x.time} seconds (with #{x.warmup} seconds warmup.)"
  puts

  x.report("scan:") {
    scanner.scan_setup(src)
    while scanner.next_token != nil ; end
  }

  x.report("parse:") {
    scanner.scan_setup(src)
    parser = TPPlus::Parser.new scanner
    parser.parse
  }
end
