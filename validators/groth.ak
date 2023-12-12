use aiken/list

const k0 = 6

const q0 = 43

type Poly {
  polinomials: List<Int>,
}

//let r_ec = 13
const r_sign = -1

fn sum(xs: List<Int>) -> Int {
  list.foldr(xs, 0, fn(n, total) { n + total })
}

fn compare(left: Int, right: Int) -> Ordering {
  if left < right {
    Less
  } else if left > right {
    Greater
  } else {
    Equal
  }
}

fn greater_than(greater: List<Int>, lesser: List<Int>) {
  let step = list.map2(greater, lesser, fn(x, y) { compare(x, y) })
  list.all(step, fn(n) { n == Greater })
}

test greater_than_1() {
  greater_than([4, 5, 6], [1, 2, 3]) && !greater_than([1, 0, 5], [1, 2, 3])
}

test sum_1() {
  sum([1, 2, 3]) == 6
}

// Validator Functions

fn gdc(a: Int, b: Int, s1: Int, t1: Int, s2: Int, t2: Int) -> (Int, Int, Int) {
  let remainder = a % b
  let result = a / b
  let s3 = s1 - result * s2
  let t3 = t1 - result * t2

  if remainder == 0 {
    (b, s2, t2)
  } else {
    gdc(b, remainder, s2, t2, s3, t3)
  }
}

fn euclides_integer(a: Int, b: Int) -> (Int, Int, Int) {
  let (r, s, t) = gdc(a, b, 1, 0, 0, 1)
  if r < 0 {
    (r * -1, s * -1, t * -1)
  } else {
    (r, s, t)
  }
}

test euclides_integer_1() {
  euclides_integer(180, 130) == (10, -5, 7)
}

test euclides_integer_2() {
  euclides_integer(13, 7) == (1, -1, 2)
}

test euclides_integer_3() {
  euclides_integer(13, 5) == (1, 2, -5)
}

fn mod0(n: Int) {
  n % q0
}

fn mult_ff(x: Int, y: Int) -> Int {
  mod0(x * y)
}

// Modulo inverse of integer

fn inverse_integer(n: Int) -> Int {
  if mod0(n) == 0 {
    fail @"[wrong parameter] Division by zero"
  } else {
    let (_, _, t) = euclides_integer(q0, n)
    // Esta computación parece no ser necesaria | mod0(t)
    mod0(t)
  }
}

test inverse_integer_1() {
  inverse_integer(6) * 6 % q0 == 1
}

test inverse_integer_2() {
  inverse_integer(20) * 20 % q0 == 1
}

test inverse_integer_3() {
  inverse_integer(133) * 133 % q0 == 1
}

// Sum Poly

fn add_poly(ps: Poly, qs: Poly) -> Poly {
  let result = list.map2(ps.polinomials, qs.polinomials, fn(a, b) { a + b })
  Poly { polinomials: result }
}

test add_poly_1() {
  add_poly(Poly { polinomials: [6,
        6] }, Poly { polinomials: [6, 6] }) == Poly { polinomials: [12, 12] }
}

// Substraction Poly 

fn sub_poly(ps: Poly, qs: Poly) -> Poly {
  let result = list.map2(ps.polinomials, qs.polinomials, fn(a, b) { a - b })
  Poly { polinomials: result }
}

test sub_poly_1() {
  sub_poly(Poly { polinomials: [6,
        6] }, Poly { polinomials: [3, 3] }) == Poly { polinomials: [3, 3] }
}

test sub_poly_2() {
  sub_poly(Poly { polinomials: [1,
        2, 3] }, Poly { polinomials: [2] }) == Poly { polinomials: [-1] }
}

test sub_poly_3() {
  sub_poly(Poly { polinomials: [1,
        2, 3] }, Poly { polinomials: [0] }) == Poly { polinomials: [1] }
}

test sub_poly_4() {
  sub_poly(Poly { polinomials: [1,
        2, 3] }, Poly { polinomials: [] }) == Poly { polinomials: [] }
}

