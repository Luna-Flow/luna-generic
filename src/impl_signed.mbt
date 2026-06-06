///|
pub impl AddMonoid for Int

///|
pub impl AddMonoid for Int16

///|
pub impl AddMonoid for Int64

///|
pub impl MulMonoid for Int

///|
pub impl MulMonoid for Int16

///|
pub impl MulMonoid for Int64

///|
pub impl AddGroup for Int

///|
pub impl AddGroup for Int16

///|
pub impl AddGroup for Int64

///|
pub impl Semiring for Int

///|
pub impl Semiring for Int16

///|
pub impl Semiring for Int64

///|
pub impl Ring for Int

///|
pub impl Ring for Int16

///|
pub impl Ring for Int64

///|
pub impl Integral for Int

///|
pub impl Integral for Int16

///|
pub impl Integral for Int64

///|
pub impl Integral for Int with fn normalize(a) -> BigInt {
  BigInt::from_int(a)
}

///|
pub impl Integral for Int16 with fn normalize(a) -> BigInt {
  BigInt::from_int64(a.to_int64())
}

///|
pub impl Integral for Int64 with fn normalize(a) -> BigInt {
  BigInt::from_int64(a)
}

///|
pub impl One for Int with fn one() -> Int {
  1
}

///|
pub impl One for Int16 with fn one() -> Int16 {
  (1 : Int16)
}

///|
pub impl One for Int64 with fn one() -> Int64 {
  1L
}

///|
pub impl Zero for Int with fn zero() -> Int {
  0
}

///|
pub impl Zero for Int16 with fn zero() -> Int16 {
  (0 : Int16)
}

///|
pub impl Zero for Int64 with fn zero() -> Int64 {
  0L
}

pub impl Num for Int with fn abs(a) -> Int {
  Int::abs(a)
}

///|
pub impl Num for Int16 with fn abs(a) -> Int16 {
  Int16::abs(a)
}

///|
pub impl Num for Int64 with fn abs(a) -> Int64 {
  Int64::abs(a)
}

///|
pub impl Num for Int with fn signum(a) -> Int {
  if a == 0 {
    0
  } else if a < 0 {
    -1
  } else {
    1
  }
}

///|
pub impl Num for Int16 with fn signum(a) -> Int16 {
  if a == 0 {
    (0 : Int16)
  } else if a < 0 {
    (-1 : Int16)
  } else {
    (1 : Int16)
  }
}

///|
pub impl Num for Int64 with fn signum(a) -> Int64 {
  if a == 0L {
    0L
  } else if a < 0L {
    -1L
  } else {
    1L
  }
}
