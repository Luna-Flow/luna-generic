///|
pub impl Mul for Double with op_mul(a, b) -> Double {
  a * b
}

///|
pub impl Add for Double with op_add(a, b) -> Double {
  a + b
}

///|
pub impl Sub for Double with op_sub(a, b) -> Double {
  a - b
}

///|
pub impl Neg for Double with op_neg(a) -> Double {
  -a
}

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
  @double.signum(a)
}
