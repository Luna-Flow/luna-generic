// Generalized homomorphisms.
//
// A `Hom[S, A, B]` is a map `A -> B` certified to preserve every operation of
// the signature `S`. The certificate cannot be forged outside this package:
// `Hom::postulate` hands the map-preservation obligation to the caller. Law
// assumptions enter separately through `Law::postulate` and
// `LawfulModel::postulate`. Canonical conversion operations do not by
// themselves create strict Hom certificates. Every other constructor here is
// an inference rule that preserves the certificate, so obligations only
// appear at the leaves.

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
  arity : Int32
  eval : (Array[A]) -> A
}

///|
/// An interpretation of the signature `S` on the carrier `A`.
///
/// Two algebras of the same `S` must list the same operations in the same
/// order. `Hom::check_by` returns `false` when they do not.
#warnings("-unused_type_variable")
pub struct Algebra[S, A] {
  priv ops : Array[Op[A]]
}

///|
pub fn[S, A] Algebra::make(
  ops : Array[Op[A]],
) -> Result[Algebra[S, A], ModelConstructionError] {
  guard valid_operation_arities(ops) else { return Err(InvalidArity) }
  Ok({ ops, })
}

///|
fn[A] valid_operation_arities(ops : Array[Op[A]]) -> Bool {
  for op in ops {
    if op.arity < 0 {
      return false
    }
  }
  true
}

///|
pub fn[A : AddMonoidOps] Algebra::add_monoid() -> Algebra[AddMonoidSig, A] {
  { ops: [op_zero(), op_add()], }
}

///|
pub fn[A : MulMonoidOps] Algebra::mul_monoid() -> Algebra[MulMonoidSig, A] {
  { ops: [op_one(), op_mul()], }
}

///|
pub fn[A : AddGroupOps] Algebra::add_group() -> Algebra[AddGroupSig, A] {
  { ops: [op_zero(), op_add(), op_neg()], }
}

///|
pub fn[A : SemiringOps] Algebra::semiring() -> Algebra[SemiringSig, A] {
  { ops: [op_zero(), op_one(), op_add(), op_mul()], }
}

///|
pub fn[A : RingOps] Algebra::ring() -> Algebra[RingSig, A] {
  { ops: [op_zero(), op_one(), op_add(), op_mul(), op_neg()], }
}

