# core tutorial

This tutorial gets you writing one algorithm for many number types with the
traits of `luna-generic`, converting integers into any number type, and
plugging your own types into the same vocabulary. The reasons behind the
design are in the [core design](../design/core.md).

| I want to | Use |
| --- | --- |
| write one algorithm for many number types | trait bounds such as `T : Ring` |
| turn an integer constant or index into a `T` | `@luna-generic.lift_to(i)` with `T : FromInteger` |
| let my number type be built from integers | implement `FromNat` and `FromInteger` |
| define a new integer type | also implement `Integral`, and add one check |
| get one exact form of any integer | `Integral::normalize(x)`, a `BigInt` |

## Quick start

Add the package to your module:

```bash
moon add Luna-Flow/luna-generic@0.4.0
```

Import it in the `moon.pkg` of the package that uses it:

```moonbit nocheck
import {
  "Luna-Flow/luna-generic",
}
```

The examples on this page bring the traits into scope with one `using`
declaration:

```moonbit
using @luna-generic {
  trait Semiring,
  trait Ring,
  trait Field,
  trait Zero,
  trait One,
  trait FromNat,
  trait FromInteger,
  trait Integral,
}
```

The smallest useful program is one generic function used at three types:

```moonbit
fn[T : Ring] double_and_add_one(x : T) -> T {
  x + x + One::one()
}

test "quick start" {
  inspect(double_and_add_one(20), content="41")
  inspect(double_and_add_one(0.25), content="1.5")
  inspect(double_and_add_one(BigInt::from_string("99999999999999999999")), content="199999999999999999999")
}
```

`double_and_add_one` works over the signed integers, `BigInt`, `Float`,
`Double`, and any future type that implements the same traits.

## Everyday tasks

### Write algorithms against structure, not concrete numbers

Ask for the smallest trait that states what the algorithm needs. A sum of
products needs only `Semiring`, so it also runs on unsigned integers:

```moonbit
fn[T : Semiring] dot(xs : Array[T], ys : Array[T]) -> T {
  let mut acc : T = Zero::zero()
  for i, x in xs {
    acc = acc + x * ys[i]
  }
  acc
}

test "dot" {
  inspect(dot([1U, 2U, 3U], [4U, 5U, 6U]), content="32")
  inspect(dot([0.5, 2.0], [4.0, 0.25]), content="2.5")
}
```

Require `Ring` when you subtract, and `Field` only when you divide.

### Turn integers into your number type with `lift_to`

```moonbit
fn[T : Semiring + FromInteger] times_index(x : T, i : Int) -> T {
  x * @luna-generic.lift_to(i)
}

test "lift_to" {
  inspect(times_index(1.5, 4), content="6")
  inspect(times_index(BigInt::from_int(7), -3), content="-21")
}
```

`lift_to` converts the value of any integer type (`Int`, `UInt64`, `BigInt`,
...) into any type with `FromInteger`. It sees the value the integer holds
now: if an `Int` computation has already wrapped around, `lift_to` converts
the wrapped value. Do the arithmetic in `BigInt` or in `T` when you need the
full range.

### Average values in any field

```moonbit
fn[F : Field + FromInteger] mean(xs : Array[F]) -> F {
  let mut total : F = Zero::zero()
  for x in xs {
    total = total + x
  }
  total / @luna-generic.lift_to(xs.length())
}

test "mean" {
  inspect(mean([1.0, 2.0, 4.5]), content="2.5")
}
```

### Get one exact form of any integer

```moonbit
fn[T : Integral] canonical_text(x : T) -> String {
  Integral::normalize(x).to_string()
}

test "normalize" {
  inspect(canonical_text(-5), content="-5")
  inspect(canonical_text((65535 : UInt16)), content="65535")
  inspect(canonical_text(9223372036854775807L), content="9223372036854775807")
}
```

Use `Integral::normalize` when you need one exact representation across
multiple integer types. Unsigned values come out non-negative, signed values
keep their sign.

## Going further

### Make your number type buildable from integers

The running example is an 8-bit wrapping integer. A type that only needs to
be built from integers implements the two conversions from `BigInt`:

