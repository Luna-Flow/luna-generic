# core design

## Design goal

`luna-generic` gives LunaFlow a shared algebraic vocabulary. Packages such as
`arithmetic`, `luna-complex`, `linear-algebra`, and `luna-poly` should be able
to describe their requirements in terms of reusable traits instead of inventing
their own incompatible capability layers.

## Main design decisions

- The trait graph is layered and intentionally small.
- Structural traits such as `Ring`, `Field`, `Integral`, and `Nat` are kept
  separate from operational traits such as `Zero`, `One`, `Inverse`, and
  `Conjugate`.
- Conversions are split into two halves that meet at ℤ, represented by
  `BigInt`. The target side is the canonical map ℤ -> `R` (`FromInteger`),
  which is unique and always a homomorphism. The source side is
  `Integral::normalize`, which picks a representative and is a homomorphism
  only for ℤ itself. `lift_to` composes them and promises nothing about
  operations.
- The halves are single-parameter traits because every conversion factors
  through ℤ, the initial ring: no trait has to relate two types.
- `Integral` extends `FromInteger` with the law
  `from_integer(normalize(x)) == x`, which makes an integral type a quotient
  of ℤ with chosen representatives. `FromInteger` takes a `BigInt` rather than
  a generic integral source, so the traits do not refer to each other.
- Unsigned types stop before additive inverse, so the abstraction stays
  mathematically honest.
- `Field` means a commutative field. Its laws, like those of every structural
  trait, are a contract on the implementor, not something the compiler
  checks.

## Mathematical background

Each structural trait is the signature of an algebraic structure, and the
structure's axioms are the laws an instance promises. With $x, y, z$ ranging
over the carrier:

| Trait | Structure | Laws added to its supertraits |
| --- | --- | --- |
| `AddMonoid` | monoid $(A, +, 0)$ | $(x+y)+z = x+(y+z)$, $0+x = x+0 = x$ |
| `MulMonoid` | monoid $(A, \cdot, 1)$ | $(xy)z = x(yz)$, $1x = x1 = x$ |
| `AddGroup` | group $(A, +, 0, -)$ | $x + (-x) = (-x) + x = 0$ |
| `MulGroup` | group $(A, \cdot, 1, {}^{-1})$ | $x x^{-1} = x^{-1} x = 1$ |
| `Semiring` | semiring | $x+y = y+x$, $x(y+z) = xy+xz$, $(x+y)z = xz+yz$, $0x = x0 = 0$ |
| `Ring` | ring | the `AddGroup` laws |
| `Field` | field | $xy = yx$, $x x^{-1} = 1$ for $x \neq 0$, $x/y = x y^{-1}$ |

The supertrait graph mirrors the inclusions between the structures: every
ring is a semiring, every semiring is both an additive and a multiplicative
monoid, and so on. A function bounded by `T : Ring` may use exactly the
consequences of the ring axioms, which is what makes the generic code
correct for every instance.

A homomorphism $\varphi : A \to B$ of such structures preserves every
operation of the signature:

$$
\varphi(0) = 0, \quad \varphi(1) = 1, \quad
\varphi(x + y) = \varphi(x) + \varphi(y), \quad
\varphi(xy) = \varphi(x)\varphi(y).
$$

## Integers as quotients of ℤ

This section gives the mathematics behind `FromNat`, `FromInteger`,
`Integral` and `lift_to`. The [core tutorial](../tutorial/core.md) shows how
to use them without it.

### The canonical map is unique

For every ring `R` there is exactly one ring homomorphism `ℤ -> R`. A ring
homomorphism `φ` must send `1` to `1`, and additivity then forces
`φ(n) = 1 + ... + 1` (`n` times) for `n > 0` and `φ(-n) = -φ(n)`. Conversely,
`n ↦ n·1` preserves `+` and `*` by distributivity. The same argument gives
exactly one semiring homomorphism `ℕ -> R` for every semiring `R`. In
categorical terms ℕ and ℤ are initial objects.

The derivation in full, first for ℕ. Let $R$ be a semiring and define
$\varphi : \mathbb{N} \to R$ by recursion:

