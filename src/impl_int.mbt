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
pub impl Inverse for Int with inv(a) -> Int {
  guard a != 0
  1 / a
}

///|
pub impl One for Int with one() -> Int {
  1
}

///|
pub impl Zero for Int with zero() -> Int {
  0
}

///|
pub impl Num for Int with abs(a) -> Int {
  @int.abs(a)
}

///|
pub impl Num for Int with signum(a) -> Int {
  if a == 0 {
    0
  } else if a < 0 {
    -1
  } else {
    1
  }
}
