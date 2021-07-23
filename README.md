TP+
===

[![Build Status](https://travis-ci.com/kobbled/tp_plus.svg?branch=master)](https://travis-ci.org/onerobotics/tp_plus)


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

Install
-----------

1. Install Ruby
2. Install git
3. Install bundler `gem install bundler`
4. Clone the repo `git clone https://github.com/kobbled/tp_plus.git`
5. Install dependencies with `bundle`
6. Build the parser and run the tests with `rake`
7. Make sure all tests pass
8. Add full path of **./tp_plus/bin** to your environment path

```shell
set PATH=%PATH%;\path\to\tp_plus\bin
```

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
