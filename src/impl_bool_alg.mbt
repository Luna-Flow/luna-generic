///|
pub impl Mul for Bool with op_mul(a, b) -> Bool {
  a && b
}

///|
pub impl Add for Bool with op_add(a, b) -> Bool {
  a || b
}

///|
pub impl Neg for Bool with op_neg(a) -> Bool {
  not(a)
}

///|
pub impl Zero for Bool with zero() -> Bool {
  false
}

///|
pub impl One for Bool with one() -> Bool {
  true
}
