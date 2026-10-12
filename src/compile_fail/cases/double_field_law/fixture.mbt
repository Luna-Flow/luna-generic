///|
fn[T : @lf_alg.Field] requires_exact_field(_value : T) -> Unit {}

///|
test "Double does not have an exact Field law" {
  requires_exact_field((1.0 : Double))
}
