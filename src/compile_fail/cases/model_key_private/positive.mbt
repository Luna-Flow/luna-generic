///|
test "Model identity keys are not a public API" {
  let model : @lf_alg.Model[@lf_alg.SemiringSig, Int] = @lf_alg.Model::semiring()
  let key = model.same_identity(model)
  ignore(key)
}
