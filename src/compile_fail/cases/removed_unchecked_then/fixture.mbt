///|
enum FixtureSig {}

///|
test "runtime composition has no unchecked aborting variant" {
  let model : @lf_alg.Model[FixtureSig, Int] = @lf_alg.Model::make([]).unwrap()
  let hom : @lf_alg.Hom[FixtureSig, Int, Int] = @lf_alg.Hom::postulate(
    model,
    model,
    x => x,
  )
  let _unchecked : @lf_alg.Hom[FixtureSig, Int, Int] = hom.then_checked(hom)
}
