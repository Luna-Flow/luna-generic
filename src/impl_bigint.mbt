///|
pub impl AddMonoid for BigInt

///|
pub impl MulMonoid for BigInt

///|
pub impl AddGroup for BigInt

///|
pub impl Semiring for BigInt

///|
pub impl Ring for BigInt

///|
pub impl Integral for BigInt

///|
pub impl Integral for BigInt with fn normalize(a) -> BigInt {
  a
}

///|
pub impl NatHomomorphism for BigInt

///|
pub impl IntegralHomomorphism for BigInt

///|
pub impl NatHomomorphism for BigInt with fn from_uint(a) -> BigInt {
  BigInt::from_uint(a)
}

///|
pub impl NatHomomorphism for BigInt with fn from_uint16(a) -> BigInt {
  BigInt::from_uint(a.to_uint())
}

///|
pub impl NatHomomorphism for BigInt with fn from_uint64(a) -> BigInt {
  BigInt::from_uint64(a)
}

///|
pub impl IntegralHomomorphism for BigInt with fn from_int(a) -> BigInt {
  BigInt::from_int(a)
}

///|
pub impl IntegralHomomorphism for BigInt with fn from_int16(a) -> BigInt {
  BigInt::from_int64(a.to_int64())
}

///|
pub impl IntegralHomomorphism for BigInt with fn from_int64(a) -> BigInt {
  BigInt::from_int64(a)
}

///|
pub impl IntegralHomomorphism for BigInt with fn from_bigint(a) -> BigInt {
  a
}

///|
pub impl One for BigInt with fn one() -> BigInt {
  BigInt::from_int(1)
}

///|
pub impl Zero for BigInt with fn zero() -> BigInt {
  BigInt::from_int(0)
}

pub impl Num for BigInt with fn abs(a) -> BigInt {
  if a < BigInt::from_int(0) {
    -a
  } else {
    a
  }
}

///|
pub impl Num for BigInt with fn signum(a) -> BigInt {
  if a < BigInt::from_int(0) {
    BigInt::from_int(-1)
  } else if a > BigInt::from_int(0) {
    BigInt::from_int(1)
  } else {
    a
  }
}
