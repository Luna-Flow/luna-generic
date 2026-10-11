///|
fn requires_ordered_field[T](
  _law : @lf_alg.Law[@lf_alg.OrderedFieldTh, T],
) -> Unit {}

///|
fn field_law_does_not_imply_ordered[T](
  law : @lf_alg.Law[@lf_alg.FieldTh, T],
) -> Unit {
  requires_ordered_field(law)
}
