///|
test "tolerance diagnostics are not strict Hom values" {
  let model : @lf_alg.Model[@lf_alg.SemiringSig, Float] =
    @lf_alg.Model::make([]).unwrap()
  let hom = @lf_alg.Hom::postulate(model, model, x => x)
  let result : @lf_alg.Hom[@lf_alg.SemiringSig, Float, Float] = hom.check_by(
    @lf_alg.Algebra::semiring(),
    @lf_alg.Algebra::semiring(),
    [0.0, 1.0],
    (left, right) => (left - right).abs() <= 0.001,
  )
  ignore(result)
}