// Multiplication Poly (Revisar)

fn mult_poly(ps: Poly, qs: Poly) -> Poly {
  let sequence =
    ps.polinomials
      |> list.length()
      |> list.range(1, _)

  let result =
    list.map(
      sequence,
      fn(x) {
        let xs = list.take(ps.polinomials, x)
        let ys = list.reverse(list.take(qs.polinomials, x))
        let step = list.map2(xs, ys, fn(x, y) { x * y })
        sum(step)
      },
    )
  Poly { polinomials: result }
}

test mult_poly_1() {
  let result =
    mult_poly(Poly { polinomials: [1, 2, 3] }, Poly { polinomials: [1, 2, 3] })
  result == Poly { polinomials: [1, 4, 10] }
}

test mult_poly_2() {
  let result =
    mult_poly(Poly { polinomials: [1, 2, 3] }, Poly { polinomials: [3, 2, 1] })
  result == Poly { polinomials: [3, 8, 14] }
}

test mult_poly_3() {
  let result =
    mult_poly(Poly { polinomials: [1, 2, 3] }, Poly { polinomials: [3, 2, -1] })
  result == Poly { polinomials: [3, 8, 12] }
}

test mult_poly_4() {
  let result =
    mult_poly(
      Poly { polinomials: [1, 2, 3] },
      Poly { polinomials: [-3, -2, -1] },
    )
  result == Poly { polinomials: [-3, -8, -14] }
}

test mult_poly_5() {
  let result =
    mult_poly(Poly { polinomials: [1, 2, 3] }, Poly { polinomials: [0] })
  result == Poly { polinomials: [0, 0, 0] }
}

test mult_poly_6() {
  let result =
    mult_poly(Poly { polinomials: [1, 2, 3] }, Poly { polinomials: [2] })
  result == Poly { polinomials: [2, 2, 2] }
}

fn fit(ps: Poly) -> Poly {
  let xs =
    k0 - list.length(ps.polinomials) + 1
      |> list.repeat(0, _)
  let result = list.concat(ps.polinomials, xs)

  Poly { polinomials: result }
}

test fit_1() {
  fit(Poly { polinomials: [1,
        0] }) == Poly { polinomials: [1, 0, 0, 0, 0, 0, 0] }
}

fn dec(x: Int) -> Int {
  x - 1
}

// Revisar!!! Parece ser que es un simple length - 1
fn degree(ps: Poly) -> Int {
  expect Some(n) = list.last(ps.polinomials)
  when ps.polinomials is {
    [_x] -> 0
    _ ->
      if mod0(n) == 0 {
        let step =
          ps.polinomials |> list.length |> dec() |> list.take(ps.polinomials, _)
        degree(Poly { polinomials: step })
      } else {
        ps.polinomials |> list.length() |> dec()
      }
  }
}

test degree_1() {
  degree(Poly { polinomials: [1,
        2,
        3] }) == 2 && degree(Poly { polinomials: [0,
        0,
        0] }) == 0 && degree(Poly { polinomials: [0,
        0, 0, 0, 0, 0, 0, 7] }) == 7
}

fn dme_go(ds: List<Int>, qs: List<Int>, rs: List<Int>) -> (List<Int>, List<Int>) {
  let len = list.length(ds)
  let zero = Poly { polinomials: [0, 0, 0, 0, 0, 0, 0] }
  let deg_d = degree(Poly { polinomials: ds })
  let deg_r = degree(Poly { polinomials: rs })
  expect Some(condition) = rs |> list.head()
  if deg_r == 0 && mod0(condition) == 0 {
    // qs y zero son lo mismo en todo caso.
    (qs, zero.polinomials)
  } else if //} else if compare(deg_d, deg_r) == Greater {
  deg_r < deg_d {
    (qs, rs)
  } else {
    let t1 = list.repeat(0, deg_r - deg_d)
    expect Some(r2) = list.at(rs, deg_r)
    expect Some(d2) = list.at(ds, deg_d)
    let t2 = d2 |> inverse_integer() |> mult_ff(r2)
    let t3 = list.repeat(0, len - deg_r + deg_d - 1)
    let t = t1 |> list.concat([t2]) |> list.concat(t3)
    let result1 = ds
    let result2 = add_poly(Poly { polinomials: qs }, Poly { polinomials: t })
    let result3 =
      mult_poly(Poly { polinomials: ds }, Poly { polinomials: t })
        |> sub_poly(Poly { polinomials: rs }, _)
    dme_go(result1, result2.polinomials, result3.polinomials)
  }
}

