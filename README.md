# Luna-Generic

General algebraic traits and default numeric instances for Luna projects.

## v0.3.3 - Normalize-Driven Homomorphism Cleanup

This documentation tracks the intended `v0.3.3` release content.

### Package Positioning

- `luna-generic` provides lightweight algebraic traits for additive, multiplicative, ring-like, field-like, and numeric behavior.
- The package ships default instances for signed integers, unsigned integers, `BigInt`, `Float`, and `Double`.
- Integral-to-target embeddings are now modeled explicitly through homomorphism traits instead of being mixed into `Integral`.

### What Defines v0.3.3

- `BigInt` is now part of the default exported numeric surface.
- `Integral` now provides `normalize`, which canonicalizes any integral value into `BigInt`.
- `NatHomomorphism` and `IntegralHomomorphism` provide polymorphic target-side embeddings for natural and integral source types.
- `Integral::normalize` is the canonical source-side entry point for both `Integral` and `Nat`.
- Floating-point embeddings remain approximate and follow target floating-point precision limits.

### Public Surface

- Traits: `AddMonoid`, `MulMonoid`, `AddGroup`, `MulGroup`, `Semiring`, `Ring`, `Field`, `Integral`, `Nat`, `NatHomomorphism`, `IntegralHomomorphism`, `Num`
- Operations: `One`, `Zero`, `Inverse`, `Conjugate`
- Default numeric types: `Int`, `Int16`, `Int64`, `UInt`, `UInt16`, `UInt64`, `BigInt`, `Float`, `Double`

### Integer Families

- `Nat` covers pure unsigned integer types: `UInt`, `UInt16`, `UInt64`
- `Integral` covers signed and unsigned integers plus `BigInt`: `Int`, `Int16`, `Int64`, `UInt`, `UInt16`, `UInt64`, `BigInt`
- `Byte` is intentionally excluded from both traits
- Unsigned integer instances stop at `Semiring` and do not implement `AddGroup`, `Ring`, or `Num`

### Embedding Guidance

- `Integral::normalize` provides a canonical `BigInt` representation for any integral value
- `Nat` sources reuse the same `normalize(Self) -> BigInt` path through trait inheritance
- `NatHomomorphism::from_nat` embeds any `Nat` source via `normalize`
- `IntegralHomomorphism::from_integral` embeds any `Integral` source via `normalize`
- `BigInt` embeddings are exact
- `Float` and `Double` embeddings are approximate and may round large values

### Documentation

Comprehensive API documentation is available at [mooncakes.io](https://mooncakes.io/docs/Luna-Flow/luna-generic).

We provide README-level documentation in multiple languages:

- English: [doc/en_US/README.md](./doc/en_US/README.md)
- Simplified Chinese: [doc/zh_CN/README.md](./doc/zh_CN/README.md)
- Japanese: [doc/ja_JP/README.md](./doc/ja_JP/README.md)

## Version History

| Version | Date | Status | Notes |
| --- | --- | --- | --- |
| `0.3.3` | 2026-06-12 | release candidate | Refactors homomorphism traits around polymorphic methods and unifies natural/integral embeddings through `normalize` |
| `0.3.2` | 2026-06-06 | published on mooncakes | Adds `Integral::normalize` as the canonical `BigInt` normalization entry point and aligns docs with the new integral embedding model |
| `0.3.1` | 2026-06-06 | published on mooncakes | Adds `BigInt` coverage, explicit integral embedding traits, and trilingual documentation refresh |
| `0.3.0` | 2026-06-06 | previous release baseline | Earlier generic algebraic trait surface before the current integral embedding redesign |

## Development

Useful local commands:

```bash
moon check
moon test
```

## Release Checklist

Before triggering the publish workflow:

1. Confirm `moon.mod` contains the intended version.
2. Confirm the README files match the exported package surface.
3. Run `moon check` and `moon test`.
4. Trigger `publish-package` after the release commit is pushed.
