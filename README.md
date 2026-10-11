# Luna-Generic

General algebraic traits and default numeric instances for Luna projects.

## Unreleased - Foundation Layer Split

This documentation tracks the next breaking release. The previous `v0.4.0`
surface remains documented in the changelog below.

### Package Positioning

- `luna-generic` provides lightweight algebraic traits for additive, multiplicative, ring-like, field-like, and numeric behavior.
- The package ships default instances for signed integers, unsigned integers, `BigInt`, `Float`, and `Double`.
- Conversions between number types separate the explicit exact homomorphism out of ℤ from the choice of a representative for a machine integer.

### What Defines v0.5.0

- `FromNat` and `FromInteger` are target-side traits for the unique homomorphisms ℕ -> `Self` and ℤ -> `Self`, taking a `BigInt` argument.
- Operation bundles (`AddMonoidOps`, `SemiringOps`, `RingOps`, `FieldOps` and `NumOps`) carry capabilities without claiming laws. Exact structure traits return opaque `Law` certificates and require an explicit law method.
- `Float` and `Double` implement operation bundles and `RoundedArithmetic`; they do not implement exact `Semiring`, `Ring` or `Field` laws.
- `Integral` now extends `SemiringOps + FromInteger` and requires explicit `IntegralTh` and `IntegerHomomorphismTh` law methods. An integral type is ℤ or a quotient ℤ/2^k, and `normalize` picks a representative.
- `lift_to` lifts an integral value to its representative and maps it into any `FromInteger` target. It is a function, not a homomorphism.
- `Section[S, Q, A]` certifies representative lifts of quotient algebras; `Section::of_integral` is the canonical one for every integral type.
- `Hom::from_integer_exact` certifies the canonical map out of ℤ only with a target `LawfulModel[IntegerHomomorphismTh, SemiringSig, R]`.
- `NatHomomorphism` and `IntegralHomomorphism` remain deprecated operations. `Hom::from_nat`, `Hom::from_integral` and the old `Hom::from_integer` are removed; use `FromNat`, `FromInteger`, `Section` and `lift_to` for ordinary conversions.

### Public Surface

- Traits: operation bundles (`AddMonoidOps`, `MulMonoidOps`, `AddGroupOps`, `MulGroupOps`, `SemiringOps`, `RingOps`, `FieldOps`, `NumOps`), exact structures (`AddMonoid`, `MulMonoid`, `AddGroup`, `MulGroup`, `Semiring`, `Ring`, `CommRing`, `IntegralDomain`, `Field`, `OrderedField`), `FromNat`, `FromInteger`, `Integral`, `Nat`, and the deprecated `NatHomomorphism`, `IntegralHomomorphism`
- Certificates and runtime models: `Law`, `LawfulModel`, `Model`, `ModelConstructionError`, `ModelMismatch`, and `RoundedArithmetic`
- Model identities are opaque and compared with `Model::same_identity`; model-bound finite checks use `Hom::check_models` and `Hom::check_models_by`
- Operations: `One`, `Zero`, `Inverse`, `Conjugate`
- Functions: `lift_to`
- Generalized homomorphisms: `Hom`, `Section`, `Algebra`, `Op`, `Prod`, `Reduct`, and the signature tags `AddMonoidSig`, `MulMonoidSig`, `AddGroupSig`, `SemiringSig`, `RingSig`
- Default numeric types: `Int`, `Int16`, `Int64`, `UInt`, `UInt16`, `UInt64`, `BigInt`, `Float`, `Double`

### Integer Families

- `Integral` covers signed and unsigned integers plus `BigInt`: `Int`, `Int16`, `Int64`, `UInt`, `UInt16`, `UInt64`, `BigInt`
- `Nat` covers the integral types with non-negative representatives: `UInt`, `UInt16`, `UInt64`
- Fixed-width integers are ℤ/2^k: their canonical map from ℤ reduces modulo 2^k, and `normalize` picks the representative in the type's range
- `Byte` is intentionally excluded from both traits
- Unsigned integer instances stop at `SemiringOps` and do not implement `AddGroupOps`, `RingOps`, or `NumOps`

### Conversion Guidance

- `FromInteger::from_integer` is exact for `BigInt`, reduces modulo 2^k for fixed-width integers, and rounds for `Float` and `Double`
- `lift_to(x)` turns a machine integer into another number type without promising to preserve operations; it is a homomorphism only when the target modulus divides the source modulus, as for `Int64 -> Int`
- Use `Section::of_integral` and `Hom::from_integer_exact` when the exact integer-homomorphism law is available; use `FromInteger::from_integer` as an ordinary rounded operation otherwise

### Documentation

Comprehensive API documentation is available at [mooncakes.io](https://mooncakes.io/docs/Luna-Flow/luna-generic).

The manual is published at [lunaflow.cn/en/luna-generic](https://lunaflow.cn/en/luna-generic/), with Simplified Chinese and Japanese translations. Its English source lives in [doc/manual](./doc/manual/index.md); translations are maintained as gettext catalogs in `doc/locale`.

## Changelog

The current version is `0.4.0`. Release notes for every version are in [CHANGELOG.md](./CHANGELOG.md).

## Development

Requires the MoonBit toolchain 0.10 or later. Useful local commands:

```bash
moon check
moon test
```

## Release Checklist

Before triggering the publish workflow:

1. Confirm `moon.mod` contains the intended version.
2. Confirm the README and `doc/manual` match the exported package surface.
3. Run `moon check` and `moon test`.
4. Trigger `publish-package` after the release commit is pushed.
