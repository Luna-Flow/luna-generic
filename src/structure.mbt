/// Operation-only capabilities. These traits state that operations exist;
/// they make no algebraic claim about those operations.

///|
pub(open) trait AddMonoidOps: Add + Zero {}

///|
pub(open) trait MulMonoidOps: Mul + One {}

///|
pub(open) trait AddGroupOps: AddMonoidOps + Neg + Sub {}

///|
pub(open) trait MulGroupOps: MulMonoidOps + Inverse + Div {}

///|
pub(open) trait SemiringOps: AddMonoidOps + MulMonoidOps {}

///|
pub(open) trait RingOps: SemiringOps + Neg + Sub {}

///|
pub(open) trait FieldOps: RingOps + Inverse + Div {}

///|
/// Numeric operations used by algorithms that need absolute value and sign,
/// without claiming exact ring laws.
pub(open) trait NumOps: RingOps {
  fn abs(Self) -> Self
  fn signum(Self) -> Self
}

///|
/// Marker for arithmetic whose operations are rounded. It does not certify
/// any algebraic law.
pub(open) trait RoundedArithmetic {}

///|
pub enum AddMonoidTh {}

///|
pub enum MulMonoidTh {}

///|
pub enum AddGroupTh {}

///|
pub enum MulGroupTh {}

///|
pub enum SemiringTh {}

///|
pub enum RingTh {}

///|
pub enum CommRingTh {}

///|
pub enum IntegralDomainTh {}

///|
pub enum FieldTh {}

///|
pub enum OrderedFieldTh {}

///|
pub enum IntegralTh {}

///|
pub enum NatTh {}

///|
/// The exact canonical map from BigInt into a semiring preserves zero, one,
/// addition, and multiplication.
pub enum IntegerHomomorphismTh {}

///|
/// Opaque evidence that a carrier satisfies a theory. postulate is the
/// explicit trust entry; a certificate records an assumption and is not a
/// machine-checked proof.
#warnings("-unused_type_variable")
pub struct Law[Th, A] {
  priv _witness : Unit
}

///|
/// Construction errors for operation tables and runtime Models. The Result
/// error reports user input validation only; exhausting the monotonic ID
/// counter violates an internal invariant and aborts before the counter can
/// wrap.
pub enum ModelConstructionError {
  InvalidArity
  InvalidOperationTable
}

///|
#warnings("-unused_constructor")
pub enum ModelMismatch {
  ModelMismatch
}

///|
/// Runtime identity for one operation interpretation.
///
/// This representation is package-private. Callers compare Models through
/// `Model::same_identity`; they cannot forge or mutate a lineage key.
#warnings("-unused_constructor")
enum ModelKey {
  Canonical(String)
  Custom(UInt64, Array[String])
}

///|
#warnings("-unused_value")
fn same_model_key(left : ModelKey, right : ModelKey) -> Bool {
  match (left, right) {
    (Canonical(left), Canonical(right)) => left == right
    (Custom(left_id, left_path), Custom(right_id, right_path)) => {
      if left_id != right_id || left_path.length() != right_path.length() {
        return false
      }
      for i, marker in left_path {
        if marker != right_path[i] {
          return false
        }
      }
      true
    }
    _ => false
  }
}

///|
#warnings("-unused_field")
pub struct Model[S, A] {
  priv algebra : Algebra[S, A]
  priv key : ModelKey
  priv product_origin : ProductOrigin?
}

///|
struct ProductOrigin {
  left : ModelKey
  right : ModelKey
}

///|
#warnings("-unused_constructor")
pub struct LawfulModel[Th, S, A] {
  priv model : Model[S, A]
  priv law : Law[Th, A]
}

///|
/// One process-local counter assigns identities to custom Models. Allocation
/// is serialized by the caller on multithreaded runtimes.
#warnings("-unused_value")
let custom_identity_counter : @ref.Ref[UInt64] = @ref.Ref(0UL)

///|
fn custom_identity_can_advance(current : UInt64) -> Bool {
  current != 18446744073709551615UL
}

///|
#warnings("-unused_value")
fn next_custom_identity() -> UInt64 {
  let counter = custom_identity_counter
  guard custom_identity_can_advance(counter.val) else {
    abort("luna-generic internal invariant: custom identity counter exhausted")
  }
  let current = counter.val
  counter.val = current + 1UL
  current
}

///|
/// Builds a custom runtime model. Each successful construction receives a
/// process-local identity. Construction is not thread-safe; callers using
/// native threads must serialize it. Negative operation arity returns
/// InvalidArity before an identity is allocated.
pub fn[S, A] Model::make(
  ops : Array[Op[A]],
) -> Result[Model[S, A], ModelConstructionError] {
  match Algebra::make(ops) {
    Ok(algebra) =>
      Ok({
        algebra,
        key: Custom(next_custom_identity(), []),
        product_origin: None,
      })
    Err(error) => Err(error)
  }
}

///|
fn[S, A] Model::canonical(
  algebra : Algebra[S, A],
  label : String,
) -> Model[S, A] {
  { algebra, key: Canonical(label), product_origin: None, }
}

