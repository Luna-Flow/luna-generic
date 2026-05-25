///|
pub impl AddMonoid for UInt

///|
pub impl AddMonoid for UInt16

///|
pub impl AddMonoid for UInt64

///|
pub impl MulMonoid for UInt

///|
pub impl MulMonoid for UInt16

///|
pub impl MulMonoid for UInt64

///|
pub impl Semiring for UInt

///|
pub impl Semiring for UInt16

///|
pub impl Semiring for UInt64

///|
pub impl Integral for UInt

///|
pub impl Integral for UInt16

///|
pub impl Integral for UInt64

///|
pub impl Nat for UInt

///|
pub impl Nat for UInt16

///|
pub impl Nat for UInt64

///|
pub impl One for UInt with fn one() -> UInt {
  1U
}

///|
pub impl One for UInt16 with fn one() -> UInt16 {
  (1 : UInt16)
}

///|
pub impl One for UInt64 with fn one() -> UInt64 {
  1UL
}

///|
pub impl Zero for UInt with fn zero() -> UInt {
  0U
}

///|
pub impl Zero for UInt16 with fn zero() -> UInt16 {
  (0 : UInt16)
}

///|
pub impl Zero for UInt64 with fn zero() -> UInt64 {
  0UL
}

///|
pub impl Integral for UInt with fn to_float(a) -> Float {
  Float::from_uint(a)
}

///|
pub impl Integral for UInt16 with fn to_float(a) -> Float {
  Float::from_uint(a.to_uint())
}

///|
pub impl Integral for UInt64 with fn to_float(a) -> Float {
  Float::from_uint64(a)
}

///|
pub impl Integral for UInt with fn to_double(a) -> Double {
  a.to_double()
}

///|
pub impl Integral for UInt16 with fn to_double(a) -> Double {
  a.to_uint().to_double()
}

///|
pub impl Integral for UInt64 with fn to_double(a) -> Double {
  a.to_double()
}