fn div_mod_e(ns: Poly, ds: Poly) -> (Poly, Poly) {
  let zero = Poly { polinomials: [0, 0, 0, 0, 0, 0, 0] }
  let (xs, ys) = dme_go(ds.polinomials, zero.polinomials, ns.polinomials)
  (Poly { polinomials: xs }, Poly { polinomials: ys })
}

test div_mod_e_1() {
  div_mod_e(Poly { polinomials: [1] }, Poly { polinomials: [1] }) == (
    Poly { polinomials: [1] },
    Poly { polinomials: [0, 0, 0, 0, 0, 0, 0] },
  )
}

test div_mod_e_2() {
  div_mod_e(Poly { polinomials: [0] }, Poly { polinomials: [0] }) == (
    Poly { polinomials: [0, 0, 0, 0, 0, 0, 0] },
    Poly { polinomials: [0, 0, 0, 0, 0, 0, 0] },
  )
}

test div_mod_e_3() {
  div_mod_e(Poly { polinomials: [22,
        23] }, Poly { polinomials: [22,
        23] }) == (
    Poly { polinomials: [1, 0] },
    Poly { polinomials: [0, 0, 0, 0, 0, 0, 0] },
  )
}

test div_mod_e_4() {
  div_mod_e(Poly { polinomials: [22,
        0] }, Poly { polinomials: [22,
        23] }) == (
    Poly { polinomials: [0, 0, 0, 0, 0, 0, 0] },
    Poly { polinomials: [22, 0] },
  )
}

test div_mod_e_5() {
  div_mod_e(Poly { polinomials: [1,
        2,
        3] }, Poly { polinomials: [3,
        2,
        1] }) == (
    Poly { polinomials: [3, 0, 0] },
    Poly { polinomials: [-8, -4, 0] },
  )
}

// Euclides Polinomials

fn euclides_poly_go(
  r0: Poly,
  s0: Poly,
  t0: Poly,
  r1: Poly,
  s1: Poly,
  t1: Poly,
) -> (Poly, Poly, Poly) {
  let zero = Poly { polinomials: [0, 0, 0, 0, 0, 0, 0] }
  if r1 == zero {
    (r0, s0, t0)
  } else {
    let (q, r2) = div_mod_e(r0, r1)
    let s2 = mult_poly(q, s1) |> sub_poly(s0, _)
    let t2 = mult_poly(q, t1) |> sub_poly(t0, _)
    euclides_poly_go(r1, s1, t1, r2, s2, t2)
  }
}

fn euclides_poly(xs: Poly, ys: Poly) -> (Poly, Poly, Poly) {
  let zero = Poly { polinomials: [0, 0, 0, 0, 0, 0, 0] }
  let one = Poly { polinomials: [1, 0, 0, 0, 0, 0, 0] }
  let (rs, ss, ts) = euclides_poly_go(xs, one, zero, ys, zero, one)
  expect Some(value) = list.head(rs.polinomials)
  let i0 = inverse_integer(value)
  let result1 = list.map(rs.polinomials, fn(x) { mult_ff(i0, x) })
  let result2 = list.map(ss.polinomials, fn(x) { mult_ff(i0, x) })
  let result3 = list.map(ts.polinomials, fn(x) { mult_ff(i0, x) })
  (
    Poly { polinomials: result1 },
    Poly { polinomials: result2 },
    Poly { polinomials: result3 },
  )
}

