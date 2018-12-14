use "aoc-tools"
use "collections"
use "ponytest"

primitive TrackToString
  fun apply(track: Grid[U8], dim_x: USize, dim_y: USize): String iso^ =>
    let ss = Array[String]
    for y in Range(0, dim_y) do
      let s = recover iso String end
      for x in Range(0, dim_x) do
        s.push(try track(x, y)? else 'X' end)
      end
      ss.push(consume s)
    end

    "\n".join(ss.values())

class Day13Tests is TestList
  fun tag tests(test: PonyTest) =>
    let ts: Array[UnitTest iso] =
[
object iso is UnitTest
  fun name(): String => "test"
  fun apply(h: TestHelper) =>
    None
end

object iso is UnitTest
  fun name(): String => "parse trains"
  fun apply(h: TestHelper) ? =>
    let a: Array[String] val = [
      " < >"
      "> v "
    ]

    let trains = ParseTrains(a)?

    h.assert_eq[USize](trains.size(), 4)
    h.assert_eq[ISize](trains(0)?.xyd()._1, 1)
    h.assert_eq[ISize](trains(0)?.xyd()._2, 0)
    h.assert_is[Direction](trains(0)?.xyd()._3, West)
end

object iso is UnitTest
  fun name(): String => "parse track"
  fun apply(h: TestHelper) ? =>
    let a: Array[String] val = [
      "/>\\"
      "| v"
      "\\-/"
    ]

    let track = ParseTrack(a)?

    h.assert_eq[U8](track(2, 0)?, '\\')
    h.assert_eq[U8](track(1, 0)?, '-')
    h.assert_eq[U8](track(2, 1)?, '|')
end

object iso is UnitTest
  fun name(): String => "train sort"
  fun apply(h: TestHelper) ? =>
    let ts: Array[Train] ref = [
      Train(North, 7, 9)
      Train(South, 1, 3)
      Train(East, 1, 5)
      Train(West, 5, 1)
    ]

    Sort[Array[Train], Train](ts)

    h.assert_is[Direction](ts(0)?.xyd()._3, South)
    h.assert_is[Direction](ts(1)?.xyd()._3, East)
    h.assert_is[Direction](ts(2)?.xyd()._3, West)
    h.assert_is[Direction](ts(3)?.xyd()._3, North)
end

object iso is UnitTest
  fun name(): String => "update trains"
  fun apply(h: TestHelper) ? =>
    let input: Array[String] val = [
      "/>-\\"
      "|  ^"
      "\\--/"
    ]

    let track = ParseTrack(input)?

    let trains = ParseTrains(input)?

    let c1 = UpdateTrains(track, trains)

    h.assert_eq[USize](c1.size(), 0)

    let c2 = UpdateTrains(track, trains)

    h.assert_eq[USize](c2.size(), 0)
end

object iso is UnitTest
  fun name(): String => "update trains +"
  fun apply(h: TestHelper) ? =>
    let input: Array[String] val = [
      " ++++"
      " ++++"
      " ++++"
      " ++++"
      ">++++"
      " ++++"
      " ++++"
    ]

      // " +6++"
      // " +5++"
      // " 34++"
      // " 2+++"
      // "01+++"
      // " ++++"
      // " ++++"


    let track = ParseTrack(input)?

    let trains = ParseTrains(input)?

    var x: ISize = 0
    var y: ISize = 0
    var d: Direction = North

    // enter 1
    UpdateTrains(track, trains)
    (x, y, d) = trains(0)?.xyd()
    h.assert_eq[ISize](x, 1)
    h.assert_eq[ISize](y, 4)
    h.assert_is[Direction](d, East)

    // turn left 2
    UpdateTrains(track, trains)
    (x, y, d) = trains(0)?.xyd()
    h.assert_eq[ISize](x, 1)
    h.assert_eq[ISize](y, 3)
    h.assert_is[Direction](d, North)

    // straight 3
    UpdateTrains(track, trains)
    (x, y, d) = trains(0)?.xyd()
    h.assert_eq[ISize](x, 1)
    h.assert_eq[ISize](y, 2)
    h.assert_is[Direction](d, North)

    // turn right 4
    UpdateTrains(track, trains)
    (x, y, d) = trains(0)?.xyd()
    h.assert_eq[ISize](x, 2)
    h.assert_eq[ISize](y, 2)
    h.assert_is[Direction](d, East)

    // turn left 5
    UpdateTrains(track, trains)
    (x, y, d) = trains(0)?.xyd()
    h.assert_eq[ISize](x, 2)
    h.assert_eq[ISize](y, 1)
    h.assert_is[Direction](d, North)

    // straight 6
    UpdateTrains(track, trains)
    (x, y, d) = trains(0)?.xyd()
    h.assert_eq[ISize](x, 2)
    h.assert_eq[ISize](y, 0)
    h.assert_is[Direction](d, North)
end

object iso is UnitTest
  fun name(): String => "track test"
  fun apply(h: TestHelper) =>
    h.assert_true(_test_train((5, 5, North), "/", (6, 5, East)))
    h.assert_true(_test_train((5, 5, East), "/", (5, 4, North)))
    h.assert_true(_test_train((5, 5, West), "/", (5, 6, South)))
    h.assert_true(_test_train((5, 5, South), "/", (4, 5, West)))

    h.assert_true(_test_train((5, 5, North), "\\", (4, 5, West)))
    h.assert_true(_test_train((5, 5, East), "\\", (5, 6, South)))
    h.assert_true(_test_train((5, 5, West), "\\", (5, 4, North)))
    h.assert_true(_test_train((5, 5, South), "\\", (6, 5, East)))

  fun _test_train(xyd: (ISize, ISize, Direction), cs: String,
    ex_xyd: (ISize, ISize, Direction)): Bool
  =>
    let t = Train(xyd._3, xyd._1, xyd._2)

    for c in cs.values() do
      t.move(c)
    end

    (let new_x, let new_y, let new_d) = t.xyd()

    (ex_xyd._1 == new_x) and (ex_xyd._2 == new_y) and (ex_xyd._3 is new_d)
end
]

    while ts.size() > 0 do
      try
        test(ts.pop()?)
      end
    end

