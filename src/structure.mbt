///|
pub(open) trait AddMonoid: Add + Zero {}

///|
pub(open) trait MulMonoid: Mul + One {}

///|
pub(open) trait AddGroup: AddMonoid + Neg + Sub {}

///|
pub(open) trait MulGroup: MulMonoid + Inverse + Div {}

///|
pub(open) trait Semiring: AddMonoid + MulMonoid {}

///|
pub(open) trait Ring: Semiring + Neg + Sub {}

///|
pub(open) trait Field: Ring + Inverse + Div {}

///|
pub(open) trait Integral: Semiring {}

///|
pub(open) trait Nat: Integral {
  fn to_integral(Self) -> BigInt
}

///|
pub(open) trait NatHomomorphism {
  fn from_uint(UInt) -> Self
  fn from_uint16(UInt16) -> Self
  fn from_uint64(UInt64) -> Self
}

///|
pub(open) trait IntegralHomomorphism: NatHomomorphism {
  fn from_int(Int) -> Self
  fn from_int16(Int16) -> Self
  fn from_int64(Int64) -> Self
  fn from_bigint(BigInt) -> Self
}

///|
pub(open) trait Num: Ring {
  fn abs(Self) -> Self
  fn signum(Self) -> Self
}
