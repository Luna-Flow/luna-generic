type BoolAlg Bool

pub fn BoolAlg::not(self : BoolAlg) -> BoolAlg {
  not(self._)
}

pub fn BoolAlg::and(self : BoolAlg, other : BoolAlg) -> BoolAlg {
  self._ && other._
}

pub fn BoolAlg::or(self : BoolAlg, other : BoolAlg) -> BoolAlg {
  self._ || other._
}

pub fn BoolAlg::xor(self : BoolAlg, other : BoolAlg) -> BoolAlg {
  self.or(other).and(self.and(other).not())
}

pub fn BoolAlg::nand(self : BoolAlg, other : BoolAlg) -> BoolAlg {
  self.and(other).not()
}

pub fn BoolAlg::nor(self : BoolAlg, other : BoolAlg) -> BoolAlg {
  self.or(other).not()
}

pub fn BoolAlg::from_bool(b : Bool) -> BoolAlg {
  b
}

pub fn BoolAlg::to_bool(self : BoolAlg) -> Bool {
  self._
}