```moonbit
priv struct I8 {
  v : Int // always in [-128, 128)
} derive(Eq, Debug)

fn I8::wrap(n : Int) -> I8 {
  let r = ((n % 256) + 256) % 256
  { v: if r >= 128 { r - 256 } else { r } }
}

impl Add for I8 with fn add(a, b) { I8::wrap(a.v + b.v) }
impl Mul for I8 with fn mul(a, b) { I8::wrap(a.v * b.v) }
impl Neg for I8 with fn neg(a) { I8::wrap(-a.v) }
impl Sub for I8 with fn sub(a, b) { I8::wrap(a.v - b.v) }
impl Zero for I8 with fn zero() { { v: 0 } }
impl One for I8 with fn one() { { v: 1 } }
impl @luna-generic.AddMonoid for I8
impl @luna-generic.MulMonoid for I8
impl @luna-generic.AddGroup for I8
impl Semiring for I8
impl Ring for I8

impl FromNat for I8 with fn from_natural(n) {
  I8::wrap((n % BigInt::from_int(256)).to_int())
}

impl FromInteger for I8 with fn from_integer(n) {
  I8::wrap((n % BigInt::from_int(256)).to_int())
}
```

`from_natural` is only called with non-negative values. Both must agree with
your arithmetic: converting `a + b` gives the sum of the converted values, the
same holds for `*`, and `0` and `1` become your zero and one. Check it on a
few values, including large and negative ones:

```moonbit
test "from_integer is a homomorphism" {
  let h : @luna-generic.Hom[@luna-generic.RingSig, BigInt, I8] = @luna-generic.Hom::from_integer().to_ring()
  let samples = [0, 1, -1, 127, 128, -129, 1000].map(BigInt::from_int)
  assert_true(h.check(@luna-generic.Algebra::ring(), @luna-generic.Algebra::ring(), samples))
  inspect(h.apply(BigInt::from_int(200)).v, content="-56")
}
```

Floating-point types only agree up to rounding; the
[hom tutorial](hom.md) shows how to check them with a tolerance.

### Define a new integer type

This is rare. An integer type implements `Integral` on top of the two
conversions above. `normalize` returns the value of `x` as a `BigInt`, exactly
as your type shows it, so converting it back gives `x` again. Check that
round trip with the smallest and largest values of your type:

```moonbit
impl Integral for I8 with fn normalize(x) { BigInt::from_int(x.v) }

test "normalize is a section" {
  let s : @luna-generic.Section[@luna-generic.SemiringSig, I8, BigInt] = @luna-generic.Section::of_integral()
  let samples = [-128, -1, 0, 1, 127].map(I8::wrap)
  assert_true(s.check(samples))
  let n : Int = @luna-generic.lift_to(I8::wrap(127) + One::one())
  inspect(n, content="-128")
}
```

The last line shows the wrap-around: `127 + 1` is `-128` in `I8`, and
`lift_to` converts the wrapped value.

### Combine with sibling packages

Higher-level Luna Flow packages state their requirements with these traits,
so a type that implements them can be passed to their generic code. Keep
your instances honest: implement a trait only when your type satisfies its
laws, listed on the [core API](../api/core.md).

## Common pitfalls

- Choose the smallest trait set that expresses the algorithm you need.
- Require `Field` only when reciprocal or division semantics are really needed.
- `Field` promises commutative multiplication. Do not implement it for a type
  whose products depend on the order of the factors; ask for
  `Ring + Inverse + Div` in code that must accept such types.
- Treat `Float` and `Double` as approximate backends even though they satisfy
  the same abstract surface as exact types.
- `Inverse::inv` aborts on `0.0` for `Float` and `Double`, while `/` returns
  an infinity. Test for zero before inverting.
- Unsigned integers are not `Ring`: generic code that negates cannot take
  `UInt`.
- `lift_to` converts the wrapped value. Overflow that happened before the
  call is not undone.
- Prefer `lift_to`, `FromNat` and `FromInteger` over the deprecated
  `NatHomomorphism` and `IntegralHomomorphism`.

## Next steps

- The [core API](../api/core.md) lists every trait, its laws and the shipped
  instances.
- The [core design](../design/core.md) derives why conversions factor
  through ℤ and why `Field` must be commutative.
- The [hom tutorial](hom.md) checks conversions and other maps with
  certificates.