///|
/// Canonical operation models have stable nominal identity per signature.
pub fn[A : AddMonoidOps] Model::add_monoid() -> Model[AddMonoidSig, A] {
  Model::canonical(Algebra::add_monoid(), "AddMonoidSig")
}

///|
pub fn[A : MulMonoidOps] Model::mul_monoid() -> Model[MulMonoidSig, A] {
  Model::canonical(Algebra::mul_monoid(), "MulMonoidSig")
}

///|
pub fn[A : AddGroupOps] Model::add_group() -> Model[AddGroupSig, A] {
  Model::canonical(Algebra::add_group(), "AddGroupSig")
}

///|
pub fn[A : SemiringOps] Model::semiring() -> Model[SemiringSig, A] {
  Model::canonical(Algebra::semiring(), "SemiringSig")
}

///|
pub fn[A : RingOps] Model::ring() -> Model[RingSig, A] {
  Model::canonical(Algebra::ring(), "RingSig")
}

///|
/// Constructs one product interpretation. Reuse this returned Model when
/// pairing maps and constructing projections; another call has a new ID.
pub fn[S, A, B] Model::prod(
  left : Model[S, A],
  right : Model[S, B],
) -> Result[Model[S, Prod[A, B]], ModelMismatch] {
  match Algebra::prod(left.algebra, right.algebra) {
    Ok(algebra) =>
      Ok({
        algebra,
        key: Custom(next_custom_identity(), []),
        product_origin: Some({ left: left.key, right: right.key, }),
      })
    Err(error) => Err(error)
  }
}

///|
/// Explicitly assumes a theory for this exact runtime model. This is a trust
/// entry, not a proof of the law.
pub fn[Th, S, A] LawfulModel::postulate(
  model : Model[S, A],
) -> LawfulModel[Th, S, A] {
  { model, law: Law::postulate(), }
}

///|
/// Binds the exact integer-map law for an Integral carrier to its canonical
/// semiring Model.
pub fn[R : Integral] LawfulModel::integer_homomorphism() -> LawfulModel[
  IntegerHomomorphismTh,
  SemiringSig,
  R,
] {
  let model = Model::semiring()
  { model, law: Integral::integer_homomorphism_law(), }
}

///|
#warnings("-unused_value")
pub fn[S, A] Model::algebra(self : Model[S, A]) -> Algebra[S, A] {
  self.algebra
}

///|
pub fn[S, A] Model::same_identity(
  self : Model[S, A],
  other : Model[S, A],
) -> Bool {
  same_model_key(self.key, other.key)
}

///|
test "custom identity exhaustion guard" {
  assert_true(custom_identity_can_advance(18446744073709551614UL))
  assert_false(custom_identity_can_advance(18446744073709551615UL))
  let previous = custom_identity_counter.val
  defer {
    custom_identity_counter.val = previous
  }
  custom_identity_counter.val = 18446744073709551614UL
  assert_eq(next_custom_identity(), 18446744073709551614UL)
  assert_eq(custom_identity_counter.val, 18446744073709551615UL)
}

///|
#warnings("-unused_value")
fn[Th, S, A] LawfulModel::model(self : LawfulModel[Th, S, A]) -> Model[S, A] {
  self.model
}

///|
#warnings("-unused_value")
fn[Th, S, A] LawfulModel::law(self : LawfulModel[Th, S, A]) -> Law[Th, A] {
  self.law
}

///|
pub fn[Th, A] Law::postulate() -> Law[Th, A] {
  { _witness: (), }
}

///|
/// Binds a canonical AddGroup law to its canonical operation Model.
pub fn[A : AddGroup] LawfulModel::add_group() -> LawfulModel[
  AddGroupTh,
  AddGroupSig,
  A,
] {
  let model = Model::add_group()
  { model, law: AddGroup::add_group_law(), }
}

///|
/// Binds a canonical Ring law to its canonical operation Model.
pub fn[A : Ring] LawfulModel::ring() -> LawfulModel[RingTh, RingSig, A] {
  let model = Model::ring()
  { model, law: Ring::ring_law(), }
}

///|
/// Kernel-owned weakening rules. Only actual theory implications are
/// provided; in particular there is no RingTh -> CommRingTh or RingTh ->
/// FieldTh conversion.
pub fn[A] Law::semiring_to_add_monoid(
  _law : Law[SemiringTh, A],
) -> Law[AddMonoidTh, A] {
  { _witness: (), }
}

///|
pub fn[A] Law::semiring_to_mul_monoid(
  _law : Law[SemiringTh, A],
) -> Law[MulMonoidTh, A] {
  { _witness: (), }
}

///|
pub fn[A] Law::ring_to_semiring(_law : Law[RingTh, A]) -> Law[SemiringTh, A] {
  { _witness: (), }
}

///|
pub fn[A] Law::ring_to_add_group(_law : Law[RingTh, A]) -> Law[AddGroupTh, A] {
  { _witness: (), }
}

///|
pub fn[A] Law::add_group_to_add_monoid(
  _law : Law[AddGroupTh, A],
) -> Law[AddMonoidTh, A] {
  { _witness: (), }
}

