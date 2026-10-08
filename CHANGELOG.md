# Changelog

All notable changes to `Luna-Flow/luna-generic` are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/) (in `0.x`, a minor bump may break the API).

## Unreleased

### Documentation

- Every public item is documented on the API pages with its signature, laws and a compiled example.
- Tutorials are layered: quick start, everyday tasks, going further, common pitfalls.
- Design pages derive the results they rely on: initiality of ℕ and ℤ, uniqueness of the canonical map, sections of ℤ → ℤ/2^k, and why unsigned types stop at `Semiring`.
- `Field` documents its commutativity contract ($ab = ba$, $a a^{-1} = 1$ for $a \ne 0$, $a / b = a b^{-1}$), both on the API page and as a doc comment on the trait.
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
