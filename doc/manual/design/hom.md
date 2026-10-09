# hom design

## Goals

Express structure-preserving maps within MoonBit's current type system, hand
the laws the type system cannot prove to the developer, and keep those
obligations auditable and testable.

## Constraints

- MoonBit traits only have the `Self` parameter: there are no multi-parameter
  traits and no associated types, so a homomorphism `A -> B` cannot be a trait.
- Homomorphisms out of ℕ and ℤ are unique (initial objects), which is why
  `FromNat` and `FromInteger` can live as target-side traits. Other
  homomorphisms are generally not unique and must be values.

## Core decisions

- LCF-style certificates: `Hom[S, A, B]` has private fields and is only
  constructed inside this package.
- The only public trust entry is `Hom::postulate`. Kernel rules use the
  package-private `trust`, so searching for `postulate` lists exactly the
  user-level obligations. (`assume` is a reserved word in MoonBit, hence the
  name.) `Section::postulate` is the trust entry for sections, and the
  canonical `Hom::from_integer` and `Section::of_integral` are the other
  leaves: their obligation sits on the trait instances.
- A lift from a quotient back to its cover is a `Section`, not a `Hom`. It
  carries the projection as a `Hom` and only promises `proj(lift(q)) == q`;
  agreement with the operations on representatives follows from that law.
  Keeping the two apart stops a representative lift, such as `Int -> BigInt`,
  from being composed as if it were a homomorphism.
- The signature is a phantom type `S` on the certificate, while the algebra is
  passed as a dictionary value `Algebra[S, A]`: the certificate says what is
  preserved, the dictionary is used for checking.
- Custom operations supplied to `Algebra::make` must have nonnegative arity.
  Law checking enumerates argument tuples recursively, so rejecting invalid
  arities at construction prevents nontermination before a certificate is
  checked.
- Signature inclusions are `Reduct[S, T]` witnesses only this package can build.
- The strength of preservation is the relation `rel` chosen at check time, so
  strict, lax and approximate homomorphisms share one API.

## Sections

The [hom tutorial](../tutorial/hom.md) uses `Section` without this
mathematics.

### Definition

Let `π : A -> Q` be a surjective homomorphism, for example the reduction
`BigInt -> Int`. A section is a map `s : Q -> A` with `π(s(q)) = q` for every
`q`: it picks one element of every class `π⁻¹(q)`. By the first isomorphism
theorem `Q` is the quotient `A / ker π`, so a section is a choice of
representatives for a quotient algebra.

### What a section preserves

For every operation `ω` and arguments `x`:

1. `s(ω(x))` and `ω(s(x))` are congruent modulo `ker π`. Apply `π` to both:
   `π(s(ω(x))) = ω(x)` by the section law, and
   `π(ω(s(x))) = ω(π(s(x))) = ω(x)` because `π` is a homomorphism.
2. `s(ω(x)) = ω(s(x))` exactly when `ω(s(x))` lies in the image of `s`. If
   `ω(s(x)) = s(y)`, then `y = π(s(y)) = π(ω(s(x))) = ω(x)` by the same
   computation, so `ω(s(x)) = s(ω(x))`. Conversely `s(ω(x))` is always in the
   image.

The same two steps in display form, for an $n$-ary operation $\omega$ and
$x = (x_1, \dots, x_n)$ with $s(x) = (s(x_1), \dots, s(x_n))$:

$$
\begin{aligned}
\pi\bigl(s(\omega_Q(x))\bigr) &= \omega_Q(x)
  && \text{section law} \\
\pi\bigl(\omega_A(s(x))\bigr) &= \omega_Q(\pi(s(x))) = \omega_Q(x)
  && \pi \text{ is a homomorphism}
\end{aligned}
$$

so $s(\omega_Q(x)) - \omega_A(s(x)) \in \ker \pi$ whenever $A$ has
subtraction. If $\omega_A(s(x)) = s(y)$ for some $y$, applying $\pi$ gives
$y = \omega_Q(x)$, hence $\omega_A(s(x)) = s(\omega_Q(x))$.

So `Section::check` only tests the section law; `check_ops` tests that `π` is
a homomorphism on lifted arguments, and point 2 follows. For `Int`, the image
of `s` is `[-2^31, 2^31)`, and "the result is in the image" means "the result
did not wrap around".

