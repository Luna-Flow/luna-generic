# luna-generic

This manual documents the intended `v0.4.0` release of `Luna-Flow/luna-generic`.

## Overview

`luna-generic` provides general algebraic traits and default numeric instances for Luna projects.

The current release candidate centers on three changes:

- `FromNat` and `FromInteger` describe the unique homomorphisms out of ℕ and ℤ as target-side traits.
- `Integral` is ℤ or a quotient ℤ/2^k, and `normalize` must be a section of its canonical map.
- `lift_to` and `Section` keep the choice of a representative apart from homomorphisms.

## Install

```bash
moon add Luna-Flow/luna-generic@0.4.0
```

Then import `"Luna-Flow/luna-generic"` in your `moon.pkg`. The package needs
the MoonBit toolchain 0.10 or later (`moonc` ≥ 0.10).

## Pages

The repository is one MoonBit package at `src`, documented as `core`. Its
certificate subsystem, `Hom` and `Section`, has its own pages as `hom`.

| Part | Tutorial | API | Design |
| --- | --- | --- | --- |
| `core`: traits, conversions, instances | [tutorial](tutorial/core.md) | [API](api/core.md) | [design](design/core.md) |
| `hom`: homomorphisms and sections | [tutorial](tutorial/hom.md) | [API](api/hom.md) | [design](design/hom.md) |

## Exported traits

- `AddMonoid`, `MulMonoid`
- `AddGroup`, `MulGroup`
- `Semiring`, `Ring`, `Field` (commutative, $0 \ne 1$: $ab = ba$)
- `FromNat`, `FromInteger`
- `Integral`, `Nat`
- `Num`
- Deprecated: `NatHomomorphism`, `IntegralHomomorphism`

## Exported operations and default types

- Operations: `One`, `Zero`, `Inverse`, `Conjugate`
- Default numeric types: `Int`, `Int16`, `Int64`, `UInt`, `UInt16`, `UInt64`, `BigInt`, `Float`, `Double`

## Integer model

- `Integral` covers signed integers, unsigned integers, and `BigInt`
- `Nat` covers the integral types with non-negative representatives: `UInt`, `UInt16`, and `UInt64`
- Fixed-width integers are ℤ/2^k; `FromInteger::from_integer` reduces modulo 2^k
- `Integral::normalize` picks the representative of a value as a `BigInt`, and `from_integer(normalize(x)) == x`
- Unsigned integer instances stop at `Semiring`

## Conversions

- `FromInteger::from_integer` is the canonical map out of ℤ: exact for `BigInt`, modular for fixed-width integers, rounded for `Float` and `Double`
- `lift_to(x)` lifts to the representative and maps it into the target; it is a function, not a homomorphism
- `NatHomomorphism::from_nat` and `IntegralHomomorphism::from_integral` are deprecated in favour of `FromNat`, `FromInteger` and `lift_to`

## Generalized homomorphisms

- `Hom[S, A, B]`: a certificate for maps preserving the signature `S`, built only through `Hom::postulate` (which creates a proof obligation), the canonical map `Hom::from_integer`, or inference rules
- `Section[S, Q, A]`: a certificate that a lift picks one representative per class of a quotient; `Section::of_integral` is the canonical one for integral types
- Signature tags: `AddMonoidSig`, `MulMonoidSig`, `AddGroupSig`, `SemiringSig`, `RingSig`
- Algebra dictionaries `Algebra[S, A]`, operations `Op[A]`, the product type `Prod[A, B]` and reduct witnesses `Reduct[S, T]`
- `Hom::check` / `Hom::check_by` test the homomorphism laws on samples with strict, lax or approximate strength
- See the [hom API](api/hom.md), [tutorial](tutorial/hom.md) and [design](design/hom.md)

## Where to read next

The [core tutorial](tutorial/core.md) writes small generic algorithms against these traits. The [core API](api/core.md) lists every exported trait and instance, and the [core design](design/core.md) explains why the hierarchy and the conversions are shaped this way.

- New to the package: read the [core tutorial](tutorial/core.md), then the [hom tutorial](tutorial/hom.md).
- Using it in a library: keep the [core API](api/core.md) and the [hom API](api/hom.md) at hand; each trait lists the laws an instance must satisfy.
- Contributing: read both design pages, [core](design/core.md) and [hom](design/hom.md), before changing a trait or adding an inference rule.

## Validation

Recommended release checks:

```bash
moon check
moon test
```
