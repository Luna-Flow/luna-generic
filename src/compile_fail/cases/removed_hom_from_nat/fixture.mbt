///|
test "removed from_nat" {
  let h : @lf_alg.Hom[@lf_alg.SemiringSig, UInt, BigInt] = @lf_alg.Hom::from_nat()
  ignore(h)
}
