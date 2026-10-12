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

///|
test "model diagnostics reject each endpoint independently" {
  let a : @lf_alg.Model[FixtureSig, Int] = @lf_alg.Model::make([]).unwrap()
  let b : @lf_alg.Model[FixtureSig, Int] = @lf_alg.Model::make([]).unwrap()
  let wrong : @lf_alg.Model[FixtureSig, Int] = @lf_alg.Model::make([]).unwrap()
  let h = @lf_alg.Hom::postulate(a, b, x => x)
  assert_true(h.check_models(a, wrong, [1]) is Err(@lf_alg.ModelMismatch))
  assert_true(
    h.check_models_by(wrong, b, [1], (x, y) => x == y)
    is Err(@lf_alg.ModelMismatch),
  )
  // Empty tables have no operation equations. This is vacuous, not proof.
  assert_true(h.check_models(a, b, []) is Ok(true))
}

///|
test "pair rejects source left endpoint and nonproduct independently" {
  let a : @lf_alg.Model[FixtureSig, Int] = @lf_alg.Model::make([]).unwrap()
  let b : @lf_alg.Model[FixtureSig, Int] = @lf_alg.Model::make([]).unwrap()
  let c : @lf_alg.Model[FixtureSig, Int] = @lf_alg.Model::make([]).unwrap()
  let wrong : @lf_alg.Model[FixtureSig, Int] = @lf_alg.Model::make([]).unwrap()
  let product = @lf_alg.Model::prod(b, c).unwrap()
  let f = @lf_alg.Hom::postulate(a, b, x => x)
  let g = @lf_alg.Hom::postulate(a, c, x => x)
  let wrong_source = @lf_alg.Hom::postulate(wrong, c, x => x)
  let wrong_left = @lf_alg.Hom::postulate(a, wrong, x => x)
  assert_true(@lf_alg.Hom::pair(product, f, g) is Ok(_))
  assert_true(
    @lf_alg.Hom::pair(product, f, wrong_source) is Err(@lf_alg.ModelMismatch),
  )
  assert_true(
    @lf_alg.Hom::pair(product, wrong_left, g) is Err(@lf_alg.ModelMismatch),
  )
  let nonproduct : @lf_alg.Model[FixtureSig, @lf_alg.Prod[Int, Int]] = @lf_alg.Model::make([],
  ).unwrap()
  assert_true(@lf_alg.Hom::pair(nonproduct, f, g) is Err(@lf_alg.ModelMismatch))
  assert_true(@lf_alg.Hom::fst(nonproduct, b) is Err(@lf_alg.ModelMismatch))
  assert_true(@lf_alg.Hom::snd(nonproduct, c) is Err(@lf_alg.ModelMismatch))
  let second = @lf_alg.Model::prod(b, c).unwrap()
  assert_false(product.same_identity(second))
}

///|
test "to_ring checks each endpoint independently" {
  let a : @lf_alg.Model[@lf_alg.RingSig, Int] = @lf_alg.Model::ring()
  let wrong : @lf_alg.Model[@lf_alg.RingSig, Int] = @lf_alg.Model::make([]).unwrap()
  let law : @lf_alg.LawfulModel[@lf_alg.RingTh, @lf_alg.RingSig, Int] = @lf_alg.LawfulModel::postulate(
    a,
  )
  let bad_law : @lf_alg.LawfulModel[@lf_alg.RingTh, @lf_alg.RingSig, Int] = @lf_alg.LawfulModel::postulate(
    wrong,
  )
  let h = @lf_alg.Hom::id(a.forget(@lf_alg.ring_to_semiring).unwrap())
  assert_true(h.to_ring(law, law) is Ok(_))
  assert_true(h.to_ring(bad_law, law) is Err(@lf_alg.ModelMismatch))
  assert_true(h.to_ring(law, bad_law) is Err(@lf_alg.ModelMismatch))
}

///|
test "to_add_group checks each endpoint independently" {
  let a : @lf_alg.Model[@lf_alg.AddGroupSig, Int] = @lf_alg.Model::add_group()
  let wrong : @lf_alg.Model[@lf_alg.AddGroupSig, Int] = @lf_alg.Model::make([]).unwrap()
  let law : @lf_alg.LawfulModel[@lf_alg.AddGroupTh, @lf_alg.AddGroupSig, Int] = @lf_alg.LawfulModel::postulate(
    a,
  )
  let bad_law : @lf_alg.LawfulModel[
    @lf_alg.AddGroupTh,
    @lf_alg.AddGroupSig,
    Int,
  ] = @lf_alg.LawfulModel::postulate(wrong)
  let h = @lf_alg.Hom::id(a.forget(@lf_alg.add_group_to_add_monoid).unwrap())
  assert_true(h.to_add_group(law, law) is Ok(_))
  assert_true(h.to_add_group(bad_law, law) is Err(@lf_alg.ModelMismatch))
  assert_true(h.to_add_group(law, bad_law) is Err(@lf_alg.ModelMismatch))
}

///|
test "reduct index composition preserves operation evaluation" {
  let model : @lf_alg.Model[@lf_alg.RingSig, Int] = @lf_alg.Model::ring()
  let composite = @lf_alg.ring_to_add_group.then(
    @lf_alg.add_group_to_add_monoid,
  )
  let projected = model.forget(composite).unwrap()
  // If indices are copied rather than composed, position 1 selects one, not plus.
  assert_true(
    @lf_alg.Hom::id(projected).check(
      @lf_alg.Algebra::add_monoid(),
      projected.algebra(),
      [2, 3],
    ),
  )
  let malformed : @lf_alg.Model[@lf_alg.RingSig, Int] = @lf_alg.Model::make([]).unwrap()
  assert_true(
    malformed.forget(@lf_alg.ring_to_semiring)
    is Err(@lf_alg.InvalidOperationTable),
  )
  let bad_source = @lf_alg.Hom::postulate(malformed, model, x => x)
  let bad_target = @lf_alg.Hom::postulate(model, malformed, x => x)
  assert_true(
    bad_source.forget(@lf_alg.ring_to_semiring)
    is Err(@lf_alg.InvalidOperationTable),
  )
  assert_true(
    bad_target.forget(@lf_alg.ring_to_semiring)
    is Err(@lf_alg.InvalidOperationTable),
  )
}

///|
test "postulated rounded integer law remains caller trust" {
  let target : @lf_alg.Model[@lf_alg.SemiringSig, Float] = @lf_alg.Model::semiring()
  let trusted : @lf_alg.LawfulModel[
    @lf_alg.IntegerHomomorphismTh,
    @lf_alg.SemiringSig,
    Float,
  ] = @lf_alg.LawfulModel::postulate(target)
  let hom = @lf_alg.Hom::from_integer_exact(trusted)
  let source : @lf_alg.Model[@lf_alg.SemiringSig, BigInt] = @lf_alg.Model::semiring()
  assert_false(
    hom
    .check_models(source, target, [
      BigInt::from_int(16777217),
      BigInt::from_int(1),
    ])
    .unwrap(),
  )
}
