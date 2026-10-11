/// Exact preservation of the canonical integer operations is assumed for the
/// shipped integral carriers. The law does not assert injectivity.

///|
pub impl Integral for BigInt with fn integer_homomorphism_law() {
  Law::postulate()
}

///|
pub impl Integral for Int with fn integer_homomorphism_law() {
  Law::postulate()
}

///|
pub impl Integral for Int16 with fn integer_homomorphism_law() {
  Law::postulate()
}

///|
pub impl Integral for Int64 with fn integer_homomorphism_law() {
  Law::postulate()
}

///|
pub impl Integral for UInt with fn integer_homomorphism_law() {
  Law::postulate()
}

///|
pub impl Integral for UInt16 with fn integer_homomorphism_law() {
  Law::postulate()
}

///|
pub impl Integral for UInt64 with fn integer_homomorphism_law() {
  Law::postulate()
}
