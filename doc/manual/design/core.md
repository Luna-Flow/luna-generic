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

## Integers as quotients of ℤ

This section gives the mathematics behind `FromNat`, `FromInteger`,
`Integral` and `lift_to`. The [core tutorial](../tutorial/core.md) shows how
to use them without it.

### The canonical map is unique

For every ring `R` there is exactly one ring homomorphism `ℤ -> R`. A ring
homomorphism `φ` must send `1` to `1`, and additivity then forces
`φ(n) = 1 + ... + 1` (`n` times) for `n > 0` and `φ(-n) = -φ(n)`. Conversely,
`n ↦ n·1` preserves `+` and `*` by distributivity. The same argument gives
exactly one semiring homomorphism `ℕ -> R` for every semiring `R`. In
categorical terms ℕ and ℤ are initial objects.

Because the map depends only on `R`, it is a property of the target and fits
a single-parameter trait: `FromNat::from_natural` and
`FromInteger::from_integer`.

### Fixed-width integers

`Int` adds and multiplies modulo 2^32, so as a ring it is ℤ/2^32. Its
`from_integer` is the reduction `ℤ -> ℤ/2^32`, which is surjective.
`normalize` goes the other way and picks one integer in every residue class,
the one in `[-2^31, 2^31)`. The law `from_integer(normalize(x)) == x` says
exactly that `normalize` is a section of the reduction:

- `normalize` is injective, because it has a left inverse.
- Its image contains exactly one element of every class: at most one because
  it is injective, and at least one because of the law.
- It is not a homomorphism: `normalize(2147483647 + 1) = -2^31`, while
  `normalize(2147483647) + normalize(1) = 2^31`.

The [hom design](hom.md) shows what a section does preserve.

### When a conversion is a homomorphism

`lift_to : S -> R` is `R::from_integer` composed with `S::normalize`. When
`S` is ℤ/m (with `m = 0` for `BigInt`), a ring homomorphism `ℤ/m -> R` exists
if and only if `m·1 = 0` in `R`:

- If `ψ` is one, then `0 = ψ(0) = ψ(m·1) = m·1` in `R`.
- If `m·1 = 0`, the canonical map `ℤ -> R` sends `mℤ` to `0` and so factors
  through ℤ/m. It is unique because `ℤ -> ℤ/m` is surjective.

In that case `lift_to` is this homomorphism: write the canonical map
`ℤ -> R` as `ψ ∘ π` with `π : ℤ -> ℤ/m`; then
`lift_to = ψ ∘ π ∘ normalize = ψ`. So:

- `Int64 -> Int` is a homomorphism, because `2^64 ≡ 0 (mod 2^32)`.
- `Int -> Int64` is not, because `2^32 ≢ 0 (mod 2^64)`.
- No fixed-width integer maps homomorphically into `BigInt`, `Float` or
  `Double`, where `m·1 ≠ 0` for every `m > 0`.

### Why the traits do not refer to each other

Every conversion factors through ℤ: `S -> ℤ -> R`. The first half depends
only on `S` (`Integral`), the second only on `R` (`FromInteger`), so neither
trait has to relate two types. `FromInteger` takes a `BigInt` rather than a
generic integral source, which lets `Integral` extend it without a cycle.

## Boundaries

- This package does not define matrices, complex numbers, polynomials, parsing,
  or numerical algorithms.
- It does not erase the semantic difference between exact and approximate
  number systems.
