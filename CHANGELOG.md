# Changelog

All notable changes to `Luna-Flow/luna-generic` are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/) (in `0.x`, a minor bump may break the API).

## Unreleased

### Changed

- **Breaking:** split operation-only bundles (AddMonoidOps, RingOps, FieldOps, and NumOps) from exact law-bearing traits. Law-bearing traits now require an explicit opaque Law certificate, and Num is removed.
- **Breaking:** remove the automatic exact Semiring, Ring, and Field instances for Float and Double; retain rounded operation capabilities through RoundedArithmetic.
- **Breaking:** Algebra::make and Model::make return Result and report negative operation arity as InvalidArity rather than aborting.
- **Breaking:** replace `Hom::from_integer`, `Hom::from_nat` and `Hom::from_integral` with the model-bound `Hom::from_integer_exact`; runtime identity, pairing, projection, reduct and law upgrades are checked with `Result`.
- **Breaking:** split `ModelMismatch` into the payload-free variants `IdentityMismatch`, `SignatureMismatch` and `NotProductModel`; `Algebra::prod` and `Model::prod` report `SignatureMismatch`, `Hom::pair`/`fst`/`snd` report `NotProductModel` for a Model not built by `Model::prod`, every other checked operation reports `IdentityMismatch`; `InvalidOperationTable` is unchanged ([#20](https://github.com/Luna-Flow/luna-generic/issues/20)).
- **Breaking:** make runtime `ModelKey` identity opaque and remove `Model::key`; compare Models only with `Model::same_identity` ([#20](https://github.com/Luna-Flow/luna-generic/issues/20)).

The G2 migration is tracked in [#19](https://github.com/Luna-Flow/luna-generic/issues/19).

| Previous entry | 0.5.0 migration |
|---|---|
| `Num` | `NumOps` for operations; add the required exact law separately |
| Float/Double law traits | operation bundles and `RoundedArithmetic` |
| law trait inheritance | each law trait extends operations and has its own mandatory law method |
| `Hom::then` | `then_checked`, handle `Result` |
| `Hom::postulate(f)` | `postulate(source_model, target_model, f)` |
| `Hom::id()` | `id(model)` |
| `Hom::pair/fst/snd` | retain and explicitly pass one product Model; handle `Result` |
| `Hom::from_integer/from_nat/from_integral` | `from_integer_exact` with `IntegerHomomorphismTh`; ordinary conversions use `lift_to` |
| `Algebra::make/prod` | handle constructor/product `Result` |
| `Hom::forget`, `Section::forget` | handle `Result` |
| `ModelMismatch` (single variant) | match `IdentityMismatch`, `SignatureMismatch`, `NotProductModel` |
| `Section::then` | `then_checked`, handle `Result` |
| `Model::key` | `same_identity`; identity representation is private |

### Added

- Opaque theory certificates and kernel-owned weakening rules.
- The runtime Model / LawfulModel types and checked custom Model construction.
- The RoundedArithmetic marker for floating-point operation implementations.
- A pinned-source classification of all 128 entries in the G2 field-bound inventory.
- Model-bound finite diagnostics through `Hom::check_models` and `Hom::check_models_by` ([#20](https://github.com/Luna-Flow/luna-generic/issues/20)).

### Fixed

- `Algebra::make` rejects negative arity before any runtime identity is allocated; this prevents recursive law checks from overflowing the stack ([#16](https://github.com/Luna-Flow/luna-generic/issues/16)).
- `from_integer`, `from_natural` and `lift_to` into `Float` and `Double` (and the deprecated `from_nat` and `from_integral`) no longer abort on huge integers. They now round directly from the bits of the `BigInt`, to nearest with ties to even, and return ±inf when the rounded value overflows, that is for |n| ≥ 2^128 − 2^103 (`Float`) and |n| ≥ 2^1024 − 2^970 (`Double`), as IEEE 754 requires. `Float` is rounded once at 24 bits rather than through `Double`, which was one ulp off for values such as 2^53 + 2^29 + 1. The conversion no longer goes through a decimal string ([#13](https://github.com/Luna-Flow/luna-generic/issues/13)).

### Documentation

- API pages document public signatures and law contracts. All `moonbit` example blocks are compiled and their tests executed by `tools/check_doc_examples.py` in CI; `mbti` blocks are interface notation.
- Tutorials are layered: quick start, everyday tasks, going further, common pitfalls.
- Design pages derive the results they rely on: initiality of ℕ and ℤ, uniqueness of the canonical map, sections of ℤ → ℤ/2^k, and why unsigned types stop at `Semiring`.
- `Field` documents its nontriviality and commutativity contracts ($0 \ne 1$, $ab = ba$, $a a^{-1} = 1$ for $a \ne 0$, $a / b = a b^{-1}$), both on the API page and as a doc comment on the trait.
- zh_CN and ja_JP translations are complete.

## 0.4.0 - 2026-10-07

### Added

- `FromNat` and `FromInteger`: the unique homomorphisms out of ℕ and ℤ, taking a `BigInt` argument.
- `Section[S, Q, A]`: a certificate for lifts of a quotient back to its cover, with `Section::of_integral` as the canonical one for integral types.
- `Hom::from_integer` for the canonical map out of ℤ, and `lift_to` for uncertified conversions between number types.
- `Hom[S, A, B]`: an LCF-style certificate that a map preserves every operation of the signature `S`.
  - `Hom::postulate` is the only public trust entry.
  - `id`, `then`, `forget`, `pair`, `fst`, `snd`, `to_add_group` and `to_ring` act as inference rules.
  - `check` and `check_by` test the law on sample tuples.

### Changed

- **Breaking:** `Integral` now extends `Semiring + FromInteger` with the law `from_integer(normalize(x)) == x`. An integral type is ℤ or a quotient ℤ/2^k, and `normalize` picks its representatives.
- Conversions into fixed-width integers reduce modulo 2^k. Conversions into `Float` and `Double` round.
- Migrated to MoonBit 0.10:
  - `moon.mod` uses the top-level `source` field.
  - `Float::inv` and `Double::inv` abort with an explicit message on zero.
  - The blackbox trait tests call trait methods by their qualified names.

### Deprecated

- `Hom::from_nat` and `Hom::from_integral`, together with the `NatHomomorphism` and `IntegralHomomorphism` traits. They compose a lift with a canonical map, which is not a homomorphism for fixed-width types. Use `FromNat`, `FromInteger`, `Section` and `lift_to` instead.

## 0.3.3 - 2026-06-12

### Changed

- The homomorphism traits are refactored around polymorphic methods.
- Natural and integral embeddings are unified through `normalize`.

## 0.3.2 - 2026-06-06

### Added

- `Integral::normalize`, the canonical `BigInt` normalization entry point. The documentation follows the new integral embedding model.

## 0.3.1 - 2026-06-06

### Added

- `BigInt` instances and explicit integral embedding traits.

### Documentation

- Documentation refreshed in English, Chinese and Japanese.

## 0.3.0 - 2026-06-06

### Added

- Integral traits and conversion guidance. This release is the baseline of the generic algebraic trait surface before the integral embedding redesign.

## Earlier releases (2025)

### Added

- The `Field` trait. `AddGroup` gains `Sub`, and `MulGroup` gains `Div`.
- `Inverse` with `inv` implementations.
- `Float` instances.