$$
\varphi(0) = 0, \qquad \varphi(n + 1) = \varphi(n) + 1 .
$$

Additivity, by induction on $n$ (associativity of $+$ in $R$):

$$
\begin{aligned}
\varphi(m + 0) &= \varphi(m) = \varphi(m) + \varphi(0), \\
\varphi(m + (n+1)) &= \varphi((m + n) + 1) = \varphi(m + n) + 1 \\
&= (\varphi(m) + \varphi(n)) + 1 = \varphi(m) + \varphi(n + 1).
\end{aligned}
$$

Multiplicativity, by induction on $n$ (absorption $x \cdot 0 = 0$, additivity,
distributivity):

$$
\begin{aligned}
\varphi(m \cdot 0) &= 0 = \varphi(m) \cdot 0 = \varphi(m)\varphi(0), \\
\varphi(m(n+1)) &= \varphi(mn + m) = \varphi(m)\varphi(n) + \varphi(m) \\
&= \varphi(m)(\varphi(n) + 1) = \varphi(m)\varphi(n + 1).
\end{aligned}
$$

Uniqueness: any semiring homomorphism $\psi$ satisfies $\psi(0) = 0$ and
$\psi(n + 1) = \psi(n) + \psi(1) = \psi(n) + 1$, the same recursion, so
$\psi = \varphi$ by induction.

For ℤ, let $R$ be a ring. Every integer is a difference $a - b$ of naturals;
put $\hat\varphi(a - b) = \varphi(a) - \varphi(b)$. This is well defined,
because $a - b = c - d$ means $a + d = b + c$ in ℕ, hence
$\varphi(a) + \varphi(d) = \varphi(b) + \varphi(c)$ in $R$, and adding
$-\varphi(b) - \varphi(d)$ to both sides (with $+$ commutative) gives
$\varphi(a) - \varphi(b) = \varphi(c) - \varphi(d)$. It is additive term by
term, and multiplicative by distributivity:

$$
\begin{aligned}
\hat\varphi((a - b)(c - d)) &= \hat\varphi((ac + bd) - (ad + bc)) \\
&= \varphi(a)\varphi(c) + \varphi(b)\varphi(d) - \varphi(a)\varphi(d) - \varphi(b)\varphi(c) \\
&= (\varphi(a) - \varphi(b))(\varphi(c) - \varphi(d)).
\end{aligned}
$$

A ring homomorphism must also satisfy $\psi(-n) = -\psi(n)$, so it agrees
with $\hat\varphi$ on negatives too, and $\hat\varphi$ is unique.[^initial]

[^initial]: In the language of category theory, ℕ is the initial object of
the category of semirings and ℤ that of rings. ℤ is the Grothendieck group of
the additive monoid ℕ, which is the construction used above.

Because the map depends only on `R`, it is a property of the target and fits
a single-parameter trait: `FromNat::from_natural` and
`FromInteger::from_integer`.

### Fixed-width integers

`Int` adds and multiplies modulo 2^32, so as a ring it is ℤ/2^32. Its
`from_integer` is the reduction `ℤ -> ℤ/2^32`, which is surjective.
`normalize` goes the other way and picks one integer in every residue class,
the one in `[-2^31, 2^31)`. The law `from_integer(normalize(x)) == x` says
exactly that `normalize` is a section of the reduction:

- `normalize` is injective, because it has a left inverse.
- Its image contains exactly one element of every class: at most one because
  it is injective, and at least one because of the law.
- It is not a homomorphism: `normalize(2147483647 + 1) = -2^31`, while
  `normalize(2147483647) + normalize(1) = 2^31`.

In symbols, with $m = 2^k$ and $\pi : \mathbb{Z} \to \mathbb{Z}/m$ the
reduction, whose kernel is $m\mathbb{Z}$, the shipped instances use

$$
s_{\text{signed}}(\pi(n)) = \bigl((n + 2^{k-1}) \bmod 2^k\bigr) - 2^{k-1},
\qquad
s_{\text{unsigned}}(\pi(n)) = n \bmod 2^k,
$$

