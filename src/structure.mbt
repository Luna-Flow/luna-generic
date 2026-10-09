///|
pub(open) trait AddMonoid: Add + Zero {}

///|
pub(open) trait MulMonoid: Mul + One {}

///|
pub(open) trait AddGroup: AddMonoid + Neg + Sub {}

///|
pub(open) trait MulGroup: MulMonoid + Inverse + Div {}

///|
pub(open) trait Semiring: AddMonoid + MulMonoid {}

///|
pub(open) trait Ring: Semiring + Neg + Sub {}

///|
/// A field: a commutative ring with `0 != 1` in which every non-zero element
/// has an inverse.
///
/// Laws, which the compiler does not check: `0 != 1`, `a * b == b * a`,
/// `a * inv(a) == 1` for `a != 0`, and `a / b == a * inv(b)` for `b != 0`.
/// Nontriviality and commutativity are part of the contract: a zero ring or a
/// noncommutative division ring must not implement `Field`.
pub(open) trait Field: Ring + Inverse + Div {}

///|
/// The canonical map out of the naturals: the unique semiring homomorphism
/// ℕ -> `Self`. The argument must be non-negative.
pub(open) trait FromNat {
  fn from_natural(BigInt) -> Self
}

///|
/// The canonical map out of the integers: the unique ring homomorphism
/// ℤ -> `Self`. It must agree with `from_natural` on non-negative arguments.
pub(open) trait FromInteger: FromNat {
  fn from_integer(BigInt) -> Self
}

///|
/// An integer type: ℤ itself, or a quotient ℤ/2^k such as the fixed-width
/// integers. `normalize` picks the representative of each class as a
/// `BigInt`; it is a homomorphism only when `Self` really is ℤ.
///
/// Law: `normalize` is a section of the canonical map,
/// `Self::from_integer(normalize(x)) == x`. `Section::of_integral` packages
/// the pair as a certificate.
pub(open) trait Integral: Semiring + FromInteger {
  fn normalize(Self) -> BigInt
}

///|
/// An integer type whose representatives are non-negative, such as the
/// unsigned fixed-width integers.
pub(open) trait Nat: Integral {}

///|
/// Deprecated: lifts a `Nat` source to ℕ and maps it into `Self`, which is not
/// a homomorphism for fixed-width sources. Implement `FromNat` and use
/// `lift_to` instead.
#deprecated("Implement `FromNat` and use `lift_to` instead.", skip_current_package=true)
pub(open) trait NatHomomorphism {
  fn[S : Nat] from_nat(value : S) -> Self
}

///|
/// Deprecated: lifts an `Integral` source to ℤ and maps it into `Self`, which
/// is not a homomorphism for fixed-width sources. Implement `FromInteger` and
/// use `lift_to` instead.
#deprecated("Implement `FromInteger` and use `lift_to` instead.", skip_current_package=true)
pub(open) trait IntegralHomomorphism: NatHomomorphism {
  fn[S : Integral] from_integral(value : S) -> Self
}

///|
pub(open) trait Num: Ring {
  fn abs(Self) -> Self
  fn signum(Self) -> Self
}
