# core tutorial

## Quick start for library authors

| I want to | Use |
| --- | --- |
| write one algorithm for many number types | trait bounds such as `T : Ring` |
| turn an integer constant or index into a `T` | `@luna-generic.lift_to(i)` with `T : FromInteger` |
| let my number type be built from integers | implement `FromNat` and `FromInteger` |
| define a new integer type | also implement `Integral`, and add one check |
| get one exact form of any integer | `Integral::normalize(x)`, a `BigInt` |

The rest of this page walks through each row. The reasons behind the
design are in the [core design](../design/core.md).

## Write algorithms against structure, not concrete numbers

```moonbit
fn[T : Ring + One] double_and_add_one(x : T) -> T {
  x + x + One::one()
}
```

This function can work over signed integers, `BigInt`, `Float`, `Double`, and
future external types that implement the same traits.

## Turn integers into your number type with `lift_to`

```moonbit
fn[T : Semiring + FromInteger] times_index(x : T, i : Int) -> T {
  x * @luna-generic.lift_to(i)
}
```

`lift_to` converts the value of any integer type (`Int`, `UInt64`, `BigInt`,
...) into any type with `FromInteger`. It sees the value the integer holds
now: if an `Int` computation has already wrapped around, `lift_to` converts
the wrapped value. Do the arithmetic in `BigInt` or in `T` when you need the
full range.

## Make your number type buildable from integers

Implement the two conversions from `BigInt`:

```moonbit
pub impl FromNat for MyNumber with fn from_natural(n) {
  MyNumber::from_bigint(n)
}

pub impl FromInteger for MyNumber with fn from_integer(n) {
  MyNumber::from_bigint(n)
}
```

`from_natural` is only called with non-negative values. Both must agree with
your arithmetic: converting `a + b` gives the sum of the converted values, the
same holds for `*`, and `0` and `1` become your zero and one. Check it on a
few values, including large and negative ones:

```moonbit
let h : Hom[SemiringSig, BigInt, MyNumber] = Hom::from_integer()
assert_true(h.check(Algebra::semiring(), Algebra::semiring(), samples))
```

Floating-point types only agree up to rounding; the
[hom tutorial](hom.md) shows how to check them with a tolerance.

## Define a new integer type

This is rare. An integer type implements `Integral` on top of the two
conversions above. `normalize` returns the value of `x` as a `BigInt`, exactly
as your type shows it, so converting it back gives `x` again. Check that
round trip with the smallest and largest values of your type:

```moonbit
let s : Section[SemiringSig, MyInt, BigInt] = Section::of_integral()
assert_true(s.check(samples))
```

## Get one exact form of any integer

```moonbit
fn[T : Integral] canonical_text(x : T) -> String {
  Integral::normalize(x).to_string()
}
```

Use `Integral::normalize` when you need one exact representation across
multiple integer types.

## Practical guidance

- Choose the smallest trait set that expresses the algorithm you need.
- Require `Field` only when reciprocal or division semantics are really needed.
- Treat `Float` and `Double` as approximate backends even though they satisfy
  the same abstract surface as exact types.
- Prefer `lift_to`, `FromNat` and `FromInteger` over the deprecated
  `NatHomomorphism` and `IntegralHomomorphism`.
