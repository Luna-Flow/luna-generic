///|
using @luna-generic {
  type Hom,
  type Algebra,
  type Prod,
  type Reduct,
  type Model,
  type AddMonoidSig,
  type AddGroupSig,
  type SemiringSig,
  type RingSig,
}

///|
/// Truncation ℤ/2^64 → ℤ/2^32 is a ring homomorphism, because 2^64 ≡ 0 mod
/// 2^32, so the law holds on every input, including values that wrap.
fn int64_to_int() -> Hom[RingSig, Int64, Int32] {
  Hom::postulate(Model::ring(), Model::ring(), x => x.to_int())
}

///|
fn[A : RingOps, B : RingOps] ring_hom(f : (A) -> B) -> Hom[RingSig, A, B] {
  Hom::postulate(Model::ring(), Model::ring(), f)
}

///|
fn[A : AddGroupOps, B : AddGroupOps] add_group_hom(
  f : (A) -> B,
) -> Hom[AddGroupSig, A, B] {
  Hom::postulate(Model::add_group(), Model::add_group(), f)
}

///|
fn[A : AddMonoidOps, B : AddMonoidOps] add_monoid_hom(
  f : (A) -> B,
) -> Hom[AddMonoidSig, A, B] {
  Hom::postulate(Model::add_monoid(), Model::add_monoid(), f)
}

///|
let small_ints : Array[Int32] = [0, 1, -1, 2, -3, 7, 100]

///|
let edge_int64s : Array[Int64] = [
  0L,
  1L,
  -1L,
  2L,
  -3L,
  7L,
  2147483647L,
  3000000000L,
  4294967296L,
  9223372036854775807L,
  -9223372036854775807L - 1L,
]

///|
test "postulated ring hom passes the exact law check" {
  let h = int64_to_int()
  assert_true(h.check(Algebra::ring(), Algebra::ring(), edge_int64s))
  inspect(h.apply(-42L), content="-42")
  inspect(h.apply(4294967296L + 5L), content="5")
}

///|
test "widening Int to Int64 is not a ring hom" {
  // ℤ/2^32 → ℤ/2^64 would need 2^32 ≡ 0 mod 2^64. The law only holds while
  // Int arithmetic does not wrap, so small samples cannot tell.
  let widen : Hom[RingSig, Int32, Int64] = ring_hom(x => x.to_int64())
  assert_true(widen.check(Algebra::ring(), Algebra::ring(), small_ints))
  assert_false(widen.check(Algebra::ring(), Algebra::ring(), [1, 2147483647]))
}

///|
test "law check rejects a map that only preserves part of the signature" {
  let double : Hom[RingSig, Int64, Int32] = ring_hom(x => 2 * x.to_int())
  assert_false(double.check(Algebra::ring(), Algebra::ring(), edge_int64s))
  let additive : Hom[AddGroupSig, Int64, Int32] = add_group_hom(x => {
    2 * x.to_int()
  })
  assert_true(
    additive.check(Algebra::add_group(), Algebra::add_group(), edge_int64s),
  )
}

///|
test "identity and composition keep the certificate" {
  let h = Hom::id(Model::ring())
    .then_checked(int64_to_int())
    .unwrap()
    .then_checked(Hom::id(Model::ring()))
    .unwrap()
  assert_true(h.check(Algebra::ring(), Algebra::ring(), edge_int64s))
}

///|
test "reducts forget structure and compose" {
  let r : Reduct[RingSig, AddMonoidSig] = @luna-generic.ring_to_semiring.then(
    @luna-generic.semiring_to_add_monoid,
  )
  let h = int64_to_int().forget(r).unwrap()
  assert_true(
    h.check(Algebra::add_monoid(), Algebra::add_monoid(), edge_int64s),
  )
  let h2 = int64_to_int()
    .forget(@luna-generic.ring_to_add_group)
    .unwrap()
    .forget(@luna-generic.add_group_to_add_monoid)
    .unwrap()
    .forget(Reduct::refl())
    .unwrap()
  assert_true(
    h2.check(Algebra::add_monoid(), Algebra::add_monoid(), edge_int64s),
  )
}

