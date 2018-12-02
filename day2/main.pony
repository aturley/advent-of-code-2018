use "aoc-tools"
use "itertools"

primitive HammingDistance
  fun apply(s1: String, s2: String): USize =>
    Iter[U8](s1.values()).zip[U8](s2.values())
      .fold[USize](0, {
        (dist, cs) =>
          if cs._1 != cs._2 then
            dist + 1
          else
            dist
          end
      })

class Day2 is AOCApp
  fun _count_two_and_three(line: String): (USize, USize) =>
    let counter = Counter[U8]

    for c in line.values() do
      counter.add(c)
    end

    var twos: USize = 0
    var threes: USize = 0

    for (_, count) in counter.pairs() do
      match count
      | 2 =>
        twos = 1
      | 3 =>
        threes = 1
      end
    end

    (twos, threes)

  fun part1(file_lines: Array[String] val): (String | AOCAppError) =>
    var twos: USize = 0
    var threes: USize = 0

    for line in file_lines.values() do
      (let n2, let n3) = _count_two_and_three(line)
      twos = twos + n2
      threes = threes + n3
    end

    (twos * threes).string()

  fun part2(file_lines: Array[String] val): (String | AOCAppError) =>
    var part_match: (None | (String, String)) = None
    for id in file_lines.values() do
      try
        let match_location = file_lines.find(id
          where predicate =
            {(a, b) => HammingDistance(a, b) == 1})?
        part_match = (id, file_lines(match_location)?)
        break
      end
    end

    match part_match
    | (let a: String, let b: String) =>
      Iter[U8](a.values()).zip[U8](Iter[U8](b.values()))
        .fold[String]("", {(acc, cs) =>
          if (cs._1 == cs._2) then
            acc + String.from_utf32(cs._1.u32())
          else
            acc
          end
        })
    else
      AOCAppError("No matches!")
    end

actor Main
  new create(env: Env) =>
    AOCAppRunner(Day2, env)
