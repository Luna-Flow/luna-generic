///|
fn requires_exact_field[T : @lf_alg.Field](_value : T) -> Unit {}

///|
test "Float has operations but no exact Field law" {
  requires_exact_field((1.0 : Float))
}
