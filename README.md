# Luna-Generic

General algebraic traits and default numeric instances for Luna projects.

## Exports

- Traits: `AddMonoid`, `MulMonoid`, `AddGroup`, `MulGroup`, `Semiring`, `Ring`, `Field`, `Integral`, `Nat`, `Num`
- Operations: `One`, `Zero`, `Inverse`, `Conjugate`
- Default numeric types: `Int`, `Int16`, `Int64`, `UInt`, `UInt16`, `UInt64`, `Float`, `Double`

## Integer Families

- `Nat` covers pure unsigned integer types: `UInt`, `UInt16`, `UInt64`
- `Integral` covers signed and unsigned integers: `Int`, `Int16`, `Int64`, `UInt`, `UInt16`, `UInt64`
- `Byte` is intentionally excluded from both traits

Unsigned integer instances stop at `Semiring`. They do not implement `AddGroup`, `Ring`, or `Num`.

## Floating-Point Embeddings

`Integral::to_float` and `Integral::to_double` provide embeddings into floating-point types.

- `Float` preserves integer values and semiring structure only within its exact integer range, i.e. absolute values up to `2^24`
- `Double` preserves integer values and semiring structure only within its exact integer range, i.e. absolute values up to `2^53`

## Conversion Safety

Here "absolutely safe" means every value of the source integral type is represented exactly in the target floating-point type, so small algebraic laws over integer values remain intact after conversion.

### `Integral::to_float`

Absolutely safe:

- `Int16 -> Float`
- `UInt16 -> Float`

Risky, user must pay attention:

- `Int -> Float`
- `UInt -> Float`
- `Int64 -> Float`
- `UInt64 -> Float`

For these risky conversions, values outside the exact integer range `[-2^24, 2^24]` may be rounded. The result is still finite for these integral types, but it may no longer preserve exact integer equality, addition, or multiplication.

### `Integral::to_double`

Absolutely safe:

- `Int16 -> Double`
- `UInt16 -> Double`
- `Int -> Double`
- `UInt -> Double`

Risky, user must pay attention:

- `Int64 -> Double`
- `UInt64 -> Double`

For these risky conversions, values outside the exact integer range `[-2^53, 2^53]` may be rounded. The result is still finite for these integral types, but it may no longer preserve exact integer equality, addition, or multiplication.

If exactness matters, keep computations in the integral domain until the final step, or explicitly restrict inputs to the exact range of the target floating-point type.

## Testing

Run `moon check` to validate trait impls and package metadata.
