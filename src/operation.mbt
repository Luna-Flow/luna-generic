///|
pub(open) trait Inverse {
  inv(Self) -> Self
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
