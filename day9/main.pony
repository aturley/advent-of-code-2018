use "aoc-tools"
use "collections"
use "debug"

class RingNodeFactor

class RingNode[T]
  let _v: T!
  var _l: (None | RingNode[T]) = None
  var _r: (None | RingNode[T]) = None

  new create(v: T, lr: (None | (RingNode[T], RingNode[T])) = None) =>
    _v = v

    match lr
    | (let l: RingNode[T], let r: RingNode[T]) =>
      _l = l
      _r = r
    | None =>
      _l = this
      _r = this
    end

  fun value(): this->T! =>
    _v

  fun ref left(): RingNode[T] =>
    try _l as RingNode[T] else this end

  fun ref right(): RingNode[T] =>
    try _r as RingNode[T] else this end

  fun ref insert_left(v: T): RingNode[T] =>
    let l = left()
    let n = RingNode[T](consume v, (l, this))
    l._r = n
    _l = n
     n

  fun ref insert_right(v: T): RingNode[T] =>
    let r = right()
    let n = RingNode[T](consume v, (this, r))
    r._l = n
    _r = n
    n

  fun ref remove(): (RingNode[T], RingNode[T]) =>
    let l = left()
    let r = right()
    l._r = r
    r._l = l
    (l, r)

primitive ParseGame
  fun apply(line: String): (USize, USize) ? =>
    let parts = line.split(" ")
    (parts(0)?.usize()?, parts(6)?.usize()?)

class Game
  let _players: USize
  let _scores: Array[U64]
  var _circle: RingNode[U64]
  var _cur_marble: U64
  var _cur_player: USize

  new create(players: USize) =>
    _players = players
    _scores = Array[U64].init(0, players)
    _circle = RingNode[U64](0)
    _cur_marble = 1
    _cur_player = 0

  fun ref play() =>
    if (_cur_marble % 23) == 0 then
      try
        _scores(_cur_player)? = _scores(_cur_player)? + _cur_marble
        for _ in Range(0, 7) do
          _circle = _circle.left()
        end
        _scores(_cur_player)? = _scores(_cur_player)? + _circle.value()
        (_, _circle) = _circle.remove()
      end
    else
      _circle = _circle.right().insert_right(_cur_marble)
    end

    _cur_marble = _cur_marble + 1
    _cur_player = (_cur_player + 1) % _players

  fun ref values_from_circle(start_at_zero: Bool = false): Array[String] val =>
    let arr = recover iso Array[String] end

    var cur = if start_at_zero then
      var ss = _circle
      let s = _circle
      ss = ss.right()
      while true do
        if (s is ss) or (ss.value() == 0) then
          break
        end
        ss = ss.right()
      end
      ss
    else
      _circle
    end

    let start = cur

    while true do
      let s = if start_at_zero and (cur is _circle) then
        "(" + cur.value().string() + ")"
      else
        cur.value().string()
      end

      arr.push(s)
      cur = cur.right()
      if start is cur then
        break
      end
    end

    consume arr

  fun scores(): this->Array[U64]! =>
    _scores

actor Day9 is AOCActorApp
  be part1(file_lines: Array[String] val, args: Array[String] val,
    reporter: AOCActorAppReporter)
  =>
    (let players, let last_value) = try
      ParseGame(file_lines(0)?)?
    else
      reporter.err("error parsing the input")
      return
    end

    let game = Game(players)

    for _ in Range(0, last_value) do
      game.play()
    end

    var max_score: U64 = 0
    for s in game.scores().values() do
      max_score = max_score.max(s)
    end

    reporter(max_score.string())

  be part2(file_lines: Array[String] val, args: Array[String] val,
    reporter: AOCActorAppReporter)
  =>
    (let players, let last_value) = try
      ParseGame(file_lines(0)?)?
    else
      reporter.err("error parsing the input")
      return
    end

    let game = Game(players)

    for _ in Range(0, last_value* 100) do
      game.play()
    end

    var max_score: U64 = 0
    for s in game.scores().values() do
      max_score = max_score.max(s)
    end

    reporter(max_score.string())

actor Main
  new create(env: Env) =>
    AOCActorAppRunner(Day9, env)