///|
pub fn[A] Law::field_to_ring(_law : Law[FieldTh, A]) -> Law[RingTh, A] {
  { _witness: (), }
}

///|
pub fn[A] Law::field_to_comm_ring(_law : Law[FieldTh, A]) -> Law[CommRingTh, A] {
  { _witness: (), }
}

///|
pub fn[A] Law::field_to_integral_domain(
  _law : Law[FieldTh, A],
) -> Law[IntegralDomainTh, A] {
  { _witness: (), }
}

///|
pub fn[A] Law::field_to_semiring(_law : Law[FieldTh, A]) -> Law[SemiringTh, A] {
  { _witness: (), }
}

///|
pub fn[A] Law::ordered_field_to_field(
  _law : Law[OrderedFieldTh, A],
) -> Law[FieldTh, A] {
  { _witness: (), }
}

///|
pub fn[A, B] Law::product_add_monoid(
  _left : Law[AddMonoidTh, A],
  _right : Law[AddMonoidTh, B],
) -> Law[AddMonoidTh, Prod[A, B]] {
  { _witness: (), }
}

///|
pub fn[A, B] Law::product_mul_monoid(
  _left : Law[MulMonoidTh, A],
  _right : Law[MulMonoidTh, B],
) -> Law[MulMonoidTh, Prod[A, B]] {
  { _witness: (), }
}

///|
pub fn[A, B] Law::product_add_group(
  _left : Law[AddGroupTh, A],
  _right : Law[AddGroupTh, B],
) -> Law[AddGroupTh, Prod[A, B]] {
  { _witness: (), }
}

///|
pub fn[A, B] Law::product_semiring(
  _left : Law[SemiringTh, A],
  _right : Law[SemiringTh, B],
) -> Law[SemiringTh, Prod[A, B]] {
  { _witness: (), }
}

///|
pub fn[A, B] Law::product_ring(
  _left : Law[RingTh, A],
  _right : Law[RingTh, B],
) -> Law[RingTh, Prod[A, B]] {
  { _witness: (), }
}

///|
/// Exact structures carry an explicit law method with no default. A type can
/// independently implement an operation bundle without claiming its laws.
pub(open) trait AddMonoid: AddMonoidOps {
  fn add_monoid_law() -> Law[AddMonoidTh, Self]
}

///|
pub(open) trait MulMonoid: MulMonoidOps {
  fn mul_monoid_law() -> Law[MulMonoidTh, Self]
}

///|
pub(open) trait AddGroup: AddGroupOps {
  fn add_group_law() -> Law[AddGroupTh, Self]
}

///|
pub(open) trait MulGroup: MulGroupOps {
  fn mul_group_law() -> Law[MulGroupTh, Self]
}

///|
pub(open) trait Semiring: SemiringOps {
  fn semiring_law() -> Law[SemiringTh, Self]
}

///|
pub(open) trait Ring: RingOps {
  fn ring_law() -> Law[RingTh, Self]
}

///|
pub(open) trait CommRing: RingOps {
  fn comm_ring_law() -> Law[CommRingTh, Self]
}

///|
pub(open) trait IntegralDomain: RingOps {
  fn integral_domain_law() -> Law[IntegralDomainTh, Self]
}

///|
/// A commutative field with nonzero denominator requirements on division and
/// inversion.
pub(open) trait Field: FieldOps {
  fn field_law() -> Law[FieldTh, Self]
}

///|
pub(open) trait OrderedField: FieldOps + Compare {
  fn ordered_field_law() -> Law[OrderedFieldTh, Self]
}

///|
/// The canonical map out of the naturals: the unique semiring homomorphism
/// ℕ -> Self. The argument must be non-negative. This is an operation, not
/// a law certificate.
pub(open) trait FromNat {
  fn from_natural(BigInt) -> Self
}

///|
/// The canonical operation out of the integers. Rounded implementations do
/// not create strict Hom certificates.
pub(open) trait FromInteger: FromNat {
  fn from_integer(BigInt) -> Self
}

///|
/// An integer type: ℤ itself, or a quotient ℤ/2^k such as the fixed-width
/// integers. normalize picks the representative of each class as a BigInt.
pub(open) trait Integral: SemiringOps + FromInteger {
  fn integral_law() -> Law[IntegralTh, Self]
  fn integer_homomorphism_law() -> Law[IntegerHomomorphismTh, Self]
  fn normalize(Self) -> BigInt
}

///|
/// An integer type whose representatives are non-negative, such as the
/// unsigned fixed-width integers.
pub(open) trait Nat: Integral {
  fn nat_law() -> Law[NatTh, Self]
}

///|
/// Deprecated operation for mapping a fixed-width natural representative.
#deprecated("Implement FromNat and use lift_to instead.", skip_current_package=true)
pub(open) trait NatHomomorphism {
  fn[S : Nat] from_nat(value : S) -> Self
}

///|
/// Deprecated operation for mapping a fixed-width integer representative.
#deprecated("Implement FromInteger and use lift_to instead.", skip_current_package=true)
pub(open) trait IntegralHomomorphism: NatHomomorphism {
  fn[S : Integral] from_integral(value : S) -> Self
}
