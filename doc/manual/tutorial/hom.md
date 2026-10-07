# hom tutorial

## Leaf homomorphisms: one `postulate`, one check

```moonbit
fn int_to_int64() -> Hom[RingSig, Int, Int64] {
  Hom::postulate(x => x.to_int64())
}

test {
  let samples = [0, 1, -1, 2, -3, 7, 100]
  assert_true(int_to_int64().check(Algebra::ring(), Algebra::ring(), samples))
}
```

Every `Hom::postulate` is a proof obligation. Searching the repository for
`postulate` lists every unproven homomorphism, and each one should have a
matching `check` test.

## Lifting from smaller homomorphisms

```moonbit
let h = int_to_int64()
let both : Hom[RingSig, Int, BigInt] = Hom::from_integral().to_ring()
let p = Hom::pair(h, both)                      // Int -> Prod[Int64, BigInt]
let back = p.then(Hom::fst())                   // same as h
let additive = h.forget(@luna-generic.ring_to_add_group)
```

Composition, forgetting, pairing, projection and upgrades are inference rules
and create no new obligations.

## Choosing the strength of preservation

```moonbit
let abs : Hom[AddMonoidSig, Double, Double] = Hom::postulate(x => x.abs())
// |x + y| <= |x| + |y|: subadditive, a lax homomorphism
abs.check_by(Algebra::add_monoid(), Algebra::add_monoid(), samples, (l, r) => l <= r)
```

Use a tolerance for floating-point targets:

```moonbit
let close = (l : Float, r : Float) => {
  (l - r).abs() <= (1.0e-6 : Float) * ((1.0 : Float) + r.abs())
}
h.check_by(Algebra::semiring(), Algebra::semiring(), samples, close)
```

## Custom signatures

```moonbit
enum MaxSig {}

let max_int : Algebra[MaxSig, Int] = Algebra::make([
  { name: "max", arity: 2, eval: xs => if xs[0] > xs[1] { xs[0] } else { xs[1] } },
])
```

`Hom` and `check` work for any single-sorted signature as long as both
dictionaries list the same operations in the same order.

## Practical guidance

- Express unique homomorphisms (the canonical embeddings out of ℕ and ℤ) as
  traits and bring them into `Hom` through `Hom::from_nat` /
  `Hom::from_integral`.
- Write non-unique homomorphisms (such as two conjugate embeddings) as
  explicit `Hom` values, never as trait instances.
- Include edge values in `check` samples: 0, 1, negatives, and values close to
  overflow for fixed-width types.
