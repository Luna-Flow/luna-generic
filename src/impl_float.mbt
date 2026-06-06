///|
pub impl AddMonoid for Float

///|
pub impl MulMonoid for Float

///|
pub impl AddGroup for Float

///|
pub impl MulGroup for Float

///|
pub impl Semiring for Float

///|
pub impl Ring for Float

///|
pub impl Field for Float

///|
pub impl NatHomomorphism for Float

///|
pub impl IntegralHomomorphism for Float

///|
pub impl NatHomomorphism for Float with fn from_uint(a) -> Float {
  Float::from_uint(a)
}

///|
pub impl NatHomomorphism for Float with fn from_uint16(a) -> Float {
  Float::from_uint(a.to_uint())
}

///|
pub impl NatHomomorphism for Float with fn from_uint64(a) -> Float {
  Float::from_uint64(a)
}

///|
pub impl IntegralHomomorphism for Float with fn from_int(a) -> Float {
  Float::from_int(a)
}

///|
pub impl IntegralHomomorphism for Float with fn from_int16(a) -> Float {
  Float::from_int64(a.to_int64())
}

///|
pub impl IntegralHomomorphism for Float with fn from_int64(a) -> Float {
  Float::from_int64(a)
}

///|
pub impl IntegralHomomorphism for Float with fn from_bigint(a) -> Float {
  Float::from_double(
    @string.from_str(BigInt::to_string(a)) catch {
      _ => abort("BigInt decimal conversion failed")
    },
  )
}

///|
pub impl Inverse for Float with fn inv(a) -> Float {
  guard a != 0
  1.0 / a
}

///|
pub impl One for Float with fn one() -> Float {
  1.0
}

///|
pub impl Zero for Float with fn zero() -> Float {
  0.0
}

///|
pub impl Num for Float with fn abs(a) -> Float {
  Float::abs(a)
}

///|
pub impl Num for Float with fn signum(a) -> Float {
  if a < 0.0 {
    -1.0
  } else if a > 0.0 {
    1.0
  } else {
    a
  }
}
