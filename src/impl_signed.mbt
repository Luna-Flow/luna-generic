///|
pub impl AddMonoidOps for Int

///|
pub impl AddMonoidOps for Int16

///|
pub impl AddMonoidOps for Int64

///|
pub impl MulMonoidOps for Int

///|
pub impl MulMonoidOps for Int16

///|
pub impl MulMonoidOps for Int64

///|
pub impl AddGroupOps for Int

///|
pub impl AddGroupOps for Int16

///|
pub impl AddGroupOps for Int64

///|
pub impl SemiringOps for Int

///|
pub impl SemiringOps for Int16

///|
pub impl SemiringOps for Int64

///|
pub impl RingOps for Int

///|
pub impl RingOps for Int16

///|
pub impl RingOps for Int64

///|
pub impl Integral for Int with fn integral_law() {
  Law::postulate()
}

///|
pub impl Integral for Int16 with fn integral_law() {
  Law::postulate()
}

///|
pub impl Integral for Int64 with fn integral_law() {
  Law::postulate()
}

///|
pub impl Integral for Int with fn normalize(a) -> BigInt {
  BigInt::from_int(a)
}

///|
pub impl Integral for Int16 with fn normalize(a) -> BigInt {
  BigInt::from_int64(a.to_int64())
}

///|
pub impl Integral for Int64 with fn normalize(a) -> BigInt {
  BigInt::from_int64(a)
}

///|
pub impl FromNat for Int

///|
pub impl FromNat for Int16

///|
pub impl FromNat for Int64

///|
pub impl FromInteger for Int

///|
pub impl FromInteger for Int16

///|
pub impl FromInteger for Int64

// Reduction modulo 2^k: the unique ring hom out of ℤ.
// `Integral::normalize` is a section of it.

///|
pub impl FromNat for Int with fn from_natural(n) -> Int {
  n.to_int()
}

///|
pub impl FromNat for Int16 with fn from_natural(n) -> Int16 {
  Int16::from_int(n.to_int())
}

///|
pub impl FromNat for Int64 with fn from_natural(n) -> Int64 {
  n.to_int64()
}

///|
pub impl FromInteger for Int with fn from_integer(n) -> Int {
  n.to_int()
}

///|
pub impl FromInteger for Int16 with fn from_integer(n) -> Int16 {
  Int16::from_int(n.to_int())
}

///|
pub impl FromInteger for Int64 with fn from_integer(n) -> Int64 {
  n.to_int64()
}

///|
pub impl One for Int with fn one() -> Int {
  1
}

///|
pub impl One for Int16 with fn one() -> Int16 {
  (1 : Int16)
}

///|
pub impl One for Int64 with fn one() -> Int64 {
  1L
}

///|
pub impl Zero for Int with fn zero() -> Int {
  0
}

///|
pub impl Zero for Int16 with fn zero() -> Int16 {
  (0 : Int16)
}

///|
pub impl Zero for Int64 with fn zero() -> Int64 {
  0L
}

///|
pub impl NumOps for Int with fn abs(a) -> Int {
  Int::abs(a)
}

///|
pub impl NumOps for Int16 with fn abs(a) -> Int16 {
  Int16::abs(a)
}

///|
pub impl NumOps for Int64 with fn abs(a) -> Int64 {
  Int64::abs(a)
}

///|
pub impl NumOps for Int with fn signum(a) -> Int {
  if a == 0 {
    0
  } else if a < 0 {
    -1
  } else {
    1
  }
}

///|
pub impl NumOps for Int16 with fn signum(a) -> Int16 {
  if a == 0 {
    (0 : Int16)
  } else if a < 0 {
    (-1 : Int16)
  } else {
    (1 : Int16)
  }
}

///|
pub impl NumOps for Int64 with fn signum(a) -> Int64 {
  if a == 0L {
    0L
  } else if a < 0L {
    -1L
  } else {
    1L
  }
}
