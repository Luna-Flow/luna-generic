///|
pub(open) trait AddMonoid: Add + Zero {}

///|
pub(open) trait MulMonoid: Mul + One {}

///|
pub(open) trait AddGroup: AddMonoid + Neg {}

///|
pub(open) trait MulGroup: MulMonoid + Neg {}

///|
pub(open) trait Semiring: AddMonoid + MulMonoid {}

///|
pub(open) trait Ring: Semiring + Neg {}

///|
pub(open) trait Num: Ring {
  abs(Self) -> Self
  signum(Self) -> Self
}
