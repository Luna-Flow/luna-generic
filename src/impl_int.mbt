///|
pub impl Mul for Int with op_mul(a, b) -> Int {
  a * b
}

///|
pub impl Add for Int with op_add(a, b) -> Int {
  a + b
}

///|
pub impl Sub for Int with op_sub(a, b) -> Int {
  a - b
}

///|
pub impl Neg for Int with op_neg(a) -> Int {
  -a
}

///|
pub impl One for Int with one() -> Int {
  1
}

///|
pub impl Zero for Int with zero() -> Int {
  0
}
