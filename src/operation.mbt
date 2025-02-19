///|
pub(open) trait Mul {
  op_mul(Self, Self) -> Self
}

///|
pub(open) trait Add {
  op_add(Self, Self) -> Self
}

///|
pub(open) trait Neg {
  op_neg(Self) -> Self
}

///|
pub(open) trait One {
  one() -> Self
}

///|
pub(open) trait Zero {
  zero() -> Self
}

///|
pub(open) trait Conjugate {
  conjugate(Self) -> Self
}

///|
pub(open) trait Sub {
  op_sub(Self, Self) -> Self
}

