///|
test "removed from_integer" {
  let h : @lf_alg.Hom[@lf_alg.SemiringSig, BigInt, Int] = @lf_alg.Hom::from_integer()
  ignore(h)
}
