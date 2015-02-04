TP+
===

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


    foo = 1

    @loop
      foo += 1

      jump_to @foo if foo < 10

    turn_on bar if foo == 5
    toggle baz

    linear_move.to(home).at(2000mm/s).term(0)


example_1.ls

    /PROG example_1
    /MN
      1:  R[1:foo] = 1 ;
      1:   ;
      1:  LBL[1:loop] ;
      1:  R[1:foo]=R[1:foo]+1 ;
      1:  IF R[1:foo]<10,JMP LBL[1] ;
      1:   ;
      1:  IF (R[1:foo]=5),DO[1:bar]=(ON) ;
      1:  DO[2:baz]=(!DO[2:baz]) ;
      1:   ;
      1:  L PR[1:home] 2000mm/sec CNT0 ;
    /END

Usage
-----

1. `gem install tp_plus`
2. `tpp filename.tpp > filename.ls`

See `tpp --help` for options.

License
-------

TP+ is released under the [MIT License](http://www.opensource.org/licenses/MIT).
