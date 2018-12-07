use "aoc-tools"
use "collections"
use "itertools"
use "ponytest"

class Day7Tests is TestList
  fun tag tests(test: PonyTest) =>
    test(_TestParseDependency)

class iso _TestParseDependency is UnitTest
  fun name(): String => "ParseDependency"
  fun apply(h: TestHelper) ? =>
    let ab = ParseDependency("Step J must be finished before step H can begin.")?
    h.assert_eq[String](ab._1, "J")
    h.assert_eq[String](ab._2, "H")

primitive ParseDependency
  fun apply(line: String): (String, String) ? =>
    let parts = line.split(" ")
    (parts(1)?, parts(7)?)

actor Day7 is AOCActorApp
  be part1x(file_lines: Array[String] val, args: Array[String] val,
    reporter: AOCActorAppReporter)
  =>
    var instructions: Array[String] = file_lines.clone()

    let remaining = Set[String]

    for x in Range[U8]('A', 'Z' + 1) do
      for y in file_lines.values() do
        let s = recover val String.from_utf32(x.u32()) end
        if y.contains("Step " + s) or y.contains("step " + s) then
          remaining.set(recover String.from_utf32(x.u32()) end)
        end
      end
    end

    var steps: String = ""

    while true do
      // find step to process
      var cur = "a"

      for s in remaining.values() do
        try
          instructions.find("before step " + s where predicate = {(l, r) => l.contains(r)})?
        else
          cur = if s < cur then
            s
          else
            cur
          end
        end
      end

      if cur == "a" then
        break
      end

      let new_instructions = Array[String]

      for x in instructions.values() do
        if not x.contains("Step " + cur) then
          new_instructions.push(x)
        end
      end

      remaining.unset(cur)
      steps = steps + cur
      instructions = new_instructions
    end

    reporter(steps)

  be part1(file_lines: Array[String] val, args: Array[String] val,
    reporter: AOCActorAppReporter)
  =>
    let graph = Map[String, Set[String]]

    for d in Iter[String](file_lines.values())
      .map[(String, String)]({(l) ? => ParseDependency(l)?})
    do
      try
        graph.upsert(d._2, Set[String].>set(d._1), {(o, n) => o.>union(n.values())})?
        if not graph.contains(d._1) then
          graph(d._1) = Set[String]
        end
      else
        reporter.err("graph upsert failed")
        return
      end
    end

    let remaining = Set[String]

    for k in graph.keys() do
      remaining.set(k)
    end

    var cur = ""

    for (k, ds) in graph.pairs() do
      if ds.size() == 0 then
        cur = if k < cur then
          k
        else
          cur
        end
      end
    end

    let steps = recover iso String end

    while true do
      remaining.unset(cur)
      steps.append(cur)

      let empties = Set[String]

      for (p, ds) in graph.pairs() do
        if remaining.contains(p) then
          ds.unset(cur)
          if ds.size() == 0 then
            empties.set(p)
          end
        end
      end

      let ei = empties.values()

      cur = try
        ei.next()?
      else
        break
      end

      for e in ei do
        cur = if e < cur then
          e
        else
          cur
        end
      end
    end

    reporter(consume steps)

  be part2(file_lines: Array[String] val, args: Array[String] val,
    reporter: AOCActorAppReporter)
  =>
    reporter.err("part2 is not implemented")


actor Main
  new create(env: Env) =>
    AOCActorAppRunner(Day7, env, Day7Tests)
