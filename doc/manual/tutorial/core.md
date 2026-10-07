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

## Use explicit target-side embeddings

```moonbit
fn[F : NatHomomorphism] embed_nat(x : UInt) -> F {
  NatHomomorphism::from_nat(x)
}
```

This keeps conversions explicit and avoids hidden assumptions in higher-level
packages.

Implement `NatHomomorphism` and `IntegralHomomorphism` by normalizing the
source into `BigInt` first, then performing the target-specific conversion.

## Practical guidance

- Choose the smallest trait set that expresses the algorithm you need.
- Require `Field` only when reciprocal or division semantics are really needed.
- Treat `Float` and `Double` as approximate backends even though they satisfy
  the same abstract surface as exact types.
