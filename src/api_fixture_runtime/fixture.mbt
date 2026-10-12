///|
priv enum FixtureSig {}

///|
test "runtime model mismatches return errors" {
  let source : @lf_alg.Model[FixtureSig, Int32] = @lf_alg.Model::make([]).unwrap()
  let middle : @lf_alg.Model[FixtureSig, Int32] = @lf_alg.Model::make([]).unwrap()
  let other_middle : @lf_alg.Model[FixtureSig, Int32] = @lf_alg.Model::make([]).unwrap()
  let target : @lf_alg.Model[FixtureSig, Int32] = @lf_alg.Model::make([]).unwrap()
  let first : @lf_alg.Hom[FixtureSig, Int32, Int32] = @lf_alg.Hom::postulate(
    source,
    middle,
    x => x,
  )
  let matching : @lf_alg.Hom[FixtureSig, Int32, Int32] = @lf_alg.Hom::postulate(
    middle,
    target,
    x => x,
  )
  let mismatched : @lf_alg.Hom[FixtureSig, Int32, Int32] = @lf_alg.Hom::postulate(
    other_middle,
    target,
    x => x,
  )
  assert_true(first.then_checked(matching) is Ok(_))
  assert_true(first.then_checked(mismatched) is Err(@lf_alg.IdentityMismatch))

  let left : @lf_alg.Model[FixtureSig, Int32] = @lf_alg.Model::make([]).unwrap()
  let right : @lf_alg.Model[FixtureSig, Int32] = @lf_alg.Model::make([]).unwrap()
  let to_left : @lf_alg.Hom[FixtureSig, Int32, Int32] = @lf_alg.Hom::postulate(
    source,
    left,
    x => x,
  )
  let to_right : @lf_alg.Hom[FixtureSig, Int32, Int32] = @lf_alg.Hom::postulate(
    source,
    right,
    x => x,
  )
  let product = @lf_alg.Model::prod(left, left).unwrap()
  assert_true(
    @lf_alg.Hom::pair(product, to_left, to_right)
    is Err(@lf_alg.IdentityMismatch),
  )
  assert_true(@lf_alg.Hom::fst(product, right) is Err(@lf_alg.IdentityMismatch))
  assert_true(@lf_alg.Hom::snd(product, right) is Err(@lf_alg.IdentityMismatch))
}

///|
test "law-bound upgrades reject unrelated runtime endpoints" {
  let source : @lf_alg.Model[@lf_alg.SemiringSig, Int32] = @lf_alg.Model::make([]).unwrap()
  let target : @lf_alg.Model[@lf_alg.SemiringSig, Int32] = @lf_alg.Model::make([]).unwrap()
  let hom : @lf_alg.Hom[@lf_alg.SemiringSig, Int32, Int32] = @lf_alg.Hom::postulate(
    source,
    target,
    x => x,
  )
  assert_true(
    hom.to_ring(@lf_alg.LawfulModel::ring(), @lf_alg.LawfulModel::ring())
    is Err(@lf_alg.IdentityMismatch),
  )

  let add_source : @lf_alg.Model[@lf_alg.AddMonoidSig, Int32] = @lf_alg.Model::make([],
  ).unwrap()
  let add_target : @lf_alg.Model[@lf_alg.AddMonoidSig, Int32] = @lf_alg.Model::make([],
  ).unwrap()
  let add_hom : @lf_alg.Hom[@lf_alg.AddMonoidSig, Int32, Int32] = @lf_alg.Hom::postulate(
    add_source,
    add_target,
    x => x,
  )
  assert_true(
    add_hom.to_add_group(
      @lf_alg.LawfulModel::add_group(),
      @lf_alg.LawfulModel::add_group(),
    )
    is Err(@lf_alg.IdentityMismatch),
  )
}

///|
test "model-bound diagnostics reject unrelated endpoints" {
  let source : @lf_alg.Model[FixtureSig, Int32] = @lf_alg.Model::make([]).unwrap()
  let target : @lf_alg.Model[FixtureSig, Int32] = @lf_alg.Model::make([]).unwrap()
  let hom : @lf_alg.Hom[FixtureSig, Int32, Int32] = @lf_alg.Hom::postulate(
    source,
    target,
    x => x,
  )
  assert_true(hom.check_models(source, target, [1]) is Ok(true))
  assert_true(
    hom.check_models_by(source, target, [1], (left, right) => left == right)
    is Ok(true),
  )
  let wrong_source : @lf_alg.Model[FixtureSig, Int32] = @lf_alg.Model::make([]).unwrap()
  let wrong_target : @lf_alg.Model[FixtureSig, Int32] = @lf_alg.Model::make([]).unwrap()
  assert_true(
    hom.check_models(wrong_source, target, [1]) is Err(@lf_alg.IdentityMismatch),
  )
  assert_true(
    hom.check_models_by(source, wrong_target, [1], (left, right) => {
      left == right
    })
    is Err(@lf_alg.IdentityMismatch),
  )
}

