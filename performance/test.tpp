# EXAMPLE
# =======
# Feel free to write comments as long as you want. They will be wrapped automatically.

# variable definitions
foo             := R[1]
tb_val          := R[2]
another         := R[3]
cnt_val         := R[4]
bar             := DO[1]
signal          := DI[1]
flag            := F[1]
home            := PR[1]
my_offset       := PR[2]
lpos            := PR[3]
my_timer        := TIMER[1]

# namespaced definitions
namespace Infeed
  part_present? := DI[2]
  pick_location := PR[4]
end

namespace Alarms
  gripper       := UALM[1]
  part_presence := UALM[2]
end

# Constants
PI              := 3.14
MEANING_OF_LIFE := 42

# variable assignment
foo = 1
foo = foo + PI

# increment/decrement shortcuts
foo += 1
foo -= 1
foo += another

# label definitions
# notice automatic label numbering
@foo
@bar

# jump to labels
jump_to @foo

# if statements
# notice automatic mixed logic if possible
if foo==1
  # foo is 1
end

if foo==1
  # this one cannot be done with mixed logic
  # because it has multiple lines inside
  # the block
  turn_on bar
end

# if-else statements
if foo==1
  # foo is 1
else
  # foo is not 1
end

# unless statements
unless foo==1
  # foo is not 1
end

# for loops
for foo in (1 to 10)
  toggle bar
end

# while loops
while foo < 10
  # foo is less than 10
  foo += 1
end

# io readability
turn_on bar
turn_off bar
toggle bar
pulse bar
pulse(bar, 500, 'ms')

# inline conditionals
turn_on bar if foo < 10
jump_to @bar unless Infeed::part_present?

# program calls
my_program()
my_program(1,2,3)
my_program(foo)

# async programs
run my_program()
run my_program(1,2,3)

# user alarms
raise Alarms::gripper
raise Alarms::part_presence

# motion readability
linear_move.to(Infeed::pick_location).at(2000, 'mm/s').term(0)
joint_move.to(home).at(foo, '%').term(0)
# separate motion options onto multiple lines
linear_move.
  to(home).
  at('max_speed').
  term(cnt_val).
  offset(my_offset).
  time_before(tb_val, open_gripper())

# skip conditions
set_skip_condition signal
linear_move.to(home).at(250, 'mm/s').term(0).skip_to(@bar)
linear_move.to(home).at(250, 'mm/s').term(0).skip_to(@bar, lpos)

# automatic WAIT time-unit conversion
wait_for(1, 's')
wait_for(100, 'ms')

# wait_until for expression conditions
wait_until(foo>3)

# wait timeouts
wait_until(foo>3).timeout_to(@bar)

# automatically set $WAITTMOUT
wait_until(foo>3).timeout_to(@bar).after(5,'s')

# better Position Register component access
my_offset.x = 0
my_offset.z = 100

# mixed-logic boolean assignment
flag = flag && !signal || signal && bar

# select statements
case foo
when 1
  one()
when 2
  two()
when 3
  three()
else
  jump_to @bar
end

# evaluate TP code in place
eval "! literal TP code"
eval "DO[1]=ON"

# timer methods
start my_timer
stop  my_timer
reset my_timer
# restart short-cut
restart my_timer

# position data stored as JSON for easy use with other languages/tools
position_data
{
  'positions' : [
    {
      'id' : 1,
      'comment' : "test position",
      'group' : 1,
      'uframe' : 1,
      'utool' : 1,
      'config' : {
        'flip' : true,
        'up'   : true,
        'top'  : true,
        'turn_counts' : [0,0,0]
      },
      'components' : {
        'x' : 0.0,
        'y' : 0.0,
        'z' : 0.0,
        'w' : 0.0,
        'p' : 0.0,
        'r' : 0.0
      }
    }
  ]
}
end