test euclides_poly_1() {
  euclides_poly(
    Poly { polinomials: [1, 2, 3] },
    Poly { polinomials: [3, 2, 1] },
  ) == (
    Poly { polinomials: [1, 0, 0] },
    Poly { polinomials: [0, 18, 0] },
    Poly { polinomials: [29, 32, 0] },
  )
}

test euclides_poly_2() {
  euclides_poly(
    Poly { polinomials: [1, 2, 3] },
    Poly { polinomials: [3, 2, 0] },
  ) == (
    Poly { polinomials: [1, 0, 0] },
    Poly { polinomials: [7, 0, 0] },
    Poly { polinomials: [41, 11, 0] },
  )
}

fn poly_mod(xs: Poly, ys: Poly) -> Poly {
  let (_x, y) = div_mod_e(xs, ys)
  y
}

// Note that list has to be same length.
test poly_mod_1() {
  poly_mod(Poly { polinomials: [1,
        3] }, Poly { polinomials: [1, 2] }) == Poly { polinomials: [-22, -43] }
}

test poly_mod_2() {
  poly_mod(Poly { polinomials: [1,
        3] }, Poly { polinomials: [0, 5] }) == Poly { polinomials: [1, -172] }
}

test poly_mod_3() {
  poly_mod(Poly { polinomials: [1,
        2,
        3] }, Poly { polinomials: [3,
        2, 1] }) == Poly { polinomials: [-8, -4, 0] }
}

fn poly_mod0(xs: Poly) -> Poly {
  let poly0 = Poly { polinomials: [6, 0, 0, 0, 0, 0, 1] }
  let ps = poly_mod(xs, poly0)
  let result = list.map(ps.polinomials, fn(x) { mod0(x) })
  Poly { polinomials: result }
}

fn mult_ef(xs: Poly, ys: Poly) -> Poly {
  let poly0 = Poly { polinomials: [6, 0, 0, 0, 0, 0, 1] }
  let tail_0s = list.repeat(0, k0)
  let x = list.concat(xs.polinomials, tail_0s)
  let y = list.concat(ys.polinomials, tail_0s)
  let o = list.concat(poly0.polinomials, tail_0s)
  let zs =
    mult_poly(Poly { polinomials: x }, Poly { polinomials: y })
      |> poly_mod(Poly { polinomials: o })
  let zss = list.take(zs.polinomials, k0 + 1)
  let result = list.map(zss, fn(x) { mod0(x) })
  Poly { polinomials: result }
}

test mult_ef_1() {
  mult_ef(Poly { polinomials: [1,
        2,
        3] }, Poly { polinomials: [1,
        2, 3] }) == Poly { polinomials: [1, 4, 10, 12, 9, 0, 0] }
}

test mult_ef_2() {
  mult_ef(Poly { polinomials: [-4, 5, 6] }, Poly { polinomials: [7, -5, 10] }) == Poly {
    polinomials: [15, 12, 20, 20, 17, 0, 0],
  }
}

test mult_ef_3() {
  mult_ef(
    Poly { polinomials: [0, 4, 5, -7] },
    Poly { polinomials: [8, 11, 12] },
  ) == Poly { polinomials: [0, 32, 41, 4, 26, 2, 0] }
}

fn inverse_poly(ps: Poly) -> Poly {
  let poly0 = Poly { polinomials: [6, 0, 0, 0, 0, 0, 1] }
  let (_, _, t) = euclides_poly(poly0, ps)
  poly_mod(t, poly0)
}

test inverse_poly_1() {
  inverse_poly(Poly { polinomials: [1,
        2,
        3, 4, 5, 6, 7] }) == Poly { polinomials: [14, 21, 11, 10, 25, 37, 0] }
}

test inverse_poly_2() {
  inverse_poly(Poly { polinomials: [70,
        1, 12, 3, 0, 0, 0] }) == Poly { polinomials: [17, 27, 31, 20, 0, 2, 0] }
}

