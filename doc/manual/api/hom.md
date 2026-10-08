# hom API

## Purpose

The `hom` subsystem provides generalized homomorphisms. A `Hom[S, A, B]` is a
map `A -> B` that carries a certificate stating it preserves every operation
of the signature `S`. A `Section[S, Q, A]` certifies a lift that picks one
representative per class of a quotient. Neither certificate can be forged
outside this package. The unproven leaves are `Hom::postulate`,
`Section::postulate`, and the canonical `Hom::from_integer` and
`Section::of_integral`, whose obligation sits on trait instances.

Source: `src/hom.mbt`, `src/section.mbt`. The mathematics is in the
[hom design](../design/hom.md).

The examples on this page assume this declaration:

```moonbit
using @luna-generic {
  type Hom,
  type Section,
  type Algebra,
  type Op,
  type Prod,
  type Reduct,
  type AddMonoidSig,
  type MulMonoidSig,
  type AddGroupSig,
  type SemiringSig,
  type RingSig,
  semiring_to_add_monoid,
  semiring_to_mul_monoid,
  ring_to_semiring,
  ring_to_add_group,
  add_group_to_add_monoid,
}

let ints : Array[Int] = [0, 1, -1, 7, 2147483647, -2147483648]

let longs : Array[Int64] = [0L, 1L, -1L, 7L, 4294967296L, 9223372036854775807L]
```

## Signature tags

Signature tags are empty enums that only appear at the type level, as the
`S` parameter of `Hom`, `Section`, `Algebra` and `Reduct`. Users may define
their own.

### `AddMonoidSig`

`AddMonoidSig` is the signature `0`, `+`.

```mbti
pub enum AddMonoidSig {
}
```

### `MulMonoidSig`

`MulMonoidSig` is the signature `1`, `*`.

```mbti
pub enum MulMonoidSig {
}
```

### `AddGroupSig`

`AddGroupSig` is the signature `0`, `+`, `neg`.

```mbti
pub enum AddGroupSig {
}
```

### `SemiringSig`

`SemiringSig` is the signature `0`, `1`, `+`, `*`.

```mbti
pub enum SemiringSig {
}
```

### `RingSig`

`RingSig` is the signature `0`, `1`, `+`, `*`, `neg`.

```mbti
pub enum RingSig {
}
```

## Algebra dictionaries

Two dictionaries of the same `S` must list the same operations (name and
arity) in the same order; otherwise `Algebra::prod` and `Hom::check_by` abort.

Certificates assume one `S`-algebra per carrier: every dictionary of the same
`S` on the same carrier must interpret the operations the same way. `then`
composes through the middle carrier, so two different `Algebra::make`
dictionaries on it would compose into a map that preserves neither.

### `Op`

`Op[A]` is one operation of a single-sorted signature.

```mbti
pub(all) struct Op[A] {
  name : String
  arity : Int
  eval : (Array[A]) -> A
}
```

`arity == 0` is a constant. `eval` receives exactly `arity` arguments.

### `Algebra`

`Algebra[S, A]` is an interpretation of the signature `S` on the carrier
`A`: a list of `Op[A]` in the order the signature fixes.

```mbti
pub struct Algebra[S, A] {
  // private fields
}
```

### `Algebra::make`

`Algebra::make(ops)` builds a dictionary for a custom signature tag.

```mbti
pub fn[S, A] Algebra::make(Array[Op[A]]) -> Algebra[S, A]
```

Keep one dictionary per tag and carrier, as explained above.

```moonbit
enum MaxSig {}

fn max_int() -> Algebra[MaxSig, Int] {
  Algebra::make([
    Op::{ name: "max", arity: 2, eval: xs => if xs[0] > xs[1] { xs[0] } else { xs[1] } },
  ])
}
```

### `Algebra::add_monoid`, `Algebra::mul_monoid`, `Algebra::add_group`, `Algebra::semiring`, `Algebra::ring`

These functions derive the dictionary of a built-in tag from the structure
trait instance of `A`.

```mbti
pub fn[A : AddMonoid] Algebra::add_monoid() -> Algebra[AddMonoidSig, A]
pub fn[A : MulMonoid] Algebra::mul_monoid() -> Algebra[MulMonoidSig, A]
pub fn[A : AddGroup] Algebra::add_group() -> Algebra[AddGroupSig, A]
pub fn[A : Semiring] Algebra::semiring() -> Algebra[SemiringSig, A]
pub fn[A : Ring] Algebra::ring() -> Algebra[RingSig, A]
```

