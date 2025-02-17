///|
pub trait AddMonoid: Add + Zero {}

///|
pub trait MulMonoid: Mul + One {}

///|
pub trait Semiring: AddMonoid + MulMonoid {}

///|
pub trait Num: Semiring + Neg {}
