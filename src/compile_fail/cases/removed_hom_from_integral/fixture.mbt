///|
test "removed from_integral" {
  let h : @lf_alg.Hom[@lf_alg.SemiringSig, Int, BigInt] = @lf_alg.Hom::from_integral()
  ignore(h)
}
