///|
pub(open) trait Mul {
  op_mul(Self, Self) -> Self
}

///|
pub(open) trait Add {
  op_add(Self, Self) -> Self
}

///|
pub(open) trait Neg {
  op_neg(Self) -> Self
}

///|
pub(open) trait One {
  one() -> Self
}

///|
pub(open) trait Zero {
  zero() -> Self
}

///|
pub(open) trait Conjugate {
  conjugate(Self) -> Self
}

///|
pub(open) trait Sub {
  op_sub(Self, Self) -> Self
}

///|
pub impl Mul for Int with op_mul(a, b) -> Int {
  a * b
}

///|
pub impl Add for Int with op_add(a, b) -> Int {
  a + b
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

///|
pub impl Mul for Double with op_mul(a, b) -> Double {
  a * b
}

///|
pub impl Add for Double with op_add(a, b) -> Double {
  a + b
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