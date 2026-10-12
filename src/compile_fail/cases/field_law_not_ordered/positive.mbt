///|
fn[T] requires_ordered_field(
  _law : @lf_alg.Law[@lf_alg.OrderedFieldTh, T],
) -> Unit {}

///|
fn[T] field_law_does_not_imply_ordered(
  law : @lf_alg.Law[@lf_alg.OrderedFieldTh, T],
) -> Unit {
  requires_ordered_field(law)
}
