# hom tutorial

A `Hom[S, A, B]` is a map `A -> B` that keeps the operations listed by `S`
consistent: converting a sum gives the sum of the conversions, and so on.
This page shows how to declare, check and combine them. Why they are built
this way is in the [hom design](../design/hom.md).

## Quick start

`Hom` ships with `luna-generic`; install and import the package as in the
[core tutorial](core.md). The examples on this page use this declaration:

```moonbit
using @luna-generic {
  type Hom,
  type Section,
  type Algebra,
  type Op,
  type AddMonoidSig,
  type SemiringSig,
  type RingSig,
  ring_to_add_group,
  lift_to,
}
```

The smallest useful program declares one homomorphism and checks it:

```moonbit
fn int64_to_int() -> Hom[RingSig, Int64, Int] {
  Hom::postulate(x => x.to_int())
}

test "quick start" {
  let samples = [0L, 1L, -1L, 7L, 2147483647L, 4294967296L, 9223372036854775807L]
  assert_true(int64_to_int().check(Algebra::ring(), Algebra::ring(), samples))
  inspect(int64_to_int().apply(4294967301L), content="5")
}
```

## Everyday tasks

### Leaf homomorphisms: one `postulate`, one check

Truncating `Int64` to `Int`, as above, keeps `+` and `*` consistent even
when values wrap around, so the check passes on extreme samples. Widening
`Int` to `Int64` does not: `2147483647 + 1` wraps around in `Int` but not in
`Int64`, so its check fails as soon as a sample sum overflows.

```moonbit
test "widening is not a homomorphism" {
  let widen : Hom[RingSig, Int, Int64] = Hom::postulate(x => x.to_int64())
  let samples = [0, 1, -1, 2147483647]
  assert_false(widen.check(Algebra::ring(), Algebra::ring(), samples))
}
```

Every `Hom::postulate` is a promise you make. Searching the repository for
`postulate` lists all of them, and each one should have a matching `check`
test.

### Building from smaller homomorphisms

```moonbit
test "composition" {
  let h = int64_to_int()
  let low : Hom[RingSig, Int64, Int16] = Hom::postulate(x => Int16::from_int(x.to_int()))
  let p = Hom::pair(h, low) // Int64 -> Prod[Int, Int16]
  let back = p.then(Hom::fst()) // same as h
  let additive = h.forget(ring_to_add_group)
  inspect(p.apply(65537L).snd, content="1")
  inspect(back.apply(4294967301L), content="5")
  inspect(additive.apply(-1L), content="-1")
}
```

Composition, forgetting, pairing, projection and upgrades create no new
promises. They treat every certificate as exact, so a map that only passes a
`<=` or tolerance check below must be checked again after it is composed.

### Checking a conversion that is not a homomorphism

Converting an `Int` to `BigInt` keeps every value, but not the wrapped
arithmetic: `2147483647 + 1` is negative in `Int` and positive in `BigInt`.
Such a conversion is described by a `Section` instead of a `Hom`. It records
the way back as well, and checks that going there and back returns the
original value:

```moonbit
test "section" {
  let s : Section[RingSig, Int, BigInt] = Section::of_integral().to_ring()
  let samples = [0, 1, -1, 2147483647, -2147483648]
  assert_true(s.check(samples))
  assert_true(s.check_ops(Algebra::ring(), Algebra::ring(), samples))
}
```

A conversion that changes values, for example one that drops the sign or
rounds through `Float`, fails `check`.

`s.is_representative(b)` tells whether a `BigInt` is a value the conversion
can produce. Arithmetic on converted values matches the original arithmetic
exactly when the result is such a value:

```moonbit
test "representatives" {
  let s : Section[RingSig, Int, BigInt] = Section::of_integral().to_ring()
  inspect(s.is_representative(s.lift(7) + s.lift(1)), content="true") // no wrap-around
  inspect(s.is_representative(s.lift(2147483647) + s.lift(1)), content="false") // Int wrapped
}
```

When no certificate is needed, `lift_to` converts into any `FromInteger`
target:

```moonbit
test "lift_to" {
  let x : Double = lift_to(-7)
  inspect(x, content="-7")
}
```

### Choosing the strength of preservation

```moonbit
test "lax homomorphism" {
  let abs : Hom[AddMonoidSig, Double, Double] = Hom::postulate(x => x.abs())
  let samples = [0.0, 1.5, -2.0, 3.25]
  // |x + y| <= |x| + |y|: subadditive, a lax homomorphism
  assert_true(abs.check_by(Algebra::add_monoid(), Algebra::add_monoid(), samples, (l, r) => l <= r))
}
```

Use a tolerance for floating-point targets. A tolerance relative to the
result suits non-negative inputs; with signed inputs `x + y` can cancel to a
small value while the rounding error stays proportional to `|x| + |y|`:

```moonbit
test "approximate homomorphism" {
  let h : Hom[SemiringSig, BigInt, Float] = Hom::from_integer()
  let close = (l : Float, r : Float) => {
    (l - r).abs() <= (1.0e-6 : Float) * ((1.0 : Float) + r.abs())
  }
  let samples = [0, 1, 3, 1000, 16777217].map(BigInt::from_int)
  assert_true(h.check_by(Algebra::semiring(), Algebra::semiring(), samples, close))
  assert_false(h.check(Algebra::semiring(), Algebra::semiring(), samples))
}
```

`16777217` is $2^{24} + 1$, the first integer that `Float` cannot hold, so
the exact check fails while the tolerance check passes.

## Going further

### Custom signatures

```moonbit
enum MaxSig {}

fn max_int() -> Algebra[MaxSig, Int] {
  Algebra::make([
    Op::{ name: "max", arity: 2, eval: xs => if xs[0] > xs[1] { xs[0] } else { xs[1] } },
  ])
}

test "custom signature" {
  // doubling is monotone, so it preserves max (as long as it does not wrap)
  let double : Hom[MaxSig, Int, Int] = Hom::postulate(x => 2 * x)
  assert_true(double.check(max_int(), max_int(), [-5, 0, 3, 1000]))
}
```

`Hom` and `check` work for any signature with one carrier, as long as both
dictionaries list the same operations in the same order. Keep one dictionary
per tag and carrier: certificates checked against different meanings of the
same tag do not compose.

Operation arities must be nonnegative; `Algebra::make` aborts otherwise.

### Maps that are not determined by the types

The canonical map out of ℤ is unique, so it lives in the `FromInteger`
trait. Most other homomorphisms are not unique: a type can have several
structure-preserving maps to itself, such as the identity and complex
conjugation on the complex numbers. Write such maps as explicit `Hom`
values, never as trait instances, so that the choice stays visible at the
call site.

## Common pitfalls

- Use `Hom::from_integer` for the conversion out of `BigInt` into a number
  type; it holds for every input.
- Use `Section::of_integral` to check conversions out of machine integers,
  and `lift_to` when you only need the value. Do not wrap a widening such
  as `Int -> Int64` in `Hom::postulate`: it is not a homomorphism.
- Include edge values in `check` samples: 0, 1, negatives, and values close to
  overflow for fixed-width types.
- A map checked with `<=` or a tolerance is still composed as if it were
  exact. Check the composite again.
- Checks of binary operations test every pair of samples, so a few dozen
  samples already mean thousands of evaluations.

## Next steps

- The [hom API](../api/hom.md) lists every constructor, rule and check.
- The [hom design](../design/hom.md) proves what a section preserves and
  why a lift into ℤ cannot be a homomorphism.
- The [core tutorial](core.md) covers the traits that the built-in
  signatures are derived from.
