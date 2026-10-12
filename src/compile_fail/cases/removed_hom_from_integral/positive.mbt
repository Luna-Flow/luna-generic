///|
test "removed from_integral" {
  let h : @lf_alg.Hom[@lf_alg.SemiringSig, BigInt, Int] = @lf_alg.Hom::from_integer_exact(@lf_alg.LawfulModel::integer_homomorphism())
  ignore(h)
}
