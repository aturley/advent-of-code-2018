use "aoc-tools"
use "collections"
use "debug"

type State is Map[I64, Bool]

class StateWrapper is Equatable[StateWrapper]
  let _state: State

  new create(state: State) =>
    _state = state

  fun eq(that: box->StateWrapper): Bool =>
    if _state.size() != that._state.size() then
      return false
    end

    try
      for (k, v) in _state.pairs() do
        if v != that._state(k)? then
          return false
        end
      end
    else
      return false
    end

    true

  fun hash(): USize =>
    var h: USize = 0

    for v in _state.values() do
      h = (h << 1) xor (if v then 1 else 0 end)
    end

    h

primitive ParseInitialState
  fun apply(s: String): State ? =>
    let stripped = s.split(" ")(2)?

    let state = State
    for (i, c) in stripped.array().pairs() do
      state(i.i64()) = (c == '#')
    end

    state

class val Rules
  let _rules: Array[Bool] val

  new val create(rules: Array[Bool] val) =>
    _rules = rules

  fun apply_rule(input: Array[Bool]): Bool =>
    var i: USize = 0

    for x in input.values() do
      i = (i << 1) + (if x then 1 else 0 end)
    end

    try
      _rules(i)?
    else
      Debug("Couln't find rule")
      Debug(input)
      false
    end

  fun apply(state: State): State =>
    let new_state = State

    (let min, let max) = StateMinMax(state)

    for i in Range[I64](min - 2, max + 3) do
      var arr = Array[Bool]
      for j in Range[I64](i - 2, i + 3) do
        arr.push(state.get_or_else(j, false))
      end

      new_state(i) = apply_rule(arr)
    end

    new_state

primitive StateMinMax
  fun apply(s: State): (I64, I64) =>
    var min = I64.max_value()
    var max = I64.min_value()

    for k in s.keys() do
      min = min.min(k)
      max = max.max(k)
    end

    (min, max)

primitive ParseRule
  fun apply(r: String): (USize, Bool) ? =>
    // #..#. => #
    var rule: USize = 0

    let parts: Array[String] val = r.split(" ")

    for x in parts(0)?.array().values() do
      rule = (rule << 1) + (if x == '#' then 1 else 0 end)
    end

    (rule, parts(2)? == "#")

primitive ParseRules
  fun apply(rs: Array[String]): Rules ? =>
    let rules_array = recover iso Array[Bool].init(false, 32) end

    for r in rs.values() do
      (let rule, let output) = ParseRule(r)?
      rules_array(rule)? = output
    end

    Rules(consume rules_array)

primitive ParseInput
  fun apply(file_lines: Array[String] val): (State, Rules) ? =>
    // initial state: initial state: #....#.#....#....#######..##....###.##....##.#.#.##...##.##.#...#..###....#.#...##.###.##.###...#..#
    //
    // rule1: #..#. => #
    // rule2: #...# => #

    let state = ParseInitialState(file_lines(0)?)?

    let rules = ParseRules(file_lines.slice(2))?

    (state, rules)

actor Day12 is AOCActorApp
  be part1(file_lines: Array[String] val, args: Array[String] val,
    reporter: AOCActorAppReporter)
  =>
    (var state, let rules) = try
      ParseInput(file_lines)?
    else
      reporter.err("could not parse input")
      return
    end

    for _ in Range(0, 20) do
      state = rules(state)
    end

    var sum: I64 = 0

    for (k, v) in state.pairs() do
      if v then
        sum = sum + k
      end
    end

    reporter(sum.string())

  be part2(file_lines: Array[String] val, args: Array[String] val,
    reporter: AOCActorAppReporter)
  =>
    (var state, let rules) = try
      ParseInput(file_lines)?
    else
      reporter.err("could not parse input")
      return
    end

    let rep' = recover iso String end

    for x in Range[I64](-60, 60) do
      rep'.push(if state.get_or_else(x, false) then '#' else '.' end)
    end

    Debug(consume rep')

    let seen = Map[StateWrapper, USize]

    seen(StateWrapper(state)) = 0

    var last_gen: USize = 0
    var last_state_wrapper = StateWrapper(state)

    for i in Range(0, 50000000000) do
      state = rules(state)

      let rep = recover iso String end

      // for x in Range[I64](-60, 60) do
      //   rep.push(if state.get_or_else(x, false) then '#' else '.' end)
      // end

      // Debug(consume rep)

      let sw = StateWrapper(state)
      if seen.contains(sw) then
        last_gen = i + 1
        last_state_wrapper = sw
        break
      else
        seen(sw) = i + 1
      end

      reporter("gen = " + i.string() + " size = " + state.size().string() + " score = " + ScoreState(state).string())

    end

    let score = ScoreState(state)

    reporter(score.string())

primitive ScoreState
  fun apply(state: State): I64 =>
    var sum: I64 = 0

    for (k, v) in state.pairs() do
      if v then
        sum = sum + k
      end
    end

    sum

actor Main
  new create(env: Env) =>
    AOCActorAppRunner(Day12, env)
