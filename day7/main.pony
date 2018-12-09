use "aoc-tools"
use "collections"
use "itertools"
use "ponytest"
use "time"

class Worker
  var _time_remaining: U64
  var _cur: (String | None)

  new create() =>
    _time_remaining = 0
    _cur = None

  fun time_remaining(): U64 =>
    _time_remaining

  fun is_ready(): Bool =>
    _time_remaining == 0

  fun ref subtract_time(t: U64): (None | String) =>
    if _time_remaining == 0 then
      return
    end

    _time_remaining = _time_remaining - t
    if _time_remaining == 0 then
      let c = _cur
      _cur = None
      return c
    end

  fun ref assign_work(c: String, t: U64) =>
    _time_remaining = t
    _cur = c

class Manager
  let _workers: Array[Worker]
  let _graph: WorkGraph
  let _add_time: U64
  var _total_work_time: U64 = 0

  new create(num_workers: USize, graph: WorkGraph, add_time: U64) =>
    _workers = Array[Worker](num_workers)
    _graph = graph
    _add_time = add_time

    for _ in Range(0, num_workers) do
      _workers.push(Worker)
    end

  fun ref process(): Bool =>
    // get min time remaining

    var min_time_remaining: (U64 | None) =  None

    for w in _workers.values() do
      min_time_remaining = if w.time_remaining() > 0 then
        match min_time_remaining
        | let mtr: U64 =>
          mtr.min(w.time_remaining())
        else
          w.time_remaining()
        end
      else
        min_time_remaining
      end
    end

    let mtr = try
      min_time_remaining as U64
    else
      0
    end

    // update the worker times

    let ready_set = SetIs[Worker]

    for w in _workers.values() do
      if w.time_remaining() == 0 then
        ready_set.set(w)
      else
        let c = w.subtract_time(mtr)
        match c
        | let done: String =>
          _graph.mark_finished(done)
          ready_set.set(w)
        end
      end
    end

    _total_work_time = _total_work_time + mtr

    for w in ready_set.values() do
      match _graph.get_next_available()
      | let c: String =>
        let t = try (c(0)? - 'A').u64() + _add_time else 1 end
        w.assign_work(c, t)
      else
        break
      end
    end

    _graph.is_done()

  fun total_time(): U64 =>
    _total_work_time

class WorkGraph
  let _dependencies: Array[(String, String)]
  let _remaining: Set[String]
  let _pending: Set[String]

  new create(lines: Array[String] val) ?=>
    _dependencies = Array[(String, String)]
    _remaining = Set[String]
    _pending = Set[String]

    for l in lines.values() do
      let d = ParseDependency(l)?
      _dependencies.push(d)
      _remaining.set(d._1)
      _remaining.set(d._2)
    end

  fun ref get_next_available(): (String | None) =>
    let available = _remaining.clone()

    // d => d._1 must be completed before d._2 can begin

    for d in _dependencies.values() do
      // if d._1 is remaining or pending then remove it from available
      if _remaining.contains(d._1) or _pending.contains(d._1) then
        available.unset(d._2)
      end
    end

    var next: (None | String) = None

    for a in available.values() do
      match next
      | None =>
        next = a
      | let s: String =>
        next = if a < s then
          a
        else
          s
        end
      end
    end

    match next
    | let s: String =>
      _pending.set(s)
      _remaining.unset(s)
    end
    next

  fun ref mark_finished(c: String) =>
    _pending.unset(c)

  fun is_done(): Bool =>
    (_remaining.size() + _pending.size()) == 0

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
  var _reporter: (AOCActorAppReporter | None) = None

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
    let graph = try
      WorkGraph(file_lines)?
    else
      reporter.err("could not parse work graph")
      return
    end

    (let num_workers: USize, let add_time: U64)= try
      (args(3)?.usize()?, args(4)?.u64()?)
    else
      (5, 60)
    end

    let manager = Manager(num_workers, graph, add_time)

    while manager.process() == false do
      None
    end

    reporter(manager.total_time().string())

actor Main
  new create(env: Env) =>
    AOCActorAppRunner(Day7, env, Day7Tests)
