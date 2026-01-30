///|
pub impl Inverse for Float with inv(a) -> Float {
  guard a != 0
  1.0 / a
}

///|
pub impl One for Float with one() -> Float {
  1.0
}

///|
pub impl Zero for Float with zero() -> Float {
  0.0
}

///|
pub impl Num for Float with abs(a) -> Float {
  Float::abs(a)
}

///|
pub impl Num for Float with signum(a) -> Float {
  if a < 0.0 {
    -1.0
  } else if a > 0.0 {
    1.0
  } else {
    a
  }
}
