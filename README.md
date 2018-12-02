# Advent of Code 2018

This is a repository of my solutions to
the [2018 Advent of Code](https://adventofcode.com/2018/) problems. I
will be doing these in [Pony](https://ponylang.io).

## About the Code

I created [some helper code](https://github.com/aturley/aoc-tools)
based on my experience with last year's AoC. My solutions to this
years problems will probably all use this library.

## Building the Solution

Each day's solution lives in a directory that is named for the day
(`day1`, `day2`, etc). You will need to have
the [Pony compiler](https://github.com/ponylang/ponyc)
and [Stable](https://github.com/ponylang/pony-stable) (the Pony dependency
manager installed) in order to build the solutions. To build a
solution, go into its directory and run the following commands:

```
stable fetch
stable env ponyc
```

This will create an executable with the same name as the directory
that you are in.

## Running the Solution

The solution executables take two arguments:

1. the name of the input file
2. the part that you want to run (`1` or `2`)

For example, if you wanted to run part 2 of the day 7 solution on the
file `ex7-4.txt` you would run the following command:

```
./day7 ex7-4.txt 2
```
