///|
impl Mul for Bool with op_mul(a, b) -> Bool {
  a && b
}

///|
impl Add for Bool with op_add(a, b) -> Bool {
  a || b
}

///|
impl Neg for Bool with op_neg(a) -> Bool {
  not(a)
}

///|
impl Zero for Bool with zero() -> Bool {
  false
}

///|
impl One for Bool with one() -> Bool {
  true
}
