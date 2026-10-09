// Correctly rounded conversion of a `BigInt` to a binary floating-point
// format (IEEE 754-2019 §5.4.1 convertFromInt, roundTiesToEven, §7.4
// overflow to ±inf).
//
// Only `bit_length`, `>>`, `<<`, `to_uint64`, negation and comparisons of
// `BigInt` are used. The audit of moonbitlang/core 0.10.14 found these
// identical on native, wasm, wasm-gc and js. The cost is O(len) in the size
// of the argument, and no decimal string is built.

///|
/// Rounds a positive integer `m` to `p` significant bits, ties to even.
///
/// `n` must be `m.bit_length()`, so that `2^(n-1) <= m < 2^n`, and
/// `1 <= p <= 62`. Returns `(e, q)` with `2^(p-1) <= q < 2^p` and
///
///   RNE_p(m) = q * 2^(e - p + 1),
///
/// so `e` is the unbiased binary exponent of the rounded value. The result is
/// never subnormal: integers below `2^p` are exact.
///
/// Proof. Let `s = n - p - 1`, `t = floor(m / 2^s)` and `r = m - t * 2^s`
/// when `s >= 0` (so `0 <= r < 2^s`); when `s < 0` let `t = m * 2^(-s)` and
/// `r = 0`, which is exact. In both cases `2^p <= t < 2^(p+1)`, so `t` has
/// exactly `p + 1` bits. Write `t = 2q + b` with `b` in {0, 1}. Then
///
///   m = (q + f) * 2^(s+1),  f = b/2 + r/2^(s+1),  0 <= f < 1,
///
/// with `2^(p-1) <= q < 2^p`. The two candidates are `q` and `q + 1` (times
/// `2^(s+1)`), and round-to-nearest-even picks `q + 1` exactly when
/// `f > 1/2`, or `f = 1/2` and `q` is odd. Since `r/2^(s+1) < 1/2`:
/// `f > 1/2` iff `b = 1` and `r != 0`; `f = 1/2` iff `b = 1` and `r = 0`;
/// otherwise `f < 1/2`. That is the test below, with `sticky = (r != 0)`
/// computed as `(t << s) != m`. If rounding up gives `q + 1 = 2^p`, the value
/// is `2^(p-1) * 2^(s+2)`, so the significand is renormalized and the
/// exponent grows by one. Without carry `e = (p - 1) + (s + 1) = n - 1`; with
/// carry `e = n`.
fn round_magnitude(m : BigInt, n : Int, p : Int) -> (Int, UInt64) {
  let (t, sticky) = if n <= p + 1 {
    // m < 2^(p+1) <= 2^63: to_uint64 is exact and the shift loses nothing.
    (m.to_uint64() << (p + 1 - n), false)
  } else {
    let s = n - p - 1
    let hi = m >> s
    // hi < 2^(p+1), so to_uint64 is exact.
    (hi.to_uint64(), hi << s != m)
  }
  let q = t >> 1
  let round_up = (t & 1UL) == 1UL && (sticky || (q & 1UL) == 1UL)
  let q = if round_up { q + 1UL } else { q }
  if q == 1UL << p {
    (n, q >> 1)
  } else {
    (n - 1, q)
  }
}

///|
/// 2^1024: every finite `Double` is below it.
let double_overflow_bound : BigInt = BigInt::from_int(1) << 1024

///|
/// 2^128: every finite `Float` is below it.
let float_overflow_bound : BigInt = BigInt::from_int(1) << 128

///|
/// The `Double` nearest to `a`, ties to even; ±inf when the rounded value
/// exceeds the largest finite `Double`, i.e. for |a| >= 2^1024 - 2^970.
fn double_from_bigint(a : BigInt) -> Double {
  let negative = a < 0N
  let m = if negative { -a } else { a }
  let sign = if negative { 1UL << 63 } else { 0UL }
  if m == 0N {
    return 0.0
  }
  // A finite Double is below 2^1024, so m >= 2^1024 always overflows. This
  // is decided by comparison before `bit_length` is called, because
  // `bit_length` returns an `Int` that wraps for values of 2^31 bits or more.
  let inf = sign | 0x7FF0000000000000UL
  if m >= double_overflow_bound {
    return inf.reinterpret_as_double()
  }
  // 0 < m < 2^1024, so `bit_length` is the exact bit count, in [1, 1024].
  let n = m.bit_length()
  let (e, q) = round_magnitude(m, n, 53)
  // e >= 0 here, so the value is normal. emax = 1023.
  if e > 1023 {
    return inf.reinterpret_as_double()
  }
  // Biased exponent e + 1023 in [1023, 2046]; q has its leading bit at
  // position 52, which the encoding leaves implicit.
  let bits = sign | ((e + 1023).to_uint64() << 52) | (q & 0x000FFFFFFFFFFFFFUL)
  bits.reinterpret_as_double()
}

///|
/// The `Float` nearest to `a`, ties to even; ±inf when the rounded value
/// exceeds the largest finite `Float`, i.e. for |a| >= 2^128 - 2^103.
///
/// The rounding is done once, directly at 24 bits. Rounding to `Double` first
/// and then to `Float` would round twice and can be one ulp off, e.g. for
/// 2^53 + 2^29 + 1.
fn float_from_bigint(a : BigInt) -> Float {
  let negative = a < 0N
  let m = if negative { -a } else { a }
  let sign = if negative { 1U << 31 } else { 0U }
  if m == 0N {
    return 0.0
  }
  // A finite Float is below 2^128; see `double_from_bigint`.
  let inf = sign | 0x7F800000U
  if m >= float_overflow_bound {
    return Float::reinterpret_from_uint(inf)
  }
  // 0 < m < 2^128, so `bit_length` is exact, in [1, 128].
  let n = m.bit_length()
  let (e, q) = round_magnitude(m, n, 24)
  // emax = 127.
  if e > 127 {
    return Float::reinterpret_from_uint(inf)
  }
  // Biased exponent e + 127 in [127, 254]; q < 2^24 fits in a UInt.
  let bits = sign |
    ((e + 127).reinterpret_as_uint() << 23) |
    (q.to_uint() & 0x007FFFFFU)
  Float::reinterpret_from_uint(bits)
}
