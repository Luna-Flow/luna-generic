///|
using @test {assert_eq}

///|
fn[T : AddMonoid] add_monoid_identity(x : T) -> T {
  x + T::zero()
}

///|
fn[T : MulMonoid] mul_monoid_identity(x : T) -> T {
  x * T::one()
}

///|
fn[T : Nat] nat_semiring_identity(x : T) -> T {
  x * T::one() + T::zero()
}

///|
fn[T : Integral] integral_normalize(x : T) -> BigInt {
  Integral::normalize(x)
}

///|
fn[F : NatHomomorphism] nat_hom_from_uint(x : UInt) -> F {
  NatHomomorphism::from_nat(x)
}

///|
fn[F : NatHomomorphism] nat_hom_from_uint16(x : UInt16) -> F {
  NatHomomorphism::from_nat(x)
}

///|
fn[F : NatHomomorphism] nat_hom_from_uint64(x : UInt64) -> F {
  NatHomomorphism::from_nat(x)
}

///|
fn[F : IntegralHomomorphism] integral_hom_from_int(x : Int) -> F {
  IntegralHomomorphism::from_integral(x)
}

///|
fn[F : IntegralHomomorphism] integral_hom_from_int16(x : Int16) -> F {
  IntegralHomomorphism::from_integral(x)
}

///|
fn[F : IntegralHomomorphism] integral_hom_from_int64(x : Int64) -> F {
  IntegralHomomorphism::from_integral(x)
}

///|
fn[F : IntegralHomomorphism] integral_hom_from_bigint(x : BigInt) -> F {
  IntegralHomomorphism::from_integral(x)
}

///|
fn[T : AddGroup] add_group_cancel(x : T) -> T {
  x - x
}

///|
fn[T : Ring] ring_roundtrip(x : T) -> T {
  x + T::zero()
}

///|
fn[T : Field] field_roundtrip(x : T) -> T {
  x / T::one()
}

///|
test {
  let z0 : BigInt = integral_hom_from_int(3)
  let z1 : Float = integral_hom_from_int(3)
  let z2 : Double = integral_hom_from_int(3)
  let z3 : Float = integral_hom_from_int(3 + 4)
  let z4 : Float = integral_hom_from_int(3) + integral_hom_from_int(4)
  let z5 : Double = integral_hom_from_int(3 + 4)
  let z6 : Double = integral_hom_from_int(3) + integral_hom_from_int(4)
  inspect(add_monoid_identity(3), content="3")
  inspect(mul_monoid_identity(3), content="3")
  inspect(add_group_cancel(3), content="0")
  inspect(ring_roundtrip(3), content="3")
  assert_eq(z0, BigInt::from_int(3))
  assert_eq(integral_normalize(3), BigInt::from_int(3))
  assert_eq(z1, (3.0 : Float))
  assert_eq(z2, (3.0 : Double))
  assert_eq(z3, z4)
  assert_eq(z5, z6)
}

///|
test {
  inspect(add_monoid_identity(3.0), content="3")
  inspect(mul_monoid_identity(3.0), content="3")
  inspect(add_group_cancel(3.0), content="0")
  inspect(ring_roundtrip(3.0), content="3")
  inspect(field_roundtrip(3.0), content="3")
}

///|
test {
  assert_eq(add_monoid_identity((3.0 : Double)), (3.0 : Double))
  assert_eq(mul_monoid_identity((3.0 : Double)), (3.0 : Double))
  assert_eq(add_group_cancel((3.0 : Double)), (0.0 : Double))
  assert_eq(ring_roundtrip((3.0 : Double)), (3.0 : Double))
  assert_eq(field_roundtrip((3.0 : Double)), (3.0 : Double))
}

///|
test {
  let z : BigInt = integral_hom_from_int16((3 : Int16))
  let zf : Float = integral_hom_from_int16((3 : Int16))
  let zd : Double = integral_hom_from_int16((3 : Int16))
  assert_eq(add_monoid_identity((3 : Int16)), (3 : Int16))
  assert_eq(mul_monoid_identity((3 : Int16)), (3 : Int16))
  assert_eq(add_group_cancel((3 : Int16)), (0 : Int16))
  assert_eq(ring_roundtrip((3 : Int16)), (3 : Int16))
  assert_eq(z, BigInt::from_int(3))
  assert_eq(integral_normalize((-3 : Int16)), BigInt::from_int(-3))
  assert_eq(Int16::abs((-3 : Int16)), (3 : Int16))
  assert_eq(Num::signum((-3 : Int16)), (-1 : Int16))
  assert_eq(Num::signum((0 : Int16)), (0 : Int16))
  assert_eq(Num::signum((3 : Int16)), (1 : Int16))
  assert_eq(zf, (3.0 : Float))
  assert_eq(zd, (3.0 : Double))
}

