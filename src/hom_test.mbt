///|
using @luna-generic {
  type Hom,
  type Algebra,
  type Prod,
  type Reduct,
  type AddMonoidSig,
  type AddGroupSig,
  type SemiringSig,
  type RingSig,
}

///|
/// Truncation ℤ/2^64 → ℤ/2^32 is a ring homomorphism, because 2^64 ≡ 0 mod
/// 2^32, so the law holds on every input, including values that wrap.
fn int64_to_int() -> Hom[RingSig, Int64, Int] {
  Hom::postulate(x => x.to_int())
}

///|
let small_ints : Array[Int] = [0, 1, -1, 2, -3, 7, 100]

///|
let edge_int64s : Array[Int64] = [
  0L,
  1L,
  -1L,
  2L,
  -3L,
  7L,
  2147483647L,
  3000000000L,
  4294967296L,
  9223372036854775807L,
  -9223372036854775807L - 1L,
]

///|
test "postulated ring hom passes the exact law check" {
  let h = int64_to_int()
  assert_true(h.check(Algebra::ring(), Algebra::ring(), edge_int64s))
  inspect(h.apply(-42L), content="-42")
  inspect(h.apply(4294967296L + 5L), content="5")
}

///|
test "widening Int to Int64 is not a ring hom" {
  // ℤ/2^32 → ℤ/2^64 would need 2^32 ≡ 0 mod 2^64. The law only holds while
  // Int arithmetic does not wrap, so small samples cannot tell.
  let widen : Hom[RingSig, Int, Int64] = Hom::postulate(x => x.to_int64())
  assert_true(widen.check(Algebra::ring(), Algebra::ring(), small_ints))
  assert_false(widen.check(Algebra::ring(), Algebra::ring(), [1, 2147483647]))
}

///|
test "law check rejects a map that only preserves part of the signature" {
  let double : Hom[RingSig, Int64, Int] = Hom::postulate(x => 2 * x.to_int())
  assert_false(double.check(Algebra::ring(), Algebra::ring(), edge_int64s))
  let additive : Hom[AddGroupSig, Int64, Int] = Hom::postulate(x => {
    2 * x.to_int()
  })
  assert_true(
    additive.check(Algebra::add_group(), Algebra::add_group(), edge_int64s),
  )
}

///|
test "identity and composition keep the certificate" {
  let h = Hom::id().then(int64_to_int()).then(Hom::id())
  assert_true(h.check(Algebra::ring(), Algebra::ring(), edge_int64s))
}

///|
test "reducts forget structure and compose" {
  let r : Reduct[RingSig, AddMonoidSig] = @luna-generic.ring_to_semiring.then(
    @luna-generic.semiring_to_add_monoid,
  )
  let h = int64_to_int().forget(r)
  assert_true(
    h.check(Algebra::add_monoid(), Algebra::add_monoid(), edge_int64s),
  )
  let h2 = int64_to_int()
    .forget(@luna-generic.ring_to_add_group)
    .forget(@luna-generic.add_group_to_add_monoid)
    .forget(Reduct::refl())
  assert_true(
    h2.check(Algebra::add_monoid(), Algebra::add_monoid(), edge_int64s),
  )
}

///|
test "monoid and semiring homs upgrade between groups and rings" {
  let m : Hom[AddMonoidSig, Int64, Int] = Hom::postulate(x => 3 * x.to_int())
  assert_true(
    m
    .to_add_group()
    .check(Algebra::add_group(), Algebra::add_group(), edge_int64s),
  )
  // The canonical map out of ℤ holds everywhere.
  let s : Hom[SemiringSig, BigInt, BigInt] = Hom::from_integer()
  let big = BigInt::from_int64(9223372036854775807L) * BigInt::from_int(10)
  let bigs = [
    BigInt::from_int(0),
    BigInt::from_int(1),
    BigInt::from_int(-7),
    big,
    -big,
  ]
  assert_true(s.to_ring().check(Algebra::ring(), Algebra::ring(), bigs))
}

