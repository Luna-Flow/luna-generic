///|
pub impl Mul for BoolAlg with op_mul(a, b) -> BoolAlg {
  a.and(b)
}

///|
pub impl Add for BoolAlg with op_add(a, b) -> BoolAlg {
  a.or(b)
}

///|
pub impl Neg for BoolAlg with op_neg(a) -> BoolAlg {
  a.not()
}

///|
pub impl Zero for BoolAlg with zero() -> BoolAlg {
  false
}

///|
pub impl One for BoolAlg with one() -> BoolAlg {
  true
}