///|
test {
  let z : BigInt = integral_hom_from_int64(3L)
  let zf : Float = integral_hom_from_int64(3L)
  let zd : Double = integral_hom_from_int64(3L)
  assert_eq(add_monoid_identity(3L), 3L)
  assert_eq(mul_monoid_identity(3L), 3L)
  assert_eq(add_group_cancel(3L), 0L)
  assert_eq(ring_roundtrip(3L), 3L)
  assert_eq(z, BigInt::from_int64(3L))
  assert_eq(integral_normalize(-3L), BigInt::from_int64(-3L))
  assert_eq(Int64::abs(-3L), 3L)
  assert_eq(Num::signum(-3L), -1L)
  assert_eq(Num::signum(0L), 0L)
  assert_eq(Num::signum(3L), 1L)
  assert_eq(zf, (3.0 : Float))
  assert_eq(zd, (3.0 : Double))
}

///|
test {
  let z0 : BigInt = nat_hom_from_uint(3U)
  let z1 : Float = nat_hom_from_uint(3U)
  let z2 : Double = nat_hom_from_uint(3U)
  let z3 : Float = nat_hom_from_uint(3U + 4U)
  let z4 : Float = nat_hom_from_uint(3U) + nat_hom_from_uint(4U)
  let z5 : Double = nat_hom_from_uint(3U + 4U)
  let z6 : Double = nat_hom_from_uint(3U) + nat_hom_from_uint(4U)
  assert_eq(add_monoid_identity(3U), 3U)
  assert_eq(mul_monoid_identity(3U), 3U)
  assert_eq(nat_semiring_identity(3U), 3U)
  assert_eq(integral_normalize(3U), BigInt::from_uint(3U))
  assert_eq(z0, BigInt::from_uint(3U))
  assert_eq(z1, (3.0 : Float))
  assert_eq(z2, (3.0 : Double))
  assert_eq(z3, z4)
  assert_eq(z5, z6)
}

///|
test {
  let z : BigInt = nat_hom_from_uint16((3 : UInt16))
  let zf : Float = nat_hom_from_uint16((3 : UInt16))
  let zd : Double = nat_hom_from_uint16((3 : UInt16))
  assert_eq(add_monoid_identity((3 : UInt16)), (3 : UInt16))
  assert_eq(mul_monoid_identity((3 : UInt16)), (3 : UInt16))
  assert_eq(nat_semiring_identity((3 : UInt16)), (3 : UInt16))
  assert_eq(integral_normalize((3 : UInt16)), BigInt::from_uint(3U))
  assert_eq(z, BigInt::from_int(3))
  assert_eq(zf, (3.0 : Float))
  assert_eq(zd, (3.0 : Double))
}

///|
test {
  let z : BigInt = nat_hom_from_uint64(3UL)
  let zf : Float = nat_hom_from_uint64(3UL)
  let zd : Double = nat_hom_from_uint64(3UL)
  assert_eq(add_monoid_identity(3UL), 3UL)
  assert_eq(mul_monoid_identity(3UL), 3UL)
  assert_eq(nat_semiring_identity(3UL), 3UL)
  assert_eq(integral_normalize(3UL), BigInt::from_uint64(3UL))
  assert_eq(z, BigInt::from_uint64(3UL))
  assert_eq(zf, (3.0 : Float))
  assert_eq(zd, (3.0 : Double))
}

///|
test {
  let x = BigInt::from_string("3")
  let z0 : BigInt = integral_hom_from_bigint(x)
  let z1 : Float = integral_hom_from_bigint(x)
  let z2 : Double = integral_hom_from_bigint(x)
  let z3 : Float = integral_hom_from_bigint(x + BigInt::from_int(4))
  let z4 : Float = integral_hom_from_bigint(x) +
    integral_hom_from_bigint(BigInt::from_int(4))
  let z5 : Double = integral_hom_from_bigint(x + BigInt::from_int(4))
  let z6 : Double = integral_hom_from_bigint(x) +
    integral_hom_from_bigint(BigInt::from_int(4))
  assert_eq(add_monoid_identity(x), x)
  assert_eq(mul_monoid_identity(x), x)
  assert_eq(add_group_cancel(x), BigInt::from_int(0))
  assert_eq(ring_roundtrip(x), x)
  assert_eq(z0, x)
  assert_eq(integral_normalize(x), x)
  assert_eq(z1, (3.0 : Float))
  assert_eq(z2, (3.0 : Double))
  assert_eq(Num::abs(BigInt::from_string("-3")), x)
  assert_eq(Num::signum(BigInt::from_string("-3")), BigInt::from_int(-1))
  assert_eq(Num::signum(BigInt::from_int(0)), BigInt::from_int(0))
  assert_eq(Num::signum(x), BigInt::from_int(1))
  assert_eq(z3, z4)
  assert_eq(z5, z6)
}
