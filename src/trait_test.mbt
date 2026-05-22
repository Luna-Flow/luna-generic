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
  inspect(add_monoid_identity(3), content="3")
  inspect(mul_monoid_identity(3), content="3")
  inspect(add_group_cancel(3), content="0")
  inspect(ring_roundtrip(3), content="3")
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
