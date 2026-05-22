///|
pub(open) trait Inverse {
  fn inv(Self) -> Self
}

///|
pub(open) trait One {
  fn one() -> Self
}

///|
pub(open) trait Zero {
  fn zero() -> Self
}

///|
pub(open) trait Conjugate {
  fn conjugate(Self) -> Self
}
