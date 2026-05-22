///|
pub impl AddMonoid for Int

///|
pub impl MulMonoid for Int

///|
pub impl AddGroup for Int

///|
pub impl Semiring for Int

///|
pub impl Ring for Int

///|
pub impl One for Int with fn one() -> Int {
  1
}

///|
pub impl Zero for Int with fn zero() -> Int {
  0
}

///|
pub impl Num for Int with fn abs(a) -> Int {
  Int::abs(a)
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
