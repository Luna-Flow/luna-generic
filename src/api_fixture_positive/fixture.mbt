///|
#warnings("-unused_trait_bound")
fn[T : @lf_alg.FieldOps + @lf_alg.RoundedArithmetic] accepts_rounded_field_ops(
  _value : T,
) -> Unit {

}

///|
test "law methods require explicit postulates" {
  let law : @lf_alg.Law[@lf_alg.RingTh, Int32] = @lf_alg.Ring::ring_law()
  ignore(law)
  let ops : @lf_alg.Algebra[@lf_alg.RingSig, Float] = @lf_alg.Algebra::ring()
  ignore(ops)
  accepts_rounded_field_ops((1.0 : Float))
  accepts_rounded_field_ops((1.0 : Double))
  let field_law : @lf_alg.Law[@lf_alg.FieldTh, Int32] = @lf_alg.Law::postulate()
  let ring_law : @lf_alg.Law[@lf_alg.RingTh, Int32] = @lf_alg.Law::field_to_ring(
    field_law,
  )
  ignore(ring_law)
}

///|
test "ordered field weakening is explicit" {
  let ordered_law : @lf_alg.Law[@lf_alg.OrderedFieldTh, Int32] = @lf_alg.Law::postulate()
  let ordered_as_field : @lf_alg.Law[@lf_alg.FieldTh, Int32] = @lf_alg.Law::ordered_field_to_field(
    ordered_law,
  )
  ignore(ordered_as_field)
}

///|
priv enum FixtureSig {}

///|
test "custom lawful models bind a postulate to one model" {
  let model : @lf_alg.Model[FixtureSig, Int32] = match
    @lf_alg.Model::make([
      { name: "0", arity: 0, eval: _ => 0, },
      { name: "+", arity: 2, eval: xs => xs[0] + xs[1], },
    ]) {
    Ok(value) => value
    Err(@lf_alg.InvalidArity) => abort("valid model arity was rejected")
    Err(@lf_alg.InvalidOperationTable) =>
      abort("valid model table was rejected")
  }
  let lawful : @lf_alg.LawfulModel[@lf_alg.RingTh, FixtureSig, Int32] = @lf_alg.LawfulModel::postulate(
    model,
  )
  ignore(lawful)
}

///|
test "fixed-width integer conversion has an exact homomorphism premise" {
  let hom = @lf_alg.Hom::from_integer_exact(
    @lf_alg.LawfulModel::integer_homomorphism(),
  )
  let samples = [
    BigInt::from_int(0),
    BigInt::from_int(1),
    BigInt::from_int(16777217),
    BigInt::from_string("4294967296"),
    BigInt::from_string("-4294967297"),
  ]
  assert_true(
    hom.check(@lf_alg.Algebra::semiring(), @lf_alg.Algebra::semiring(), samples),
  )
  assert_eq(hom.apply(BigInt::from_string("4294967297")), 1)
}

///|
test "approved weakening and error traits" {
  let comm : @lf_alg.Law[@lf_alg.CommRingTh, Int32] = @lf_alg.Law::postulate()
  let domain : @lf_alg.Law[@lf_alg.IntegralDomainTh, BigInt] = @lf_alg.Law::postulate()
  let _int_additive : @lf_alg.Law[@lf_alg.AddMonoidTh, Int32] = @lf_alg.Law::semiring_to_add_monoid(
    @lf_alg.Law::ring_to_semiring(@lf_alg.Law::comm_ring_to_ring(comm)),
  )
  let _bigint_additive : @lf_alg.Law[@lf_alg.AddMonoidTh, BigInt] = @lf_alg.Law::semiring_to_add_monoid(
    @lf_alg.Law::ring_to_semiring(@lf_alg.Law::integral_domain_to_ring(domain)),
  )
  let model : @lf_alg.Model[@lf_alg.RingSig, Int32] = @lf_alg.Model::ring()
  let other : @lf_alg.Model[@lf_alg.RingSig, Int32] = @lf_alg.Model::make([]).unwrap()
  match @lf_alg.Hom::id(model).then_checked(@lf_alg.Hom::id(other)) {
    Err(error) => {
      assert_eq(error, error)
      debug_inspect(error, content="ModelMismatch")
    }
    Ok(_) => fail("expected mismatch")
  }
  match other.forget(@lf_alg.ring_to_semiring) {
    Err(error) => {
      assert_eq(error, error)
      debug_inspect(error, content="InvalidOperationTable")
    }
    Ok(_) => fail("expected malformed table")
  }
}
