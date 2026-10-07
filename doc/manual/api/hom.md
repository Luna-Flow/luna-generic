# hom API

## Purpose

The `hom` subsystem provides generalized homomorphisms. A `Hom[S, A, B]` is a
map `A -> B` that carries a certificate stating it preserves every operation
of the signature `S`. A `Section[S, Q, A]` certifies a lift that picks one
representative per class of a quotient. Neither certificate can be forged
outside this package. The unproven leaves are `Hom::postulate`,
`Section::postulate`, and the canonical `Hom::from_integer` and
`Section::of_integral`, whose obligation sits on trait instances.

Source: `src/hom.mbt`, `src/section.mbt`.

## Signature tags

- `AddMonoidSig`: `0`, `+`
- `MulMonoidSig`: `1`, `*`
- `AddGroupSig`: `0`, `+`, `neg`
- `SemiringSig`: `0`, `1`, `+`, `*`
- `RingSig`: `0`, `1`, `+`, `*`, `neg`

Signature tags are empty enums that only appear at the type level. Users may
define their own.

## Algebra dictionaries

- `Op[A]`: one operation with `name`, `arity` and `eval`. `arity == 0` is a constant.
- `Algebra[S, A]`: an interpretation of the signature `S` on the carrier `A`.
- `Algebra::add_monoid`, `mul_monoid`, `add_group`, `semiring`, `ring`:
  derived from the existing structure trait instances.
- `Algebra::make(ops)`: builds a dictionary for a custom signature tag.
- `Algebra::prod(a, b)`: the componentwise product algebra on `Prod[A, B]`.

Two dictionaries of the same `S` must list the same operations (name and
arity) in the same order; otherwise `Algebra::prod` and `Hom::check_by` abort.

Certificates assume one `S`-algebra per carrier: every dictionary of the same
`S` on the same carrier must interpret the operations the same way. `then`
composes through the middle carrier, so two different `Algebra::make`
dictionaries on it would compose into a map that preserves neither.

## Product type

- `Prod[A, B]`: fields `fst` and `snd`. Implements `Add`, `Mul`, `Neg`, `Sub`,
  `Zero` and `One`, and `AddMonoid`, `MulMonoid`, `AddGroup`, `Semiring` and
  `Ring` whenever both components do.

## Homomorphisms

Trust entry (creates a proof obligation):

- `Hom::postulate(f)`: the caller promises that for every operation `op` of
  `S` and all arguments `xs`, `f(op_A(xs)) == op_B(xs.map(f))`. The promise is
  always strict equality, even when the map is only checked with a lax or
  tolerance relation.

Inference rules (no new obligation):

- `Hom::id()`, `h.then(g)`: identity and composition.
- `h.forget(r)`: forgets structure along a `Reduct[S, T]` witness.
- `Hom::pair(f, g)`, `Hom::fst()`, `Hom::snd()`: pairing and projections.
- `h.to_add_group()`: an additive monoid hom between groups preserves `neg`.
- `h.to_ring()`: a semiring hom between rings preserves `neg`.

Canonical map (the obligation sits on the trait instance):

- `Hom::from_integer()`: the canonical map ℤ -> `R` of `FromInteger`, typed
  `Hom[SemiringSig, BigInt, R]`. It holds on every input; upgrade with
  `to_ring` when `R` is a ring.
- Deprecated: `Hom::from_nat()` and `Hom::from_integral()` certify a lift
  followed by a canonical map, which is not a homomorphism for fixed-width
  sources. Use `Hom::from_integer` with `Section::of_integral`.

Use:

- `h.apply(x)`

## Sections

A section lifts a quotient `Q` back into `A` along a homomorphism
`proj : A -> Q`, with `proj(lift(q)) == q`. The lift is not a homomorphism,
but it preserves every operation up to the kernel of `proj`, and exactly
whenever the result is itself a representative.

- `Section::postulate(proj, lift)`: the caller promises
  `proj.apply(lift(q)) == q` for every `q`.
- `Section::of_integral()`: the canonical section of an integral type,
  `Section[SemiringSig, Z, BigInt]`, with `proj = FromInteger::from_integer`
  and `lift = Integral::normalize`.
- `s.lift(q)`, `s.proj()`.
- `s.normalize(a)`: `lift(proj(a))`, the normal form of `a`. Two values are
  congruent exactly when their normal forms are equal.
- `s.is_representative(a)`: `normalize(a) == a`; on such results the lift
  agrees with the operations.
- `s.then(next)`, `s.forget(r)`, `s.to_add_group()`, `s.to_ring()`: inference
  rules, no new obligation.
- `s.check(samples)`: tests the section law.
- `s.check_ops(quotient, cover, samples)`: tests
  `proj(op_A(xs.map(lift))) == op_Q(xs)` for every operation.

The section law rejects lifts that leave the class of their argument. It
does not choose among representatives: `[0, 2^32)` and `[-2^31, 2^31)` are
both sections of `BigInt -> Int`, and only the second preserves the signed
order.

`lift_to(x)` lifts an integral value and maps it into any `FromInteger`
target without a certificate.

## Reduct witnesses

- `semiring_to_add_monoid`, `semiring_to_mul_monoid`
- `ring_to_semiring`, `ring_to_add_group`
- `add_group_to_add_monoid`
- `Reduct::refl()`, `r.then(r2)`

Only this package constructs `Reduct` values.

## Law checks

- `h.check(src, dst, samples)`: checks the law with exact equality; requires `B : Eq`.
- `h.check_by(src, dst, samples, rel)`: checks `rel(f(op_A(xs)), op_B(f(xs)))`.
  `rel` sets the strength of preservation: equality for strict homomorphisms,
  `<=` for lax ones such as subadditive maps, and a tolerance for approximate
  homomorphisms into floating-point targets.

An operation of arity `n` is tested on `samples.length()^n` tuples.

## Semantic notes

- Fixed-width integer sources (`Int`, `Int64`, `UInt`, ...) are ℤ/2^k rather
  than the integers. There is no semiring map from them into `BigInt`, so a
  lift into ℤ is a section, not a homomorphism. The same argument rules out
  widening such as `Int -> Int64`, while truncation such as `Int64 -> Int` is
  a ring homomorphism.
- The inference rules compose certificates as strict homomorphisms. A map that
  only satisfies a lax (`<=`) or tolerance law must be checked again after
  composition.
- `Float` and `Double` targets satisfy the laws only up to rounding; use
  `check_by` with a tolerance. See the embedding notes in the
  [core API](core.md).
