///|
pub impl AddMonoidOps for UInt32

///|
pub impl AddMonoidOps for UInt16

///|
pub impl AddMonoidOps for UInt64

///|
pub impl MulMonoidOps for UInt32

///|
pub impl MulMonoidOps for UInt16

///|
pub impl MulMonoidOps for UInt64

///|
pub impl SemiringOps for UInt32

///|
pub impl SemiringOps for UInt16

///|
pub impl SemiringOps for UInt64

///|
pub impl Integral for UInt32 with fn integral_law() {
  Law::postulate()
}

///|
pub impl Integral for UInt16 with fn integral_law() {
  Law::postulate()
}

///|
pub impl Integral for UInt64 with fn integral_law() {
  Law::postulate()
}

///|
pub impl Integral for UInt32 with fn normalize(a) -> BigInt {
  BigInt::from_uint(a)
}

///|
pub impl Integral for UInt16 with fn normalize(a) -> BigInt {
  BigInt::from_uint(a.to_uint())
}

///|
pub impl Integral for UInt64 with fn normalize(a) -> BigInt {
  BigInt::from_uint64(a)
}

///|
pub impl FromNat for UInt32

///|
pub impl FromNat for UInt16

///|
pub impl FromNat for UInt64

///|
pub impl FromInteger for UInt32

///|
pub impl FromInteger for UInt16

///|
pub impl FromInteger for UInt64

// Reduction modulo 2^k: the unique ring hom out of ℤ.
// `Integral::normalize` is a section of it.

///|
pub impl FromNat for UInt32 with fn from_natural(n) -> UInt32 {
  n.to_uint()
}

///|
pub impl FromNat for UInt16 with fn from_natural(n) -> UInt16 {
  n.to_int().to_uint16()
}

///|
pub impl FromNat for UInt64 with fn from_natural(n) -> UInt64 {
  n.to_uint64()
}

///|
pub impl FromInteger for UInt32 with fn from_integer(n) -> UInt32 {
  n.to_uint()
}

///|
pub impl FromInteger for UInt16 with fn from_integer(n) -> UInt16 {
  n.to_int().to_uint16()
}

///|
pub impl FromInteger for UInt64 with fn from_integer(n) -> UInt64 {
  n.to_uint64()
}

///|
pub impl One for UInt32 with fn one() -> UInt32 {
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
pub impl Zero for UInt32 with fn zero() -> UInt32 {
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
