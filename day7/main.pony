use "aoc-tools"
use "collections"
use "debug"
use "itertools"
use "ponytest"
use "time"

actor Manager
  let _app: Day7
  var _start_time: U64
  let _available: SetIs[Worker] = SetIs[Worker]

  let _graph: Map[String, Set[String]]
  let _remaining: Set[String]
  var _cur: String = ""
  let _pending: Set[String] = Set[String]

  new create(app: Day7, file_lines: Array[String] val) =>
    _app = app
    _start_time = 0

    _graph = Map[String, Set[String]]

    for d in Iter[String](file_lines.values())
      .map[(String, String)]({(l) ? => ParseDependency(l)?})
    do
      try
        _graph.upsert(d._2, Set[String].>set(d._1), {(o, n) => o.>union(n.values())})?
        if not _graph.contains(d._1) then
          _graph(d._1) = Set[String]
        end
      end
    end

    _remaining = Set[String]

    for k in _graph.keys() do
      _remaining.set(k)
    end

    _cur = "[" // bigger than "Z"

    for (k, ds) in _graph.pairs() do
      if ds.size() == 0 then
        _cur = if k < _cur then
          k
        else
          _cur
        end
      end
    end

    Debug("cur starts at '" + _cur + "'")

  be start() =>
    _start_time = Time.millis().u64()

  be finished(worker: Worker, item: String) =>
    Debug("finished " + item)
    _pending.unset(item)

    for ds in _graph.values() do
      ds.unset(item)
    end

    _app.finished_part2((Time.millis().u64() - _start_time) / 1000)
    _available.set(worker)
    _new_work()

  be new_work(worker: Worker) =>
    _available.set(worker)
    _new_work()

  fun ref _new_work() =>
    if _remaining.size() > 0 then
      try
        if not (_cur == "[") then
          let worker = _available.values().next()?
          _remaining.unset(_cur)
          _pending.set(_cur)
          worker.work(_cur)
          Debug("assignedx " + _cur)
          _available.unset(worker)
        end
      else
        // no more available workers
        return
      end
    end

    let empties = Set[String]

    for (p, ds) in _graph.pairs() do
      if _remaining.contains(p) and (ds.size() == 0) then
        empties.set(p)
      end
    end

    let ei = empties.values()

    _cur = try
      ei.next()?
    else
      // no empties
      _cur = "["
      return
    end

    for e in ei do
      _cur = if e < _cur then
        e
      else
        _cur
      end
    end

    _new_work()

class WorkerNotify is TimerNotify
  let _worker: Worker

  new iso create(worker: Worker) =>
    _worker = worker
  fun ref apply(timer: Timer, count: U64): Bool =>
    _worker.ping()
    false

actor Worker
  var _cur: (String | None)
  let _manager: Manager
  let _timers: Timers
  let _time_add: U64

  new create(manager: Manager, timers: Timers, time_add: U64) =>
    _cur = None
    _manager = manager
    _timers = timers
    _time_add = time_add

  be ping() =>
    _get_new_work()

  be work(item: String) =>
    _cur = item
    try
      _set_timer(item(0)?)
    end

  fun ref _set_timer(t: U8) =>
    let timer = Timer(WorkerNotify(this), (_time_add + (t -'A').u64()) * 1_000_000_000)
    _timers(consume timer)

  fun ref _get_new_work() =>
    try
      _manager.finished(this, _cur as String)
      _cur = None
    end

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
    _reporter = reporter

    let workers = try
      args(3)?.usize()?
    else
      5
    end

    let time_add = try
      args(4)?.u64()?
    else
      60
    end

    let manager = Manager(this, file_lines)
    manager.start()

    for i in Range(0, workers) do
      Debug("created worker " + i.string())
      manager.new_work(Worker(manager, Timers, time_add))
    end

  be finished_part2(dur: U64) =>
    try
      (_reporter as AOCActorAppReporter)(dur.string())
    end

actor Main
  new create(env: Env) =>
    AOCActorAppRunner(Day7, env, Day7Tests)
