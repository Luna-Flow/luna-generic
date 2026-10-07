// Generalized homomorphisms.
//
// A `Hom[S, A, B]` is a map `A -> B` certified to preserve every operation of
// the signature `S`. The certificate cannot be forged outside this package:
// the only public trust entry is `Hom::postulate`, which hands the proof
// obligation to the caller. The canonical embeddings `Hom::from_nat` and
// `Hom::from_integral` are the other leaves; their obligation sits on the
// trait instances. Every other constructor here is an inference rule that
// preserves the certificate, so obligations only appear at the leaves.

///|
/// Signature tag: `0` and `+`.
pub enum AddMonoidSig {}

///|
/// Signature tag: `1` and `*`.
pub enum MulMonoidSig {}

///|
/// Signature tag: `0`, `+` and unary `-`.
pub enum AddGroupSig {}

///|
/// Signature tag: `0`, `1`, `+` and `*`.
pub enum SemiringSig {}

///|
/// Signature tag: `0`, `1`, `+`, `*` and unary `-`.
pub enum RingSig {}

///|
/// One operation of a single-sorted signature. `arity == 0` is a constant.
/// `eval` receives exactly `arity` arguments.
pub(all) struct Op[A] {
  name : String
  arity : Int
  eval : (Array[A]) -> A
}

///|
/// An interpretation of the signature `S` on the carrier `A`.
///
/// Two algebras of the same `S` must list the same operations in the same
/// order; `Hom::check_by` aborts when they do not.
#warnings("-unused_type_variable")
pub struct Algebra[S, A] {
  priv ops : Array[Op[A]]
}

///|
/// Builds an algebra for a custom signature tag.
///
/// Certificates assume one `S`-algebra per carrier: every `Algebra[S, A]`
/// passed to `check` for the same `S` and `A` must interpret the operations
/// the same way. `Hom::then` chains certificates through the middle carrier,
/// so two different algebras on it (say `max` and `min` both tagged `S`)
/// would compose into a map that preserves neither.
pub fn[S, A] Algebra::make(ops : Array[Op[A]]) -> Algebra[S, A] {
  { ops, }
}

///|
pub fn[A : AddMonoid] Algebra::add_monoid() -> Algebra[AddMonoidSig, A] {
  { ops: [op_zero(), op_add()], }
}

///|
pub fn[A : MulMonoid] Algebra::mul_monoid() -> Algebra[MulMonoidSig, A] {
  { ops: [op_one(), op_mul()], }
}

///|
pub fn[A : AddGroup] Algebra::add_group() -> Algebra[AddGroupSig, A] {
  { ops: [op_zero(), op_add(), op_neg()], }
}

///|
pub fn[A : Semiring] Algebra::semiring() -> Algebra[SemiringSig, A] {
  { ops: [op_zero(), op_one(), op_add(), op_mul()], }
}

///|
pub fn[A : Ring] Algebra::ring() -> Algebra[RingSig, A] {
  { ops: [op_zero(), op_one(), op_add(), op_mul(), op_neg()], }
}

///|
/// The componentwise product algebra.
pub fn[S, A, B] Algebra::prod(
  a : Algebra[S, A],
  b : Algebra[S, B],
) -> Algebra[S, Prod[A, B]] {
  ensure_same_signature(a.ops, b.ops)
  {
    ops: a.ops.mapi((i, oa) => {
      let ob = b.ops[i]
      {
        name: oa.name,
        arity: oa.arity,
        eval: xs => {
          fst: (oa.eval)(xs.map(x => x.fst)),
          snd: (ob.eval)(xs.map(x => x.snd)),
        },
      }
    }),
  }
}

///|
fn[A : Zero] op_zero() -> Op[A] {
  { name: "0", arity: 0, eval: _ => Zero::zero(), }
}

///|
fn[A : One] op_one() -> Op[A] {
  { name: "1", arity: 0, eval: _ => One::one(), }
}

///|
fn[A : Add] op_add() -> Op[A] {
  { name: "+", arity: 2, eval: xs => xs[0] + xs[1], }
}

///|
fn[A : Mul] op_mul() -> Op[A] {
  { name: "*", arity: 2, eval: xs => xs[0] * xs[1], }
}

///|
fn[A : Neg] op_neg() -> Op[A] {
  { name: "neg", arity: 1, eval: xs => -xs[0], }
}

///|
fn[A, B] ensure_same_signature(a : Array[Op[A]], b : Array[Op[B]]) -> Unit {
  guard a.length() == b.length() else {
    abort("Algebra: signatures have different numbers of operations")
  }
  for i, oa in a {
    let ob = b[i]
    guard oa.name == ob.name && oa.arity == ob.arity else {
      abort(
        "Algebra: operation mismatch at index \{i}: \{oa.name}/\{oa.arity} vs \{ob.name}/\{ob.arity}",
      )
    }
  }
}

