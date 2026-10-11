///|
test "rounded Float conversion cannot satisfy exact integer Hom" {
  let semiring : @lf_alg.LawfulModel[
    @lf_alg.SemiringTh,
    @lf_alg.SemiringSig,
    Float,
  ] = @lf_alg.LawfulModel::postulate(@lf_alg.Model::semiring())
  let _hom : @lf_alg.Hom[@lf_alg.SemiringSig, BigInt, Float] =
    @lf_alg.Hom::from_integer_exact(semiring)
}
