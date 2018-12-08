use "aoc-tools"
use "collections"
use "itertools"

primitive SumNodeAndChildren
  fun apply(input: Array[U64] box): (U64, Array[U64] box) ? =>
    let child_nodes = input(0)?
    let metadata_count = input(1)?
    var rem: Array[U64] box = input.slice(2)
    var sum: U64 = 0

    for _ in Range(0, child_nodes.usize()) do
      (let acc, rem) = SumNodeAndChildren(rem)?
      sum = sum + acc
    end

    for m in rem.slice(0, metadata_count.usize()).values() do
      sum = sum + m
    end

    (sum, rem.slice(metadata_count.usize()))

primitive SumNodeAndChildren2
  fun apply(input: Array[U64] box): (U64, Array[U64] box) ? =>
    let child_nodes = input(0)?
    let metadata_count = input(1)?
    var rem: Array[U64] box = input.slice(2)

    let sum = if child_nodes.usize() == 0 then
      var sum': U64 = 0

      for m in rem.slice(0, metadata_count.usize()).values() do
        sum' = sum' + m
      end

      sum'
    else
      var sum': U64 = 0
      var sums = Array[U64]

      for _ in Range(0, child_nodes.usize()) do
        (let acc, rem) = SumNodeAndChildren2(rem)?
        sums.push(acc)
      end

      for m in rem.slice(0, metadata_count.usize()).values() do
        sum' = sum' + try sums(m.usize() - 1)? else 0 end
      end

      sum'
    end

    (sum, rem.slice(metadata_count.usize()))

actor Day8 is AOCActorApp
  be part1(file_lines: Array[String] val, args: Array[String] val,
    reporter: AOCActorAppReporter)
  =>
    let numbers = try
      let n = Iter[String](file_lines(0)?.split(" ").values())
        .map[U64]({(s) ? => s.u64()?})
        .collect(Array[U64])
      if n.size() != file_lines(0)?.split(" ").size() then
        error
      end
      n
    else
      reporter.err("error parsing numbers")
      return
    end

    (let sum, let rem) = try
      SumNodeAndChildren(numbers)?
    else
      reporter.err("error getting sum")
      return
    end

    if rem.size() > 0 then
      reporter.err("number remaining = " + rem.size().string())
      return
    end

    reporter(sum.string())

  be part2(file_lines: Array[String] val, args: Array[String] val,
    reporter: AOCActorAppReporter)
  =>
    let numbers = try
      let n = Iter[String](file_lines(0)?.split(" ").values())
        .map[U64]({(s) ? => s.u64()?})
        .collect(Array[U64])
      if n.size() != file_lines(0)?.split(" ").size() then
        error
      end
      n
    else
      reporter.err("error parsing numbers")
      return
    end

    (let sum, let rem) = try
      SumNodeAndChildren2(numbers)?
    else
      reporter.err("error getting sum")
      return
    end

    if rem.size() > 0 then
      reporter.err("number remaining = " + rem.size().string())
      return
    end

    reporter(sum.string())

actor Main
  new create(env: Env) =>
    AOCActorAppRunner(Day8, env)
