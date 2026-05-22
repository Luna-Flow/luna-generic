///|
pub impl AddMonoid for Float

///|
pub impl MulMonoid for Float

///|
pub impl AddGroup for Float

///|
pub impl MulGroup for Float

///|
pub impl Semiring for Float

///|
pub impl Ring for Float

///|
pub impl Field for Float

///|
pub impl Inverse for Float with fn inv(a) -> Float {
  guard a != 0
  1.0 / a
}

///|
pub impl One for Float with fn one() -> Float {
  1.0
}

///|
pub impl Zero for Float with fn zero() -> Float {
  0.0
}

///|
pub impl Num for Float with fn abs(a) -> Float {
  Float::abs(a)
}

///|
pub impl Num for Float with fn signum(a) -> Float {
  if a < 0.0 {
    -1.0
  } else if a > 0.0 {
    1.0
  } else {
    a
  }
}
