use "aoc-tools"
use "collections"
use "debug"

primitive Parse
  fun date_time_from_string(date_time: String): DateTime ? =>
    // "1518-11-22 00:00"
    let dt = date_time.split(" ")
    let date = dt(0)?
    let time = dt(1)?

    let yymmdd = date.split("-")
    let y = yymmdd(0)?.u64()?
    let mo = yymmdd(1)?.u64()?
    let d = yymmdd(2)?.u64()?

    let hhmm = time.split(":")
    let h = hhmm(0)?.u64()?
    let min = hhmm(1)?.u64()?

    DateTime(y, mo, d, h, min)

  fun event_from_string(ev: String): GuardEvent ?=>
    // [1518-11-22 00:00] Guard #1231 begins shift
    // [1518-04-13 00:00] falls asleep
    // [1518-09-09 00:02] falls asleep
    // [1518-04-06 00:58] wakes up
    // [1518-04-28 00:19] falls asleep

    let date_time = Parse.date_time_from_string(ev.substring(1, 17))?

    let info = ev.substring(19).split(" ")

    match info(0)?
    | "Guard" =>
      let id = info(1)?.substring(1).u64()?
      BeginShift(date_time, id)
    | "falls" =>
      FallsAsleepNoId(date_time)
    | "wakes" =>
      WakesUpNoId(date_time)
    else
      error
    end

class val SleepSession
  let id: U64
  let _start: U64
  let _end: U64

  new val create(id': U64, start': U64, end': U64) =>
    id = id'
    _start = start'
    _end = end'

  fun duration(): U64 =>
    _end - _start

  fun minutes(): Array[U64] val =>
    recover
      let a = Array[U64]
      for m in Range[U64](_start, _end) do
        a.push(m)
      end
      a
    end

class val DateTime is (Comparable[DateTime] & Equatable[DateTime])
  let year: U64
  let month: U64
  let day: U64
  let hour: U64
  let minute: U64

  new val create(y: U64, mo: U64, d: U64, h: U64, min: U64) =>
    year = y
    month = mo
    day = d
    hour = h
    minute = min

  fun eq(that: DateTime box): Bool =>
    (year == that.year) and
      (month == that.month) and
      (day == that.day) and
      (hour == that.hour) and
      (minute == that.minute)

  fun lt(that: DateTime box): Bool =>
    if (year < that.year) then return true end
    if (year > that.year) then return false end

    if (month < that.month) then return true end
    if (month > that.month) then return false end

    if (day < that.day) then return true end
    if (day > that.day) then return false end

    if (hour < that.hour) then return true end
    if (hour > that.hour) then return false end

    if (minute < that.minute) then return true end
    if (minute > that.minute) then return false end

    false

type GuardId is U64

trait val GuardEvent is (Comparable[GuardEvent] & Equatable[GuardEvent])
  fun dt(): DateTime

  fun eq(that: GuardEvent box): Bool =>
    dt().eq(that.dt())

  fun lt(that: GuardEvent box): Bool =>
    dt().lt(that.dt())

  fun string(): String iso^ =>
    let dt' = dt()
    ("-".join([dt'.year; dt'.month; dt'.day].values()) +
      " " +
      ":".join([dt'.hour; dt'.minute].values())
    ).clone()

class val BeginShift is GuardEvent
  let _dt: DateTime
  let _id: GuardId

  new val create(dt': DateTime, id: GuardId) =>
    _dt = dt'
    _id = id

  fun guard_id(): GuardId =>
    _id

  fun dt(): DateTime =>
    _dt

class val FallsAsleepNoId is GuardEvent
  let _dt: DateTime

  new val create(dt': DateTime) =>
    _dt = dt'

  fun add_id(id: GuardId): GuardEvent =>
    FallsAsleep(_dt, id)

  fun dt(): DateTime =>
    _dt

class val FallsAsleep is GuardEvent
  let _dt: DateTime
  let _id: GuardId

  new val create(dt': DateTime, id: GuardId) =>
    _dt = dt'
    _id = id

  fun guard_id(): GuardId =>
    _id

  fun dt(): DateTime =>
    _dt

class val WakesUpNoId is GuardEvent
  let _dt: DateTime

  new val create(dt': DateTime) =>
    _dt = dt'

  fun add_id(id: GuardId): GuardEvent =>
    WakesUp(_dt, id)

  fun dt(): DateTime =>
    _dt

class val WakesUp is GuardEvent
  let _dt: DateTime
  let _id: GuardId

  new val create(dt': DateTime, id: GuardId) =>
    _dt = dt'
    _id = id

  fun guard_id(): GuardId =>
    _id

  fun dt(): DateTime =>
    _dt

type GuardEventWithId is (BeginShift | FallsAsleep | WakesUp)

class Day4 is AOCApp
  fun part1(file_lines: Array[String] val): (String | AOCAppError) ? =>
    let events_no_id = Array[GuardEvent]

    for l in file_lines.values() do
      try
        let e = Parse.event_from_string(l)?
        events_no_id.push(Parse.event_from_string(l)?)
      else
        return AOCAppError("Error parsing line '" + l + "'")
      end
    end

    let sorted_events_no_id =
      Sort[Array[GuardEvent], GuardEvent](events_no_id)

    let sorted_events = Array[GuardEvent]

    var last_id: GuardId = 0
    for e in sorted_events_no_id.values() do
      match e
        | let bs: BeginShift =>
          last_id = bs.guard_id()
          sorted_events.push(bs)
        | let no_id: (FallsAsleepNoId | WakesUpNoId) =>
          let wid = no_id.add_id(last_id)
          sorted_events.push(wid)
        else
          error
        end
    end

    let sleep_sessions = Array[SleepSession]

    var last_sleep_start: U64 = 0

    for e in sorted_events.values() do
      match e
      | let fa: FallsAsleep =>
        last_sleep_start = fa.dt().minute
      | let wu: WakesUp =>
        sleep_sessions.push(SleepSession(wu.guard_id(), last_sleep_start, wu.dt().minute))
      end
    end

    let total_sleep = Map[GuardId, U64]
    let sleep_hists = Map[GuardId, Counter[U64]]

    for ss in sleep_sessions.values() do
      let gid = ss.id
      total_sleep(gid) = (try total_sleep(gid)? else 0 end) + ss.duration()

      let sh = try sleep_hists(gid)? else Counter[U64] end
      for m in ss.minutes().values() do
        sh.add(m)
      end
      sleep_hists(gid) = sh
    end

    var longest_sleeper: (GuardId, U64) = (0, 0)
    for (id, time) in total_sleep.pairs() do
      if time > longest_sleeper._2 then
        longest_sleeper = (id, time)
      end
    end

    (let longest_minute, _) = sleep_hists(longest_sleeper._1)?.max()?

    (longest_sleeper._1 * longest_minute).string()

actor Main
  new create(env: Env) =>
    AOCAppRunner(Day4, env)