test inverse_poly_3() {
  inverse_poly(Poly { polinomials: [-12, -4, 6, 25, 13, 7, 3] }) == Poly {
    polinomials: [13, 28, 40, 35, 33, 21, 0],
  }
}

test inverse_poly_4() {
  inverse_poly(Poly { polinomials: [0,
        1,
        2, 3, 4, 5, 6] }) == Poly { polinomials: [13, 28, 40, 35, 33, 21, 0] }
}

type Eliptic_Curve_Int {
  ECI { x: Int, y: Int }
  InfinityI
}

fn eci_equivalence(ec1: Eliptic_Curve_Int, ec2: Eliptic_Curve_Int) -> Bool {
  let input = (ec1, ec2)
  when input is {
    (ECI { x: x1, y: y1 }, ECI { x: x2, y: y2 }) ->
      mod0(x2 - x1) == 0 && mod0(y2 - y1) == 0
    (InfinityI, InfinityI) -> True
    (InfinityI, _any) -> False
    (_any, InfinityI) -> False
  }
}

test eci_equivalence_1() {
  eci_equivalence(InfinityI, InfinityI) == True
}

test eci_equivalence_2() {
  eci_equivalence(ECI { x: 1, y: 2 }, ECI { x: 1, y: 2 }) == True
}

test eci_equivalence_3() {
  eci_equivalence(InfinityI, ECI { x: 2, y: 2 }) == False
}

test eci_equivalence_4() {
  eci_equivalence(ECI { x: 2, y: 2 }, InfinityI) == False
}

fn int_congruence(x: Int, y: Int) -> Bool {
  mod0(x - y) == 0
}

fn semigroup_eci(
  ec1: Eliptic_Curve_Int,
  ec2: Eliptic_Curve_Int,
) -> Eliptic_Curve_Int {
  if InfinityI == ec1 {
    ec2
  } else if InfinityI == ec2 {
    ec1
  } else {
    expect ECI { x: x1, y: y1 } = ec1
    expect ECI { x: x2, y: y2 } = ec2
    if int_congruence(x1, x2) && int_congruence(y1, -y2) {
      InfinityI
    } else if int_congruence(x1, x2) && int_congruence(y1, y2) {
      let (x, y) = (x1, y1)
      let m =
        y
          |> mult_ff(2)
          |> inverse_integer()
          |> mult_ff(mult_ff(x, x))
          |> mult_ff(3)
      let xp = mult_ff(m, m) - mult_ff(2, x)
      let yp = mult_ff(m, x - xp) - y
      let result1 = mod0(xp)
      let result2 = mod0(yp)
      ECI { x: result1, y: result2 }
    } else {
      let m = x2 - x1 |> inverse_integer() |> mult_ff(y2 - y1)
      let x3 = mult_ff(m, m) - x1 - x2
      let y3 = ( x1 - x3 |> mult_ff(m) ) - y1
      ECI { x: mod0(x3), y: mod0(y3) }
    }
  }
}

test semigroup_eci_1() {
  semigroup_eci(ECI { x: 1, y: 1 }, InfinityI) == ECI { x: 1, y: 1 }
}

test semigroup_eci_2() {
  semigroup_eci(InfinityI, ECI { x: 1, y: 1 }) == ECI { x: 1, y: 1 }
}

test semigroup_eci_3() {
  semigroup_eci(ECI { x: 1, y: 1 }, ECI { x: 1, y: 1 }) == ECI { x: 11, y: 27 }
}

test semigroup_eci_4() {
  semigroup_eci(ECI { x: 9, y: 3 }, ECI { x: 9, y: 2 }) == ECI { x: 31, y: 16 }
}

test semigroup_eci_5() {
  semigroup_eci(ECI { x: 13, y: 15 }, ECI { x: 33, y: 34 }) == ECI {
    x: 38,
    y: 15,
  }
}

type Eliptic_Curve_Poly {
  ECP { x: Poly, y: Poly }
  InfinityP
}

