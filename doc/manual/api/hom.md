# hom API

## Purpose

The `hom` subsystem provides generalized homomorphisms. A `Hom[S, A, B]` is a
map `A -> B` that carries a certificate stating it preserves every operation
of the signature `S`. A `Section[S, Q, A]` certifies a lift that picks one
representative per class of a quotient. Neither certificate can be forged
outside this package. The unproven leaves are `Hom::postulate`,
`Section::postulate`, `Law::postulate`, and `LawfulModel::postulate`.
`Hom::from_integer_exact` consumes an explicit integer-homomorphism law;
`Section::of_integral` obtains that law from `Integral`.

Source: `src/hom.mbt`, `src/section.mbt`. The mathematics is in the
[hom design](../design/hom.md).

The examples on this page assume this declaration:

```moonbit
using @lf_alg {
  type Hom,
  type Section,
  type Algebra,
  type Model,
  type LawfulModel,
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
arity) in the same order. `Algebra::prod` returns `Err(ModelMismatch)` when
they do not. Finite `Hom::check` and `Hom::check_by` diagnostics return
`false` for dictionaries with different operation signatures. These checks
do not verify the Hom endpoint Model identities; `check_models` and
`check_models_by` do that for the exact stored Models.

### `Model`

`Model[S, A]` binds an operation dictionary to one runtime identity. Two
models with the same signature and carrier remain distinct when they were
constructed separately, even if their operations happen to compare equal.
The identity representation is opaque: callers cannot construct or mutate a
`ModelKey`, and `Model::same_identity` is the only public identity operation.

```mbti
pub struct Model[S, A] {
  // private fields
}

pub enum ModelConstructionError {
  InvalidArity
  InvalidOperationTable
}

pub fn[S, A] Model::make(Array[Op[A]]) -> Result[Model[S, A], ModelConstructionError]
pub fn[S, A] Model::same_identity(Model[S, A], Model[S, A]) -> Bool
```

Negative operation arity returns `Err(InvalidArity)` before allocating an
identity. Successful custom Models use process-local `UInt64` identities.
Construction is not thread-safe: callers must serialize it when using native
threads. If the counter reaches `UInt64::max`, construction aborts with an
internal-invariant failure before incrementing; it never wraps or reuses an
identity. This exhaustion case is physically unreachable in supported use.

Canonical factories use one stable identity per signature and carrier type
implementation. Repeated calls for the same canonical interpretation return
Models with the same identity.

```mbti
pub fn[A : AddGroupOps] Model::add_group() -> Model[AddGroupSig, A]
pub fn[A : MulMonoidOps] Model::mul_monoid() -> Model[MulMonoidSig, A]
pub fn[A : SemiringOps] Model::semiring() -> Model[SemiringSig, A]
```

### Construction errors and mismatch diagnostics

`ModelConstructionError` reports invalid arity or an operation table that a
kernel reduct cannot project. `ModelMismatch` reports different runtime model
identities. Both derive `Eq` and `Debug`, so callers can compare errors or
inspect their debug representation.

```mbti
pub fn ModelConstructionError::equal(ModelConstructionError, ModelConstructionError) -> Bool
pub fn ModelConstructionError::not_equal(ModelConstructionError, ModelConstructionError) -> Bool
pub fn ModelConstructionError::to_repr(ModelConstructionError) -> @debug.Repr
pub fn ModelMismatch::equal(ModelMismatch, ModelMismatch) -> Bool
pub fn ModelMismatch::not_equal(ModelMismatch, ModelMismatch) -> Bool
pub fn ModelMismatch::to_repr(ModelMismatch) -> @debug.Repr
```

### `LawfulModel::add_group`

This canonical convenience binds the `AddGroupTh` certificate and canonical
additive-group Model for `A`.

```mbti
pub fn[A : AddGroup] LawfulModel::add_group() -> LawfulModel[AddGroupTh, AddGroupSig, A]
```

### `Model::algebra`, `Model::prod`, `Model::forget`

`Model::algebra()` returns the model's operation dictionary. `Model::prod`
returns a fresh product identity with the two component identities recorded;
reuse that value for pairing and projections. `Model::forget` projects a
kernel mapping and returns `InvalidOperationTable` for incompatible tables.

```mbti
pub fn[S, A] Model::algebra(Model[S, A]) -> Algebra[S, A]
pub fn[S, A, B] Model::prod(Model[S, A], Model[S, B]) -> Result[Model[S, Prod[A, B]], ModelMismatch]
pub fn[S, T, A] Model::forget(Model[S, A], Reduct[S, T]) -> Result[Model[T, A], ModelConstructionError]
```

`Algebra::make` and `Model::make` validate nonnegative arity only, even for
built-in phantom signature tags. An empty table is allowed. Finite checks
over empty operation lists return true vacuously and establish no law.
`LawfulModel::postulate` can explicitly trust a rounded carrier; a small
sample may pass while a larger one fails. The caller owns that assumption.

`ModelMismatch` reports incompatible identities, product components, or
operation lists in checked composition and product construction. Both error
types implement `Eq` and `Debug`; match their variants to handle failures.

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

`Algebra::make(ops)` builds a dictionary for a custom signature tag. It
returns `Err(InvalidArity)` if any operation has a negative arity.

```mbti
pub fn[S, A] Algebra::make(Array[Op[A]]) -> Result[Algebra[S, A], ModelConstructionError]
```

Keep one dictionary per tag and carrier, as explained above.

```moonbit
enum MaxSig {}

