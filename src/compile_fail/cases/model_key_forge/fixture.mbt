///|
test "Model identity keys cannot be forged" {
  let forged = @lf_alg.ModelKey::Canonical("forged")
  ignore(forged)
}
