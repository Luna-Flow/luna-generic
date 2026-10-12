///|
fn[T] complex_field_premise(_law : @lf_alg.Law[@lf_alg.OrderedFieldTh, T]) -> Unit {}

///|
test "a Field law alone cannot justify the exact Complex Field premise" {
  let field_law : @lf_alg.Law[@lf_alg.FieldTh, Int] = @lf_alg.Law::postulate()
  complex_field_premise(field_law)
}