with $\bmod$ taking values in $[0, 2^k)$. Both are well defined, since $n$
and $n + jm$ give the same value, and both satisfy $\pi(s(x)) = x$, since
each differs from $n$ by a multiple of $m$. The two injectivity steps
above, written out:

$$
s(x) = s(y) \;\Longrightarrow\; x = \pi(s(x)) = \pi(s(y)) = y .
$$

The failure of additivity is a multiple of the modulus:

$$
s(x) + s(y) - s(x + y) \in m\mathbb{Z},
\qquad\text{because}\qquad
\pi\bigl(s(x) + s(y)\bigr) = x + y = \pi\bigl(s(x + y)\bigr).
$$

For $x = 2^{31} - 1$ and $y = 1$ on `Int` the difference is $2^{32}$, so no
choice of representatives can repair it: $s$ is a homomorphism only when
$m = 0$, that is for `BigInt`.

The [hom design](hom.md) shows what a section does preserve.

### When a conversion is a homomorphism

`lift_to : S -> R` is `R::from_integer` composed with `S::normalize`. When
`S` is ℤ/m (with `m = 0` for `BigInt`), a ring homomorphism `ℤ/m -> R` exists
if and only if `m·1 = 0` in `R`:

- If `ψ` is one, then `0 = ψ(0) = ψ(m·1) = m·1` in `R`.
- If `m·1 = 0`, the canonical map `ℤ -> R` sends `mℤ` to `0` and so factors
  through ℤ/m. It is unique because `ℤ -> ℤ/m` is surjective.

In that case `lift_to` is this homomorphism: write the canonical map
`ℤ -> R` as `ψ ∘ π` with `π : ℤ -> ℤ/m`; then
`lift_to = ψ ∘ π ∘ normalize = ψ`. So:

- `Int64 -> Int` is a homomorphism, because `2^64 ≡ 0 (mod 2^32)`.
- `Int -> Int64` is not, because `2^32 ≢ 0 (mod 2^64)`.
- No fixed-width integer maps homomorphically into `BigInt`, `Float` or
  `Double`, where `m·1 ≠ 0` for every `m > 0`.

The same argument as one chain, with $\iota_R : \mathbb{Z} \to R$ the
canonical map and $\iota_R = \psi \circ \pi$ when $m \cdot 1_R = 0$:

$$
\texttt{lift\_to} = \iota_R \circ s = \psi \circ \pi \circ s =
\psi \circ \mathrm{id}_{\mathbb{Z}/m} = \psi .
$$

For the two modulus examples, $2^{64} \cdot 1 = 2^{32} \cdot (2^{32} \cdot 1)
= 2^{32} \cdot 0 = 0$ in ℤ/2^32, while $2^{32} \cdot 1 \neq 0$ in ℤ/2^64
because $0 < 2^{32} < 2^{64}$.

### Why unsigned types stop at `Semiring`

`UInt`, `UInt16` and `UInt64` are read as natural numbers that wrap: `Nat`
promises non-negative representatives, and code over them treats values as
counts and sizes. ℕ has no additive inverses, so it is a semiring and not a
ring:

$$
1 + x = 0 \text{ in } \mathbb{N} \;\Longrightarrow\; 0 = 1 + x \geq 1,
$$

a contradiction. As an abstract ring the unsigned type is ℤ/2^k, which does
have negatives, $-x = 2^k - x$. Exposing them would make `-1` silently mean
$2^k - 1$ in generic code written for rings, which is the confusion the
`Nat` reading avoids. The core library also provides no `Neg` for unsigned
types, and MoonBit does not let this package add an instance of a foreign
trait to a foreign type, so `AddGroup` could not be implemented without a
wrapper type anyway. The canonical map is still total: `from_integer(-1)` on
`UInt` is $2^{32} - 1$, the image of $-1$ in ℤ/2^32.

### Why the traits do not refer to each other

Every conversion factors through ℤ: `S -> ℤ -> R`. The first half depends
only on `S` (`Integral`), the second only on `R` (`FromInteger`), so neither
trait has to relate two types. `FromInteger` takes a `BigInt` rather than a
generic integral source, which lets `Integral` extend it without a cycle.

