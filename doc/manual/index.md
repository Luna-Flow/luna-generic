# luna-generic

This manual documents the intended `v0.3.3` release of `Luna-Flow/luna-generic`.

## Overview

`luna-generic` provides general algebraic traits and default numeric instances for Luna projects.

The current release candidate centers on three changes:

- `BigInt` is now part of the default exported numeric surface.
- Integral-to-target conversions are expressed through explicit homomorphism traits.
- `Integral::normalize` now provides a canonical `BigInt` form for all integral source types.

## Exported traits

- `AddMonoid`, `MulMonoid`
- `AddGroup`, `MulGroup`
- `Semiring`, `Ring`, `Field`
- `Integral`, `Nat`
- `NatHomomorphism`, `IntegralHomomorphism`
- `Num`

## Exported operations and default types

- Operations: `One`, `Zero`, `Inverse`, `Conjugate`
- Default numeric types: `Int`, `Int16`, `Int64`, `UInt`, `UInt16`, `UInt64`, `BigInt`, `Float`, `Double`

## Integer model

- `Nat` covers `UInt`, `UInt16`, and `UInt64`
- `Integral` covers signed integers, unsigned integers, and `BigInt`
- Unsigned integer instances stop at `Semiring`
- `Integral::normalize` canonicalizes any integral value into `BigInt`
- `Nat` reuses `Integral::normalize` for its exact embedding into `BigInt`

## Embeddings

- `NatHomomorphism::from_nat` provides polymorphic target-side embeddings from any `Nat` source type
- `IntegralHomomorphism::from_integral` provides polymorphic target-side embeddings from any `Integral` source type
- The default implementation strategy is `Integral::normalize` followed by target-specific `BigInt` conversion
- `BigInt` embeddings are exact
- `Float` and `Double` embeddings are approximate and may round large values

## Generalized homomorphisms

- `Hom[S, A, B]`: a certificate for maps preserving the signature `S`, built only through `Hom::postulate` (which creates a proof obligation) or inference rules
- Signature tags: `AddMonoidSig`, `MulMonoidSig`, `AddGroupSig`, `SemiringSig`, `RingSig`
- Algebra dictionaries `Algebra[S, A]`, operations `Op[A]`, the product type `Prod[A, B]` and reduct witnesses `Reduct[S, T]`
- `Hom::check` / `Hom::check_by` test the homomorphism laws on samples with strict, lax or approximate strength
- See the [hom API](api/hom.md), [tutorial](tutorial/hom.md) and [design](design/hom.md)

## Where to read next

The [core tutorial](tutorial/core.md) writes small generic algorithms against these traits. The [core API](api/core.md) lists every exported trait and instance, and the [core design](design/core.md) explains why the hierarchy and the embeddings are shaped this way.

## Validation

Recommended release checks:

```bash
moon check
moon test
```
