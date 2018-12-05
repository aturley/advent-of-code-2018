use "aoc-tools"
use "collections"
use "debug"

primitive TriggerReactions
  fun check_for_reaction(u1: U8, u2: U8): Bool =>
    let min = u1.min(u2)
    let max = u1.max(u2)

    (max - min) == 32

  fun apply(polymer: String): String ? =>
    let keep_list = Array[Bool].init(true, polymer.size())

    for (i, u1) in polymer.array().pairs() do
      if i == (polymer.size() - 1) then
        break
      end

      if keep_list(i)? == false then
        continue
      end

      let u2 = polymer(i + 1)?

      if check_for_reaction(u1, u2) then
        keep_list(i)? = false
        keep_list(i + 1)? = false
      end
    end

    let output = String

    for (i, k) in keep_list.pairs() do
      if k then
        output.push(polymer(i)?)
      end
    end

    output.clone()

  fun until_stable(polymer': String): String ? =>
    var polymer = polymer'
    var last_polymer_size: USize = 0

    while true do
      polymer = TriggerReactions(polymer)?
      if polymer.size() == last_polymer_size then
        break
      end
      last_polymer_size = polymer.size()
    end

    polymer

class Day5 is AOCApp
  fun part1(file_lines: Array[String] val): (String | AOCAppError) ? =>
    let polymer = TriggerReactions.until_stable(file_lines(0)?)?
    polymer.size().string()

  fun part2(file_lines: Array[String] val): (String | AOCAppError) ? =>
    var shortest_polymer = file_lines(0)?

    for c in Range[U8]('a', 'z' + 1) do
      Debug("testing " + String.from_utf32(c.u32()))
      let new_polymer: String = file_lines(0)?.clone().>remove(String.from_utf32(c.u32())).>remove(String.from_utf32((c - 'a').u32() + 'A')).clone()

      let result = TriggerReactions.until_stable(new_polymer)?
      if result.size() < shortest_polymer.size() then
        shortest_polymer = result
      end
    end

    shortest_polymer.size().string()

actor Main
  new create(env: Env) =>
    AOCAppRunner(Day5, env)
