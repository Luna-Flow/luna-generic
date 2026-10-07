# hom tutorial

## Leaf homomorphisms: one `postulate`, one check

```moonbit
fn int64_to_int() -> Hom[RingSig, Int64, Int] {
  Hom::postulate(x => x.to_int())
}

test {
  let samples = [0L, 1L, -1L, 7L, 2147483647L, 4294967296L, 9223372036854775807L]
  assert_true(int64_to_int().check(Algebra::ring(), Algebra::ring(), samples))
}
```

Truncation is a ring homomorphism even when values wrap. Widening `Int` to
`Int64` is not: `Int` is ℤ/2^32, and `2147483647 + 1` wraps in `Int` but not
in `Int64`, so its check fails as soon as a sample sum overflows.

Every `Hom::postulate` is a proof obligation. Searching the repository for
`postulate` lists every unproven homomorphism, and each one should have a
matching `check` test.

## Lifting from smaller homomorphisms

```moonbit
let h = int64_to_int()
let low : Hom[RingSig, Int64, Int16] = Hom::postulate(x => Int16::from_int(x.to_int()))
let p = Hom::pair(h, low)                       // Int64 -> Prod[Int, Int16]
let back = p.then(Hom::fst())                   // same as h
let additive = h.forget(@luna-generic.ring_to_add_group)
```

Composition, forgetting, pairing, projection and upgrades are inference rules
and create no new obligations. They treat every certificate as strict, so a
map that only passes a lax or tolerance check below must be checked again
after it is composed.

## Lifting quotients back

`Int` is ℤ/2^32. Mapping it into `BigInt` picks a representative of each
class, which is a section of the reduction `BigInt -> Int`, not a
homomorphism:

```moonbit
let s : Section[RingSig, Int, BigInt] = Section::of_integral().to_ring()
assert_true(s.check([0, 1, -1, 2147483647, -2147483648]))
assert_true(s.check_ops(Algebra::ring(), Algebra::ring(), samples))
s.is_representative(s.lift(2147483647) + s.lift(1))  // false: the sum wrapped
```

The lift agrees with the operations exactly on representatives; elsewhere it
differs by a multiple of 2^32, the carry. A lift that leaves the class, such
as one that drops the sign or rounds through `Float`, fails `check`.

When no certificate is needed, `lift_to` lifts and maps into any
`FromInteger` target:

```moonbit
let x : Double = @luna-generic.lift_to(-7)
```

## Choosing the strength of preservation

```moonbit
let abs : Hom[AddMonoidSig, Double, Double] = Hom::postulate(x => x.abs())
// |x + y| <= |x| + |y|: subadditive, a lax homomorphism
abs.check_by(Algebra::add_monoid(), Algebra::add_monoid(), samples, (l, r) => l <= r)
```

Use a tolerance for floating-point targets. A tolerance relative to the
result suits non-negative sources; with signed sources `x + y` can cancel to
a small value while the rounding error stays proportional to `|x| + |y|`:

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
dictionaries list the same operations in the same order. Keep one dictionary
per tag and carrier: certificates checked against different interpretations
of the same tag do not compose.

## Practical guidance

- Express unique homomorphisms (the canonical maps out of ℕ and ℤ) as traits
  and bring the one out of ℤ into `Hom` through `Hom::from_integer`.
- Describe machine integers as quotients with `Section::of_integral`, and
  use `lift_to` for conversions that are not mapped back.
- Write non-unique homomorphisms (such as two conjugate embeddings) as
  explicit `Hom` values, never as trait instances.
- Include edge values in `check` samples: 0, 1, negatives, and values close to
  overflow for fixed-width types.
