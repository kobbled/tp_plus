#!/usr/bin/ruby

require_relative '../stack'

range = *(50..59)
type = 'R'
stack = TPPlus::Stack.new(range, type)

stack.push

stack.add("pi")
stack.add("index")
stack.add("increments")
stack.add("radius")
stack.add("degree")
stack.add("shouldrun")
stack.add("sensor")
stack.add("start_vec")
stack.add("end_vec")
stack.add("config")

puts "stack is full" if stack.full?

# #overflow
# stack.add("overflow")

name = "shouldrun"
puts "find #{name} := #{stack.getid(name)}"

name = "index"
puts "find #{name} := #{stack.getid(name)}"

puts stack.pop

puts "stack is empty" if stack.empty?