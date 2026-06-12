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
  fn normalize(Self) -> BigInt
}

///|
pub(open) trait Nat: Integral {}

///|
pub(open) trait NatHomomorphism {
  fn[S : Nat] from_nat(value : S) -> Self
}

///|
pub(open) trait IntegralHomomorphism: NatHomomorphism {
  fn[S : Integral] from_integral(value : S) -> Self
}

///|
pub(open) trait Num: Ring {
  fn abs(Self) -> Self
  fn signum(Self) -> Self
}