///|
/// Binary product carrier. Operations act componentwise.
pub(all) struct Prod[A, B] {
  fst : A
  snd : B
} derive(Eq, Debug)

///|
pub impl[A : Add, B : Add] Add for Prod[A, B] with fn add(x, y) {
  { fst: x.fst + y.fst, snd: x.snd + y.snd, }
}

///|
pub impl[A : Mul, B : Mul] Mul for Prod[A, B] with fn mul(x, y) {
  { fst: x.fst * y.fst, snd: x.snd * y.snd, }
}

///|
pub impl[A : Neg, B : Neg] Neg for Prod[A, B] with fn neg(x) {
  { fst: -x.fst, snd: -x.snd, }
}

///|
pub impl[A : Sub, B : Sub] Sub for Prod[A, B] with fn sub(x, y) {
  { fst: x.fst - y.fst, snd: x.snd - y.snd, }
}

///|
pub impl[A : Zero, B : Zero] Zero for Prod[A, B] with fn zero() {
  { fst: Zero::zero(), snd: Zero::zero(), }
}

///|
pub impl[A : One, B : One] One for Prod[A, B] with fn one() {
  { fst: One::one(), snd: One::one(), }
}

///|
pub impl[A : AddMonoid, B : AddMonoid] AddMonoid for Prod[A, B]

///|
pub impl[A : MulMonoid, B : MulMonoid] MulMonoid for Prod[A, B]

///|
pub impl[A : AddGroup, B : AddGroup] AddGroup for Prod[A, B]

///|
pub impl[A : Semiring, B : Semiring] Semiring for Prod[A, B]

///|
pub impl[A : Ring, B : Ring] Ring for Prod[A, B]

///|
pub extend Prod with Eq::{equal, not_equal}

///|
pub extend Prod with Debug::{to_repr}

///|
pub extend Prod with Add::{add}

///|
pub extend Prod with Mul::{mul}

///|
pub extend Prod with Neg::{neg}

///|
pub extend Prod with Sub::{sub}

///|
pub extend Prod with Zero::{zero}

///|
pub extend Prod with One::{one}

///|
/// Witness that every `S`-structure is also a `T`-structure, so an
/// `S`-homomorphism is also a `T`-homomorphism. Only this package creates
/// witnesses.
#warnings("-unused_type_variable")
pub struct Reduct[S, T] {
  priv _witness : Unit
}

///|
pub let semiring_to_add_monoid : Reduct[SemiringSig, AddMonoidSig] = {
  _witness: (),
}

///|
pub let semiring_to_mul_monoid : Reduct[SemiringSig, MulMonoidSig] = {
  _witness: (),
}

///|
pub let ring_to_semiring : Reduct[RingSig, SemiringSig] = { _witness: (), }

///|
pub let ring_to_add_group : Reduct[RingSig, AddGroupSig] = { _witness: (), }

///|
pub let add_group_to_add_monoid : Reduct[AddGroupSig, AddMonoidSig] = {
  _witness: (),
}

///|
pub fn[S] Reduct::refl() -> Reduct[S, S] {
  { _witness: (), }
}

///|
#warnings("-unused_value")
pub fn[S, T, U] Reduct::then(
  self : Reduct[S, T],
  _next : Reduct[T, U],
) -> Reduct[S, U] {
  { _witness: (), }
}

///|
/// A map `A -> B` certified to preserve every operation of `S`.
#warnings("-unused_type_variable")
pub struct Hom[S, A, B] {
  priv f : (A) -> B
}

///|
/// Trusts `f` as an `S`-homomorphism without proof.
///
/// Proof obligation for the caller: for every operation `op` of `S` and all
/// arguments `xs`, `f(op_A(xs)) == op_B(xs.map(f))`. Back every call with a
/// `Hom::check` or `Hom::check_by` test.
///
/// The obligation is always strict equality. A map that only passes a lax
/// (`<=`) or tolerance check is still composed as a strict homomorphism by
/// `then`, `pair` and the other rules, so do not compose such certificates
/// without checking the result again.
pub fn[S, A, B] Hom::postulate(f : (A) -> B) -> Hom[S, A, B] {
  trust(f)
}

///|
/// Kernel-internal certificate constructor. Keeping it separate from
/// `Hom::postulate` means a search for `postulate` lists only user obligations.
fn[S, A, B] trust(f : (A) -> B) -> Hom[S, A, B] {
  { f, }
}

///|
pub fn[S, A, B] Hom::apply(self : Hom[S, A, B], x : A) -> B {
  (self.f)(x)
}

///|
pub fn[S, A] Hom::id() -> Hom[S, A, A] {
  trust(x => x)
}

