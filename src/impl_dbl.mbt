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

///|
pub impl One for Double with one() -> Double {
  1.0
}

///|
pub impl Zero for Double with zero() -> Double {
  0.0
}