## Fields and division rings

`Field` is `Ring + Inverse + Div` with commutative multiplication. The
commutativity is part of the contract even though no method states it.

### Definitions

A *division ring* is a ring with $1 \neq 0$ in which every $a \neq 0$ has a
two-sided inverse, $a a^{-1} = a^{-1} a = 1$. A *field* is a division ring
whose multiplication commutes, $ab = ba$. The two differ only in that law,
and the method signatures of `Ring + Inverse + Div` cannot tell them apart.

The standard example of a division ring that is not a field is Hamilton's
quaternions ℍ, with basis $1, i, j, k$ and
$i^2 = j^2 = k^2 = ijk = -1$. From $ijk = -1$, multiplying on the right by
$k$ gives $ij \cdot k^2 = -k$, so $ij = k$; similarly $ji = -k$:

$$
ij = k, \qquad ji = -k, \qquad ij \neq ji .
$$

### What breaks without commutativity

In any division ring the inverse of a product reverses the order:

$$
(ab)(b^{-1}a^{-1}) = a(bb^{-1})a^{-1} = a a^{-1} = 1,
\qquad\text{so}\qquad (ab)^{-1} = b^{-1}a^{-1}.
$$

The other order is the inverse of the other product,
$a^{-1}b^{-1} = (ba)^{-1}$, and inversion is injective, so

$$
(ab)^{-1} = a^{-1}b^{-1} \iff (ab)^{-1} = (ba)^{-1} \iff ab = ba .
$$

In ℍ, $(ij)^{-1} = k^{-1} = -k$, while
$i^{-1} j^{-1} = (-i)(-j) = ij = k$. Division is ambiguous in the same way:
$a b^{-1}$ and $b^{-1} a$ are different elements in general, and `Div`
provides only one of them.

Generic code bounded by `F : Field` may rely on $ab = ba$: rewrite
$(ab)^{-1}$ as $a^{-1}b^{-1}$, compute $a/b \cdot c$ as $ac/b$, or reorder
products to save work. A non-commutative type that implemented `Field`
would compile and then get wrong answers from such code. That is why the
trait states commutativity, and why a division ring that is not a field must
not implement it. Generic code that also works for division rings asks for
`Ring + Inverse + Div` and keeps the order of its factors.

Every finite division ring is commutative,[^wedderburn] so the distinction
only arises for infinite types.

[^wedderburn]: Wedderburn's little theorem (1905): a finite division ring is
a field. Over the reals, Frobenius' theorem (1877) adds that the only
finite-dimensional associative division algebras are ℝ, ℂ and ℍ.

### Floating-point instances

`Float` and `Double` implement `Field` up to rounding. Their multiplication
is commutative exactly, $\mathrm{fl}(ab) = \mathrm{fl}(ba)$, because IEEE 754
rounds the exact product, which does not depend on the order. Associativity
and distributivity hold only approximately, and `0` has no inverse: `inv`
aborts on it.

## Alternatives rejected

- A two-parameter conversion trait `Into[S, R]`: MoonBit traits have only
  `Self`, and the factorization through ℤ makes it unnecessary.
- One broad "number" trait: it would hide the difference between ℤ, ℤ/2^k,
  approximate reals and fields, which are exactly the differences generic
  code has to respect.
- `NatHomomorphism` and `IntegralHomomorphism` as the conversion interface:
  they promised a homomorphism that a fixed-width source cannot give. They
  remain only as deprecated traits.
- A separate division-ring trait: no shipped type needs it, and code that
  must work without commutativity can ask for `Ring + Inverse + Div`.

## Boundaries

- This package does not define matrices, complex numbers, polynomials, parsing,
  or numerical algorithms.
- It does not erase the semantic difference between exact and approximate
  number systems.
- It does not check laws at compile time. The laws of every structural
  trait, including the commutativity of `Field`, are contracts on the
  implementor, tested with the tools of the [hom API](../api/hom.md).
- It does not model an arbitrary-precision ℕ: such a type is not a quotient
  of ℤ, so it cannot be `Integral`.