///|
test "refl reduct preserves the runtime operation table" {
  let model : @luna-generic.Model[MaxSig, Int32] = @luna-generic.Model::make([
    {
      name: "max",
      arity: 2,
      eval: xs => if xs[0] > xs[1] { xs[0] } else { xs[1] },
    },
  ]).unwrap()
  let reflected = model.forget(@luna-generic.Reduct::refl()).unwrap()
  let identity = Hom::id(reflected)
  assert_true(identity.check(model.algebra(), reflected.algebra(), [0, 1, 2]))
}

///|
test "monoid and semiring homs upgrade between groups and rings" {
  let m : Hom[AddMonoidSig, Int64, Int32] = add_monoid_hom(x => 3 * x.to_int())
  assert_true(
    m
    .to_add_group(
      @luna-generic.LawfulModel::add_group(),
      @luna-generic.LawfulModel::add_group(),
    )
    .unwrap()
    .check(Algebra::add_group(), Algebra::add_group(), edge_int64s),
  )
}

///|
test "pairing and projections" {
  let h = int64_to_int()
  let low : Hom[RingSig, Int64, Int16] = ring_hom(x => {
    Int16::from_int(x.to_int())
  })
  let product_model : Model[RingSig, Prod[Int32, Int16]] = Model::prod(
    Model::ring(),
    Model::ring(),
  ).unwrap()
  let p = Hom::pair(product_model, h, low).unwrap()
  let dst : Algebra[RingSig, Prod[Int32, Int16]] = product_model.algebra()
  assert_true(p.check(Algebra::ring(), dst, edge_int64s))
  for x in edge_int64s {
    assert_eq(
      p
      .then_checked(Hom::fst(product_model, Model::ring()).unwrap())
      .unwrap()
      .apply(x),
      h.apply(x),
    )
    assert_eq(
      p
      .then_checked(Hom::snd(product_model, Model::ring()).unwrap())
      .unwrap()
      .apply(x),
      low.apply(x),
    )
  }
}

///|
test "fixed-width sources are not the integers once arithmetic wraps" {
  let h : Hom[SemiringSig, Int32, BigInt] = Hom::postulate(
    Model::semiring(),
    Model::semiring(),
    x => @luna-generic.lift_to(x),
  )
  assert_true(h.check(Algebra::semiring(), Algebra::semiring(), [1, 1000]))
  assert_false(
    h.check(Algebra::semiring(), Algebra::semiring(), [1, 2147483647]),
  )
}

///|
test "lax preservation through a custom relation" {
  // Only the lax law holds, while the certificate type claims strictness:
  // do not compose `abs` with other homs.
  let abs : Hom[AddMonoidSig, Double, Double] = add_monoid_hom(x => x.abs())
  let samples = [-2.0, 0.0, 1.5, 3.0]
  assert_false(abs.check(Algebra::add_monoid(), Algebra::add_monoid(), samples))
  assert_true(
    abs.check_by(Algebra::add_monoid(), Algebra::add_monoid(), samples, (l, r) => {
      l <= r
    }),
  )
}

///|
test "model-bound diagnostics validate both endpoint identities" {
  let source : @luna-generic.Model[MaxSig, Int32] = @luna-generic.Model::make([]).unwrap()
  let target : @luna-generic.Model[MaxSig, Int32] = @luna-generic.Model::make([]).unwrap()
  let hom : Hom[MaxSig, Int32, Int32] = Hom::postulate(source, target, x => x)
  assert_true(hom.check_models(source, target, [1, 2]) is Ok(true))
  assert_true(
    hom.check_models_by(source, target, [1, 2], (left, right) => left == right)
    is Ok(true),
  )

  let wrong_source : @luna-generic.Model[MaxSig, Int32] = @luna-generic.Model::make([],
  ).unwrap()
  let wrong_target : @luna-generic.Model[MaxSig, Int32] = @luna-generic.Model::make([],
  ).unwrap()
  assert_true(
    hom.check_models(wrong_source, target, [1])
    is Err(@luna-generic.ModelMismatch),
  )
  assert_true(
    hom.check_models_by(source, wrong_target, [1], (left, right) => {
      left == right
    })
    is Err(@luna-generic.ModelMismatch),
  )
}

