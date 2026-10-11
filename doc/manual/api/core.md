# core API

## Purpose

`luna-generic` is the algebraic trait layer of LunaFlow. It does not provide
numerical algorithms or containers by itself; it defines the reusable
capability surface that higher-level packages depend on.

This page lists the traits, the conversion functions and the shipped
instances. The certificates `Hom` and `Section` are on the
[hom API](hom.md) page. The reasons behind the shapes are in the
[core design](../design/core.md).

## Importing

Add the package to your `moon.pkg`:

```moonbit nocheck
import {
  "Luna-Flow/luna-generic",
}
```

The examples on this page bring the names into scope with one `using`
declaration, so they can be written without the `@lf_alg.` prefix:

```moonbit
using @lf_alg {
  trait AddMonoid,
  trait MulMonoid,
  trait AddGroup,
  trait MulGroup,
  trait Semiring,
  trait Ring,
  trait Field,
  trait AddMonoidOps,
  trait MulMonoidOps,
  trait AddGroupOps,
  trait MulGroupOps,
  trait SemiringOps,
  trait RingOps,
  trait FieldOps,
  trait NumOps,
  trait RoundedArithmetic,
  trait Zero,
  trait One,
  trait Inverse,
  trait Conjugate,
  trait FromNat,
  trait FromInteger,
  trait Integral,
  trait Nat,
  lift_to,
}
```

## Laws are contracts

Operation bundles (`AddMonoidOps`, `SemiringOps`, `RingOps`, `FieldOps`,
and `NumOps`) describe available operations without asserting equations.
Exact structural traits (`AddMonoid`, `Semiring`, `Ring`, `Field`, and
the others) require a method returning an opaque `Law[Theory, Self]`.
Implementations choose an explicit `Law::postulate()` assumption or derive a
weaker law through a kernel-owned implication. The compiler checks that a
certificate is returned, not that its equations are true.

`Float` and `Double` implement operation bundles and `RoundedArithmetic`;
they do not receive exact structural law instances.

## Operation traits

These traits live in `src/operation.mbt`. They name single operations and
state no laws on their own; the structural traits give them their meaning.

### `Zero`

`Zero::zero()` returns the additive identity of `Self`.

```mbti
pub(open) trait Zero {
  fn zero() -> Self
}
```

In an `AddMonoid` it must satisfy $0 + x = x + 0 = x$. Shipped for every
default numeric type.

### `One`

`One::one()` returns the multiplicative identity of `Self`.

```mbti
pub(open) trait One {
  fn one() -> Self
}
```

In a `MulMonoid` it must satisfy $1 \cdot x = x \cdot 1 = x$. Shipped for
every default numeric type.

```moonbit
test "zero and one" {
  let z : Int = Zero::zero()
  let o : Double = One::one()
  inspect(z, content="0")
  inspect(o, content="1")
}
```

### `Inverse`

`Inverse::inv(x)` returns the multiplicative inverse $x^{-1}$.

```mbti
pub(open) trait Inverse {
  fn inv(Self) -> Self
}
```

In a `MulGroup` or `Field` it must satisfy $x \cdot x^{-1} = x^{-1} \cdot x =
1$ for every $x$ that has an inverse. The shipped `Float` and `Double`
instances abort with a message on `0`, rather than returning an infinity as
`1.0 / 0.0` does.

```moonbit
test "inv" {
  inspect(Inverse::inv(4.0), content="0.25")
}
```

### `Conjugate`

`Conjugate::conjugate(x)` returns the conjugate $\overline{x}$.

```mbti
pub(open) trait Conjugate {
  fn conjugate(Self) -> Self
}
```

No instance is shipped. Implementors usually make it an involution that
respects the arithmetic: $\overline{\overline{x}} = x$,
$\overline{x + y} = \overline{x} + \overline{y}$ and
$\overline{xy} = \overline{y}\,\overline{x}$, which is
$\overline{x}\,\overline{y}$ when multiplication commutes. The trait does
not enforce these laws.

