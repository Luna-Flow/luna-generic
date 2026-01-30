///|
pub impl One for Int with one() -> Int {
  1
}

///|
pub impl Zero for Int with zero() -> Int {
  0
}

///|
pub impl Num for Int with abs(a) -> Int {
  Int::abs(a)
}

///|
pub impl Num for Int with signum(a) -> Int {
  if a == 0 {
    0
  } else if a < 0 {
    -1
  } else {
    1
  }
}
