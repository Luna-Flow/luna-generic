# core tutorial

This tutorial gets you writing one algorithm for many number types with the
traits of `luna-generic`, converting integers into any number type, and
plugging your own types into the same vocabulary. The reasons behind the
design are in the [core design](../design/core.md).

| I want to | Use |
| --- | --- |
| write one algorithm for many number types | trait bounds such as `T : RingOps` |
| turn an integer constant or index into a `T` | `@lf_alg.lift_to(i)` with `T : FromInteger` |
| let my number type be built from integers | implement `FromNat` and `FromInteger` |
| define a new integer type | also implement `Integral`, and add one check |
| get one exact form of any integer | `Integral::normalize(x)`, a `BigInt` |

## Quick start

Add the package to your module:

```bash
moon add Luna-Flow/luna-generic@0.5.0
```

Import it in the `moon.pkg` of the package that uses it:

```moonbit nocheck
import {
  "Luna-Flow/luna-generic" @lf_alg,
}
```

The examples on this page bring the traits into scope with one `using`
declaration:

```moonbit
using @lf_alg {
  trait SemiringOps,
  trait RingOps,
  trait FieldOps,
  trait Zero,
  trait One,
  trait FromNat,
  trait FromInteger,
  trait Integral,
}
```

The smallest useful program is one generic function used at three types:

```moonbit
fn[T : RingOps] double_and_add_one(x : T) -> T {
  x + x + One::one()
}

test "quick start" {
  inspect(double_and_add_one(20), content="41")
  inspect(double_and_add_one(0.25), content="1.5")
  inspect(double_and_add_one(BigInt::from_string("99999999999999999999")), content="199999999999999999999")
}
```

`double_and_add_one` needs only operations, so it works over the signed
integers, `BigInt`, `Float`, `Double`, and any future type that implements the
same bundle.

## Everyday tasks

### Write algorithms against structure, not concrete numbers

Ask for the smallest trait that states what the algorithm needs. A sum of
products needs only `SemiringOps`, so it also runs on unsigned integers:

```moonbit
fn[T : SemiringOps] dot(xs : Array[T], ys : Array[T]) -> T {
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

Require `RingOps` when you subtract, and `FieldOps` only when you divide.

### Turn integers into your number type with `lift_to`

```moonbit
fn[T : SemiringOps + FromInteger] times_index(x : T, i : Int) -> T {
  x * @lf_alg.lift_to(i)
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
fn[F : FieldOps + FromInteger] mean(xs : Array[F]) -> F {
  let mut total : F = Zero::zero()
  for x in xs {
    total = total + x
  }
  total / @lf_alg.lift_to(xs.length())
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
impl @lf_alg.AddMonoidOps for I8
impl @lf_alg.MulMonoidOps for I8
impl @lf_alg.AddGroupOps for I8
impl @lf_alg.SemiringOps for I8
impl @lf_alg.RingOps for I8
impl @lf_alg.AddMonoid for I8 with fn add_monoid_law() {
  @lf_alg.Law::postulate()
}
impl @lf_alg.MulMonoid for I8 with fn mul_monoid_law() {
  @lf_alg.Law::postulate()
}
impl @lf_alg.AddGroup for I8 with fn add_group_law() {
  @lf_alg.Law::postulate()
}
impl @lf_alg.Semiring for I8 with fn semiring_law() {
  @lf_alg.Law::postulate()
}
impl @lf_alg.Ring for I8 with fn ring_law() {
  @lf_alg.Law::postulate()
}

impl FromNat for I8 with fn from_natural(n) {
  I8::wrap((n % BigInt::from_int(256)).to_int())
}

impl FromInteger for I8 with fn from_integer(n) {
  I8::wrap((n % BigInt::from_int(256)).to_int())
}
```

`from_natural` is only called with non-negative values. These conversion
operations do not by themselves certify algebraic laws. For this wrapping
type they reduce modulo 256, so the same residue arithmetic is used by `+`
and `*`:

```moonbit
test "from_integer returns the wrapped value" {
  let value : I8 = FromInteger::from_integer(BigInt::from_int(200))
  inspect(value.v, content="-56")
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
impl @lf_alg.Integral for I8 with fn integral_law() {
  @lf_alg.Law::postulate()
}

impl @lf_alg.Integral for I8 with fn integer_homomorphism_law() {
  @lf_alg.Law::postulate()
}

impl @lf_alg.Integral for I8 with fn normalize(x) {
  BigInt::from_int(x.v)
}

test "normalize is a section" {
  let s : @lf_alg.Section[@lf_alg.SemiringSig, I8, BigInt] = @lf_alg.Section::of_integral()
  let samples = [-128, -1, 0, 1, 127].map(I8::wrap)
  assert_true(s.check(samples))
  let n : Int = @lf_alg.lift_to(I8::wrap(127) + One::one())
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
- Require `FieldOps` only when reciprocal or division operations are needed.
- `Field` promises `0 != 1` and commutative multiplication through an explicit
  law certificate. Do not implement
  it for a zero ring or a type whose products depend on factor order; ask for
  `RingOps + Inverse + Div` in code that must accept noncommutative types.
- Treat `Float` and `Double` as rounded operation providers. They implement
  `FieldOps` but do not have exact `Field` law instances.
- `Inverse::inv` aborts on `0.0` for `Float` and `Double`, while `/` returns
  an infinity. Test for zero before inverting.
- Converting a huge integer into `Float` or `Double` with `from_integer` or
  `lift_to` gives an infinity, not an error: anything from about $3.4 \times
  10^{38}$ for `Float` and $1.8 \times 10^{308}$ for `Double`. Check the
  result with `is_inf` when the input can be that large.
- Unsigned integers are not `RingOps`: generic code that negates cannot take
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
