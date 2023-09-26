tsk_label := R[1]
reg4      := R[4]

set_label(50)

if (tsk_label == 101) || (tsk_label == 1101) || (tsk_label == 1103) || (tsk_label == 1201)
    jump_to indirect('r', &reg4)
else
    jump_to @end
end

pop_label

@flat_pad1
  jump_to @end

@flat_pad2
  jump_to @end

  @layer1:1101
    jump_to @end

  @layer3:1103
    jump_to @end

  @pocket1:1201
    jump_to @end

@end