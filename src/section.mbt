// Representative lifts of quotient algebras.
//
// A `Section[S, Q, A]` pairs a surjective homomorphism `proj : A -> Q` with a
// map `lift : Q -> A` that picks one representative of every class, so that
// `proj(lift(q)) == q`. `lift` is not a homomorphism, but the section law
// alone implies:
//
// - `lift(op_Q(xs))` and `op_A(xs.map(lift))` are congruent modulo `proj`;
// - they are equal whenever `op_A(xs.map(lift))` is itself a representative;
// - `normalize = lift ∘ proj` is a normal form: two values are congruent
//   exactly when their normal forms are equal.
//
// Fixed-width integers are the motivating case: `Int` is ℤ/2^32, `proj` is
// the reduction `BigInt -> Int`, and `lift` picks the representative in
// [-2^31, 2^31). The section law rejects lifts that leave the class of their
// argument; it says nothing about which representative is chosen.

///|
/// A lift of the quotient `Q` back into `A` along the projection `proj`.
pub struct Section[S, Q, A] {
  priv proj : Hom[S, A, Q]
  priv lift : (Q) -> A
}

///|
/// Trusts `lift` as a section of `proj` without proof.
///
/// Proof obligation for the caller: `proj.apply(lift(q)) == q` for every `q`.
/// The law makes `proj` surjective; `proj` carries its own `Hom` obligation.
/// Back every call with a `Section::check` or `Section::check_ops` test.
pub fn[S, Q, A] Section::postulate(
  proj : Hom[S, A, Q],
  lift : (Q) -> A,
) -> Section[S, Q, A] {
  { proj, lift, }
}

///|
/// The canonical section of an integer type: `proj` is the canonical map
/// `BigInt -> Z` given by `FromInteger`, and `lift` is `Integral::normalize`.
/// The obligation sits on those instances: `Z::from_integer(normalize(x)) ==
/// x` for every `x`. Use `to_ring` when `Z` is a ring.
pub fn[Z : Integral] Section::of_integral() -> Section[SemiringSig, Z, BigInt] {
  {
    proj: trust(x => FromInteger::from_integer(x)),
    lift: x => Integral::normalize(x),
  }
}

///|
/// The chosen representative of `q`.
pub fn[S, Q, A] Section::lift(self : Section[S, Q, A], q : Q) -> A {
  (self.lift)(q)
}

///|
/// The projection onto the quotient.
pub fn[S, Q, A] Section::proj(self : Section[S, Q, A]) -> Hom[S, A, Q] {
  self.proj
}

///|
/// The normal form of `a`: the chosen representative of its class.
pub fn[S, Q, A] Section::normalize(self : Section[S, Q, A], a : A) -> A {
  (self.lift)(self.proj.apply(a))
}

///|
/// Whether `a` is the chosen representative of its class. On such results the
/// lift agrees exactly with the operations of `A`.
pub fn[S, Q, A : Eq] Section::is_representative(
  self : Section[S, Q, A],
  a : A,
) -> Bool {
  self.normalize(a) == a
}

///|
/// Composition: lift `Q` into `A` with `self`, then `A` into `B` with `next`.
/// The projection is `next.proj` followed by `self.proj`.
pub fn[S, Q, A, B] Section::then(
  self : Section[S, Q, A],
  next : Section[S, A, B],
) -> Section[S, Q, B] {
  let inner = self.lift
  let outer = next.lift
  { proj: next.proj.then(self.proj), lift: q => outer(inner(q)), }
}

///|
/// Forgets part of the structure along a reduct. The section law does not
/// mention the operations, so only the projection changes.
pub fn[S, T, Q, A] Section::forget(
  self : Section[S, Q, A],
  reduct : Reduct[S, T],
) -> Section[T, Q, A] {
  { proj: self.proj.forget(reduct), lift: self.lift, }
}

///|
/// Upgrades the projection along `Hom::to_add_group`.
pub fn[Q : AddGroup, A : AddGroup] Section::to_add_group(
  self : Section[AddMonoidSig, Q, A],
) -> Section[AddGroupSig, Q, A] {
  { proj: self.proj.to_add_group(), lift: self.lift, }
}

///|
/// Upgrades the projection along `Hom::to_ring`.
pub fn[Q : Ring, A : Ring] Section::to_ring(
  self : Section[SemiringSig, Q, A],
) -> Section[RingSig, Q, A] {
  { proj: self.proj.to_ring(), lift: self.lift, }
}

///|
/// Tests the section law `proj(lift(q)) == q` on every sample.
pub fn[S, Q : Eq, A] Section::check(
  self : Section[S, Q, A],
  samples : Array[Q],
) -> Bool {
  samples.iter().all(q => self.proj.apply((self.lift)(q)) == q)
}

///|
/// Tests `proj(op_A(xs.map(lift))) == op_Q(xs)` for every operation of `S`
/// over all tuples drawn from `samples`, which exercises `proj` as a
/// homomorphism on representatives.
///
/// Together with the section law this means `lift` preserves every operation
/// up to the kernel of `proj`, and exactly whenever `op_A(xs.map(lift))` is a
/// representative: then it equals `lift(proj(...)) == lift(op_Q(xs))`. Outside
/// the representatives the difference is a kernel element, such as the carry
/// of a wrapped addition.
pub fn[S, Q : Eq, A] Section::check_ops(
  self : Section[S, Q, A],
  quotient : Algebra[S, Q],
  cover : Algebra[S, A],
  samples : Array[Q],
) -> Bool {
  ensure_same_signature(quotient.ops, cover.ops)
  for i, op in quotient.ops {
    let lifted = cover.ops[i]
    for args in tuples(samples, op.arity) {
      let r = (lifted.eval)(args.map(self.lift))
      if self.proj.apply(r) != (op.eval)(args) {
        return false
      }
    }
  }
  true
}

///|
/// Lifts `x` to its representative in ℤ, then maps it into `R` along the
/// canonical map. This is a function, not a homomorphism: for a fixed-width
/// source it is one only when the modulus of `R` divides that of `S`, as for
/// `Int64 -> Int`. Use it to turn machine integers into exact or approximate
/// numbers that are not mapped back.
pub fn[S : Integral, R : FromInteger] lift_to(x : S) -> R {
  FromInteger::from_integer(x.normalize())
}
