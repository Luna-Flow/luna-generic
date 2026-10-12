///|
fn[T : @lf_alg.FieldOps] exact_field_algorithm(_value : T) -> Unit {}

///|
test "field-bound inventory algorithms cannot silently accept Float" {
  exact_field_algorithm((1.0 : Float))
}
