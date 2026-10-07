# core design

## Design goal

`luna-generic` gives LunaFlow a shared algebraic vocabulary. Packages such as
`arithmetic`, `luna-complex`, `linear-algebra`, and `luna-poly` should be able
to describe their requirements in terms of reusable traits instead of inventing
their own incompatible capability layers.

## Main design decisions

- The trait graph is layered and intentionally small.
- Structural traits such as `Ring`, `Field`, `Integral`, and `Nat` are kept
  separate from operational traits such as `Zero`, `One`, `Inverse`, and
  `Conjugate`.
- Conversions are split into two halves that meet at ℤ, represented by
  `BigInt`. The target side is the canonical map ℤ -> `R` (`FromInteger`),
  which is unique and always a homomorphism. The source side is
  `Integral::normalize`, which picks a representative and is a homomorphism
  only for ℤ itself. `lift_to` composes them and promises nothing about
  operations.
- The halves are single-parameter traits because every conversion factors
  through ℤ, the initial ring: no trait has to relate two types.
- `Integral` extends `FromInteger` with the law
  `from_integer(normalize(x)) == x`, which makes an integral type a quotient
  of ℤ with chosen representatives. `FromInteger` takes a `BigInt` rather than
  a generic integral source, so the traits do not refer to each other.
- Unsigned types stop before additive inverse, so the abstraction stays
  mathematically honest.

## Boundaries

- This package does not define matrices, complex numbers, polynomials, parsing,
  or numerical algorithms.
- It does not erase the semantic difference between exact and approximate
  number systems.