The operations are listed in the order of the tag: for example `0`, `1`,
`+`, `*`, `neg` for `RingSig`. Trait coherence gives one dictionary per tag
and carrier.

```moonbit
test "built-in dictionaries" {
  let int_ring : Algebra[RingSig, Int] = Algebra::ring()
  let id : Hom[RingSig, Int, Int] = Hom::id()
  assert_true(id.check(int_ring, int_ring, ints))
}
```

### `Algebra::prod`

`Algebra::prod(a, b)` is the componentwise product algebra on `Prod[A, B]`.

```mbti
pub fn[S, A, B] Algebra::prod(Algebra[S, A], Algebra[S, B]) -> Algebra[S, Prod[A, B]]
```

Each operation acts on `fst` with `a` and on `snd` with `b`. Aborts when `a`
and `b` do not list the same operations.

## Product type

### `Prod`

`Prod[A, B]` is the binary product carrier with fields `fst` and `snd`.

```mbti
pub(all) struct Prod[A, B] {
  fst : A
  snd : B
} derive(Eq, @debug.Debug)
```

Operations act componentwise. `Prod` implements `Add`, `Mul`, `Neg`, `Sub`,
`Zero` and `One`, and `AddMonoid`, `MulMonoid`, `AddGroup`, `Semiring` and
`Ring` whenever both components do.

### `Prod::add`, `Prod::sub`, `Prod::mul`, `Prod::neg`, `Prod::zero`, `Prod::one`

These methods are the componentwise operations, also available as `+`, `-`,
`*`, unary `-` and the `Zero` / `One` traits.

```mbti
pub fn[A : Add, B : Add] Prod::add(Prod[A, B], Prod[A, B]) -> Prod[A, B]
pub fn[A : Sub, B : Sub] Prod::sub(Prod[A, B], Prod[A, B]) -> Prod[A, B]
pub fn[A : Mul, B : Mul] Prod::mul(Prod[A, B], Prod[A, B]) -> Prod[A, B]
pub fn[A : Neg, B : Neg] Prod::neg(Prod[A, B]) -> Prod[A, B]
pub fn[A : Zero, B : Zero] Prod::zero() -> Prod[A, B]
pub fn[A : One, B : One] Prod::one() -> Prod[A, B]
```

$$
(a, b) + (a', b') = (a + a', b + b'), \qquad
(a, b)(a', b') = (aa', bb'), \qquad 0 = (0, 0), \qquad 1 = (1, 1).
$$

### `Prod::equal`, `Prod::not_equal`, `Prod::to_repr`

These methods compare componentwise and render a `Prod` for debugging; use
`==`, `!=` and `inspect` in new code.

```mbti
pub fn[A : Eq, B : Eq] Prod::equal(Prod[A, B], Prod[A, B]) -> Bool
pub fn[A : Eq, B : Eq] Prod::not_equal(Prod[A, B], Prod[A, B]) -> Bool
pub fn[A : @debug.Debug, B : @debug.Debug] Prod::to_repr(Prod[A, B]) -> @debug.Repr
```

```moonbit
test "prod" {
  let p : Prod[Int, Double] = { fst: 2, snd: 0.5 }
  let q : Prod[Int, Double] = { fst: 3, snd: 4.0 }
  assert_eq(p * q + Prod::one(), { fst: 7, snd: 3.0 })
  assert_true(p != q)
}
```

## Homomorphisms

### `Hom`

`Hom[S, A, B]` is a map `A -> B` certified to preserve every operation of
`S`.

```mbti
pub struct Hom[S, A, B] {
  // private fields
}
```

The certificate means that for every operation $\omega$ of `S` with arity
$n$ and all $x_1, \dots, x_n$,

$$
f(\omega_A(x_1, \dots, x_n)) = \omega_B(f(x_1), \dots, f(x_n)).
$$

Only this package constructs `Hom` values. The leaves are
`Hom::postulate` and `Hom::from_integer`; every other constructor is an
inference rule.

### `Hom::postulate`

`Hom::postulate(f)` trusts `f` as an `S`-homomorphism without proof and
creates a proof obligation.

```mbti
pub fn[S, A, B] Hom::postulate((A) -> B) -> Hom[S, A, B]
```

The caller promises that for every operation `op` of `S` and all arguments
`xs`, `f(op_A(xs)) == op_B(xs.map(f))`. The promise is always strict
equality, even when the map is only checked with a lax or tolerance
relation. Back every call with a `check` test.

```moonbit
fn int64_to_int() -> Hom[RingSig, Int64, Int] {
  Hom::postulate(x => x.to_int())
}

test "postulate and check" {
  assert_true(int64_to_int().check(Algebra::ring(), Algebra::ring(), longs))
}
```