///|
/// Composition: first `self`, then `next`.
pub fn[S, A, B, C] Hom::then(
  self : Hom[S, A, B],
  next : Hom[S, B, C],
) -> Hom[S, A, C] {
  let f = self.f
  let g = next.f
  trust(x => g(f(x)))
}

///|
/// Forgets part of the preserved structure along a reduct.
pub fn[S, T, A, B] Hom::forget(
  self : Hom[S, A, B],
  _reduct : Reduct[S, T],
) -> Hom[T, A, B] {
  trust(self.f)
}

///|
/// Pairing into the product: `x => { fst: f(x), snd: g(x) }`.
pub fn[S, A, B, C] Hom::pair(
  f : Hom[S, A, B],
  g : Hom[S, A, C],
) -> Hom[S, A, Prod[B, C]] {
  let f = f.f
  let g = g.f
  trust(x => { fst: f(x), snd: g(x), })
}

///|
pub fn[S, A, B] Hom::fst() -> Hom[S, Prod[A, B], A] {
  trust(p => p.fst)
}

///|
pub fn[S, A, B] Hom::snd() -> Hom[S, Prod[A, B], B] {
  trust(p => p.snd)
}

///|
/// A monoid homomorphism between groups preserves negation.
#warnings("-unused_trait_bound")
pub fn[A : AddGroup, B : AddGroup] Hom::to_add_group(
  self : Hom[AddMonoidSig, A, B],
) -> Hom[AddGroupSig, A, B] {
  trust(self.f)
}

///|
/// A semiring homomorphism between rings preserves negation.
#warnings("-unused_trait_bound")
pub fn[A : Ring, B : Ring] Hom::to_ring(
  self : Hom[SemiringSig, A, B],
) -> Hom[RingSig, A, B] {
  trust(self.f)
}

///|
/// The canonical embedding of a `Nat` source, backed by the
/// `NatHomomorphism` instance of the target. The obligation sits on that
/// instance: it must be the unique semiring map out of the naturals.
///
/// The certificate is not found by searching for `postulate`, and it only
/// holds where the source really is ℕ. Fixed-width sources such as `UInt`
/// are ℤ/2^k, which has no semiring map into a target of characteristic 0
/// such as `BigInt`, so the law holds only while source arithmetic does not
/// wrap. `Float` and `Double` targets only satisfy it up to rounding.
pub fn[N : Nat, R : NatHomomorphism] Hom::from_nat() -> Hom[SemiringSig, N, R] {
  trust(x => NatHomomorphism::from_nat(x))
}

///|
/// The canonical embedding of an `Integral` source, backed by the
/// `IntegralHomomorphism` instance of the target. Use `Hom::to_ring` when
/// both sides are rings.
///
/// The certificate is not found by searching for `postulate`, and it only
/// holds where the source really is ℤ. It is exact for `BigInt`; fixed-width
/// sources such as `Int` and `Int64` are ℤ/2^k, so the law holds only while
/// source arithmetic does not wrap. `Float` and `Double` targets only satisfy
/// the obligation up to rounding.
pub fn[Z : Integral, R : IntegralHomomorphism] Hom::from_integral() -> Hom[
  SemiringSig,
  Z,
  R,
] {
  trust(x => IntegralHomomorphism::from_integral(x))
}

///|
/// Tests the homomorphism law with exact equality on every operation of `S`
/// over all tuples drawn from `samples`.
pub fn[S, A, B : Eq] Hom::check(
  self : Hom[S, A, B],
  src : Algebra[S, A],
  dst : Algebra[S, B],
  samples : Array[A],
) -> Bool {
  self.check_by(src, dst, samples, (l, r) => l == r)
}

///|
/// Tests `rel(f(op_A(xs)), op_B(xs.map(f)))` for every operation of `S` over
/// all tuples drawn from `samples`. Choose `rel` to set the strength of
/// preservation: equality for strict homomorphisms, `<=` for lax ones such as
/// subadditive maps, and a tolerance for floating-point targets.
///
/// An operation of arity `n` is tested on `samples.length()^n` tuples.
pub fn[S, A, B] Hom::check_by(
  self : Hom[S, A, B],
  src : Algebra[S, A],
  dst : Algebra[S, B],
  samples : Array[A],
  rel : (B, B) -> Bool,
) -> Bool {
  ensure_same_signature(src.ops, dst.ops)
  let f = self.f
  for i, op in src.ops {
    let target = dst.ops[i]
    for args in tuples(samples, op.arity) {
      if !rel(f((op.eval)(args)), (target.eval)(args.map(f))) {
        return false
      }
    }
  }
  true
}

///|
fn[A] tuples(xs : Array[A], n : Int) -> Array[Array[A]] {
  if n == 0 {
    return [[]]
  }
  let out = []
  for t in tuples(xs, n - 1) {
    for x in xs {
      out.push([..t, x])
    }
  }
  out
}
