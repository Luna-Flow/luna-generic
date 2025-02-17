///|
pub trait Mul {
  op_mul(Self, Self) -> Self
}

///|
pub trait Add {
  op_add(Self, Self) -> Self
}

///|
pub trait Neg {
  op_neg(Self) -> Self
}

///|
pub trait One {
  one() -> Self
}

///|
pub trait Zero {
  zero() -> Self
}

///|
pub trait Conjugate {
  conjugate(Self) -> Self
}

///|
pub trait Sub {
  op_sub(Self, Self) -> Self
}

