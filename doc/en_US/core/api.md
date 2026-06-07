# core API

## Purpose

`luna-generic` is the algebraic trait layer of LunaFlow. It does not provide
numerical algorithms or containers by itself; it defines the reusable
capability surface that higher-level packages depend on.

## Structural traits

- `AddMonoid`, `MulMonoid`
- `AddGroup`, `MulGroup`
- `Semiring`, `Ring`, `Field`
- `Integral`
- `Nat`
- `NatHomomorphism`
- `IntegralHomomorphism`
- `Num`

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

## Semantic notes

- `Integral::normalize(Self) -> BigInt` is the canonical exact bridge from any
  integral instance into `BigInt`.
- `Nat::to_integral(Self) -> BigInt` is the natural-number-specific exact
  embedding path.
- `NatHomomorphism` and `IntegralHomomorphism` keep target-side embeddings
  explicit instead of relying on ad hoc casts.
- Unsigned integer instances stop at `Semiring`; they do not pretend to be
  additive groups or rings.
- `Float` and `Double` implement homomorphism traits as approximate embeddings,
  so very large integral values may round.

## Source map

- `src/structure.mbt`: trait definitions
- `src/operation.mbt`: operational traits
- `src/impl_signed.mbt`, `src/impl_unsigned.mbt`, `src/impl_bigint.mbt`,
  `src/impl_float.mbt`, `src/impl_dbl.mbt`: default instances