fn ecp_equivalence(ecp1: Eliptic_Curve_Poly, ecp2: Eliptic_Curve_Poly) -> Bool {
  let zero = Poly { polinomials: [0, 0, 0, 0, 0, 0, 0] }
  let input = (ecp1, ecp2)
  when input is {
    (ECP { x: x1, y: y1 }, ECP { x: x2, y: y2 }) ->
      ( sub_poly(x2, x1) |> poly_mod0() ) == zero && (
        sub_poly(y2, y1) |> poly_mod0()
      ) == zero
    (ECP { x: _x1, y: _y1 }, InfinityP) -> False
    (InfinityP, ECP { x: _x1, y: _y1 }) -> False
    (InfinityP, InfinityP) -> False
  }
}

test ecp_equivalence_1() {
  ecp_equivalence(
    ECP { x: Poly { polinomials: [0, 1] }, y: Poly { polinomials: [0, 1] } },
    ECP { x: Poly { polinomials: [0, 1] }, y: Poly { polinomials: [0, 1] } },
  ) == True
}

test ecp_equivalence_2() {
  ecp_equivalence(
    ECP { x: Poly { polinomials: [1, 1] }, y: Poly { polinomials: [0, 1] } },
    ECP { x: Poly { polinomials: [0, 1] }, y: Poly { polinomials: [0, 1] } },
  ) == False
}

test ecp_equivalence_3() {
  ecp_equivalence(
    ECP { x: Poly { polinomials: [1] }, y: Poly { polinomials: [0, 1] } },
    ECP { x: Poly { polinomials: [0, 1] }, y: Poly { polinomials: [0, 1] } },
  ) == False
}

fn poly_congruence(p: Poly, q: Poly) -> Bool {
  let zero = Poly { polinomials: [0, 0, 0, 0, 0, 0, 0] }
  let poly0 = Poly { polinomials: [6, 0, 0, 0, 0, 0, 1] }
  poly_mod(sub_poly(p, q), poly0) == zero
}

test poly_congruence_1() {
  poly_congruence(
    Poly { polinomials: [1, 2, 3] },
    Poly { polinomials: [3, 2, 1] },
  ) == False
}

test poly_congruence_2() {
  poly_congruence(
    Poly { polinomials: [1, 2, 3] },
    Poly { polinomials: [0, 0, 0] },
  ) == False
}

test poly_congruence_3() {
  poly_congruence(
    Poly { polinomials: [1, 0, 3] },
    Poly { polinomials: [1, 0, 3] },
  ) == True
}

fn negate(n: Int) -> Int {
  -n
}

test negate_1() {
  negate(1) == -1
}

test negate_2() {
  negate(0) == 0
}

fn negate_poly(ns: Poly) -> Poly {
  let list = ns.polinomials |> list.map(fn(x) { negate(x) })
  Poly { polinomials: list }
}

test negate_poly_1() {
  negate_poly(Poly { polinomials: [0,
        1, 2, 3] }) == Poly { polinomials: [0, -1, -2, -3] }
}

fn embed(n: Int) -> Poly {
  fit(Poly { polinomials: [n] })
}

test embed_1() {
  embed(-1) == Poly { polinomials: [-1, 0, 0, 0, 0, 0, 0] }
}

test embed_2() {
  embed(3) == Poly { polinomials: [3, 0, 0, 0, 0, 0, 0] }
}