### `Hom::apply`

`h.apply(x)` applies the underlying map.

```mbti
pub fn[S, A, B] Hom::apply(Hom[S, A, B], A) -> B
```

```moonbit
test "apply" {
  inspect(int64_to_int().apply(4294967301L), content="5")
}
```

### `Hom::id`

`Hom::id()` is the identity homomorphism.

```mbti
pub fn[S, A] Hom::id() -> Hom[S, A, A]
```

### `Hom::then`

`h.then(g)` is the composite: first `h`, then `g`.

```mbti
pub fn[S, A, B, C] Hom::then(Hom[S, A, B], Hom[S, B, C]) -> Hom[S, A, C]
```

If $f$ and $g$ preserve $\omega$, so does $g \circ f$:

$$
g(f(\omega(x))) = g(\omega(f(x))) = \omega(g(f(x))).
$$

### `Hom::forget`

`h.forget(r)` forgets structure along a `Reduct[S, T]` witness.

```mbti
pub fn[S, T, A, B] Hom::forget(Hom[S, A, B], Reduct[S, T]) -> Hom[T, A, B]
```

A map that preserves every operation of `S` preserves the operations of the
smaller signature `T`.

### `Hom::pair`, `Hom::fst`, `Hom::snd`

`Hom::pair(f, g)` maps `x` to `{ fst: f(x), snd: g(x) }`; `Hom::fst()` and
`Hom::snd()` are the projections out of `Prod`.

```mbti
pub fn[S, A, B, C] Hom::pair(Hom[S, A, B], Hom[S, A, C]) -> Hom[S, A, Prod[B, C]]
pub fn[S, A, B] Hom::fst() -> Hom[S, Prod[A, B], A]
pub fn[S, A, B] Hom::snd() -> Hom[S, Prod[A, B], B]
```

They satisfy `pair(f, g).then(fst()) = f` and `pair(f, g).then(snd()) = g`.

```moonbit
test "composition rules" {
  let h = int64_to_int()
  let low : Hom[RingSig, Int64, Int16] = Hom::postulate(x => Int16::from_int(x.to_int()))
  let p = Hom::pair(h, low)
  let back = p.then(Hom::fst())
  let additive = h.forget(ring_to_add_group)
  inspect(back.apply(4294967301L), content="5")
  assert_true(additive.check(Algebra::add_group(), Algebra::add_group(), longs))
}
```

### `Hom::to_add_group`

`h.to_add_group()` upgrades an additive monoid homomorphism between groups
to an additive group homomorphism.

```mbti
pub fn[A : AddGroup, B : AddGroup] Hom::to_add_group(Hom[AddMonoidSig, A, B]) -> Hom[AddGroupSig, A, B]
```

No new obligation: $f(-x) + f(x) = f(-x + x) = f(0) = 0$, so $f(-x) = -f(x)$.

### `Hom::to_ring`

`h.to_ring()` upgrades a semiring homomorphism between rings to a ring
homomorphism.

```mbti
pub fn[A : Ring, B : Ring] Hom::to_ring(Hom[SemiringSig, A, B]) -> Hom[RingSig, A, B]
```

No new obligation, by the same computation as `to_add_group`.

### `Hom::from_integer`

`Hom::from_integer()` is the canonical map ℤ → `R` of `FromInteger`, as a
certificate.

```mbti
pub fn[R : FromInteger] Hom::from_integer() -> Hom[SemiringSig, @bigint.BigInt, R]
```

It holds on every input; upgrade with `to_ring` when `R` is a ring. `Float`
and `Double` targets satisfy it only up to rounding. For a fixed-width
source, lift first with `Section::of_integral`.

```moonbit
test "from_integer" {
  let h : Hom[RingSig, BigInt, Int] = Hom::from_integer().to_ring()
  let samples = [0, 1, -1, 2147483647].map(BigInt::from_int)
  assert_true(h.check(Algebra::ring(), Algebra::ring(), samples))
}
```

## Sections

A section lifts a quotient `Q` back into `A` along a homomorphism
`proj : A -> Q`, with `proj(lift(q)) == q`. The lift is not a homomorphism,
but it preserves every operation up to the kernel of `proj`, and exactly
whenever the result is itself a representative.

The section law rejects lifts that leave the class of their argument. It
does not choose among representatives: `[0, 2^32)` and `[-2^31, 2^31)` are
both sections of `BigInt -> Int`, and only the second preserves the signed
order.

### `Section`

