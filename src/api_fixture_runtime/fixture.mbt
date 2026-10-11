///|
priv enum FixtureSig {}

///|
test "runtime model mismatches return errors" {
  let source : @lf_alg.Model[FixtureSig, Int] = @lf_alg.Model::make([]).unwrap()
  let middle : @lf_alg.Model[FixtureSig, Int] = @lf_alg.Model::make([]).unwrap()
  let other_middle : @lf_alg.Model[FixtureSig, Int] = @lf_alg.Model::make([]).unwrap()
  let target : @lf_alg.Model[FixtureSig, Int] = @lf_alg.Model::make([]).unwrap()
  let first : @lf_alg.Hom[FixtureSig, Int, Int] = @lf_alg.Hom::postulate(
    source,
    middle,
    x => x,
  )
  let matching : @lf_alg.Hom[FixtureSig, Int, Int] = @lf_alg.Hom::postulate(
    middle,
    target,
    x => x,
  )
  let mismatched : @lf_alg.Hom[FixtureSig, Int, Int] = @lf_alg.Hom::postulate(
    other_middle,
    target,
    x => x,
  )
  assert_true(first.then_checked(matching) is Ok(_))
  assert_true(first.then_checked(mismatched) is Err(@lf_alg.ModelMismatch))

  let left : @lf_alg.Model[FixtureSig, Int] = @lf_alg.Model::make([]).unwrap()
  let right : @lf_alg.Model[FixtureSig, Int] = @lf_alg.Model::make([]).unwrap()
  let to_left : @lf_alg.Hom[FixtureSig, Int, Int] = @lf_alg.Hom::postulate(
    source,
    left,
    x => x,
  )
  let to_right : @lf_alg.Hom[FixtureSig, Int, Int] = @lf_alg.Hom::postulate(
    source,
    right,
    x => x,
  )
  let product = @lf_alg.Model::prod(left, left).unwrap()
  assert_true(
    @lf_alg.Hom::pair(product, to_left, to_right) is Err(@lf_alg.ModelMismatch),
  )
  assert_true(@lf_alg.Hom::fst(product, right) is Err(@lf_alg.ModelMismatch))
  assert_true(@lf_alg.Hom::snd(product, right) is Err(@lf_alg.ModelMismatch))
}

///|
test "law-bound upgrades reject unrelated runtime endpoints" {
  let source : @lf_alg.Model[@lf_alg.SemiringSig, Int] = @lf_alg.Model::make([]).unwrap()
  let target : @lf_alg.Model[@lf_alg.SemiringSig, Int] = @lf_alg.Model::make([]).unwrap()
  let hom : @lf_alg.Hom[@lf_alg.SemiringSig, Int, Int] = @lf_alg.Hom::postulate(
    source,
    target,
    x => x,
  )
  assert_true(
    hom.to_ring(@lf_alg.LawfulModel::ring(), @lf_alg.LawfulModel::ring())
    is Err(@lf_alg.ModelMismatch),
  )

  let add_source : @lf_alg.Model[@lf_alg.AddMonoidSig, Int] = @lf_alg.Model::make([],
  ).unwrap()
  let add_target : @lf_alg.Model[@lf_alg.AddMonoidSig, Int] = @lf_alg.Model::make([],
  ).unwrap()
  let add_hom : @lf_alg.Hom[@lf_alg.AddMonoidSig, Int, Int] = @lf_alg.Hom::postulate(
    add_source,
    add_target,
    x => x,
  )
  assert_true(
    add_hom.to_add_group(
      @lf_alg.LawfulModel::add_group(),
      @lf_alg.LawfulModel::add_group(),
    )
    is Err(@lf_alg.ModelMismatch),
  )
}

///|
test "model-bound diagnostics reject unrelated endpoints" {
  let source : @lf_alg.Model[FixtureSig, Int] = @lf_alg.Model::make([]).unwrap()
  let target : @lf_alg.Model[FixtureSig, Int] = @lf_alg.Model::make([]).unwrap()
  let hom : @lf_alg.Hom[FixtureSig, Int, Int] = @lf_alg.Hom::postulate(
    source,
    target,
    x => x,
  )
  assert_true(hom.check_models(source, target, [1]) is Ok(true))
  assert_true(
    hom.check_models_by(source, target, [1], (left, right) => left == right)
    is Ok(true),
  )
  let wrong_source : @lf_alg.Model[FixtureSig, Int] = @lf_alg.Model::make([]).unwrap()
  let wrong_target : @lf_alg.Model[FixtureSig, Int] = @lf_alg.Model::make([]).unwrap()
  assert_true(
    hom.check_models(wrong_source, target, [1]) is Err(@lf_alg.ModelMismatch),
  )
  assert_true(
    hom.check_models_by(source, wrong_target, [1], (left, right) => {
      left == right
    })
    is Err(@lf_alg.ModelMismatch),
  )
}
