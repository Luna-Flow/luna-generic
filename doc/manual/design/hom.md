# hom design

## Goals

Express structure-preserving maps within MoonBit's current type system, hand
the laws the type system cannot prove to the developer, and keep those
obligations auditable and testable.

## Constraints

- MoonBit traits only have the `Self` parameter: there are no multi-parameter
  traits and no associated types, so a homomorphism `A -> B` cannot be a trait.
- Homomorphisms out of ℕ and ℤ are unique (initial objects), which is why
  `NatHomomorphism` and `IntegralHomomorphism` can live as target-side traits.
  Other homomorphisms are generally not unique and must be values.

## Core decisions

- LCF-style certificates: `Hom[S, A, B]` has private fields and is only
  constructed inside this package.
- The only public trust entry is `Hom::postulate`. Kernel rules use the
  package-private `trust`, so searching for `postulate` lists exactly the
  user-level obligations. (`assume` is a reserved word in MoonBit, hence the
  name.) The canonical embeddings `Hom::from_nat` and `Hom::from_integral`
  are the other leaves: their obligation sits on the trait instances.
- The signature is a phantom type `S` on the certificate, while the algebra is
  passed as a dictionary value `Algebra[S, A]`: the certificate says what is
  preserved, the dictionary is used for checking.
- Signature inclusions are `Reduct[S, T]` witnesses only this package can build.
- The strength of preservation is the relation `rel` chosen at check time, so
  strict, lax and approximate homomorphisms share one API.

## Boundaries

- Only single-sorted signatures. Multi-sorted structures such as modules
  (scalars plus vectors) are out of scope for this subsystem.
- Without higher-kinded types, functorial lifts (polynomials, matrices, ...)
  belong to their own packages and are not generalized here.
- Laws are tested, not proven. The certificate guarantees traceable origin,
  not that the laws hold.
- Soundness of `then` relies on one `S`-algebra per carrier. Built-in tags get
  this from trait coherence; dictionaries from `Algebra::make` only by
  convention.
- The certificate does not record the relation used by `check_by`, so lax and
  approximate maps compose as if they were strict.
- Fixed-width integers are ℤ/2^k, not ℤ or ℕ, so canonical embeddings out of
  them hold only while source arithmetic does not wrap.
