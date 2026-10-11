// Canonical integer-carrier law assumptions. Stronger structures are the
// single postulate per carrier; weaker certificates use kernel weakening.

///|
pub impl Ring for BigInt with fn ring_law() {
  Law::postulate()
}

///|
pub impl Semiring for BigInt with fn semiring_law() {
  Law::ring_to_semiring(Ring::ring_law())
}

///|
pub impl AddGroup for BigInt with fn add_group_law() {
  Law::ring_to_add_group(Ring::ring_law())
}

///|
pub impl AddMonoid for BigInt with fn add_monoid_law() {
  Law::add_group_to_add_monoid(AddGroup::add_group_law())
}

///|
pub impl MulMonoid for BigInt with fn mul_monoid_law() {
  Law::semiring_to_mul_monoid(Semiring::semiring_law())
}

///|
pub impl CommRing for BigInt with fn comm_ring_law() {
  Law::postulate()
}

///|
pub impl IntegralDomain for BigInt with fn integral_domain_law() {
  Law::postulate()
}

///|
pub impl Ring for Int with fn ring_law() {
  Law::postulate()
}

///|
pub impl Semiring for Int with fn semiring_law() {
  Law::ring_to_semiring(Ring::ring_law())
}

///|
pub impl AddGroup for Int with fn add_group_law() {
  Law::ring_to_add_group(Ring::ring_law())
}

///|
pub impl AddMonoid for Int with fn add_monoid_law() {
  Law::add_group_to_add_monoid(AddGroup::add_group_law())
}

///|
pub impl MulMonoid for Int with fn mul_monoid_law() {
  Law::semiring_to_mul_monoid(Semiring::semiring_law())
}

///|
pub impl CommRing for Int with fn comm_ring_law() {
  Law::postulate()
}

///|
pub impl Ring for Int16 with fn ring_law() {
  Law::postulate()
}

///|
pub impl Semiring for Int16 with fn semiring_law() {
  Law::ring_to_semiring(Ring::ring_law())
}

///|
pub impl AddGroup for Int16 with fn add_group_law() {
  Law::ring_to_add_group(Ring::ring_law())
}

///|
pub impl AddMonoid for Int16 with fn add_monoid_law() {
  Law::add_group_to_add_monoid(AddGroup::add_group_law())
}

///|
pub impl MulMonoid for Int16 with fn mul_monoid_law() {
  Law::semiring_to_mul_monoid(Semiring::semiring_law())
}

///|
pub impl CommRing for Int16 with fn comm_ring_law() {
  Law::postulate()
}

///|
pub impl Ring for Int64 with fn ring_law() {
  Law::postulate()
}

///|
pub impl Semiring for Int64 with fn semiring_law() {
  Law::ring_to_semiring(Ring::ring_law())
}

///|
pub impl AddGroup for Int64 with fn add_group_law() {
  Law::ring_to_add_group(Ring::ring_law())
}

///|
pub impl AddMonoid for Int64 with fn add_monoid_law() {
  Law::add_group_to_add_monoid(AddGroup::add_group_law())
}

///|
pub impl MulMonoid for Int64 with fn mul_monoid_law() {
  Law::semiring_to_mul_monoid(Semiring::semiring_law())
}

///|
pub impl CommRing for Int64 with fn comm_ring_law() {
  Law::postulate()
}

///|
pub impl Semiring for UInt with fn semiring_law() {
  Law::postulate()
}

///|
pub impl AddMonoid for UInt with fn add_monoid_law() {
  Law::semiring_to_add_monoid(Semiring::semiring_law())
}

///|
pub impl MulMonoid for UInt with fn mul_monoid_law() {
  Law::semiring_to_mul_monoid(Semiring::semiring_law())
}

///|
pub impl Nat for UInt with fn nat_law() {
  Law::postulate()
}

///|
pub impl Semiring for UInt16 with fn semiring_law() {
  Law::postulate()
}

///|
pub impl AddMonoid for UInt16 with fn add_monoid_law() {
  Law::semiring_to_add_monoid(Semiring::semiring_law())
}

///|
pub impl MulMonoid for UInt16 with fn mul_monoid_law() {
  Law::semiring_to_mul_monoid(Semiring::semiring_law())
}

///|
pub impl Nat for UInt16 with fn nat_law() {
  Law::postulate()
}

///|
pub impl Semiring for UInt64 with fn semiring_law() {
  Law::postulate()
}

///|
pub impl AddMonoid for UInt64 with fn add_monoid_law() {
  Law::semiring_to_add_monoid(Semiring::semiring_law())
}

///|
pub impl MulMonoid for UInt64 with fn mul_monoid_law() {
  Law::semiring_to_mul_monoid(Semiring::semiring_law())
}

///|
pub impl Nat for UInt64 with fn nat_law() {
  Law::postulate()
}