///|
test "model diagnostics reject each endpoint independently" {
  let a : @lf_alg.Model[FixtureSig, Int32] = @lf_alg.Model::make([]).unwrap()
  let b : @lf_alg.Model[FixtureSig, Int32] = @lf_alg.Model::make([]).unwrap()
  let wrong : @lf_alg.Model[FixtureSig, Int32] = @lf_alg.Model::make([]).unwrap()
  let h = @lf_alg.Hom::postulate(a, b, x => x)
  assert_true(h.check_models(a, wrong, [1]) is Err(@lf_alg.IdentityMismatch))
  assert_true(
    h.check_models_by(wrong, b, [1], (x, y) => x == y)
    is Err(@lf_alg.IdentityMismatch),
  )
  // Empty tables have no operation equations. This is vacuous, not proof.
  assert_true(h.check_models(a, b, []) is Ok(true))
}

///|
test "pair rejects source left endpoint and nonproduct independently" {
  let a : @lf_alg.Model[FixtureSig, Int32] = @lf_alg.Model::make([]).unwrap()
  let b : @lf_alg.Model[FixtureSig, Int32] = @lf_alg.Model::make([]).unwrap()
  let c : @lf_alg.Model[FixtureSig, Int32] = @lf_alg.Model::make([]).unwrap()
  let wrong : @lf_alg.Model[FixtureSig, Int32] = @lf_alg.Model::make([]).unwrap()
  let product = @lf_alg.Model::prod(b, c).unwrap()
  let f = @lf_alg.Hom::postulate(a, b, x => x)
  let g = @lf_alg.Hom::postulate(a, c, x => x)
  let wrong_source = @lf_alg.Hom::postulate(wrong, c, x => x)
  let wrong_left = @lf_alg.Hom::postulate(a, wrong, x => x)
  assert_true(@lf_alg.Hom::pair(product, f, g) is Ok(_))
  assert_true(
    @lf_alg.Hom::pair(product, f, wrong_source) is Err(@lf_alg.IdentityMismatch),
  )
  assert_true(
    @lf_alg.Hom::pair(product, wrong_left, g) is Err(@lf_alg.IdentityMismatch),
  )
  let nonproduct : @lf_alg.Model[FixtureSig, @lf_alg.Prod[Int32, Int32]] = @lf_alg.Model::make([],
  ).unwrap()
  assert_true(
    @lf_alg.Hom::pair(nonproduct, f, g) is Err(@lf_alg.NotProductModel),
  )
  assert_true(@lf_alg.Hom::fst(nonproduct, b) is Err(@lf_alg.NotProductModel))
  assert_true(@lf_alg.Hom::snd(nonproduct, c) is Err(@lf_alg.NotProductModel))
  let second = @lf_alg.Model::prod(b, c).unwrap()
  assert_false(product.same_identity(second))
}

///|
test "to_ring checks each endpoint independently" {
  let a : @lf_alg.Model[@lf_alg.RingSig, Int32] = @lf_alg.Model::ring()
  let wrong : @lf_alg.Model[@lf_alg.RingSig, Int32] = @lf_alg.Model::make([]).unwrap()
  let law : @lf_alg.LawfulModel[@lf_alg.RingTh, @lf_alg.RingSig, Int32] = @lf_alg.LawfulModel::postulate(
    a,
  )
  let bad_law : @lf_alg.LawfulModel[@lf_alg.RingTh, @lf_alg.RingSig, Int32] = @lf_alg.LawfulModel::postulate(
    wrong,
  )
  let h = @lf_alg.Hom::id(a.forget(@lf_alg.ring_to_semiring).unwrap())
  assert_true(h.to_ring(law, law) is Ok(_))
  assert_true(h.to_ring(bad_law, law) is Err(@lf_alg.IdentityMismatch))
  assert_true(h.to_ring(law, bad_law) is Err(@lf_alg.IdentityMismatch))
}

///|
test "to_add_group checks each endpoint independently" {
  let a : @lf_alg.Model[@lf_alg.AddGroupSig, Int32] = @lf_alg.Model::add_group()
  let wrong : @lf_alg.Model[@lf_alg.AddGroupSig, Int32] = @lf_alg.Model::make([]).unwrap()
  let law : @lf_alg.LawfulModel[@lf_alg.AddGroupTh, @lf_alg.AddGroupSig, Int32] = @lf_alg.LawfulModel::postulate(
    a,
  )
  let bad_law : @lf_alg.LawfulModel[
    @lf_alg.AddGroupTh,
    @lf_alg.AddGroupSig,
    Int32,
  ] = @lf_alg.LawfulModel::postulate(wrong)
  let h = @lf_alg.Hom::id(a.forget(@lf_alg.add_group_to_add_monoid).unwrap())
  assert_true(h.to_add_group(law, law) is Ok(_))
  assert_true(h.to_add_group(bad_law, law) is Err(@lf_alg.IdentityMismatch))
  assert_true(h.to_add_group(law, bad_law) is Err(@lf_alg.IdentityMismatch))
}