```moonbit
priv struct Pair {
  re : Double
  im : Double
} derive(Eq, Debug)

impl Conjugate for Pair with fn conjugate(z) {
  { re: z.re, im: -z.im }
}

test "conjugate" {
  let z = Pair::{ re: 1.0, im: 2.0 }
  assert_eq(Conjugate::conjugate(Conjugate::conjugate(z)), z)
}
```

## Structural traits

These traits live in `src/structure.mbt`. Each returns an opaque law
certificate. The equations are contracts represented by that certificate;
the compiler does not prove them.

### `AddMonoid`

`AddMonoid` is a type with an associative `+` and the identity `0`.

```mbti
pub(open) trait AddMonoid : AddMonoidOps {
  add_monoid_law() -> Law[AddMonoidTh, Self]
}
```

$$
(x + y) + z = x + (y + z), \qquad 0 + x = x + 0 = x.
$$

`+` is not required to commute here; every structure that builds on
`AddMonoid` in this package (`Semiring`, `Ring`) requires it to.

```moonbit
fn[T : AddMonoidOps] sum(xs : Array[T]) -> T {
  xs.fold(init=Zero::zero(), (acc, x) => acc + x)
}

test "sum" {
  inspect(sum([1, 2, 3]), content="6")
  inspect(sum(([] : Array[UInt])), content="0")
}
```

### `MulMonoid`

`MulMonoid` is a type with an associative `*` and the identity `1`.

```mbti
pub(open) trait MulMonoid : MulMonoidOps {
  mul_monoid_law() -> Law[MulMonoidTh, Self]
}
```

$$
(xy)z = x(yz), \qquad 1 \cdot x = x \cdot 1 = x.
$$

```moonbit
fn[T : MulMonoidOps] power(x : T, n : Int) -> T {
  let mut acc : T = One::one()
  for _ in 0..<n {
    acc = acc * x
  }
  acc
}

test "power" {
  inspect(power(3, 4), content="81")
  inspect(power(2UL, 0), content="1")
}
```

### `AddGroup`

`AddGroup` is an `AddMonoid` where every element has a negative.

```mbti
pub(open) trait AddGroup : AddGroupOps {
  add_group_law() -> Law[AddGroupTh, Self]
}
```

$$
x + (-x) = (-x) + x = 0, \qquad x - y = x + (-y).
$$

Unsigned types do not implement it; see the semantic notes below.

```moonbit
fn[T : AddGroupOps] difference(x : T, y : T) -> T {
  x + -y
}

test "difference" {
  inspect(difference(3, 5), content="-2")
}
```

### `MulGroup`

`MulGroup` is a `MulMonoid` with inverses and division.

```mbti
pub(open) trait MulGroup : MulGroupOps {
  mul_group_law() -> Law[MulGroupTh, Self]
}
```

$$
x \cdot x^{-1} = x^{-1} \cdot x = 1, \qquad x / y = x \cdot y^{-1}.
$$

`Float` and `Double` implement `MulGroupOps` for executable operations, but
they do not provide the exact `MulGroup` law certificate: `0` has no inverse
and floating-point identities are rounded.

### `Semiring`

`Semiring` is an exact law contract over semiring operations.

```mbti
pub(open) trait Semiring : SemiringOps {
  semiring_law() -> Law[SemiringTh, Self]
}
```

$$
x + y = y + x, \qquad x(y + z) = xy + xz, \qquad (x + y)z = xz + yz,
\qquad 0 \cdot x = x \cdot 0 = 0.
$$

Signed and unsigned integer types and `BigInt` provide an explicit
`SemiringTh` assumption. `Float` and `Double` provide `SemiringOps`
without a `Semiring` law instance.

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
}
```

### `Ring`

`Ring` is an exact law contract over ring operations. Its operation
requirements are independent of its certificate.

```mbti
pub(open) trait Ring : RingOps {
  ring_law() -> Law[RingTh, Self]
}
```

The `RingTh` certificate includes the ring axioms; multiplication need not
commute. The compiler does not prove the equations represented by the returned
certificate.

```moonbit
fn[T : RingOps] square_of_difference(x : T, y : T) -> T {
  (x - y) * (x - y)
}

