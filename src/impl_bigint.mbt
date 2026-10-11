///|
pub impl AddMonoidOps for BigInt

///|
pub impl MulMonoidOps for BigInt

///|
pub impl AddGroupOps for BigInt

///|
pub impl SemiringOps for BigInt

///|
pub impl RingOps for BigInt

///|
pub impl Integral for BigInt with fn integral_law() {
  Law::postulate()
}

///|
pub impl Integral for BigInt with fn normalize(a) -> BigInt {
  a
}

///|
pub impl FromNat for BigInt

///|
pub impl FromInteger for BigInt

///|
pub impl FromNat for BigInt with fn from_natural(n) -> BigInt {
  n
}

///|
pub impl FromInteger for BigInt with fn from_integer(n) -> BigInt {
  n
}

///|
pub impl NatHomomorphism for BigInt

///|
pub impl IntegralHomomorphism for BigInt

///|
pub impl NatHomomorphism for BigInt with fn[S : Nat] from_nat(a : S) -> BigInt {
  Integral::normalize(a)
}

///|
pub impl IntegralHomomorphism for BigInt with fn[S : Integral] from_integral(
  a : S,
) -> BigInt {
  Integral::normalize(a)
}

///|
pub impl One for BigInt with fn one() -> BigInt {
  BigInt::from_int(1)
}

///|
pub impl Zero for BigInt with fn zero() -> BigInt {
  BigInt::from_int(0)
}

///|
pub impl NumOps for BigInt with fn abs(a) -> BigInt {
  if a < BigInt::from_int(0) {
    -a
  } else {
    a
  }
}

///|
pub impl NumOps for BigInt with fn signum(a) -> BigInt {
  if a < BigInt::from_int(0) {
    BigInt::from_int(-1)
  } else if a > BigInt::from_int(0) {
    BigInt::from_int(1)
  } else {
    a
  }
}
