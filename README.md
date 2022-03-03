TP+
===

[![Build Status](https://travis-ci.com/kobbled/tp_plus.svg?branch=master)](https://travis-ci.org/onerobotics/tp_plus)


> Creation, and all rights of this repository goes to [One Robotics](https://www.onerobotics.com/). This branch was forked from the archived repo [TP+](https://github.com/onerobotics/tp_plus)

TP+ is a higher-level language abstraction that translates into FANUC
TP. 

This is an example script of some of its features:

```ruby
namespace System
  base_EEF     := UTOOL[1]
  variable_EEF := UTOOL[2]

  temp_uframe := PR[16]
  temp_utool  := PR[17]
  search      := PR[25]
  lpos        := PR[30]
  ofset       := PR[10]

  dummy := PR[100..150]
end

namespace Sensor
  signal := DI[1]
  val    := AI[1]
  zerod  := DI[2]
end

namespace Pose
  using System

  def goHome()
    use_uframe 0
    use_utool 1

    pHome := P[1]
    pHome.joints -> [127.834, 24.311, -29.462, -110.295, 121.424, 54.899]

    joint_move.to(pHome).at(10, '%').term(-1)
  end

  inline def offsetTool(base_frame, frame_offsets, out_frame)
    using System

    System::temp_uframe = indirect('utool', base_frame)
    Pos::cnvcart(&System::temp_uframe, 1)

    System::dummy100 = indirect('posreg', frame_offsets)
    System::temp_uframe = Pos::mult(&System::temp_uframe, &System::dummy100)

    indirect('utool', out_frame) = System::temp_uframe
  end
end

TP_GROUPMASK = "1,*,*,*,*"

start_pose := P[1]
default.group(1).pose -> [0, 0, 0, 0, 0 ,0]
default.group(1).config -> ['F', 'U', 'T', 0, 0, 0]

#send home
Pose::goHome()

#go to start pose
linear_move.to(start_pose).at(100, 'mm/s').term(-1)

#set skip condition if sensor hits zero
set_skip_condition Sensor::zerod

#set search distance
Pos::clrpr(&System::search)
System::search.z = 100

#move in until interrupt
linear_move.to(start_pose).at(20, 'mm/s').term(-1).
  tool_offset(System::search).
  skip_to(@error, System::lpos)

#offset frame by search amount
System::dummy100 = start_pose
System::ofset = Pos::sub(&System::lpos, &System::dummy100)
Pose::offsetTool(&System::base_EEF, &System::ofset, &System::variable_EEF)

return

@error
tcp_alarm := UALM[5]
raise tcp_alarm
warning('Did not find zero')

```

Install
-----------

1. Install Ruby
2. Install git
3. Install bundler `gem install bundler`
4. Clone the repo `git clone https://github.com/kobbled/tp_plus.git`
5. Install dependencies with `bundle`
6. Build the parser and run the tests with `bundle exec rake`
7. Make sure all tests pass
8. Add full path of **./tp_plus/bin** to your environment path

```shell
set PATH=%PATH%;\path\to\tp_plus\bin
```

Updating
-----------

In a command prompt, or git shell run
```
git fetch && git pull
rake
```
**WARNING** : Make sure you run `rake` after git pull to update the racc parser, as this compilation is not tracked in the repo.

Usage
-----
print output to console:

```shell
tpp filename.tpp
```

print output to file (must be the same filename):

```shell
tpp filename.tpp -o filename.ls
```

interpret using an environment file:

```shell
tpp filename.tpp -e env.tpp
```

See `tpp --help` for options.


Examples
--------

see [examples.md](examples.md)

Documentation
----------

Build rdocs with:

```
rake rdoc
```

License
-------

TP+ is released under the [MIT License](http://www.opensource.org/licenses/MIT).