test "ring" {
  inspect(square_of_difference(2, 7), content="25")
}
```

### `Field`

`Field` is a commutative, nontrivial field law contract over field
operations: $0 \ne 1$, and every non-zero element has an inverse.

```mbti
pub(open) trait Field : FieldOps {
  field_law() -> Law[FieldTh, Self]
}
```

An implementor must satisfy the `Ring` laws and, for all $a, b$:

$$
0 \ne 1, \qquad ab = ba, \qquad a \cdot a^{-1} = 1 \ \text{ for } a \neq 0, \qquad
a / b = a \cdot b^{-1} \ \text{ for } b \neq 0.
$$

Nontriviality and commutativity are part of the contract, as in the
mathematical definition of a field. The compiler checks neither: the
one-element zero ring satisfies the inverse law vacuously, and a type whose
multiplication does not commute but has inverses (a division ring) also
compiles as a `Field`. Generic code can then give wrong answers; for example,
it may rewrite $(ab)^{-1}$ as $a^{-1}b^{-1}$. Do not implement `Field` for
either type. The [core design](../design/core.md) explains the distinction.

`Float` and `Double` provide field operations but no `FieldTh` certificate.
Their `inv` aborts on `0`, while their `/` follows IEEE 754 and returns an
infinity or NaN.

```moonbit
fn[F : FieldOps] mean(xs : Array[F]) -> F {
  let mut total : F = Zero::zero()
  let mut count : F = Zero::zero()
  for x in xs {
    total = total + x
    count = count + One::one()
  }
  total / count
}

