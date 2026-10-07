///|
using @luna-generic {type Section}

///|
/// `Int` is ℤ/2^32: reduction is the canonical ring hom out of ℤ, and
/// sign extension picks the representative in [-2^31, 2^31).
fn int_section() -> Section[RingSig, Int, BigInt] {
  Section::postulate(Hom::postulate(x => x.to_int()), x => BigInt::from_int(x))
}

///|
fn int64_section() -> Section[RingSig, Int64, BigInt] {
  Section::postulate(Hom::postulate(x => x.to_int64()), x => {
    BigInt::from_int64(x)
  })
}

///|
let edge_ints : Array[Int] = [
  0, 1, -1, 2, -3, 7, 65536, 2147483647, -2147483648,
]

///|
test "Int is a quotient of BigInt with sign-extending representatives" {
  let s = int_section()
  assert_true(s.check(edge_ints))
  assert_true(s.check_ops(Algebra::ring(), Algebra::ring(), edge_ints))
  // The same map is not a homomorphism: 2147483647 + 1 wraps in Int only.
  let as_hom : Hom[RingSig, Int, BigInt] = Hom::postulate(x => {
    BigInt::from_int(x)
  })
  assert_false(as_hom.check(Algebra::ring(), Algebra::ring(), edge_ints))
}

///|
test "the lift agrees with the operations exactly on representatives" {
  let s = int_section()
  let max = s.lift(2147483647)
  let one = s.lift(1)
  let sum = max + one
  // 2^31 is not a representative, so the lift of the wrapped sum differs
  // from it by the carry 2^32.
  assert_false(s.is_representative(sum))
  inspect(s.lift(2147483647 + 1), content="-2147483648")
  inspect(sum - s.lift(2147483647 + 1), content="4294967296")
  // 7 + 1 stays a representative, so the lift is exact there.
  assert_true(s.is_representative(s.lift(7) + one))
  assert_eq(s.lift(7 + 1), s.lift(7) + one)
}

///|
test "normal forms decide congruence" {
  let s = int_section()
  let k = BigInt::from_int64(4294967296L)
  let a = BigInt::from_int(5)
  assert_eq(s.normalize(a + k * BigInt::from_int(3)), a)
  assert_eq(s.normalize(a - k), s.normalize(a))
  assert_true(s.is_representative(a))
  assert_false(s.is_representative(k))
}

///|
test "widening Int to Int64 is a section of truncation" {
  // Not a ring hom, but a perfectly good lift.
  let truncate : Hom[RingSig, Int64, Int] = Hom::postulate(x => x.to_int())
  let s = Section::postulate(truncate, x => x.to_int64())
  assert_true(s.check(edge_ints))
  assert_true(s.check_ops(Algebra::ring(), Algebra::ring(), edge_ints))
}

///|
test "sections compose" {
  let truncate : Hom[RingSig, Int64, Int] = Hom::postulate(x => x.to_int())
  let widen = Section::postulate(truncate, x => x.to_int64())
  let s = widen.then(int64_section())
  assert_true(s.check(edge_ints))
  assert_true(s.check_ops(Algebra::ring(), Algebra::ring(), edge_ints))
  for x in edge_ints {
    assert_eq(s.lift(x), int_section().lift(x))
  }
}

///|
test "sections forget along reducts" {
  let s = int_section().forget(@luna-generic.ring_to_add_group)
  let _ : Section[AddGroupSig, Int, BigInt] = s
  assert_true(
    s.check_ops(Algebra::add_group(), Algebra::add_group(), edge_ints),
  )
}

///|
test "lifts that leave the class are rejected" {
  let reduce : Hom[RingSig, BigInt, Int] = Hom::postulate(x => x.to_int())
  // Dropping the sign: lift(-3) = 3 is not in the class of -3.
  let by_abs = Section::postulate(reduce, x => BigInt::from_int(x.abs()))
  assert_false(by_abs.check(edge_ints))
  // Going through Float: 16777217 rounds to 16777216.
  let by_float = Section::postulate(reduce, x => {
    BigInt::from_int(Float::from_int(x).to_int())
  })
  assert_true(by_float.check([0, 1, -3, 65536]))
  assert_false(by_float.check([16777217]))
}

