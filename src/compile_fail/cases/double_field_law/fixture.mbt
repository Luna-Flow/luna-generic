///|
fn requires_exact_field[T : @lf_alg.Field](_value : T) -> Unit {}

///|
test "Double does not have an exact Field law" {
  requires_exact_field((1.0 : Double))
}
