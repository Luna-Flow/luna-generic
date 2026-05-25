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
fn[T : Integral] integral_to_float(x : T) -> Float {
  Integral::to_float(x)
}

///|
fn[T : Integral] integral_to_double(x : T) -> Double {
  Integral::to_double(x)
}

///|
fn[T : Integral] integral_float_add_hom(x : T, y : T) -> Bool {
  Integral::to_float(x + y) == Integral::to_float(x) + Integral::to_float(y)
}

///|
fn[T : Integral] integral_float_mul_hom(x : T, y : T) -> Bool {
  Integral::to_float(x * y) == Integral::to_float(x) * Integral::to_float(y)
}

///|
fn[T : Integral] integral_double_add_hom(x : T, y : T) -> Bool {
  Integral::to_double(x + y) == Integral::to_double(x) + Integral::to_double(y)
}

///|
fn[T : Integral] integral_double_mul_hom(x : T, y : T) -> Bool {
  Integral::to_double(x * y) == Integral::to_double(x) * Integral::to_double(y)
}

///|
test {
  inspect(add_monoid_identity(3), content="3")
  inspect(mul_monoid_identity(3), content="3")
  inspect(add_group_cancel(3), content="0")
  inspect(ring_roundtrip(3), content="3")
  assert_eq(integral_to_float(3), (3.0 : Float))
  assert_eq(integral_to_double(3), (3.0 : Double))
  assert_eq(integral_float_add_hom(3, 4), true)
  assert_eq(integral_float_mul_hom(3, 4), true)
  assert_eq(integral_double_add_hom(3, 4), true)
  assert_eq(integral_double_mul_hom(3, 4), true)
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
  assert_eq(add_monoid_identity((3 : Int16)), (3 : Int16))
  assert_eq(mul_monoid_identity((3 : Int16)), (3 : Int16))
  assert_eq(add_group_cancel((3 : Int16)), (0 : Int16))
  assert_eq(ring_roundtrip((3 : Int16)), (3 : Int16))
  assert_eq(Int16::abs((-3 : Int16)), (3 : Int16))
  assert_eq(Num::signum((-3 : Int16)), (-1 : Int16))
  assert_eq(Num::signum((0 : Int16)), (0 : Int16))
  assert_eq(Num::signum((3 : Int16)), (1 : Int16))
  assert_eq(integral_to_float((3 : Int16)), (3.0 : Float))
  assert_eq(integral_to_double((3 : Int16)), (3.0 : Double))
  assert_eq(integral_float_add_hom((3 : Int16), (4 : Int16)), true)
  assert_eq(integral_float_mul_hom((3 : Int16), (4 : Int16)), true)
  assert_eq(integral_double_add_hom((3 : Int16), (4 : Int16)), true)
  assert_eq(integral_double_mul_hom((3 : Int16), (4 : Int16)), true)
}

///|
test {
  assert_eq(add_monoid_identity(3L), 3L)
  assert_eq(mul_monoid_identity(3L), 3L)
  assert_eq(add_group_cancel(3L), 0L)
  assert_eq(ring_roundtrip(3L), 3L)
  assert_eq(Int64::abs(-3L), 3L)
  assert_eq(Num::signum(-3L), -1L)
  assert_eq(Num::signum(0L), 0L)
  assert_eq(Num::signum(3L), 1L)
  assert_eq(integral_to_float(3L), (3.0 : Float))
  assert_eq(integral_to_double(3L), (3.0 : Double))
  assert_eq(integral_float_add_hom(3L, 4L), true)
  assert_eq(integral_float_mul_hom(3L, 4L), true)
  assert_eq(integral_double_add_hom(3L, 4L), true)
  assert_eq(integral_double_mul_hom(3L, 4L), true)
}

///|
test {
  assert_eq(add_monoid_identity(3U), 3U)
  assert_eq(mul_monoid_identity(3U), 3U)
  assert_eq(nat_semiring_identity(3U), 3U)
  assert_eq(integral_to_float(3U), (3.0 : Float))
  assert_eq(integral_to_double(3U), (3.0 : Double))
  assert_eq(integral_float_add_hom(3U, 4U), true)
  assert_eq(integral_float_mul_hom(3U, 4U), true)
  assert_eq(integral_double_add_hom(3U, 4U), true)
  assert_eq(integral_double_mul_hom(3U, 4U), true)
}

///|
test {
  assert_eq(add_monoid_identity((3 : UInt16)), (3 : UInt16))
  assert_eq(mul_monoid_identity((3 : UInt16)), (3 : UInt16))
  assert_eq(nat_semiring_identity((3 : UInt16)), (3 : UInt16))
  assert_eq(integral_to_float((3 : UInt16)), (3.0 : Float))
  assert_eq(integral_to_double((3 : UInt16)), (3.0 : Double))
  assert_eq(integral_float_add_hom((3 : UInt16), (4 : UInt16)), true)
  assert_eq(integral_float_mul_hom((3 : UInt16), (4 : UInt16)), true)
  assert_eq(integral_double_add_hom((3 : UInt16), (4 : UInt16)), true)
  assert_eq(integral_double_mul_hom((3 : UInt16), (4 : UInt16)), true)
}

///|
test {
  assert_eq(add_monoid_identity(3UL), 3UL)
  assert_eq(mul_monoid_identity(3UL), 3UL)
  assert_eq(nat_semiring_identity(3UL), 3UL)
  assert_eq(integral_to_float(3UL), (3.0 : Float))
  assert_eq(integral_to_double(3UL), (3.0 : Double))
  assert_eq(integral_float_add_hom(3UL, 4UL), true)
  assert_eq(integral_float_mul_hom(3UL, 4UL), true)
  assert_eq(integral_double_add_hom(3UL, 4UL), true)
  assert_eq(integral_double_mul_hom(3UL, 4UL), true)
}