///|
test "the law does not choose the representatives" {
  // [0, 2^32) is another set of representatives. It passes the law, but it
  // does not preserve the signed order of Int: -1 < 0 lifts to 2^32 - 1 > 0.
  let reduce : Hom[RingSig, BigInt, Int] = Hom::postulate(x => x.to_int())
  let unsigned = Section::postulate(reduce, x => {
    BigInt::from_uint(x.reinterpret_as_uint())
  })
  assert_true(unsigned.check(edge_ints))
  assert_true(unsigned.check_ops(Algebra::ring(), Algebra::ring(), edge_ints))
  assert_true(unsigned.lift(-1) > unsigned.lift(0))
  assert_true(int_section().lift(-1) < int_section().lift(0))
}

///|
fn[Z : @luna-generic.Integral + Eq] canonical_section_holds(
  samples : Array[Z],
) -> Bool {
  let s : Section[SemiringSig, Z, BigInt] = Section::of_integral()
  s.check(samples) &&
  s.check_ops(Algebra::semiring(), Algebra::semiring(), samples)
}

///|
test "every integer type is a quotient of BigInt" {
  assert_true(canonical_section_holds(edge_ints))
  assert_true(canonical_section_holds([(0 : Int16), 1, -1, 300, 32767, -32768]))
  assert_true(
    canonical_section_holds([
      0L,
      1L,
      -1L,
      4294967296L,
      9223372036854775807L,
      -9223372036854775807L - 1L,
    ]),
  )
  assert_true(
    canonical_section_holds([0U, 1U, 65536U, 2147483648U, 4294967295U]),
  )
  assert_true(canonical_section_holds([(0 : UInt16), 1, 256, 65535]))
  assert_true(
    canonical_section_holds([0UL, 1UL, 4294967296UL, 18446744073709551615UL]),
  )
  let big = BigInt::from_int64(9223372036854775807L) * BigInt::from_int(10)
  assert_true(canonical_section_holds([BigInt::from_int(-7), big, -big]))
}

///|
test "signed canonical sections upgrade to rings" {
  let s : Section[RingSig, Int, BigInt] = Section::of_integral().to_ring()
  assert_true(s.check_ops(Algebra::ring(), Algebra::ring(), edge_ints))
  for x in edge_ints {
    assert_eq(s.lift(x), int_section().lift(x))
  }
}

///|
test "fixed-width canonical maps reduce modulo 2^k" {
  let big = BigInt::from_int64(9223372036854775807L) * BigInt::from_int(4) +
    BigInt::from_int(7)
  let as_int : Int = @luna-generic.FromInteger::from_integer(big)
  let as_uint16 : UInt16 = @luna-generic.FromInteger::from_integer(
    BigInt::from_int(-1),
  )
  inspect(as_int, content="3")
  inspect(as_uint16, content="65535")
}

///|
test "lift_to is a hom exactly when the target modulus divides" {
  // ℤ/2^64 -> ℤ/2^32 is the truncation, a ring hom even across wrapping.
  let truncate : Hom[RingSig, Int64, Int] = Hom::postulate(x => {
    @luna-generic.lift_to(x)
  })
  let samples = [
    0L,
    1L,
    -1L,
    3000000000L,
    4294967296L,
    9223372036854775807L,
    -9223372036854775807L - 1L,
  ]
  assert_true(truncate.check(Algebra::ring(), Algebra::ring(), samples))
  // ℤ/2^32 -> ℤ/2^64 is not.
  let widen : Hom[RingSig, Int, Int64] = Hom::postulate(x => {
    @luna-generic.lift_to(x)
  })
  assert_false(widen.check(Algebra::ring(), Algebra::ring(), [1, 2147483647]))
}

///|
test "lift_to keeps the chosen representative" {
  let d : Double = @luna-generic.lift_to(-7)
  inspect(d, content="-7")
  let b : BigInt = @luna-generic.lift_to(4294967295U)
  inspect(b, content="4294967295")
  // The unsigned representative 2^32 - 1 lands on -1 in Int.
  let i : Int = @luna-generic.lift_to(4294967295U)
  inspect(i, content="-1")
}
