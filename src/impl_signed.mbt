///|
pub impl AddMonoid for Int32

///|
pub impl AddMonoid for Int16

///|
pub impl AddMonoid for Int64

///|
pub impl MulMonoid for Int32

///|
pub impl MulMonoid for Int16

///|
pub impl MulMonoid for Int64

///|
pub impl AddGroup for Int32

///|
pub impl AddGroup for Int16

///|
pub impl AddGroup for Int64

///|
pub impl Semiring for Int32

///|
pub impl Semiring for Int16

///|
pub impl Semiring for Int64

///|
pub impl Ring for Int32

///|
pub impl Ring for Int16

///|
pub impl Ring for Int64

///|
pub impl Integral for Int32

///|
pub impl Integral for Int16

///|
pub impl Integral for Int64

///|
pub impl Integral for Int32 with fn normalize(a) -> BigInt {
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
pub impl FromNat for Int32

///|
pub impl FromNat for Int16

///|
pub impl FromNat for Int64

///|
pub impl FromInteger for Int32

///|
pub impl FromInteger for Int16

///|
pub impl FromInteger for Int64

// Reduction modulo 2^k: the unique ring hom out of ℤ.
// `Integral::normalize` is a section of it.

///|
pub impl FromNat for Int32 with fn from_natural(n) -> Int32 {
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
pub impl FromInteger for Int32 with fn from_integer(n) -> Int32 {
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
pub impl One for Int32 with fn one() -> Int32 {
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
pub impl Zero for Int32 with fn zero() -> Int32 {
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
pub impl Num for Int32 with fn abs(a) -> Int32 {
  Int32::abs(a)
}

///|
pub impl Num for Int16 with fn abs(a) -> Int16 {
  Int16::abs(a)
}

///|
pub impl Num for Int64 with fn abs(a) -> Int64 {
  Int64::abs(a)
}

///|
pub impl Num for Int32 with fn signum(a) -> Int32 {
  if a == 0 {
    0
  } else if a < 0 {
    -1
  } else {
    1
  }
}

///|
pub impl Num for Int16 with fn signum(a) -> Int16 {
  if a == 0 {
    (0 : Int16)
  } else if a < 0 {
    (-1 : Int16)
  } else {
    (1 : Int16)
  }
}

///|
pub impl Num for Int64 with fn signum(a) -> Int64 {
  if a == 0L {
    0L
  } else if a < 0L {
    -1L
  } else {
    1L
  }
}