///|
test "reduct index composition preserves operation evaluation" {
  let model : @lf_alg.Model[@lf_alg.RingSig, Int32] = @lf_alg.Model::ring()
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
  let malformed : @lf_alg.Model[@lf_alg.RingSig, Int32] = @lf_alg.Model::make([]).unwrap()
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

///|
/// (identity, signature, non-product): exactly one flag is true for an Err.
fn[T] kind(result : Result[T, @lf_alg.ModelMismatch]) -> (Bool, Bool, Bool) {
  match result {
    Ok(_) => (false, false, false)
    Err(IdentityMismatch) => (true, false, false)
    Err(SignatureMismatch) => (false, true, false)
    Err(NotProductModel) => (false, false, true)
  }
}

///|
test "IdentityMismatch is reported alone for unrelated identities" {
  let a : @lf_alg.Model[FixtureSig, Int32] = @lf_alg.Model::make([]).unwrap()
  let b : @lf_alg.Model[FixtureSig, Int32] = @lf_alg.Model::make([]).unwrap()
  let c : @lf_alg.Model[FixtureSig, Int32] = @lf_alg.Model::make([]).unwrap()
  // Same (empty) signature everywhere: only the identity differs.
  let ab = @lf_alg.Hom::postulate(a, b, x => x)
  let cc = @lf_alg.Hom::postulate(c, c, x => x)
  assert_eq(kind(ab.then_checked(cc)), (true, false, false))
  assert_eq(kind(ab.check_models(a, c, [1])), (true, false, false))
  assert_eq(
    kind(ab.check_models_by(c, b, [1], (x, y) => x == y)),
    (true, false, false),
  )
  let product = @lf_alg.Model::prod(a, b).unwrap()
  let ca = @lf_alg.Hom::postulate(c, a, x => x)
  let cb = @lf_alg.Hom::postulate(c, b, x => x)
  assert_eq(kind(@lf_alg.Hom::pair(product, ca, cb)), (false, false, false))
  assert_eq(kind(@lf_alg.Hom::pair(product, cb, ca)), (true, false, false))
  assert_eq(kind(@lf_alg.Hom::pair(product, ca, ab)), (true, false, false))
  assert_eq(kind(@lf_alg.Hom::fst(product, b)), (true, false, false))
  assert_eq(kind(@lf_alg.Hom::snd(product, a)), (true, false, false))
  // The identity-only failure is not misreported as a structure failure.
  assert_eq(kind(@lf_alg.Hom::fst(product, a)), (false, false, false))
}

///|
test "SignatureMismatch is reported alone for different operation lists" {
  let ring : @lf_alg.Algebra[@lf_alg.RingSig, Int32] = @lf_alg.Algebra::ring()
  let short : @lf_alg.Algebra[@lf_alg.RingSig, Int32] = @lf_alg.Algebra::make([
    { name: "0", arity: 0, eval: _ => 0, },
  ]).unwrap()
  let renamed : @lf_alg.Algebra[@lf_alg.RingSig, Int32] = @lf_alg.Algebra::make([
      { name: "z", arity: 0, eval: _ => 0, },
    ],
  ).unwrap()
  assert_eq(kind(@lf_alg.Algebra::prod(ring, short)), (false, true, false))
  assert_eq(kind(@lf_alg.Algebra::prod(short, renamed)), (false, true, false))
  assert_eq(kind(@lf_alg.Algebra::prod(ring, ring)), (false, false, false))
  let ring_model : @lf_alg.Model[@lf_alg.RingSig, Int32] = @lf_alg.Model::ring()
  let empty : @lf_alg.Model[@lf_alg.RingSig, Int32] = @lf_alg.Model::make([]).unwrap()
  assert_eq(kind(@lf_alg.Model::prod(ring_model, empty)), (false, true, false))
  // Identical identities never matter to Model::prod: still a signature error.
  assert_eq(kind(@lf_alg.Model::prod(empty, ring_model)), (false, true, false))
}

///|
test "NotProductModel is reported alone for a Model not built by prod" {
  let a : @lf_alg.Model[FixtureSig, Int32] = @lf_alg.Model::make([]).unwrap()
  let b : @lf_alg.Model[FixtureSig, Int32] = @lf_alg.Model::make([]).unwrap()
  let fake : @lf_alg.Model[FixtureSig, @lf_alg.Prod[Int32, Int32]] = @lf_alg.Model::make([],
  ).unwrap()
  let f = @lf_alg.Hom::postulate(a, a, x => x)
  let g = @lf_alg.Hom::postulate(a, b, x => x)
  assert_eq(kind(@lf_alg.Hom::pair(fake, f, g)), (false, false, true))
  assert_eq(kind(@lf_alg.Hom::fst(fake, a)), (false, false, true))
  assert_eq(kind(@lf_alg.Hom::snd(fake, b)), (false, false, true))
  // Wrong endpoints on top of a non-product Model: the Model kind wins.
  let h = @lf_alg.Hom::postulate(b, b, x => x)
  assert_eq(kind(@lf_alg.Hom::pair(fake, f, h)), (false, false, true))
  assert_eq(kind(@lf_alg.Hom::fst(fake, b)), (false, false, true))
}