///|
test "pairing and projections" {
  let h = int64_to_int()
  let low : Hom[RingSig, Int64, Int16] = Hom::postulate(x => {
    Int16::from_int(x.to_int())
  })
  let p = Hom::pair(h, low)
  let dst : Algebra[RingSig, Prod[Int, Int16]] = Algebra::prod(
    Algebra::ring(),
    Algebra::ring(),
  )
  assert_true(p.check(Algebra::ring(), dst, edge_int64s))
  for x in edge_int64s {
    assert_eq(p.then(Hom::fst()).apply(x), h.apply(x))
    assert_eq(p.then(Hom::snd()).apply(x), low.apply(x))
  }
}

///|
test "canonical maps out of the integers" {
  // ℤ -> ℤ/2^32 holds even on inputs far outside the Int range.
  let big = BigInt::from_int64(9223372036854775807L) * BigInt::from_int(10)
  let bigs = [BigInt::from_int(0), BigInt::from_int(-5), big, -big]
  let to_int : Hom[RingSig, BigInt, Int] = Hom::from_integer().to_ring()
  assert_true(to_int.check(Algebra::ring(), Algebra::ring(), bigs))
  let to_uint : Hom[SemiringSig, BigInt, UInt] = Hom::from_integer()
  assert_true(to_uint.check(Algebra::semiring(), Algebra::semiring(), bigs))
  let to_double : Hom[SemiringSig, BigInt, Double] = Hom::from_integer()
  assert_true(
    to_double.check(Algebra::semiring(), Algebra::semiring(), [
      BigInt::from_int(0),
      BigInt::from_int(1),
      BigInt::from_int(-5),
      BigInt::from_int(9),
    ]),
  )
}

///|
test "fixed-width sources are not the integers once arithmetic wraps" {
  let h : Hom[SemiringSig, Int, BigInt] = Hom::postulate(x => {
    @luna-generic.lift_to(x)
  })
  assert_true(h.check(Algebra::semiring(), Algebra::semiring(), [1, 1000]))
  assert_false(
    h.check(Algebra::semiring(), Algebra::semiring(), [1, 2147483647]),
  )
}

///|
test "floating-point targets hold only up to rounding" {
  let h : Hom[SemiringSig, BigInt, Float] = Hom::from_integer()
  let samples = [BigInt::from_int(1), BigInt::from_int(16777217)]
  assert_false(h.check(Algebra::semiring(), Algebra::semiring(), samples))
  let close = (l : Float, r : Float) => {
    (l - r).abs() <= (1.0e-6 : Float) * ((1.0 : Float) + r.abs())
  }
  assert_true(
    h.check_by(Algebra::semiring(), Algebra::semiring(), samples, close),
  )
}

///|
test "lax preservation through a custom relation" {
  // Only the lax law holds, while the certificate type claims strictness:
  // do not compose `abs` with other homs.
  let abs : Hom[AddMonoidSig, Double, Double] = Hom::postulate(x => x.abs())
  let samples = [-2.0, 0.0, 1.5, 3.0]
  assert_false(abs.check(Algebra::add_monoid(), Algebra::add_monoid(), samples))
  assert_true(
    abs.check_by(Algebra::add_monoid(), Algebra::add_monoid(), samples, (l, r) => {
      l <= r
    }),
  )
}

///|
test "panic algebras with different signatures are rejected" {
  let wrong : Algebra[RingSig, Int] = Algebra::make([
    { name: "0", arity: 0, eval: _ => 0, },
  ])
  ignore(int64_to_int().check(Algebra::ring(), wrong, edge_int64s))
}

///|
test "custom signatures through Algebra::make" {
  let max_src : Algebra[MaxSig, Int] = Algebra::make([
    {
      name: "max",
      arity: 2,
      eval: xs => if xs[0] > xs[1] { xs[0] } else { xs[1] },
    },
  ])
  let max_dst : Algebra[MaxSig, Int64] = Algebra::make([
    {
      name: "max",
      arity: 2,
      eval: xs => if xs[0] > xs[1] { xs[0] } else { xs[1] },
    },
  ])
  let monotone : Hom[MaxSig, Int, Int64] = Hom::postulate(x => x.to_int64() * 3L)
  assert_true(monotone.check(max_src, max_dst, small_ints))
  let flip : Hom[MaxSig, Int, Int64] = Hom::postulate(x => -x.to_int64())
  assert_false(flip.check(max_src, max_dst, small_ints))
}

///|
enum MaxSig {}