fn semigroup_ecp(
  ecp1: Eliptic_Curve_Poly,
  ecp2: Eliptic_Curve_Poly,
) -> Eliptic_Curve_Poly {
  if InfinityP == ecp1 {
    ecp2
  } else if InfinityP == ecp2 {
    ecp1
  } else {
    expect ECP { x: x1, y: y1 } = ecp1
    expect ECP { x: x2, y: y2 } = ecp2
    if poly_congruence(x1, x2) && poly_congruence(y1, negate_poly(y2)) {
      InfinityP
    } else if poly_congruence(x1, x2) && poly_congruence(y1, y2) {
      let (x, y) = (x1, y1)
      let m =
        y
          |> mult_ef(embed(2))
          |> inverse_poly()
          |> mult_ef(mult_ef(x, x))
          |> mult_ef(embed(3))
      let xp = mult_ef(m, m) |> sub_poly(mult_ef(embed(2), x))
      let yp = sub_poly(x, xp) |> mult_ef(m) |> sub_poly(y)
      ECP { x: poly_mod0(xp), y: poly_mod0(yp) }
    } else {
      let m = sub_poly(y2, y1) |> mult_ef(inverse_poly(sub_poly(x2, x1)))
      let x3 = mult_ef(m, m) |> sub_poly(x1) |> sub_poly(x2)
      let y3 = mult_ef(m, sub_poly(x1, x2)) |> sub_poly(y1)
      ECP { x: poly_mod0(x3), y: poly_mod0(y3) }
    }
  }
}

test semigroup_ecp_1() {
  semigroup_ecp(
    ECP { x: Poly { polinomials: [0, 1] }, y: Poly { polinomials: [0, 1] } },
    ECP { x: Poly { polinomials: [0, 1] }, y: Poly { polinomials: [0, 1] } },
  ) == ECP {
    x: Poly { polinomials: [0, 41, 13, 0, 0, 0, 0] },
    y: Poly { polinomials: [0, 42] },
  }
}

test semigroup_ecp_2() {
  semigroup_ecp(
    ECP { x: Poly { polinomials: [0] }, y: Poly { polinomials: [0] } },
    ECP { x: Poly { polinomials: [0] }, y: Poly { polinomials: [0] } },
  ) == InfinityP
}

test semigroup_ecp_3() {
  semigroup_ecp(
    ECP { x: Poly { polinomials: [1, 1] }, y: Poly { polinomials: [0, 1] } },
    ECP { x: Poly { polinomials: [1, 1] }, y: Poly { polinomials: [0, 1] } },
  ) == ECP {
    x: Poly { polinomials: [33, 7, 13, 0, 5, 20, 0] },
    y: Poly { polinomials: [24, 19] },
  }
}

fn miller_comb(
  ecp1: Eliptic_Curve_Poly,
  ecp2: Eliptic_Curve_Poly,
  b: Int,
  ps: (Poly, Poly, Poly, Poly),
) -> (Poly, Poly, Poly, Poly) {
  expect ECP { x: xp, y: yp } = ecp1
  expect ECP { x: xq, y: yq } = ecp2
  let zero = Poly { polinomials: [0, 0, 0, 0, 0, 0, 0] }
  let (f1, f2, x, y) = ps
  let m =
    embed(2)
      |> mult_ef(y)
      |> inverse_poly()
      |> mult_ef(mult_ef(x, x) |> mult_ef(embed(3)))
  //|> poly_mod0()
  let f1p =
    sub_poly(xq, x)
      |> mult_ef(m)
      |> sub_poly(y, _)
      |> sub_poly(yq, _)
      |> mult_ef(f1)
      |> mult_ef(f1)
  //|> poly_mod0()
  let f2p =
    mult_ef(m, m)
      |> sub_poly(mult_ef(embed(2), x), _)
      |> add_poly(xq)
      |> mult_ef(f2)
      |> mult_ef(f2)
  //|> poly_mod0()
  let xr = m |> mult_ef(m) |> sub_poly(mult_ef(embed(2), x))
  let yr =
    xr
      |> sub_poly(x)
      |> mult_ef(m)
      |> sub_poly(negate_poly(y), _)
  //|> poly_mod0()
  let condition2 = sub_poly(xr, xp) |> poly_congruence(zero)
  if b == 0 || condition2 {
    (f1p, f2p, xr, yr)
  } else {
    if b == 1 {
      let ms = sub_poly(xr, xp) |> inverse_poly() |> mult_ef(sub_poly(yr, yp))
      let f1s =
        sub_poly(xq, xr)
          |> mult_ef(ms)
          |> sub_poly(yr, _)
          |> sub_poly(yq, _)
          |> mult_ef(f1p)
      let f2s =
        add_poly(xp, xr)
          |> add_poly(xq)
          |> sub_poly(mult_ef(ms, ms))
          |> mult_ef(f2p)
      let xs = mult_ef(ms, ms) |> sub_poly(xr) |> sub_poly(xp)
      let ys = sub_poly(xs, xr) |> mult_ef(ms) |> sub_poly(negate_poly(yr), _)
      (f1s, f2s, xs, ys)
    } else {
      fail @"Error: Not binary"
    }
  }
}