`Section[S, Q, A]` is a lift of the quotient `Q` back into `A` along the
projection `proj : A -> Q`.

```mbti
pub struct Section[S, Q, A] {
  // private fields
}
```

$$
\pi(s(q)) = q \quad \text{for every } q \in Q.
$$

### `Section::postulate`

`Section::postulate(proj, lift)` trusts `lift` as a section of `proj` and
creates a proof obligation.

```mbti
pub fn[S, Q, A] Section::postulate(Hom[S, A, Q], (Q) -> A) -> Section[S, Q, A]
```

The caller promises `proj.apply(lift(q)) == q` for every `q`; `proj`
carries its own `Hom` obligation.

```moonbit
test "section postulate" {
  let truncate : Hom[RingSig, Int64, Int] = Hom::postulate(x => x.to_int())
  let widen = Section::postulate(truncate, x => x.to_int64())
  assert_true(widen.check(ints))
}
```

### `Section::of_integral`

`Section::of_integral()` is the canonical section of an integral type.

```mbti
pub fn[Z : Integral] Section::of_integral() -> Section[SemiringSig, Z, @bigint.BigInt]
```

`proj` is `FromInteger::from_integer` and `lift` is `Integral::normalize`.
The obligation sits on those instances. Use `to_ring` when `Z` is a ring.

### `Section::lift`, `Section::proj`

`s.lift(q)` is the chosen representative of `q`; `s.proj()` is the
projection onto the quotient.

```mbti
pub fn[S, Q, A] Section::lift(Section[S, Q, A], Q) -> A
pub fn[S, Q, A] Section::proj(Section[S, Q, A]) -> Hom[S, A, Q]
```

### `Section::normalize`

`s.normalize(a)` is `lift(proj(a))`, the normal form of `a`.

```mbti
pub fn[S, Q, A] Section::normalize(Section[S, Q, A], A) -> A
```

Two values are congruent exactly when their normal forms are equal.

### `Section::is_representative`

`s.is_representative(a)` tells whether `a` is the chosen representative of
its class, that is `normalize(a) == a`.

```mbti
pub fn[S, Q, A : Eq] Section::is_representative(Section[S, Q, A], A) -> Bool
```

On such results the lift agrees exactly with the operations of `A`.

```moonbit
test "representatives" {
  let s : Section[RingSig, Int, BigInt] = Section::of_integral().to_ring()
  let big = BigInt::from_int64(4294967296L)
  inspect(s.lift(-1), content="-1")
  inspect(s.proj().apply(big + BigInt::from_int(5)), content="5")
  inspect(s.normalize(big + BigInt::from_int(5)), content="5")
  assert_true(s.is_representative(s.lift(7) + s.lift(1)))
  assert_false(s.is_representative(s.lift(2147483647) + s.lift(1)))
}
```

### `Section::then`

`s.then(next)` lifts `Q` into `A` with `s`, then `A` into `B` with `next`.

```mbti
pub fn[S, Q, A, B] Section::then(Section[S, Q, A], Section[S, A, B]) -> Section[S, Q, B]
```

The projection is `next.proj` followed by `s.proj`. No new obligation: with
$s, t$ the two lifts and $\pi_s, \pi_t$ their projections,
$\pi_s(\pi_t(t(s(q)))) = \pi_s(s(q)) = q$.

### `Section::forget`, `Section::to_add_group`, `Section::to_ring`

These inference rules change the signature of the projection; the lift is
unchanged.

```mbti
pub fn[S, T, Q, A] Section::forget(Section[S, Q, A], Reduct[S, T]) -> Section[T, Q, A]
pub fn[Q : AddGroup, A : AddGroup] Section::to_add_group(Section[AddMonoidSig, Q, A]) -> Section[AddGroupSig, Q, A]
pub fn[Q : Ring, A : Ring] Section::to_ring(Section[SemiringSig, Q, A]) -> Section[RingSig, Q, A]
```

They follow `Hom::forget`, `Hom::to_add_group` and `Hom::to_ring`.

### `Section::check`

`s.check(samples)` tests the section law `proj(lift(q)) == q` on every
sample.

```mbti
pub fn[S, Q : Eq, A] Section::check(Section[S, Q, A], Array[Q]) -> Bool
```

### `Section::check_ops`

`s.check_ops(quotient, cover, samples)` tests
`proj(op_A(xs.map(lift))) == op_Q(xs)` for every operation over all tuples
drawn from `samples`.

```mbti
pub fn[S, Q : Eq, A] Section::check_ops(Section[S, Q, A], Algebra[S, Q], Algebra[S, A], Array[Q]) -> Bool
```