///|
test "algebra checks return false for different signatures" {
  let wrong : Algebra[RingSig, Int32] = Algebra::make([
    { name: "0", arity: 0, eval: _ => 0, },
  ]).unwrap()
  assert_false(int64_to_int().check(Algebra::ring(), wrong, edge_int64s))
  let section : @luna-generic.Section[SemiringSig, Int32, BigInt] = @luna-generic.Section::of_integral()
  let wrong_cover : Algebra[SemiringSig, BigInt] = Algebra::make([
    { name: "0", arity: 0, eval: _ => BigInt::from_int(0), },
  ]).unwrap()
  let quotient : Algebra[SemiringSig, Int32] = Algebra::semiring()
  assert_false(section.check_ops(quotient, wrong_cover, [1]))
}

///|
test "algebra product returns a mismatch for different signatures" {
  let wrong : Algebra[RingSig, Int32] = Algebra::make([
    { name: "0", arity: 0, eval: _ => 0, },
  ]).unwrap()
  let base : Algebra[RingSig, Int32] = Algebra::ring()
  let product = Algebra::prod(base, wrong)
  assert_true(product is Err(@luna-generic.ModelMismatch))
}

///|
test "negative operation arity returns a construction error" {
  let invalid_algebra : Result[
    Algebra[MaxSig, Int32],
    @luna-generic.ModelConstructionError,
  ] = Algebra::make([{ name: "invalid", arity: -1, eval: _ => 0, }])
  let invalid_model : Result[
    @luna-generic.Model[MaxSig, Int32],
    @luna-generic.ModelConstructionError,
  ] = @luna-generic.Model::make([{ name: "invalid", arity: -1, eval: _ => 0, }])
  assert_true(invalid_algebra is Err(@luna-generic.InvalidArity))
  assert_true(invalid_model is Err(@luna-generic.InvalidArity))
}

///|
test "each custom model receives a fresh identity" {
  let ops : Array[@luna-generic.Op[Int32]] = [
    {
      name: "max",
      arity: 2,
      eval: xs => if xs[0] > xs[1] { xs[0] } else { xs[1] },
    },
  ]
  let first : @luna-generic.Model[MaxSig, Int32] = @luna-generic.Model::make(
    ops,
  ).unwrap()
  let second : @luna-generic.Model[MaxSig, Int32] = @luna-generic.Model::make(
    ops,
  ).unwrap()
  assert_true(first.same_identity(first))
  assert_false(first.same_identity(second))
}

///|
test "runtime Hom composition checks the middle model identity" {
  let source : @luna-generic.Model[MaxSig, Int32] = @luna-generic.Model::make([]).unwrap()
  let middle : @luna-generic.Model[MaxSig, Int32] = @luna-generic.Model::make([]).unwrap()
  let other_middle : @luna-generic.Model[MaxSig, Int32] = @luna-generic.Model::make([],
  ).unwrap()
  let target : @luna-generic.Model[MaxSig, Int32] = @luna-generic.Model::make([]).unwrap()
  let first : Hom[MaxSig, Int32, Int32] = Hom::postulate(source, middle, x => x)
  let matching : Hom[MaxSig, Int32, Int32] = Hom::postulate(middle, target, x => {
    x
  })
  let mismatched : Hom[MaxSig, Int32, Int32] = Hom::postulate(
    other_middle,
    target,
    x => x,
  )
  assert_true(first.then_checked(matching) is Ok(_))
  assert_true(
    first.then_checked(mismatched) is Err(@luna-generic.ModelMismatch),
  )
}