fn max_int() -> Algebra[MaxSig, Int] {
  Algebra::make([
    Op::{ name: "max", arity: 2, eval: xs => if xs[0] > xs[1] { xs[0] } else { xs[1] } },
  ]).unwrap()
}
```

### `Algebra::add_monoid`, `Algebra::mul_monoid`, `Algebra::add_group`, `Algebra::semiring`, `Algebra::ring`

These functions derive the dictionary of a built-in tag from the structure
trait instance of `A`.

```mbti
pub fn[A : AddMonoidOps] Algebra::add_monoid() -> Algebra[AddMonoidSig, A]
pub fn[A : MulMonoidOps] Algebra::mul_monoid() -> Algebra[MulMonoidSig, A]
pub fn[A : AddGroupOps] Algebra::add_group() -> Algebra[AddGroupSig, A]
pub fn[A : SemiringOps] Algebra::semiring() -> Algebra[SemiringSig, A]
pub fn[A : RingOps] Algebra::ring() -> Algebra[RingSig, A]
```

The operations are listed in the order of the tag: for example `0`, `1`,
`+`, `*`, `neg` for `RingSig`. Trait coherence gives one dictionary per tag
and carrier.

```moonbit
test "built-in dictionaries" {
  let int_ring : Algebra[RingSig, Int] = Algebra::ring()
  let model : Model[RingSig, Int] = Model::ring()
  let id : Hom[RingSig, Int, Int] = Hom::id(model)
  assert_true(id.check(int_ring, int_ring, ints))
}
```

### `Algebra::prod`

`Algebra::prod(a, b)` is the componentwise product algebra on `Prod[A, B]`.

```mbti
pub fn[S, A, B] Algebra::prod(Algebra[S, A], Algebra[S, B]) -> Result[Algebra[S, Prod[A, B]], ModelMismatch]
```

Each operation acts on `fst` with `a` and on `snd` with `b`. The actual
signature returns `Result[Algebra[S, Prod[A, B]], ModelMismatch]` and rejects
different operation lists without aborting.

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

### Product law methods

`Prod::add_monoid_law`, `Prod::mul_monoid_law`, `Prod::add_group_law`,
`Prod::semiring_law`, and `Prod::ring_law` derive the corresponding law from
both components. An operation-only component does not provide these methods.

```mbti
pub fn[A : AddMonoid, B : AddMonoid] Prod::add_monoid_law() -> Law[AddMonoidTh, Prod[A, B]]
pub fn[A : MulMonoid, B : MulMonoid] Prod::mul_monoid_law() -> Law[MulMonoidTh, Prod[A, B]]
pub fn[A : AddGroup, B : AddGroup] Prod::add_group_law() -> Law[AddGroupTh, Prod[A, B]]
pub fn[A : Semiring, B : Semiring] Prod::semiring_law() -> Law[SemiringTh, Prod[A, B]]
pub fn[A : Ring, B : Ring] Prod::ring_law() -> Law[RingTh, Prod[A, B]]
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
`Hom::postulate` and `Hom::from_integer_exact`; the latter requires a
`LawfulModel[IntegerHomomorphismTh, SemiringSig, R]`. Every other constructor
is an inference rule or a checked runtime transformation.

### `Hom::postulate`

`Hom::postulate(source, target, f)` trusts `f` as an `S`-homomorphism without
proof and creates a proof obligation. The two Models bind the operation
interpretations used by the certificate.

```mbti
pub fn[S, A, B] Hom::postulate(Model[S, A], Model[S, B], (A) -> B) -> Hom[S, A, B]
```

The caller promises that for every operation `op` of `S` and all arguments
`xs`, `f(op_A(xs)) == op_B(xs.map(f))`. The promise is always strict
equality, even when the map is only checked with a lax or tolerance
relation. Back every call with a `check` test.