### The carry

For addition on `Int` the difference in point 1 is
`s(a) + s(b) - s(a + b) = c(a, b)·2^32` with `c(a, b) ∈ {-1, 0, 1}`, the
carry. Expanding `s(a) + s(b) + s(e)` in two ways gives

```text
c(a, b) + c(a + b, e) = c(b, e) + c(a, b + e)
```

The identity comes from associativity. Write $m = 2^{32}$ and
$s(a) + s(b) = s(a + b) + c(a, b)\,m$, then group the sum of three lifts
both ways:

$$
\begin{aligned}
(s(a) + s(b)) + s(e) &= s(a + b) + s(e) + c(a, b)\,m \\
&= s(a + b + e) + \bigl(c(a + b, e) + c(a, b)\bigr)\,m, \\
s(a) + (s(b) + s(e)) &= s(a) + s(b + e) + c(b, e)\,m \\
&= s(a + b + e) + \bigl(c(a, b + e) + c(b, e)\bigr)\,m .
\end{aligned}
$$

Both sides are equal in ℤ, so the coefficients of $m$ agree. The bound on
$c$ follows from the range of the representatives:
$s(a) + s(b) \in [-2^{32}, 2^{32} - 2]$ and $s(a + b) \in [-2^{31}, 2^{31})$,
so $c(a, b)\,m$ lies strictly between $-3 \cdot 2^{31}$ and
$3 \cdot 2^{31}$, and $c(a, b) \in \{-1, 0, 1\}$.

So `c` is a 2-cocycle describing ℤ as an extension of ℤ/2^32 by 2^32ℤ. That
extension does not split, because ℤ has no element of finite order, so no
choice of representatives makes `s` a homomorphism. Directly: an additive
section $\sigma : \mathbb{Z}/m \to \mathbb{Z}$ would give
$m\,\sigma(1) = \sigma(m \cdot 1) = \sigma(0) = 0$, so $\sigma(1) = 0$,
contradicting $\pi(\sigma(1)) = 1$. For multiplication the
difference is the high word of the product.

### Normal forms

`n = s ∘ π : A -> A` is a normal form: `n(n(a)) = n(a)`, `a` and `n(a)` are
congruent, and `a`, `b` are congruent exactly when `n(a) = n(b)`. The
quotient operations are computed on representatives as
`s(ω_Q(x)) = n(ω_A(s(x)))`: compute in `A`, then normalize. Wrapped `Int`
arithmetic is this computation for `A = ℤ`. Because `Section::normalize` is
built from `s` and `π`, it cannot give two congruent values different normal
forms.

### Why `Section` is not a `Hom`

A section is injective and agrees with the operations on its image, so it is
easy to mistake for a homomorphism and compose it as one. Keeping it in a
separate certificate makes the difference visible in the types: `Section`
carries `π` as a `Hom`, and only promises `π(s(q)) = q`.

The law does not fix which representatives are chosen. `[0, 2^32)` and
`[-2^31, 2^31)` both give sections of `BigInt -> Int`; only the second
preserves the signed order of `Int`. Such properties need their own checks.

## Alternatives rejected

- A homomorphism trait `Hom[A, B]` implemented by types: it needs two type
  parameters, which MoonBit traits do not have, and it would allow only one
  homomorphism per pair of types, while a pair usually has several, such as
  the identity and conjugation on the complex numbers.
- Plain functions `(A) -> B` without a certificate: nothing would separate
  checked homomorphisms from arbitrary conversions, and composition would
  not record where the obligations came from.
- Treating representative lifts such as `Int -> BigInt` as homomorphisms:
  the cocycle argument above shows that they are not, so they get their own
  certificate, `Section`.
- Recording the check relation (strict, lax, tolerance) in the type: it
  would multiply the inference rules for each strength. The relation is
  chosen at check time instead, and the boundaries below state the cost.

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
- Fixed-width integers are ℤ/2^k, not ℤ or ℕ. Maps out of them into ℤ are
  sections, so they agree with the operations only while arithmetic does not
  wrap.
- The section law does not fix which representatives are chosen, so
  properties such as order preservation need their own checks.
