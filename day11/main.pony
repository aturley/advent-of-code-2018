use "aoc-tools"
use "collections"
use "ponytest"

class val SkipBoxRecord

class val BoxRecord
  let box_size: USize
  let max_x: USize
  let max_y: USize
  let max_value: I64
  let box_total: I64

  new val create(bs: USize, mx: USize, my: USize, mv: I64, bt: I64) =>
    box_size = bs
    max_x = mx
    max_y = my
    max_value = mv
    box_total = bt

  fun val apply(): (USize, USize, USize, I64, I64) =>
    (box_size, max_x, max_y, max_value, box_total)

primitive PowerLevel
  fun apply(x: ISize, y: ISize, gsn: U64): I64 =>
    // Find the fuel cell's rack ID, which is its X coordinate plus 10
    let rack_id = x + 10
    // Begin with a power level of the rack ID times the Y coordinate
    var power_level = rack_id.i64() * y.i64()
    // Increase the power level by the value of the grid serial number
    power_level = power_level + gsn.i64()
    // Set the power level to itself multiplied by the rack ID
    power_level = power_level * rack_id.i64()
    // Keep only the hundreds digit of the power level
    power_level =
      ((power_level / 100) - ((power_level / 1000) * 10)).abs().i64()
    // Subtract 5 from the power level
    power_level = power_level - 5

    power_level

class Day11Tests is TestList
  fun tag tests(test: PonyTest) =>
    test(_TestPowerLevel)

class iso _TestPowerLevel is UnitTest
  fun name(): String => "PowerLevel"
  fun apply(h: TestHelper) =>
    h.assert_eq[I64](PowerLevel(3, 5, 8), 4)
    h.assert_eq[I64](PowerLevel(122, 79, 57), -5)
    h.assert_eq[I64](PowerLevel(217, 196, 39), 0)
    h.assert_eq[I64](PowerLevel(101, 153, 71), 4)

actor Day11 is AOCActorApp
  be part1(file_lines: Array[String] val, args: Array[String] val,
    reporter: AOCActorAppReporter)
  =>
    let rack_id = try
      file_lines(0)?.u64()?
    else
      reporter.err("could not read rack id")
      return
    end

    let grid = Grid[I64](300, 300, 0)

    for x in Range(1, 301) do
      for y in Range(1, 301) do
        try
          grid(x - 1, y - 1)? = PowerLevel(x.isize(), y.isize(), rack_id)
        else
          reporter.err("error writing to " + x.string() + "," + y.string())
          return
        end
      end
    end

    var max_x: USize = 0
    var max_y: USize = 0
    var max_square_value: I64 = 0

    for x in Range(1, 302 - 3) do
      for y in Range(1, 302 - 3) do
        var local_max_x: USize = 0
        var local_max_y: USize = 0
        var local_max_value: I64 = 0
        var local_square_value: I64 = 0
        for i in Range(0, 3) do
          for j in Range(0, 3) do
            try
              let v = grid((x + i).usize() - 1, (y + j).usize() - 1)?
              local_square_value = local_square_value + v
              if v > local_max_value then
                local_max_x = x
                local_max_y = y
                local_max_value = v
              end
            else
              reporter.err("could not read grid at " + x.string() + "," + y.string())
              return
            end
          end
        end

        if local_square_value > max_square_value then
          max_square_value = local_square_value
          max_x = local_max_x
          max_y = local_max_y
        end
      end
    end

    reporter(max_x.string() + "," + max_y.string())

  be part2(file_lines: Array[String] val, args: Array[String] val,
    reporter: AOCActorAppReporter)
  =>
    let rack_id = try
      file_lines(0)?.u64()?
    else
      reporter.err("could not read rack id")
      return
    end

    var original_grid = Grid[(BoxRecord | SkipBoxRecord)](300, 300, SkipBoxRecord)

    var cur_grid = Grid[(BoxRecord | SkipBoxRecord)](300, 300, SkipBoxRecord)

    var prev_grid = Grid[(BoxRecord | SkipBoxRecord)](300, 300, SkipBoxRecord)

    for x in Range(1, 301) do
      for y in Range(1, 301) do
        try
          let pl = PowerLevel(x.isize(), y.isize(), rack_id)
          prev_grid(x - 1, y - 1)? = BoxRecord(1, x, y, pl, pl)
          original_grid(x - 1, y - 1)? = BoxRecord(1, x, y, pl, pl)
        else
          reporter.err("error writing to " + x.string() + "," + y.string())
          return
        end
      end
    end

    var max_x: USize = 0
    var max_y: USize = 0
    var max_square_value: I64 = 0
    var best_size: USize = 0

    let max_sz: USize = try
      args(3)?.usize()?
    else
      300
    end

    for sz in Range(2, max_sz + 1) do
      var far_x: USize = 0
      var far_y: USize = 0
      for x in Range(1, 302 - sz) do
        for y in Range(1, 302 - sz) do
          far_x = x
          far_y = y
          var local_max_x: USize = 0
          var local_max_y: USize = 0
          var local_max_value: I64 = 0
          var local_square_value: I64 = 0

          // get the last biggest box

          (_, local_max_x, local_max_y, local_max_value, local_square_value) = try
            match prev_grid((x).usize() - 1, (y).usize() - 1)?
            | let bv: BoxRecord =>
              bv()
            else
              error
            end
          else
            reporter.err("couldn't look up in prev grid")
            return
          end

          // get bottom row
          for i in Range(0, sz) do
            try
              let br =
                original_grid((x + i).usize() - 1, (y + (sz - 1)).usize() - 1)?
              match br
              | let v: BoxRecord =>
                local_square_value = local_square_value + v.max_value
                if v.max_value > local_max_value then
                  local_max_x = x
                  local_max_y = y
                  local_max_value = v.max_value
                end
              else
                reporter.err("didn't get box record at AMC " + x.string() + "," + y.string())
                return
              end
            else
              reporter.err("could not read grid at " + x.string() + "," + y.string())
              return
            end
          end

          // get right col, skip last

          for i in Range(0, sz - 1) do
            try
              let br =
                original_grid((x + (sz - 1)).usize() - 1, (y + i).usize() - 1)?
              match br
              | let v: BoxRecord =>
                local_square_value = local_square_value + v.max_value
                if v.max_value > local_max_value then
                  local_max_x = x
                  local_max_y = y
                  local_max_value = v.max_value
                end
              else
                reporter.err("didn't get box record at BVH " + x.string() + "," + y.string())
                return
              end
            else
              reporter.err("could not read grid at " + x.string() + "," + y.string())
              return
            end
          end

          if local_square_value > max_square_value then
            max_square_value = local_square_value
            max_x = local_max_x
            max_y = local_max_y
            best_size = sz
          end

          try
            cur_grid((x - 1).usize(), (y - 1).usize())? =
              BoxRecord(sz, local_max_x, local_max_y, local_square_value, local_square_value)
          else
            reporter.err("could not get QXY " + x.string() + "," + y.string())
            return
          end

        end
      end

      prev_grid = cur_grid

      cur_grid = Grid[(BoxRecord | SkipBoxRecord)](300, 300, SkipBoxRecord)
    end

    reporter(max_x.string() + "," + max_y.string() + "," + best_size.string())

actor Main
  new create(env: Env) =>
    AOCActorAppRunner(Day11, env, Day11Tests)