fn miller_generic(
  bits: List<Int>,
  ecp1: Eliptic_Curve_Poly,
  ecp2: Eliptic_Curve_Poly,
) -> Poly {
  let one = Poly { polinomials: [1, 0, 0, 0, 0, 0, 0] }
  expect ECP { x: xp, y: yp } = ecp1
  expect ECP { x: xq, y: _yq } = ecp2
  let bits_p = list.take(bits, list.length(bits) - 1)
  let (g1, g2, xt, _yt) =
    list.foldr(
      bits_p,
      (one, one, xp, yp),
      fn(i, total) { miller_comb(ecp1, ecp2, i, total) },
    )

  //let g1p = sub_poly(xq, xt) |> poly_mod0() |> mult_ef(poly_mod0(g1))
  let g1p = sub_poly(xq, xt) |> mult_ef(g1)
  mult_ef(g1p, poly_mod0(inverse_poly(g2)))
}

fn miller(bits: List<Int>, p: Eliptic_Curve_Poly, q: Eliptic_Curve_Poly) -> Poly {
  if
  ecp_equivalence(p, InfinityP) || ecp_equivalence(q, InfinityP) || ecp_equivalence(
    p,
    q,
  ){
  
    embed(r_sign)
  } else {
    miller_generic(bits, p, q)
  }
}

fn embed_ec(eci: Eliptic_Curve_Int) -> Eliptic_Curve_Poly {
  when eci is {
    InfinityI -> InfinityP
    ECI { x: n, y: m } -> ECP { x: embed(n), y: embed(m) }
  }
}

test embed_ec_1() {
  embed_ec(ECI { x: 19, y: 5 }) == ECP {
    x: Poly { polinomials: [19, 0, 0, 0, 0, 0, 0] },
    y: Poly { polinomials: [5, 0, 0, 0, 0, 0, 0] },
  }
}

test embed_ec_2() {
  embed_ec(ECI { x: 5, y: 0 }) == ECP {
    x: Poly { polinomials: [5, 0, 0, 0, 0, 0, 0] },
    y: Poly { polinomials: [0, 0, 0, 0, 0, 0, 0] },
  }
}

test embed_ec_3() {
  embed_ec(ECI { x: -19, y: 11 }) == ECP {
    x: Poly { polinomials: [-19, 0, 0, 0, 0, 0, 0] },
    y: Poly { polinomials: [11, 0, 0, 0, 0, 0, 0] },
  }
}

type G1 =
  Eliptic_Curve_Int

type G2 =
  Eliptic_Curve_Poly

fn pairing(p1: G1, q2: G2) -> Poly {
  let bits_r =
    [1, 0, 1, 1]
  let f_p_q = miller(bits_r, embed_ec(p1), q2)
  let f_q_p = miller(bits_r, q2, embed_ec(p1))
  embed(r_sign) |> mult_ef(f_p_q) |> mult_ef(inverse_poly(f_q_p))
}

test pairing_1() {
  let ps = fit(Poly { polinomials: [0, 0, 17] })
  let qs = fit(Poly { polinomials: [0, 0, 0, 15] })

  pairing(ECI { x: 26, y: 9 }, ECP { x: ps, y: qs }) == Poly {
    polinomials: [41, 25, 24, 27, 10, 35, 0],
  }
}
