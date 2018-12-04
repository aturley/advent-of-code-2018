use "aoc-tools"
use "collections"

type GuardId is U64

primitive SleepData
  fun apply(lines: Array[String] val): (MapIs[GuardId, U64], MapIs[GuardId, Counter[U64]]) ? =>
    let sorted_input = Sort[Array[String], String](lines.clone())

    let sleep_lengths = MapIs[GuardId, U64]
    let sleep_hists = MapIs[GuardId, Counter[U64]]

    var last_guid: GuardId = 0
    var last_sleep_start: U64 = 0

    for e in sorted_input.values() do
      let parts = e.split(" ")

      match parts(2)?
      | "Guard" =>
        last_guid = parts(3)?.clone().>remove("#").u64()?
      | "falls" =>
        last_sleep_start = parts(1)?.substring(3, 5).u64()?
      | "wakes" =>
        let wake = parts(1)?.substring(3, 5).u64()?
        let sleep_time = wake - last_sleep_start
        sleep_lengths.upsert(last_guid, sleep_time, {(v1, v2) => v1 + v2})?

        let hist = try
          sleep_hists(last_guid)?
        else
          let hist' = Counter[U64]
          sleep_hists(last_guid) = hist'
          hist'
        end

        for x in Range[U64](last_sleep_start, wake) do
          hist.add(x)
        end
      end
    end

    (sleep_lengths, sleep_hists)

class Day4 is AOCApp
  fun part1(file_lines: Array[String] val): (String | AOCAppError) ? =>
    (let total_sleep, let sleep_hists) = SleepData(file_lines)?

    var longest_sleeper: (GuardId, U64) = (0, 0)
    for (id, time) in total_sleep.pairs() do
      if time > longest_sleeper._2 then
        longest_sleeper = (id, time)
      end
    end

    (let longest_minute, _) = sleep_hists(longest_sleeper._1)?.max()?

    (longest_sleeper._1 * longest_minute).string()

  fun part2(file_lines: Array[String] val): (String | AOCAppError) ? =>
    (let total_sleep, let sleep_hists) = SleepData(file_lines)?

    var minute: U64 = 0
    var guard_id: GuardId = 0
    var minute_count: USize = 0

    for (gid, hist) in sleep_hists.pairs() do
      (let m, let mc) = hist.max()?
      if mc > minute_count then
        minute = m
        minute_count = mc
        guard_id = gid
      end
    end

    (guard_id * minute).string()

actor Main
  new create(env: Env) =>
    AOCAppRunner(Day4, env)
