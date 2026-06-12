///|
pub impl AddMonoid for Double

///|
pub impl MulMonoid for Double

///|
pub impl AddGroup for Double

///|
pub impl MulGroup for Double

///|
pub impl Semiring for Double

///|
pub impl Ring for Double

///|
pub impl Field for Double

///|
pub impl NatHomomorphism for Double

///|
pub impl IntegralHomomorphism for Double

///|
fn double_from_bigint(a : BigInt) -> Double {
  @string.from_str(BigInt::to_string(a)) catch {
    _ => abort("BigInt decimal conversion failed")
  }
}

///|
pub impl NatHomomorphism for Double with fn[S : Nat] from_nat(a : S) -> Double {
  double_from_bigint(Integral::normalize(a))
}

///|
pub impl IntegralHomomorphism for Double with fn[S : Integral] from_integral(a : S) -> Double {
  double_from_bigint(Integral::normalize(a))
}

///|
pub impl Inverse for Double with fn inv(a) -> Double {
  guard a != 0
  1.0 / a
}

///|
pub impl One for Double with fn one() -> Double {
  1.0
}

///|
pub impl Zero for Double with fn zero() -> Double {
  0.0
}

///|
pub impl Num for Double with fn abs(a) -> Double {
  Double::abs(a)
}

///|
pub impl Num for Double with fn signum(a) -> Double {
  if a < 0.0 {
    -1.0
  } else if a > 0.0 {
    1.0
  } else {
    a
  }
}