///|
/// The componentwise product algebra.
pub fn[S, A, B] Algebra::prod(
  a : Algebra[S, A],
  b : Algebra[S, B],
) -> Result[Algebra[S, Prod[A, B]], ModelMismatch] {
  guard same_signature(a.ops, b.ops) else { return Err(SignatureMismatch) }
  Ok({
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
  })
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
fn[A, B] same_signature(a : Array[Op[A]], b : Array[Op[B]]) -> Bool {
  if a.length() != b.length() {
    return false
  }
  for i, oa in a {
    let ob = b[i]
    if oa.name != ob.name || oa.arity != ob.arity {
      return false
    }
  }
  true
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
pub impl[A : AddMonoidOps, B : AddMonoidOps] AddMonoidOps for Prod[A, B]

///|
pub impl[A : MulMonoidOps, B : MulMonoidOps] MulMonoidOps for Prod[A, B]

///|
pub impl[A : AddGroupOps, B : AddGroupOps] AddGroupOps for Prod[A, B]

///|
pub impl[A : SemiringOps, B : SemiringOps] SemiringOps for Prod[A, B]

///|
pub impl[A : RingOps, B : RingOps] RingOps for Prod[A, B]

///|
pub impl[A : AddMonoid, B : AddMonoid] AddMonoid for Prod[A, B] with fn add_monoid_law() {
  Law::product_add_monoid(
    AddMonoid::add_monoid_law(),
    AddMonoid::add_monoid_law(),
  )
}

///|
pub impl[A : MulMonoid, B : MulMonoid] MulMonoid for Prod[A, B] with fn mul_monoid_law() {
  Law::product_mul_monoid(
    MulMonoid::mul_monoid_law(),
    MulMonoid::mul_monoid_law(),
  )
}

///|
pub impl[A : AddGroup, B : AddGroup] AddGroup for Prod[A, B] with fn add_group_law() {
  Law::product_add_group(AddGroup::add_group_law(), AddGroup::add_group_law())
}

///|
pub impl[A : Semiring, B : Semiring] Semiring for Prod[A, B] with fn semiring_law() {
  Law::product_semiring(Semiring::semiring_law(), Semiring::semiring_law())
}

///|
pub impl[A : Ring, B : Ring] Ring for Prod[A, B] with fn ring_law() {
  Law::product_ring(Ring::ring_law(), Ring::ring_law())
}

///|
pub extend Prod with AddMonoid::{add_monoid_law}

///|
pub extend Prod with MulMonoid::{mul_monoid_law}

///|
pub extend Prod with AddGroup::{add_group_law}

///|
pub extend Prod with Semiring::{semiring_law}

///|
pub extend Prod with Ring::{ring_law}

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
priv struct OperationShape {
  name : String
  arity : Int32
}

///|
/// A kernel-owned projection between operation signatures. Its path records
/// the mapping itself; composing two reducts preserves both mapping markers.
#warnings("-unused_type_variable")
pub struct Reduct[S, T] {
  priv markers : Array[String]
  priv source_ops : Array[OperationShape]
  priv indices : Array[Int32]
  priv target_label : String
}

///|
pub let semiring_to_add_monoid : Reduct[SemiringSig, AddMonoidSig] = {
  markers: ["semiring-to-add-monoid"],
  source_ops: [
    { name: "0", arity: 0, },
    { name: "1", arity: 0, },
    { name: "+", arity: 2, },
    { name: "*", arity: 2, },
  ],
  indices: [0, 2],
  target_label: "AddMonoidSig",
}

///|
pub let semiring_to_mul_monoid : Reduct[SemiringSig, MulMonoidSig] = {
  markers: ["semiring-to-mul-monoid"],
  source_ops: [
    { name: "0", arity: 0, },
    { name: "1", arity: 0, },
    { name: "+", arity: 2, },
    { name: "*", arity: 2, },
  ],
  indices: [1, 3],
  target_label: "MulMonoidSig",
}

///|
pub let ring_to_semiring : Reduct[RingSig, SemiringSig] = {
  markers: ["ring-to-semiring"],
  source_ops: [
    { name: "0", arity: 0, },
    { name: "1", arity: 0, },
    { name: "+", arity: 2, },
    { name: "*", arity: 2, },
    { name: "neg", arity: 1, },
  ],
  indices: [0, 1, 2, 3],
  target_label: "SemiringSig",
}

///|
pub let ring_to_add_group : Reduct[RingSig, AddGroupSig] = {
  markers: ["ring-to-add-group"],
  source_ops: [
    { name: "0", arity: 0, },
    { name: "1", arity: 0, },
    { name: "+", arity: 2, },
    { name: "*", arity: 2, },
    { name: "neg", arity: 1, },
  ],
  indices: [0, 2, 4],
  target_label: "AddGroupSig",
}

///|
pub let add_group_to_add_monoid : Reduct[AddGroupSig, AddMonoidSig] = {
  markers: ["add-group-to-add-monoid"],
  source_ops: [
    { name: "0", arity: 0, },
    { name: "+", arity: 2, },
    { name: "neg", arity: 1, },
  ],
  indices: [0, 1],
  target_label: "AddMonoidSig",
}

///|
pub fn[S] Reduct::refl() -> Reduct[S, S] {
  { markers: [], source_ops: [], indices: [], target_label: "", }
}

///|
pub fn[S, T, U] Reduct::then(
  self : Reduct[S, T],
  next : Reduct[T, U],
) -> Reduct[S, U] {
  let markers = append_strings(self.markers, next.markers)
  let indices = if self.markers.length() == 0 {
    next.indices
  } else if next.markers.length() == 0 {
    self.indices
  } else {
    next.indices.map(index => self.indices[index])
  }
  let source_ops = if self.markers.length() == 0 {
    next.source_ops
  } else {
    self.source_ops
  }
  let target_label = if next.target_label == "" {
    self.target_label
  } else {
    next.target_label
  }
  { markers, source_ops, indices, target_label, }
}

///|
fn append_strings(left : Array[String], right : Array[String]) -> Array[String] {
  let out = []
  for value in left {
    out.push(value)
  }
  for value in right {
    out.push(value)
  }
  out
}

///|
fn[S, T, A] project_algebra(
  algebra : Algebra[S, A],
  reduct : Reduct[S, T],
) -> Result[Algebra[T, A], ModelConstructionError] {
  if algebra.ops.length() != reduct.source_ops.length() {
    return Err(InvalidOperationTable)
  }
  for i, shape in reduct.source_ops {
    let op = algebra.ops[i]
    if op.name != shape.name || op.arity != shape.arity {
      return Err(InvalidOperationTable)
    }
  }
  Ok({ ops: reduct.indices.map(index => algebra.ops[index]), })
}

///|
fn[S, T, A] Model::key_after_reduct(
  self : Model[S, A],
  reduct : Reduct[S, T],
) -> ModelKey {
  key_after_reduct(self.key, reduct)
}

///|
fn[S, T] key_after_reduct(key : ModelKey, reduct : Reduct[S, T]) -> ModelKey {
  if reduct.markers.length() == 0 {
    return key
  }
  match key {
    Canonical(_) => Canonical(reduct.target_label)
    Custom(id, path) => Custom(id, append_strings(path, reduct.markers))
  }
}

///|
/// Applies a kernel reduct to this operation table. An invalid source table
/// returns InvalidOperationTable; custom model identity and lineage are kept.
pub fn[S, T, A] Model::forget(
  self : Model[S, A],
  reduct : Reduct[S, T],
) -> Result[Model[T, A], ModelConstructionError] {
  if reduct.markers.length() == 0 {
    return Ok({
      algebra: { ops: self.algebra.ops, },
      key: self.key,
      product_origin: self.product_origin,
    })
  }
  match project_algebra(self.algebra, reduct) {
    Ok(algebra) =>
      Ok({
        algebra,
        key: self.key_after_reduct(reduct),
        product_origin: match self.product_origin {
          None => None
          Some(origin) =>
            Some({
              left: key_after_reduct(origin.left, reduct),
              right: key_after_reduct(origin.right, reduct),
            })
        },
      })
    Err(error) => Err(error)
  }
}

///|
/// A map `A -> B` certified to preserve every operation of `S`.
#warnings("-unused_field")
pub struct Hom[S, A, B] {
  priv source : Model[S, A]
  priv target : Model[S, B]
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
/// `then_checked`, `pair` and the other rules, so do not compose such
/// certificates without checking the result again.
pub fn[S, A, B] Hom::postulate(
  source : Model[S, A],
  target : Model[S, B],
  f : (A) -> B,
) -> Hom[S, A, B] {
  { source, target, f, }
}

///|
/// Kernel-internal certificate constructor. Keeping it separate from
/// `Hom::postulate` keeps the map-preservation assumption visible to audits.
fn[S, A, B] trust(
  source : Model[S, A],
  target : Model[S, B],
  f : (A) -> B,
) -> Hom[S, A, B] {
  { source, target, f, }
}

///|
pub fn[S, A, B] Hom::apply(self : Hom[S, A, B], x : A) -> B {
  (self.f)(x)
}

///|
pub fn[S, A] Hom::id(model : Model[S, A]) -> Hom[S, A, A] {
  { source: model, target: model, f: x => x, }
}

///|
/// Composition: first `self`, then `next`, when their middle Models match.
pub fn[S, A, B, C] Hom::then_checked(
  self : Hom[S, A, B],
  next : Hom[S, B, C],
) -> Result[Hom[S, A, C], ModelMismatch] {
  guard same_model_key(self.target.key, next.source.key) else {
    return Err(IdentityMismatch)
  }
  let f = self.f
  let g = next.f
  Ok({ source: self.source, target: next.target, f: x => g(f(x)), })
}

///|
/// Forgets part of the preserved structure along a reduct.
pub fn[S, T, A, B] Hom::forget(
  self : Hom[S, A, B],
  _reduct : Reduct[S, T],
) -> Result[Hom[T, A, B], ModelConstructionError] {
  match (self.source.forget(_reduct), self.target.forget(_reduct)) {
    (Ok(source), Ok(target)) => Ok({ source, target, f: self.f, })
    (Err(error), _) => Err(error)
    (_, Err(error)) => Err(error)
  }
}

///|
/// Pairing into the product: `x => { fst: f(x), snd: g(x) }`.
pub fn[S, A, B, C] Hom::pair(
  product : Model[S, Prod[B, C]],
  f : Hom[S, A, B],
  g : Hom[S, A, C],
) -> Result[Hom[S, A, Prod[B, C]], ModelMismatch] {
  guard product.product_origin is Some(origin) else {
    return Err(NotProductModel)
  }
  guard same_model_key(f.source.key, g.source.key) else {
    return Err(IdentityMismatch)
  }
  guard same_model_key(origin.left, f.target.key) else {
    return Err(IdentityMismatch)
  }
  guard same_model_key(origin.right, g.target.key) else {
    return Err(IdentityMismatch)
  }
  let ff = f.f
  let gg = g.f
  Ok({ source: f.source, target: product, f: x => { fst: ff(x), snd: gg(x), }, })
}

///|
pub fn[S, A, B] Hom::fst(
  product : Model[S, Prod[A, B]],
  left : Model[S, A],
) -> Result[Hom[S, Prod[A, B], A], ModelMismatch] {
  match product.product_origin {
    Some(origin) => {
      guard same_model_key(origin.left, left.key) else {
        return Err(IdentityMismatch)
      }
      Ok({ source: product, target: left, f: p => p.fst, })
    }
    None => Err(NotProductModel)
  }
}

///|
pub fn[S, A, B] Hom::snd(
  product : Model[S, Prod[A, B]],
  right : Model[S, B],
) -> Result[Hom[S, Prod[A, B], B], ModelMismatch] {
  match product.product_origin {
    Some(origin) => {
      guard same_model_key(origin.right, right.key) else {
        return Err(IdentityMismatch)
      }
      Ok({ source: product, target: right, f: p => p.snd, })
    }
    None => Err(NotProductModel)
  }
}

///|
/// Exact canonical map from BigInt into a lawful semiring model.
pub fn[R : FromInteger] Hom::from_integer_exact(
  target : LawfulModel[IntegerHomomorphismTh, SemiringSig, R],
) -> Hom[SemiringSig, BigInt, R] {
  ignore(target.law())
  {
    source: Model::semiring(),
    target: target.model(),
    f: x => FromInteger::from_integer(x),
  }
}

///|
/// A monoid homomorphism between groups preserves negation.
#warnings("-unused_trait_bound")
pub fn[A, B] Hom::to_add_group(
  self : Hom[AddMonoidSig, A, B],
  source : LawfulModel[AddGroupTh, AddGroupSig, A],
  target : LawfulModel[AddGroupTh, AddGroupSig, B],
) -> Result[Hom[AddGroupSig, A, B], ModelMismatch] {
  let source_model = source.model()
  let target_model = target.model()
  ignore(source.law())
  ignore(target.law())
  guard same_model_key(
    key_after_reduct(source_model.key, add_group_to_add_monoid),
    self.source.key,
  ) else {
    return Err(IdentityMismatch)
  }
  guard same_model_key(
    key_after_reduct(target_model.key, add_group_to_add_monoid),
    self.target.key,
  ) else {
    return Err(IdentityMismatch)
  }
  Ok(trust(source_model, target_model, self.f))
}

///|
/// A semiring homomorphism between rings preserves negation.
#warnings("-unused_trait_bound")
pub fn[A, B] Hom::to_ring(
  self : Hom[SemiringSig, A, B],
  source : LawfulModel[RingTh, RingSig, A],
  target : LawfulModel[RingTh, RingSig, B],
) -> Result[Hom[RingSig, A, B], ModelMismatch] {
  let source_model = source.model()
  let target_model = target.model()
  ignore(source.law())
  ignore(target.law())
  guard same_model_key(
    key_after_reduct(source_model.key, ring_to_semiring),
    self.source.key,
  ) else {
    return Err(IdentityMismatch)
  }
  guard same_model_key(
    key_after_reduct(target_model.key, ring_to_semiring),
    self.target.key,
  ) else {
    return Err(IdentityMismatch)
  }
  Ok(trust(source_model, target_model, self.f))
}

///|
/// Tests the homomorphism law with exact equality on every operation of `S`
/// over all tuples drawn from `samples`.
/// This Algebra-only diagnostic does not verify endpoint Model identity.
/// Use check_models for a check bound to the stored endpoint Models.
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
/// This Algebra-only diagnostic does not verify endpoint Model identity.
/// Use check_models_by to validate both stored endpoint Models first.
pub fn[S, A, B] Hom::check_by(
  self : Hom[S, A, B],
  src : Algebra[S, A],
  dst : Algebra[S, B],
  samples : Array[A],
  rel : (B, B) -> Bool,
) -> Bool {
  if !same_signature(src.ops, dst.ops) {
    return false
  }
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
/// Checks a Hom against the exact runtime Models bound to its endpoints.
/// Unlike the Algebra-only diagnostic, this rejects unrelated operation
/// interpretations before evaluating any finite samples.
pub fn[S, A, B : Eq] Hom::check_models(
  self : Hom[S, A, B],
  source : Model[S, A],
  target : Model[S, B],
  samples : Array[A],
) -> Result[Bool, ModelMismatch] {
  guard same_model_key(self.source.key, source.key) else {
    return Err(IdentityMismatch)
  }
  guard same_model_key(self.target.key, target.key) else {
    return Err(IdentityMismatch)
  }
  Ok(self.check(source.algebra, target.algebra, samples))
}

///|
/// Checks a Hom against exact runtime Models with a caller-supplied relation.
pub fn[S, A, B] Hom::check_models_by(
  self : Hom[S, A, B],
  source : Model[S, A],
  target : Model[S, B],
  samples : Array[A],
  rel : (B, B) -> Bool,
) -> Result[Bool, ModelMismatch] {
  guard same_model_key(self.source.key, source.key) else {
    return Err(IdentityMismatch)
  }
  guard same_model_key(self.target.key, target.key) else {
    return Err(IdentityMismatch)
  }
  Ok(self.check_by(source.algebra, target.algebra, samples, rel))
}

///|
fn[A] tuples(xs : Array[A], n : Int32) -> Array[Array[A]] {
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