test "field" {
  inspect(mean([1.0, 2.0, 4.5]), content="2.5")
}
```

### `NumOps`

`NumOps` provides absolute value and sign operations without claiming exact
ring laws. The old `Num` trait is removed.

```mbti
pub(open) trait NumOps : RingOps {
  fn abs(Self) -> Self
  fn signum(Self) -> Self
}
```

`signum(x)` is $-1$, $0$ or $1$ according to the sign of $x$, and

$$
\operatorname{abs}(x) \cdot \operatorname{signum}(x) = x.
$$

Implemented by signed integers, `BigInt`, `Float` and `Double`. On a
fixed-width type the identity fails at the most negative value, whose absolute
value wraps back to itself. On `Float` and `Double`, `signum` returns its
argument for `0.0`, `-0.0` and NaN. This operation bundle does not imply a
`RingTh` law.

```moonbit
test "num operations" {
  inspect(NumOps::signum(-7), content="-1")
  inspect(NumOps::abs(-7) * NumOps::signum(-7), content="-7")
}
```

## Integer conversions

### `FromNat`

`FromNat::from_natural(n)` converts a non-negative `BigInt` value to
`Self`. The operation alone does not certify that the conversion preserves
semiring operations.

```mbti
pub(open) trait FromNat {
  fn from_natural(@bigint.BigInt) -> Self
}
```

Precondition: $n \ge 0$. Exact preservation is a separate law claim;
rounded conversions are ordinary operations only.

Fixed-width integers reduce modulo $2^k$; `Float` and `Double` round to the
nearest value, ties to even, as described under `FromInteger` below.

### `FromInteger`

`FromInteger::from_integer(n)` converts a `BigInt` value to `Self`. It
does not construct a strict Hom certificate.

```mbti
pub(open) trait FromInteger : FromNat {
  fn from_integer(@bigint.BigInt) -> Self
}
```

It is defined for every integer, also on types without negation: on an
unsigned type, `from_integer(-1)` is
$2^k - 1$. Exact for `BigInt`, reduction modulo $2^k$ for fixed-width
integers, rounding for `Float` and `Double`.

For `Float` and `Double`, `from_integer(n)` is the IEEE 754 conversion
convertFromInt: $n$ rounded to the nearest value with $p$ significant bits,
$p = 24$ for `Float` and $p = 53$ for `Double`, ties to the even
significand. Integers with $|n| \le 2^p$ are exact. When the rounded value
is larger than the largest finite number, the result is $\pm\infty$; the
conversion never aborts:

| Target | Exact up to | Result is $\pm\infty$ when |
| --- | --- | --- |
| `Float` | $\lvert n \rvert \le 2^{24}$ | $\lvert n \rvert \ge 2^{128} - 2^{103}$ |
| `Double` | $\lvert n \rvert \le 2^{53}$ | $\lvert n \rvert \ge 2^{1024} - 2^{970}$ |

Zero gives $+0$. The [core design](../design/core.md) derives the rounding
rule and the thresholds.

```moonbit
test "from_integer" {
  let big = BigInt::from_string("4294967301") // 2^32 + 5
  let i : Int = FromInteger::from_integer(big)
  let u : UInt = FromInteger::from_integer(BigInt::from_int(-1))
  let d : Double = FromInteger::from_integer(big)
  inspect(i, content="5")
  inspect(u, content="4294967295")
  inspect(d, content="4294967301")
}
```

```moonbit
test "from_integer into Double rounds and overflows" {
  let two53 = BigInt::from_int(1) << 53
  // 2^53 + 1 lies halfway between 2^53 and 2^53 + 2; the tie goes to 2^53.
  let tie : Double = FromInteger::from_integer(two53 + BigInt::from_int(1))
  let huge : Double = FromInteger::from_integer(BigInt::from_int(1) << 1024)
  let tiny : Double = FromInteger::from_integer(-(BigInt::from_int(1) << 1024))
  inspect(tie == 9007199254740992.0, content="true")
  inspect(huge, content="Infinity")
  inspect(tiny, content="-Infinity")
}
```

To give your own number type these conversions, implement both traits; the
[core tutorial](../tutorial/core.md) shows how.

## Integer types

### `Integral`

`Integral` is an integer type: ℤ itself, or a quotient ℤ/2^k such as a
fixed-width integer.

```mbti
pub(open) trait Integral : Semiring + FromInteger {
  fn normalize(Self) -> @bigint.BigInt
}
```

`normalize(x)` returns the representative of `x` as a `BigInt`. The law is
that `normalize` is a section of the canonical map:

$$
\texttt{Self::from\_integer}(\operatorname{normalize}(x)) = x .
$$

The shipped instances pick $[-2^{k-1}, 2^{k-1})$ for signed types,
$[0, 2^k)$ for unsigned ones, and the identity for `BigInt`. `normalize` is
a homomorphism only for `BigInt`; on fixed-width types it is not, because
their arithmetic wraps. `Section::of_integral` packages the pair as a
certificate that can be checked.

```moonbit
test "normalize" {
  inspect(Integral::normalize(-1), content="-1")
  inspect(Integral::normalize(4294967295U), content="4294967295")
  inspect(Integral::normalize(2147483647 + 1), content="-2147483648")
}
```

### `Nat`

`Nat` is an `Integral` type whose representatives are non-negative:
$\operatorname{normalize}(x) \ge 0$ for every `x`.

```mbti
pub(open) trait Nat : Integral {
}
```

Implemented by `UInt`, `UInt16` and `UInt64`. An arbitrary-precision ℕ is
not a quotient of ℤ and therefore cannot be `Integral`; see the
[core design](../design/core.md).

```moonbit
fn[N : Nat] digits(x : N) -> Int {
  Integral::normalize(x).to_string().length()
}

