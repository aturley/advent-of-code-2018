use "aoc-tools"
use "collections"
use "itertools"

class Day1 is AOCApp
  fun part1(file_lines: Array[String] val): (String | AOCAppError) =>
    var freq: I64 = 0

    for c in file_lines.values() do
      try
        freq = freq + c.clone().>strip().>remove("+").i64()?
      else
        return AOCAppError("error converting '" + c + "' to u64")
      end
    end

    freq.string()

  fun part2(file_lines: Array[String] val): (String | AOCAppError) =>
    var freq: I64 = 0

    let seen = SetIs[I64]
    seen.set(freq)

    for c in Iter[String](file_lines.values()).cycle() do
      try
        freq = freq + c.clone().>strip().>remove("+").i64()?

        if seen.contains(freq) then
          return freq.string()
        end

        seen.set(freq)
      else
        return AOCAppError("error converting '" + c + "' to u64")
      end
    end

    "never saw a repeated frequency"

actor Main
  new create(env: Env) =>
    AOCAppRunner(Day1, env)
