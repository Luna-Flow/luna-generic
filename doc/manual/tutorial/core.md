# core tutorial

## Write algorithms against structure, not concrete numbers

```moonbit
fn[T : Ring + One] double_and_add_one(x : T) -> T {
  x + x + One::one()
}
```

This function can work over signed integers, `BigInt`, `Float`, `Double`, and
future external types that implement the same traits.

## Normalize integral inputs through `BigInt`

```moonbit
fn[T : Integral] canonical_text(x : T) -> String {
  Integral::normalize(x).to_string()
}
```

Use `Integral::normalize` when you need one exact representation across
multiple integral source types.

## Convert integers with `lift_to`

```moonbit
fn[F : FromInteger] scale_by_index(i : Int) -> F {
  @luna-generic.lift_to(i)
}
```

`lift_to` takes the representative of `i` in ℤ and maps it into `F` along
the canonical map. Use it for constants and indices that are not mapped back.
It does not preserve operations once fixed-width arithmetic wraps.

A new number type only needs the canonical maps out of ℕ and ℤ:

```moonbit
impl FromNat for MyNumber with fn from_natural(n) { MyNumber::from_bigint(n) }
impl FromInteger for MyNumber with fn from_integer(n) { MyNumber::from_bigint(n) }
```

An integer type additionally implements `Integral::normalize` so that
`from_integer(normalize(x)) == x`, and checks the law with
`Section::of_integral().check(samples)`.

## Practical guidance

- Choose the smallest trait set that expresses the algorithm you need.
- Require `Field` only when reciprocal or division semantics are really needed.
- Treat `Float` and `Double` as approximate backends even though they satisfy
  the same abstract surface as exact types.
