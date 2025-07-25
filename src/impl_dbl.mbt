///|
pub impl Inverse for Double with inv(a) -> Double {
  guard a != 0
  1.0 / a
}

///|
pub impl One for Double with one() -> Double {
  1.0
}

///|
pub impl Zero for Double with zero() -> Double {
  0.0
}

///|
pub impl Num for Double with abs(a) -> Double {
  @double.abs(a)
}

///|
pub impl Num for Double with signum(a) -> Double {
  if a < 0.0 {
    -1.0
  } else if a > 0.0 {
    1.0
  } else {
    a
  }
}
