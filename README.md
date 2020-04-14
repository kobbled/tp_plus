TP+
===

[![Build Status](https://travis-ci.org/onerobotics/tp_plus.svg?branch=master)](https://travis-ci.org/onerobotics/tp_plus)


> Creation, and all rights of this repository goes to [One Robotics](https://www.onerobotics.com/). This branch was forked from the archived repo [TP+](https://github.com/onerobotics/tp_plus)

TP+ is a higher-level language abstraction that translates into FANUC
TP. It features many useful utilities that makes creating TP programs
easier:

* Identifiers for registers, position registers, IO, etc.
* Re-usable methods
* If-else blocks
* Readable motion statements
* Automatic label numbering

Of course adding another layer of abstraction takes you a step further
away from the code the robot is running. However, it's hoped that the
increased productivity and rigid syntax requirements will actually
improve your TP code.

Examples
--------

example_1.tpp

    foo  := R[1]
    bar  := DO[1]
    baz  := DO[2]

    home := PR[1]
    lpos := PR[2]

    foo = 1

    @loop
      foo += 1

      jump_to @loop if foo < 10

    turn_on bar if foo == 5
    toggle baz

    linear_move.to(home).at(2000, 'mm/s').term(0)
    get_linear_position(lpos)


example_1.ls

    /PROG example_1
    /MN
     : R[1:foo] = 1 ;
     :  ;
     : LBL[100:loop] ;
     : R[1:foo]=R[1:foo]+1 ;
     : IF R[1:foo]<10,JMP LBL[100] ;
     :  ;
     : IF (R[1:foo]=5),DO[1:bar]=(ON) ;
     : DO[2:baz]=(!DO[2:baz]) ;
     :  ;
     : L PR[1:home] 2000mm/sec CNT0 ;
     : PR[2:lpos]=LPOS ;
    /END

For a more extensive example and test environment, visit http://tp-plus.herokuapp.com/.

Usage
-----

1. `gem install tp_plus`
2. `tpp filename.tpp -o filename.ls`

See `tpp --help` for options.

Development
-----------

1. Install Ruby
2. Install git
3. Install bundler `gem install bundler`
4. Clone the repo `git clone https://github.com/onerobotics/tp_plus.git`
5. Install dependencies with `bundle`
6. Build the parser and run the tests with `rake`

License
-------

TP+ is released under the [MIT License](http://www.opensource.org/licenses/MIT).
