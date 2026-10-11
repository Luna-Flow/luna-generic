///|
enum FixtureSig {}

///|
test "finite diagnostics do not produce Hom certificates" {
  let ops = [
    { name: "id", arity: 1, eval: xs => xs[0], },
  ]
  let model : @lf_alg.Model[FixtureSig, Int] = @lf_alg.Model::make(ops).unwrap()
  let algebra : @lf_alg.Algebra[FixtureSig, Int] = @lf_alg.Algebra::make(ops).unwrap()
  let hom : @lf_alg.Hom[FixtureSig, Int, Int] = @lf_alg.Hom::postulate(
    model,
    model,
    x => x,
  )
  let certificate : @lf_alg.Hom[FixtureSig, Int, Int] = hom.check_by(
    algebra,
    algebra,
    [1],
    (left, right) => left == right,
  )
  ignore(certificate)
}
