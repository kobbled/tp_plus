#argument_node.rb (def address)
#coord_node.rb (+n)
#expression_node.rb (differences, need resolving)
#indirect_node (differences. eval.)
#indirect_method_node.rb (+n)
#io_node.rb (changes evaluate)
#lpos_node.rb (changes evaluate. Dont know if needed?)
#numreg_node.rb (def address)
#operator_node.rb (changes evaluate. modulus operator)
#position_data_node.rb(changes eval. fixnum -> integer.)
#position_node.rb (def address)
#posreg_node.rb (changes eval)
#speed_node.rb (deg/s)
#string_register_node (def address)
#termination_node.rb (differences, from onerobotics?)
#timer_node.rb (def address)
#user_alarm_node.rb (def address)
#wait_for_node.rb (changes from onerobotics)
#interpreter.rb (changes from onerobotics)
#parser.rb and parser.output were removed?
#scanner.rb (|| isDigit?(@ch) addition)
#token.rb (tokens different between two files
                     get_joint_position instead of jpos
                     Use onerobotics jpos lpos instances 
                     before changing)
#tp_plus.rb (changes to include files)
#tpp (karel environment build. probably dont need to add this)
#test_interpreter.rb (add appropriate tests.
                      -indirect names have been changed. will need
                      to update for.
                      -groups syntax might only be valid with
                    groups(1)
                    not gp1)

# ISSUES

- [ ] labels in loops don't get recognized by compiler
- [ ] '-'ive number arguments for call functions dont work (eg. -1).

