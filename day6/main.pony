use "aoc-tools"
use "collections"
use "debug"

primitive ParseCoord
  fun apply(line: String): (ISize, ISize) ?=>
    let xy = line.clone().>remove(" ").split(",")
    (xy(0)?.isize()?, xy(1)?.isize()?)

primitive ManhattanDist
  fun apply(a: (ISize, ISize), b: (ISize, ISize)): ISize =>
    ((a._1 - b._1).abs() + (a._2 - b._2).abs()).isize()

class Day6 is AOCApp
  fun part1(file_lines: Array[String] val): (String | AOCAppError) ? =>
    let coords = Array[(ISize, ISize)]

    for l in file_lines.values() do
      coords.push(ParseCoord(l)?)
    end

    var min_xy_max_xy: (None | (ISize, ISize, ISize, ISize)) = None

    for c in coords.values() do
      match min_xy_max_xy
      | (let min_x: ISize, let min_y: ISize, let max_x: ISize, let max_y: ISize) =>
        min_xy_max_xy = (c._1.min(min_x),
                         c._2.min(min_y),
                         c._1.max(max_x),
                         c._2.max(max_y))
      else
        min_xy_max_xy = (c._1, c._2, c._1, c._2)
      end
    end

    (let min_x: ISize, let min_y: ISize, let max_x: ISize, let max_y: ISize) = try
      min_xy_max_xy as (ISize, ISize, ISize, ISize)
    else
      (0, 0, 0, 0)
    end

    Debug([min_x; min_y; max_x; max_y])

    let width = max_x - min_x
    let height = max_y - min_y

    let search_max_x = max_x + width
    let search_max_y = max_y + height
    let search_min_x = min_x - width
    let search_min_y = min_y - height

    let grid = SparseGrid[((USize | None), ISize)]

    for (id, c) in coords.pairs() do
      Debug("calculating distance for " + id.string())
      for i in Range[ISize](search_min_x, search_max_x + 1) do
        for j in Range[ISize](search_min_y, search_max_y + 1) do
          let dist_from_c = ManhattanDist(c, (i, j))
          try
            (let grid_id, let grid_dist) = grid(i, j)?
            if  dist_from_c < grid_dist then
              grid(i, j) = (id, dist_from_c)
            elseif dist_from_c == grid_dist then
              grid(i, j) = (None, dist_from_c)
            end
          else
            grid(i, j) = (id, dist_from_c)
          end
        end
      end
    end

    let ss = Array[String]

    // for j in Range[ISize](search_min_y, search_max_y + 1) do
    //   let s = recover iso String end
    //   for i in Range[ISize](search_min_x, search_max_x + 1) do
    //     try
    //       let closest = grid(i, j)?._1 as USize
    //       s.push(closest.u8() + 'A')
    //     else
    //       s.push('.')
    //     end
    //   end
    //   ss.push(consume s)
    // end

    // search borders for infinite areas

    let infinite_ids = SetIs[USize]

    for x in [min_x; max_x].values() do
      for y in Range[ISize](min_y, max_y + 1) do
        try
          infinite_ids.set(grid(x, y)?._1 as USize)
        end
      end
    end

    for y in [min_y; max_y].values() do
      for x in Range[ISize](min_x, max_x + 1) do
        try
          infinite_ids.set(grid(x, y)?._1 as USize)
        end
      end
    end

    // count everybody not in the infinite set
    let area = Counter[USize]

    for i in Range[ISize](search_min_x, search_max_x + 1) do
      for j in Range[ISize](search_min_y, search_max_y + 1) do
        try
          let closest = grid(i, j)?._1 as USize
          if not infinite_ids.contains(closest) then
            area.add(closest)
          end
        end
      end
    end

    Debug("\n".join(ss.values()))
    Debug(",".join(infinite_ids.values()))

    area.max()?._2.string()

actor Main
  new create(env: Env) =>
    AOCAppRunner(Day6, env)
