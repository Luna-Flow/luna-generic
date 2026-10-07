# hom tutorial

A `Hom[S, A, B]` is a map `A -> B` that keeps the operations listed by `S`
consistent: converting a sum gives the sum of the conversions, and so on.
This page shows how to declare, check and combine them. Why they are built
this way is in the [hom design](../design/hom.md).

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

Truncating `Int64` to `Int` keeps `+` and `*` consistent even when values wrap
around, so the check passes on extreme samples. Widening `Int` to `Int64`
does not: `2147483647 + 1` wraps around in `Int` but not in `Int64`, so its
check fails as soon as a sample sum overflows.

Every `Hom::postulate` is a promise you make. Searching the repository for
`postulate` lists all of them, and each one should have a matching `check`
test.

## Building from smaller homomorphisms

```moonbit
let h = int64_to_int()
let low : Hom[RingSig, Int64, Int16] = Hom::postulate(x => Int16::from_int(x.to_int()))
let p = Hom::pair(h, low)                       // Int64 -> Prod[Int, Int16]
let back = p.then(Hom::fst())                   // same as h
let additive = h.forget(@luna-generic.ring_to_add_group)
```

Composition, forgetting, pairing, projection and upgrades create no new
promises. They treat every certificate as exact, so a map that only passes a
`<=` or tolerance check below must be checked again after it is composed.

## Checking a conversion that is not a homomorphism

Converting an `Int` to `BigInt` keeps every value, but not the wrapped
arithmetic: `2147483647 + 1` is negative in `Int` and positive in `BigInt`.
Such a conversion is described by a `Section` instead of a `Hom`. It records
the way back as well, and checks that going there and back returns the
original value:

```moonbit
let s : Section[RingSig, Int, BigInt] = Section::of_integral().to_ring()
assert_true(s.check([0, 1, -1, 2147483647, -2147483648]))
assert_true(s.check_ops(Algebra::ring(), Algebra::ring(), samples))
```

A conversion that changes values, for example one that drops the sign or
rounds through `Float`, fails `check`.

`s.is_representative(b)` tells whether a `BigInt` is a value the conversion
can produce. Arithmetic on converted values matches the original arithmetic
exactly when the result is such a value:

```moonbit
s.is_representative(s.lift(7) + s.lift(1))           // true: no wrap-around
s.is_representative(s.lift(2147483647) + s.lift(1))  // false: Int wrapped
```

When no certificate is needed, `lift_to` converts into any `FromInteger`
target:

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
result suits non-negative inputs; with signed inputs `x + y` can cancel to a
small value while the rounding error stays proportional to `|x| + |y|`:

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

`Hom` and `check` work for any signature with one carrier, as long as both
dictionaries list the same operations in the same order. Keep one dictionary
per tag and carrier: certificates checked against different meanings of the
same tag do not compose.

## Practical guidance

- Use `Hom::from_integer` for the conversion out of `BigInt` into a number
  type; it holds for every input.
- Use `Section::of_integral` to check conversions out of machine integers,
  and `lift_to` when you only need the value.
- Write maps that are not determined by the types, such as complex
  conjugation, as explicit `Hom` values, never as trait instances.
- Include edge values in `check` samples: 0, 1, negatives, and values close to
  overflow for fixed-width types.