This exercises `proj` as a homomorphism on representatives. Aborts when the
two dictionaries do not list the same operations.

```moonbit
test "section checks" {
  let s : Section[RingSig, Int, BigInt] = Section::of_integral().to_ring()
  assert_true(s.check(ints))
  assert_true(s.check_ops(Algebra::ring(), Algebra::ring(), ints))
}
```

`lift_to(x)` lifts an integral value and maps it into any `FromInteger`
target without a certificate; it is listed on the [core API](core.md).

## Reduct witnesses

### `Reduct`

`Reduct[S, T]` witnesses that every `S`-structure is also a `T`-structure,
so an `S`-homomorphism is also a `T`-homomorphism.

```mbti
pub struct Reduct[S, T] {
  // private fields
}
```

Only this package constructs `Reduct` values.

### `semiring_to_add_monoid`, `semiring_to_mul_monoid`, `ring_to_semiring`, `ring_to_add_group`, `add_group_to_add_monoid`

These constants are the inclusions between the built-in signatures.

```mbti
pub let semiring_to_add_monoid : Reduct[SemiringSig, AddMonoidSig]
pub let semiring_to_mul_monoid : Reduct[SemiringSig, MulMonoidSig]
pub let ring_to_semiring : Reduct[RingSig, SemiringSig]
pub let ring_to_add_group : Reduct[RingSig, AddGroupSig]
pub let add_group_to_add_monoid : Reduct[AddGroupSig, AddMonoidSig]
```

### `Reduct::refl`, `Reduct::then`

`Reduct::refl()` is the trivial inclusion of `S` in itself; `r.then(r2)`
composes inclusions.

```mbti
pub fn[S] Reduct::refl() -> Reduct[S, S]
pub fn[S, T, U] Reduct::then(Reduct[S, T], Reduct[T, U]) -> Reduct[S, U]
```

```moonbit
test "reducts" {
  let r : Reduct[RingSig, AddMonoidSig] = ring_to_add_group.then(add_group_to_add_monoid)
  let h = int64_to_int().forget(r)
  assert_true(h.check(Algebra::add_monoid(), Algebra::add_monoid(), longs))
}
```

## Law checks

### `Hom::check`

`h.check(src, dst, samples)` tests the homomorphism law with exact equality
on every operation of `S`.

```mbti
pub fn[S, A, B : Eq] Hom::check(Hom[S, A, B], Algebra[S, A], Algebra[S, B], Array[A]) -> Bool
```

Requires `B : Eq`. It is `check_by` with `==`.

### `Hom::check_by`

`h.check_by(src, dst, samples, rel)` tests `rel(f(op_A(xs)), op_B(f(xs)))`
for every operation over all tuples drawn from `samples`.

```mbti
pub fn[S, A, B] Hom::check_by(Hom[S, A, B], Algebra[S, A], Algebra[S, B], Array[A], (B, B) -> Bool) -> Bool
```

`rel` sets the strength of preservation: equality for strict homomorphisms,
`<=` for lax ones such as subadditive maps, and a tolerance for approximate
homomorphisms into floating-point targets. An operation of arity `n` is
tested on `samples.length()^n` tuples. Aborts when `src` and `dst` do not
list the same operations.

```moonbit
test "check_by" {
  let abs : Hom[AddMonoidSig, Double, Double] = Hom::postulate(x => x.abs())
  let samples = [0.0, 1.5, -2.0, 3.25]
  // |x + y| <= |x| + |y|: subadditive, a lax homomorphism
  assert_true(abs.check_by(Algebra::add_monoid(), Algebra::add_monoid(), samples, (l, r) => l <= r))
  assert_false(abs.check(Algebra::add_monoid(), Algebra::add_monoid(), samples))
}
```

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

## Deprecated

### `Hom::from_nat`

`Hom::from_nat()` certifies `NatHomomorphism::from_nat`.

```mbti
#deprecated
pub fn[N : Nat, R : NatHomomorphism] Hom::from_nat() -> Hom[SemiringSig, N, R]
```

It is not a homomorphism for fixed-width sources. Replacement:
`Hom::from_integer` with `Section::of_integral`, or `lift_to` when no
certificate is needed.

### `Hom::from_integral`

`Hom::from_integral()` certifies `IntegralHomomorphism::from_integral`.

```mbti
#deprecated
pub fn[Z : Integral, R : IntegralHomomorphism] Hom::from_integral() -> Hom[SemiringSig, Z, R]
```

Deprecated for the same reason, with the same replacement.
