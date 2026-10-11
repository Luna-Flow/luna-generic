///|
test "Ring law cannot be weakened to a commutative ring law" {
  let ring_law : @lf_alg.Law[@lf_alg.RingTh, Int] = @lf_alg.Ring::ring_law()
  let _comm_law : @lf_alg.Law[@lf_alg.CommRingTh, Int] =
    @lf_alg.Law::field_to_comm_ring(ring_law)
}
