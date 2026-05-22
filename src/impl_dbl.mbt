///|
pub impl AddMonoid for Double

///|
pub impl MulMonoid for Double

///|
pub impl AddGroup for Double

///|
pub impl MulGroup for Double

///|
pub impl Semiring for Double

///|
pub impl Ring for Double

///|
pub impl Field for Double

///|
pub impl Inverse for Double with fn inv(a) -> Double {
  guard a != 0
  1.0 / a
}

///|
pub impl One for Double with fn one() -> Double {
  1.0
}

///|
pub impl Zero for Double with fn zero() -> Double {
  0.0
}

///|
pub impl Num for Double with fn abs(a) -> Double {
  Double::abs(a)
}

///|
pub impl Num for Double with fn signum(a) -> Double {
  if a < 0.0 {
    -1.0
  } else if a > 0.0 {
    1.0
  } else {
    a
  }
}