///|
test "pairing and projections reject different runtime models" {
  let model : @luna-generic.Model[MaxSig, Int32] = @luna-generic.Model::make([]).unwrap()
  let other : @luna-generic.Model[MaxSig, Int32] = @luna-generic.Model::make([]).unwrap()
  let source : @luna-generic.Model[MaxSig, Int32] = @luna-generic.Model::make([]).unwrap()
  let to_model : Hom[MaxSig, Int32, Int32] = Hom::postulate(source, model, x => {
    x
  })
  let to_other : Hom[MaxSig, Int32, Int32] = Hom::postulate(source, other, x => {
    x
  })
  let product = @luna-generic.Model::prod(model, model).unwrap()
  assert_true(
    Hom::pair(product, to_model, to_other) is Err(@luna-generic.ModelMismatch),
  )
  assert_true(Hom::fst(product, other) is Err(@luna-generic.ModelMismatch))
  assert_true(Hom::snd(product, other) is Err(@luna-generic.ModelMismatch))
}

///|
test "runtime reduct rejects malformed tables and keeps mapping lineage" {
  let malformed : @luna-generic.Model[RingSig, Int32] = @luna-generic.Model::make([
      { name: "0", arity: 0, eval: _ => 0, },
    ],
  ).unwrap()
  assert_true(
    malformed.forget(@luna-generic.ring_to_semiring)
    is Err(@luna-generic.InvalidOperationTable),
  )

  let source : @luna-generic.Model[RingSig, Int32] = @luna-generic.Model::make([
    { name: "0", arity: 0, eval: _ => 0, },
    { name: "1", arity: 0, eval: _ => 1, },
    { name: "+", arity: 2, eval: xs => xs[0] + xs[1], },
    { name: "*", arity: 2, eval: xs => xs[0] * xs[1], },
    { name: "neg", arity: 1, eval: xs => -xs[0], },
  ]).unwrap()
  let through_add_group = source
    .forget(
      @luna-generic.ring_to_add_group.then(
        @luna-generic.add_group_to_add_monoid,
      ),
    )
    .unwrap()
  let through_semiring = source
    .forget(
      @luna-generic.ring_to_semiring.then(@luna-generic.semiring_to_add_monoid),
    )
    .unwrap()
  assert_false(through_add_group.same_identity(through_semiring))
}

///|
test "custom signatures through Algebra::make" {
  let max_src : Algebra[MaxSig, Int32] = Algebra::make([
    {
      name: "max",
      arity: 2,
      eval: xs => if xs[0] > xs[1] { xs[0] } else { xs[1] },
    },
  ]).unwrap()
  let max_dst : Algebra[MaxSig, Int64] = Algebra::make([
    {
      name: "max",
      arity: 2,
      eval: xs => if xs[0] > xs[1] { xs[0] } else { xs[1] },
    },
  ]).unwrap()
  let source = Model::make([
    {
      name: "max",
      arity: 2,
      eval: xs => if xs[0] > xs[1] { xs[0] } else { xs[1] },
    },
  ]).unwrap()
  let target = Model::make([
    {
      name: "max",
      arity: 2,
      eval: xs => if xs[0] > xs[1] { xs[0] } else { xs[1] },
    },
  ]).unwrap()
  let monotone : Hom[MaxSig, Int32, Int64] = Hom::postulate(source, target, x => {
    x.to_int64() * 3L
  })
  assert_true(monotone.check(max_src, max_dst, small_ints))
  let flip : Hom[MaxSig, Int32, Int64] = Hom::postulate(source, target, x => {
    -x.to_int64()
  })
  assert_false(flip.check(max_src, max_dst, small_ints))
}

///|
enum MaxSig {}
