use "aoc-tools"
use "collections"
use "ponytest"

primitive ParseParticle
  fun apply(s: String): (ISize, ISize, ISize, ISize) ? =>
    // s = "position=< 7,  0> velocity=<-1,  0>"
    let first_split = s.split("<")
    // fs = ["position=";  " 7,  0> velocity="; "-1,  0>"]
    let xys = first_split(1)?.split(">")(0)?
    // xys = " 7, 0"
    let xy: Array[String] = xys.split(",")
    // xy = [" 7"; "0"]
    let x = xy(0)?.clone().>strip().isize()?
    let y = xy(1)?.clone().>strip().isize()?

    let vs = first_split(2)?.split(">")(0)?
    let v = vs.split(",")
    let dx = v(0)?.clone().>strip().isize()?
    let dy = v(1)?.clone().>strip().isize()?

    (x, y, dx, dy)

class Day10Tests is TestList
  fun tag tests(test: PonyTest) =>
    test(_TestParseParticle)

class iso _TestParseParticle is UnitTest
  fun name(): String => "ParseParticle"
  fun apply(h: TestHelper) ? =>
    (let x, let y, let dx, let dy) =
      ParseParticle("position=< 9,  1> velocity=< 0,  2>")?

    h.assert_eq[ISize](x, 9)
    h.assert_eq[ISize](y, 1)
    h.assert_eq[ISize](dx, 0)
    h.assert_eq[ISize](dy, 2)

class Particle
  var _x: ISize
  var _y: ISize
  let _dx: ISize
  let _dy: ISize

  new create(x: ISize, y: ISize, dx: ISize, dy: ISize) =>
    _x = x
    _y = y
    _dx = dx
    _dy = dy

  fun ref update() =>
    _x = _x + _dx
    _y = _y + _dy

  fun xy(): (ISize, ISize) =>
    (_x, _y)

class Particles
  let _particles: Array[Particle]

  new create() =>
    _particles = _particles.create()

  fun ref add(p: Particle) =>
    _particles.push(p)

  fun ref update() =>
    for p in _particles.values() do
      p.update()
    end

  fun ref values(): Iterator[Particle] =>
    _particles.values()

  fun xrange_yrange(): (ISize, ISize, ISize, ISize) =>
    var min_x = ISize.max_value()
    var max_x = ISize.min_value()
    var min_y = ISize.max_value()
    var max_y = ISize.min_value()

    for p in _particles.values() do
      (let x, let y) = p.xy()

      min_x = min_x.min(x)
      max_x = max_x.max(x)
      min_y = min_y.min(y)
      max_y = max_y.max(y)
    end

    (min_x, max_x, min_y, max_y)

actor Day10 is AOCActorApp
  be part1(file_lines: Array[String] val, args: Array[String] val,
    reporter: AOCActorAppReporter)
  =>
    let particles = Particles

    for l in file_lines.values() do
      try
        (let x, let y, let dx, let dy) = ParseParticle(l)?
        particles.add(Particle(x, y, dx, dy))
      else
        reporter.err("Could not parse particle '" + l + "'")
        return
      end
    end

    for seconds in Range(0, 100000) do
      reporter("time is " + seconds.string())
      (let min_x, let max_x, let min_y, let max_y) = particles.xrange_yrange()

      let h = max_y - min_y
      let w = max_x - min_x

      if ((max_x - min_x) < 140) and ((max_y - min_y) < 40) then
        let arr = Array[Array[U8]]

        for _ in Range[ISize](0, h + 4) do
          arr.push(Array[U8].init('.', w.usize() + 4))
        end

        for p in particles.values() do
          (let x, let y) = p.xy()

          let offset_x = (x - min_x) + 2
          let offset_y = (y - min_y) + 2

          try
            arr(offset_y.usize())?(offset_x.usize())? = 'X'
          else
            reporter.err("ERROR ACCESSING ARRAY")
          end
        end

        for a in arr.values() do
          let ia: Array[U8] iso = recover Array[U8] end

          for c in a.values() do
            ia.push(c)
          end

          reporter(String.from_array(consume ia).clone())
        end

        reporter("---------")
        reporter("---------")
        reporter("---------")
      end

      particles.update()
    end

  be part2(file_lines: Array[String] val, args: Array[String] val,
    reporter: AOCActorAppReporter)
  =>
    part1(file_lines, args, reporter)

actor Main
  new create(env: Env) =>
    AOCActorAppRunner(Day10, env, Day10Tests)
