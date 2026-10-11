///|
fn exact_field_algorithm[T : @lf_alg.Field](_value : T) -> Unit {}

///|
test "field-bound inventory algorithms cannot silently accept Float" {
  exact_field_algorithm((1.0 : Float))
}
