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
pub(open) trait Integral: Semiring {
  fn to_float(Self) -> Float
  fn to_double(Self) -> Double
}

///|
pub(open) trait Nat: Integral {}

///|
pub(open) trait Num: Ring {
  fn abs(Self) -> Self
  fn signum(Self) -> Self
}
