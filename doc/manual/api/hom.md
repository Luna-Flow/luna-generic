# hom API

## Purpose

The `hom` subsystem provides generalized homomorphisms. A `Hom[S, A, B]` is a
map `A -> B` that carries a certificate stating it preserves every operation
of the signature `S`. The certificate cannot be forged outside this package,
and the only unproven entry point is `Hom::postulate`.

Source: `src/hom.mbt`.

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

## Product type

- `Prod[A, B]`: fields `fst` and `snd`. Implements `Add`, `Mul`, `Neg`, `Sub`,
  `Zero` and `One`, and `AddMonoid`, `MulMonoid`, `AddGroup`, `Semiring` and
  `Ring` whenever both components do.

## Homomorphisms

Trust entry (creates a proof obligation):

- `Hom::postulate(f)`: the caller promises that for every operation `op` of
  `S` and all arguments `xs`, `f(op_A(xs)) == op_B(xs.map(f))`.

Inference rules (no new obligation):

- `Hom::id()`, `h.then(g)`: identity and composition.
- `h.forget(r)`: forgets structure along a `Reduct[S, T]` witness.
- `Hom::pair(f, g)`, `Hom::fst()`, `Hom::snd()`: pairing and projections.
- `h.to_add_group()`: an additive monoid hom between groups preserves `neg`.
- `h.to_ring()`: a semiring hom between rings preserves `neg`.

Canonical embeddings (the obligation sits on the trait instance):

- `Hom::from_nat()`: backed by the target's `NatHomomorphism` instance, typed
  `Hom[SemiringSig, N, R]`.
- `Hom::from_integral()`: backed by the target's `IntegralHomomorphism`
  instance, typed `Hom[SemiringSig, Z, R]`. Upgrade with `to_ring` when both
  sides are rings.

Use:

- `h.apply(x)`

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

- Fixed-width integer sources (`Int`, `Int64`, `UInt`, ...) stop being the
  integers once arithmetic wraps, so `Hom::from_integral` only holds on samples
  whose source arithmetic does not overflow.
- `Float` and `Double` targets satisfy the laws only up to rounding; use
  `check_by` with a tolerance. See the embedding notes in the
  [core API](core.md).
