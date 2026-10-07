# core API

## Purpose

`luna-generic` is the algebraic trait layer of LunaFlow. It does not provide
numerical algorithms or containers by itself; it defines the reusable
capability surface that higher-level packages depend on.

## Structural traits

- `AddMonoid`, `MulMonoid`
- `AddGroup`, `MulGroup`
- `Semiring`, `Ring`, `Field`
- `FromNat`, `FromInteger`
- `Integral`
- `Nat`
- `Num`
- Deprecated: `NatHomomorphism`, `IntegralHomomorphism`

These traits live in `src/structure.mbt`.

## Operational traits

- `Zero`
- `One`
- `Inverse`
- `Conjugate`

These traits live in `src/operation.mbt`.

## Shipped instances

- Signed integers: `Int`, `Int16`, `Int64`
- Unsigned integers: `UInt`, `UInt16`, `UInt64`
- Exact big integer: `BigInt`
- Floating instances: `Float`, `Double`

## Conversions

- `FromNat::from_natural(BigInt) -> Self`: the unique semiring homomorphism
  ℕ -> `Self`. The argument must be non-negative.
- `FromInteger::from_integer(BigInt) -> Self`: the unique ring homomorphism
  ℤ -> `Self`; it agrees with `from_natural` on non-negative arguments.
- `Integral::normalize(Self) -> BigInt`: the representative of a value.
  `Integral` extends `Semiring + FromInteger`, and the law is
  `Self::from_integer(normalize(x)) == x`.
- `lift_to(x) -> R` for `x : S` with `S : Integral` and `R : FromInteger`:
  `R::from_integer(x.normalize())`. It is a function, not a homomorphism.
- Deprecated: `NatHomomorphism::from_nat` and
  `IntegralHomomorphism::from_integral` compose `normalize` with a target
  conversion. Implement `FromNat` / `FromInteger` and call `lift_to` instead.

## Semantic notes

- Fixed-width integers are ℤ/2^k. Their `from_integer` reduces modulo 2^k, and
  `normalize` picks the representative in the type's range: `[-2^(k-1),
  2^(k-1))` for signed types, `[0, 2^k)` for unsigned ones.
- `BigInt` is ℤ itself: `from_integer` and `normalize` are the identity.
- `lift_to` is a homomorphism exactly when the target modulus divides the
  source modulus, as for `Int64 -> Int`. Into `BigInt`, `Float` or `Double` it
  is not one for fixed-width sources, because their arithmetic wraps.
- `Nat` covers the integral types whose representatives are non-negative. A
  true arbitrary-precision ℕ is not a quotient of ℤ and is out of scope.
- Unsigned integer instances stop at `Semiring`; they do not pretend to be
  additive groups or rings.
- `Float` and `Double` round in `from_natural` and `from_integer`, so very
  large values are approximate.

## Source map

- `src/structure.mbt`: trait definitions
- `src/operation.mbt`: operational traits
- `src/impl_signed.mbt`, `src/impl_unsigned.mbt`, `src/impl_bigint.mbt`,
  `src/impl_float.mbt`, `src/impl_dbl.mbt`: default instances