test "nat" {
  inspect(digits((65535 : UInt16)), content="5")
}
```

### `lift_to`

`lift_to(x)` lifts an integral value to its representative and maps it into
any `FromInteger` target.

```mbti
pub fn[S : Integral, R : FromInteger] lift_to(S) -> R
```

It is `R::from_integer(x.normalize())`. It is a function, not a
homomorphism: it converts the value `x` holds now, so a sum that has already
wrapped in `S` stays wrapped. It preserves the operations exactly when the
modulus of `R` divides that of `S`, as for `Int64 -> Int`; the
[core design](../design/core.md) derives this condition.

```moonbit
test "lift_to" {
  let a : Double = lift_to(-7)
  let b : BigInt = lift_to(4294967295U)
  let c : Int = lift_to(4294967301L) // truncation, a homomorphism
  inspect(a, content="-7")
  inspect(b, content="4294967295")
  inspect(c, content="5")
}
```

## Shipped capabilities and laws

| Type | Operation capabilities | Exact law instances |
| --- | --- | --- |
| `Int`, `Int16`, `Int64` | `AddMonoidOps`, `MulMonoidOps`, `AddGroupOps`, `SemiringOps`, `RingOps`, `NumOps` | `AddMonoid`, `MulMonoid`, `AddGroup`, `Semiring`, `Ring`, `CommRing` |
| `UInt`, `UInt16`, `UInt64` | `AddMonoidOps`, `MulMonoidOps`, `SemiringOps` | `AddMonoid`, `MulMonoid`, `Semiring`, `Nat` |
| `BigInt` | signed integer operation capabilities and `NumOps` | `AddMonoid`, `MulMonoid`, `AddGroup`, `Semiring`, `Ring`, `CommRing`, `IntegralDomain` |
| `Float`, `Double` | `AddMonoidOps`, `MulMonoidOps`, `AddGroupOps`, `MulGroupOps`, `SemiringOps`, `RingOps`, `FieldOps`, `NumOps`, `RoundedArithmetic` | none |

`Byte` implements none of them.

## Semantic notes

- Fixed-width integers are ℤ/2^k. Their `from_integer` reduces modulo 2^k, and
  `normalize` picks the representative in the type's range: `[-2^(k-1),
  2^(k-1))` for signed types, `[0, 2^k)` for unsigned ones.
- `BigInt` is ℤ itself: `from_integer` and `normalize` are the identity.
- `lift_to` is a homomorphism exactly when the target modulus divides the
  source modulus, as for `Int64 -> Int`. Into `BigInt`, `Float` or `Double` it
  is not one for fixed-width sources, because their arithmetic wraps.
- `Nat` covers the integral types whose representatives are non-negative. A
  true arbitrary-precision ℕ is not a quotient of ℤ and is out of scope.
- Unsigned integer instances stop at `Semiring`; they do not pretend to be
  additive groups or rings.
- `Float` and `Double` round to nearest, ties to even, in `from_natural` and
  `from_integer`, so very large values are approximate, and values beyond the
  largest finite number become $\pm\infty$ instead of aborting.
- A returned `Law[Th, Self]` is an explicit assumption; the compiler does
  not prove its equations. Float and Double do not receive exact field laws.

## Deprecated

### `NatHomomorphism`

`NatHomomorphism::from_nat(x)` lifts a `Nat` value to its representative and
maps it into `Self`.

```mbti
pub(open) trait NatHomomorphism {
  fn[S : Nat] from_nat(S) -> Self
}
```

Deprecated because the composite is not a homomorphism for fixed-width
sources. Replacement: implement `FromNat` and `FromInteger`, and call
`lift_to(x)`. Still implemented by `BigInt`, `Float` and `Double`.

### `IntegralHomomorphism`

`IntegralHomomorphism::from_integral(x)` lifts an `Integral` value to its
representative and maps it into `Self`.

```mbti
pub(open) trait IntegralHomomorphism : NatHomomorphism {
  fn[S : Integral] from_integral(S) -> Self
}
```

Deprecated for the same reason. Replacement: implement `FromInteger` and
call `lift_to(x)`. Still implemented by `BigInt`, `Float` and `Double`.

## Source map

- `src/structure.mbt`: trait definitions
- `src/operation.mbt`: operational traits
- `src/section.mbt`: `lift_to`
- `src/impl_signed.mbt`, `src/impl_unsigned.mbt`, `src/impl_bigint.mbt`,
  `src/impl_float.mbt`, `src/impl_dbl.mbt`: default instances
