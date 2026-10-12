///|
test "identity remains opaque" {
 let model : @lf_alg.Model[@lf_alg.SemiringSig, Int] = @lf_alg.Model::semiring()
 assert_true(model.same_identity(model))
}
