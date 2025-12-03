$:.unshift File.join(File.expand_path(File.dirname(__FILE__)),'..','lib')
require 'tp_plus'
require 'benchmark'

test_file = File.open(File.join(File.dirname(__FILE__),'test.tpp'), 'rb')
src = test_file.read
test_file.close

scanner = TPPlus::Scanner.new

iterations = 1000
tokens_total = 0

# Optional lightweight method-call counting (enable with TRACE_METHODS=1)
method_calls = Hash.new(0)
trace = nil
if ENV['TRACE_METHODS'] == '1'
  trace = TracePoint.new(:call) do |tp_event|
    klass = tp_event.defined_class
    next unless klass
    kname = klass.to_s
    # only count methods defined in TPPlus namespace (adjust as needed)
    if kname.start_with?('TPPlus')
      method_calls["#{kname}##{tp_event.method_id}"] += 1
    end
  end
  trace.enable
end

start_real = Process.clock_gettime(Process::CLOCK_MONOTONIC)
start_cpu  = Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID)

iterations.times do
  scanner.scan_setup(src)
  while scanner.next_token != nil
    tokens_total += 1
  end
end

end_cpu  = Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID)
end_real = Process.clock_gettime(Process::CLOCK_MONOTONIC)

trace.disable if trace

total_real = end_real - start_real
total_cpu  = end_cpu  - start_cpu
avg_time_per_iter = total_real / iterations.to_f
avg_tokens_per_iter = tokens_total.to_f / iterations.to_f
tokens_per_second = tokens_total.to_f / total_real

puts "Iterations: #{iterations}"
puts "Total tokens: #{tokens_total}"
puts "Total real time: #{total_real.round(6)} s"
puts "Total CPU time:  #{total_cpu.round(6)} s"
puts "Avg time / iteration: #{avg_time_per_iter.round(6)} s"
puts "Avg tokens / iteration: #{avg_tokens_per_iter.round(2)}"
puts "Tokens / second: #{tokens_per_second.round(2)}"

if method_calls.any?
  puts "\nTop TPPlus method call counts:"
  method_calls.sort_by { |_k,v| -v }.first(20).each do |m,c|
    puts "  #{m}: #{c}"
  end
end