class DirectionFactory
  fun apply(c: U8): Direction ? =>
    match c
    | '^' => North
    | '<' => West
    | '>' => East
    | 'v' => South
    else
      error
    end

primitive Left
  fun apply(walker: GridWalkerOriented): (GridWalkerOriented, LRS) =>
    (walker.ccw().forward(), Straight)

primitive Straight
  fun apply(walker: GridWalkerOriented): (GridWalkerOriented, LRS) =>
    (walker.forward(), Right)

primitive Right
  fun apply(walker: GridWalkerOriented): (GridWalkerOriented, LRS) =>
    (walker.cw().forward(), Left)

type LRS is (Left | Right | Straight)

class Train is (Equatable[Train box] & Comparable[Train box])
  var _walker: GridWalkerOriented
  var _next_intersection_choice: (Left | Right | Straight) = Left

  new create(dir: Direction, x: ISize, y: ISize) =>
    _walker = GridWalkerOriented(x, y, dir)

  fun ref move(cur_track: U8) =>
    _walker = match (cur_track, _walker.xyd()._3)
    | ('|', North) => _walker.forward()
    | ('|', South) => _walker.forward()
    | ('-', East) => _walker.forward()
    | ('-', West) => _walker.forward()
    | ('/', North) => _walker.cw().forward()
    | ('/', West) => _walker.ccw().forward()
    | ('/', East) => _walker.ccw().forward()
    | ('/', South) => _walker.cw().forward()
    | ('\\', North) => _walker.ccw().forward()
    | ('\\', West) => _walker.cw().forward()
    | ('\\', East) => _walker.cw().forward()
    | ('\\', South) => _walker.ccw().forward()
    | ('+', _) =>
      (let w, _next_intersection_choice) = _next_intersection_choice(_walker)
      w
    else
      _walker
    end

  fun xyd(): (ISize, ISize, Direction) =>
    _walker.xyd()

  fun eq(that: Train box): Bool =>
    (let x, let y, _) = _walker.xyd()
    (let tx, let ty, _) = that._walker.xyd()
    (x == tx) and (y == ty)

  fun lt(that: Train box): Bool =>
    (let x, let y, _) = _walker.xyd()
    (let tx, let ty, _) = that._walker.xyd()
    if (x < tx) then
      true
    elseif (x > tx) then
      false
    else
      (y < ty)
    end

  fun string(): String iso^ =>
    (let x, let y, let d) = xyd()

      let d' = match d
      | North => "north"
      | South => "south"
      | East => "east"
      | West => "west"
      end

      " ".join([as Stringable:
        "x ="
        x
        "y ="
        y
        "d ="
        d'].values())

primitive ParseTrains
  fun apply(lines: Array[String] val): Array[Train] ? =>
    let ta = Array[Train]

    for (y, l) in lines.pairs() do
      for (x, c) in l.array().pairs() do
        if (c == '>') or (c == '<') or (c == '^') or (c == 'v') then
          ta.push(Train(DirectionFactory(c)?, x.isize(), y.isize()))
        end
      end
    end

    ta

primitive ParseTrack
  fun apply(lines: Array[String] val): Grid[U8] ? =>
    var max_x: USize = 0

    for l in lines.values() do
      max_x = max_x.max(l.size())
    end

    let grid = Grid[U8](max_x, lines.size(), 0)

    for (y, l) in lines.pairs() do
      for (x, c) in l.array().pairs() do
        let c': U8 = match c
        | 'v' => '|'
        | '^' => '|'
        | '<' => '-'
        | '>' => '-'
        | '|' => '|'
        | '-' => '-'
        | '\\' => '\\'
        | '/' => '/'
        | '/' => '/'
        | '+' => '+'
        | ' ' => ' '
        else
          error
        end
        grid(x, y)? = c'
      end
    end

    grid

primitive UpdateTrains
  fun apply(track: Grid[U8], trains: Array[Train]): Array[Train] =>
    let crashes = Array[Train]

    let st: Array[Train] = trains.clone()
    Sort[Array[Train], Train](st)

    for t in st.values() do
      (let x, let y, _) = t.xyd()
      t.move(try
          track(x.usize(), y.usize())?
        else
          ' '
        end)

      (let nx, let ny, _) = t.xyd()

      if trains.contains(t where predicate = {
        (t1, t2) =>
          if t1 is t2 then
            return false
          end
          (let x1, let y1, _) = t1.xyd()
          (let x2, let y2, _) = t2.xyd()

          (x1 == x2) and (y1 == y2)
      })
      then
        crashes.push(t)
      end
    end

    crashes

primitive UpdateAndRemoveTrains
  fun apply(track: Grid[U8], trains: Array[Train], removed: SetIs[Train]) =>
    let st: Array[Train] = trains.clone()
    Sort[Array[Train], Train](st)

    for t in st.values() do
      if removed.contains(t) then
        continue
      end

      (let x, let y, _) = t.xyd()
      t.move(try
          track(x.usize(), y.usize())?
        else
          ' '
        end)

      try
        for (partner_idx, t2) in trains.pairs() do
          let t1 = t

          if (t1 is t2) or removed.contains(t2) then
            continue
          end

          (let x1, let y1, _) = t1.xyd()
          (let x2, let y2, _) = t2.xyd()

          if (x1 == x2) and (y1 == y2) then
            removed.set(t)
            removed.set(trains(partner_idx)?)
          end
        end
      end
    end

actor Day13 is AOCActorApp
  be part1(file_lines: Array[String] val, args: Array[String] val,
    reporter: AOCActorAppReporter)
  =>
    (let trains, let track) = try
      (ParseTrains(file_lines)?, ParseTrack(file_lines)?)
    else
      reporter.err("could not read trains or track")
      return
    end

    var crashes: Array[Train] = Array[Train]

    var tick: U64 = 0

    while crashes.size() == 0 do
      tick = tick + 1
      crashes = UpdateTrains(track, trains)
    end

    try
      (let x, let y, _) = crashes(0)?.xyd()
      reporter(x.string() + "," + y.string())
    else
      reporter.err("there was an error retrieving crash information")
    end

  be part2(file_lines: Array[String] val, args: Array[String] val,
    reporter: AOCActorAppReporter)
  =>
    (let trains, let track) = try
      (ParseTrains(file_lines)?, ParseTrack(file_lines)?)
    else
      reporter.err("could not read trains or track")
      return
    end

    let removed = SetIs[Train]

    var tick: U64 = 0

    while (trains.size() - removed.size()) > 1 do
      tick = tick + 1
      UpdateAndRemoveTrains(track, trains, removed)
    end

    let ts = SetIs[Train].>union(trains.values()).>remove(removed.values())

    for t in ts.values() do
      (let x, let y, _) = t.xyd()
      reporter(x.string() + "," + y.string())
    end

actor Main
  new create(env: Env) =>
    AOCActorAppRunner(Day13, env, Day13Tests)
