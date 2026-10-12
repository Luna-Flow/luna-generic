///|
struct Fake(Int)

///|
impl Add for Fake with fn add(_x, _y) { Fake(0) }

///|
impl Mul for Fake with fn mul(_x, _y) { Fake(0) }

///|
impl Neg for Fake with fn neg(_x) { Fake(0) }

///|
impl Sub for Fake with fn sub(_x, _y) { Fake(0) }

///|
impl @lf_alg.Zero for Fake with fn zero() { Fake(0) }

///|
impl @lf_alg.One for Fake with fn one() { Fake(1) }

///|
impl @lf_alg.AddMonoidOps for Fake

///|
impl @lf_alg.MulMonoidOps for Fake

///|
impl @lf_alg.AddGroupOps for Fake

///|
impl @lf_alg.SemiringOps for Fake

///|
impl @lf_alg.RingOps for Fake

///|
impl @lf_alg.Ring for Fake