```moonbit
fn int64_to_int() -> Hom[RingSig, Int64, Int] {
  Hom::postulate(Model::ring(), Model::ring(), x => x.to_int())
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

`Hom::id(model)` is the identity homomorphism bound to the supplied runtime
model. Both endpoints use that exact model identity.

```mbti
pub fn[S, A] Hom::id(Model[S, A]) -> Hom[S, A, A]
```

### `Hom::then_checked`

`h.then_checked(g)` is the composite when the middle Model identities match.
It returns `Err(ModelMismatch)` for different runtime interpretations.

```mbti
pub fn[S, A, B, C] Hom::then_checked(Hom[S, A, B], Hom[S, B, C]) -> Result[Hom[S, A, C], ModelMismatch]
```

If $f$ and $g$ preserve $\omega$, so does $g \circ f$:

$$
g(f(\omega(x))) = g(\omega(f(x))) = \omega(g(f(x))).
$$

### `Hom::forget`

`h.forget(r)` forgets structure along a `Reduct[S, T]` witness.

```mbti
pub fn[S, T, A, B] Hom::forget(Hom[S, A, B], Reduct[S, T]) -> Result[Hom[T, A, B], ModelConstructionError]
```

A map that preserves every operation of `S` preserves the operations of the
smaller signature `T`.

### `Hom::pair`, `Hom::fst`, `Hom::snd`

`Hom::pair(product, f, g)` maps `x` to `{ fst: f(x), snd: g(x) }`. The
explicit product Model must be reused by `Hom::fst(product, left)` and
`Hom::snd(product, right)`.

```mbti
pub fn[S, A, B, C] Hom::pair(Model[S, Prod[B, C]], Hom[S, A, B], Hom[S, A, C]) -> Result[Hom[S, A, Prod[B, C]], ModelMismatch]
pub fn[S, A, B] Hom::fst(Model[S, Prod[A, B]], Model[S, A]) -> Result[Hom[S, Prod[A, B], A], ModelMismatch]
pub fn[S, A, B] Hom::snd(Model[S, Prod[A, B]], Model[S, B]) -> Result[Hom[S, Prod[A, B], B], ModelMismatch]
```

With the same product Model and component Models, the checked composites
`Hom::pair(product, f, g).then_checked(Hom::fst(product, left))` and
`Hom::pair(product, f, g).then_checked(Hom::snd(product, right))` return `f`
and `g` respectively.

```moonbit
test "composition rules" {
  let h = int64_to_int()
  let low : Hom[RingSig, Int64, Int16] = Hom::postulate(
    Model::ring(), Model::ring(), x => Int16::from_int(x.to_int()),
  )
  let product = Model::prod(Model::ring(), Model::ring()).unwrap()
  let p = Hom::pair(product, h, low).unwrap()
  let back = p.then_checked(Hom::fst(product, Model::ring()).unwrap()).unwrap()
  let additive = h.forget(ring_to_add_group).unwrap()
  inspect(back.apply(4294967301L), content="5")
  assert_true(additive.check(Algebra::add_group(), Algebra::add_group(), longs))
}
```

### `Hom::to_add_group`

`h.to_add_group(source_law, target_law)` upgrades an additive monoid
homomorphism after checking the law-bound Models match its endpoints.

```mbti
pub fn[A, B] Hom::to_add_group(Hom[AddMonoidSig, A, B], LawfulModel[AddGroupTh, AddGroupSig, A], LawfulModel[AddGroupTh, AddGroupSig, B]) -> Result[Hom[AddGroupSig, A, B], ModelMismatch]
```

No new obligation: $f(-x) + f(x) = f(-x + x) = f(0) = 0$, so $f(-x) = -f(x)$.

### `Hom::to_ring`

`h.to_ring(source_law, target_law)` upgrades a semiring homomorphism after
checking the law-bound Models match its endpoints.

```mbti
pub fn[A, B] Hom::to_ring(Hom[SemiringSig, A, B], LawfulModel[RingTh, RingSig, A], LawfulModel[RingTh, RingSig, B]) -> Result[Hom[RingSig, A, B], ModelMismatch]
```

No new obligation, by the same computation as `to_add_group`.

### `Hom::from_integer_exact`

`Hom::from_integer_exact(target)` is the canonical map ℤ → `R` only when the
target Model carries an explicit `IntegerHomomorphismTh` law. This law states
preservation of zero, one, addition and multiplication; it does not assert
injectivity.

```mbti
pub fn[R : FromInteger] Hom::from_integer_exact(LawfulModel[IntegerHomomorphismTh, SemiringSig, R]) -> Hom[SemiringSig, @bigint.BigInt, R]
```

Rounded `Float` and `Double` conversions do not provide this law. A caller
may use `Law::postulate` explicitly, but that assumption is visible in the
type and trust audit. For a fixed-width source, use `Section::of_integral`.

```moonbit
test "from_integer_exact" {
  let h : Hom[SemiringSig, BigInt, Int] = Hom::from_integer_exact(
    LawfulModel::integer_homomorphism(),
  )
  let samples = [0, 1, -1, 2147483647].map(BigInt::from_int)
  assert_true(h.check(Algebra::semiring(), Algebra::semiring(), samples))
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
  let truncate : Hom[RingSig, Int64, Int] = Hom::postulate(
    Model::ring(), Model::ring(), x => x.to_int(),
  )
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
  let s : Section[RingSig, Int, BigInt] = Section::of_integral()
    .to_ring(LawfulModel::ring(), LawfulModel::ring())
    .unwrap()
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
pub fn[S, Q, A, B] Section::then(Section[S, Q, A], Section[S, A, B]) -> Result[Section[S, Q, B], ModelMismatch]
```

The projection is `next.proj` followed by `s.proj`. No new obligation: with
$s, t$ the two lifts and $\pi_s, \pi_t$ their projections,
$\pi_s(\pi_t(t(s(q)))) = \pi_s(s(q)) = q$.

### `Section::forget`, `Section::to_add_group`, `Section::to_ring`

These inference rules change the signature of the projection; the lift is
unchanged.

```mbti
pub fn[S, T, Q, A] Section::forget(Section[S, Q, A], Reduct[S, T]) -> Result[Section[T, Q, A], ModelConstructionError]
pub fn[Q, A] Section::to_add_group(Section[AddMonoidSig, Q, A], LawfulModel[AddGroupTh, AddGroupSig, Q], LawfulModel[AddGroupTh, AddGroupSig, A]) -> Result[Section[AddGroupSig, Q, A], ModelMismatch]
pub fn[Q, A] Section::to_ring(Section[SemiringSig, Q, A], LawfulModel[RingTh, RingSig, Q], LawfulModel[RingTh, RingSig, A]) -> Result[Section[RingSig, Q, A], ModelMismatch]
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

This exercises `proj` as a homomorphism on representatives. It returns
`false` when the two dictionaries do not list the same operations.

```moonbit
test "section checks" {
  let s : Section[RingSig, Int, BigInt] = Section::of_integral()
    .to_ring(LawfulModel::ring(), LawfulModel::ring())
    .unwrap()
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
  let h = int64_to_int().forget(r).unwrap()
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

Requires `B : Eq`. It is `check_by` with `==`. Both Algebra-only diagnostics
test only the supplied tables: they do not verify the Hom endpoint Model
identities. Use `check_models` or `check_models_by` to validate those identities.

### `Hom::check_by`

`h.check_by(src, dst, samples, rel)` tests `rel(f(op_A(xs)), op_B(f(xs)))`
for every operation over all tuples drawn from `samples`.

```mbti
pub fn[S, A, B] Hom::check_by(Hom[S, A, B], Algebra[S, A], Algebra[S, B], Array[A], (B, B) -> Bool) -> Bool
```

`rel` sets the strength of preservation: equality for strict homomorphisms,
`<=` for lax ones such as subadditive maps, and a tolerance for approximate
homomorphisms into floating-point targets. An operation of arity `n` is
tested on `samples.length()^n` tuples. It returns `false` when `src` and `dst`
do not list the same operations.

### `Hom::check_models`, `Hom::check_models_by`

These diagnostics bind the finite check to the exact source and target Models
stored in the Hom. They return `Err(ModelMismatch)` when either endpoint has a
different runtime identity, then delegate to `check` or `check_by`. They still
return diagnostics only and never create a certificate.

```mbti
pub fn[S, A, B : Eq] Hom::check_models(Hom[S, A, B], Model[S, A], Model[S, B], Array[A]) -> Result[Bool, ModelMismatch]
pub fn[S, A, B] Hom::check_models_by(Hom[S, A, B], Model[S, A], Model[S, B], Array[A], (B, B) -> Bool) -> Result[Bool, ModelMismatch]
```

```moonbit
test "check_by" {
  let abs : Hom[AddMonoidSig, Double, Double] = Hom::postulate(
    Model::add_monoid(), Model::add_monoid(), x => x.abs(),
  )
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
- `Float` and `Double` provide rounded operations without exact law
  certificates; use `check_by` with a tolerance for approximate maps. See the
  embedding notes in the [core API](core.md).

## Removed conversion constructors

`Hom::from_nat`, `Hom::from_integral` and the old `Hom::from_integer` are not
part of the 0.5.0 API. Use `FromNat` / `FromInteger` for ordinary values,
`Section::of_integral` for representative lifts, and
`Hom::from_integer_exact` only with an explicit integer-homomorphism law.
