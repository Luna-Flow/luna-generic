# Field-bound source inventory

Rechecked 2026-10-12. Audit clones are used only where their HEAD matches the queried remote main; current read-only clones replace changed linear-algebra and floating snapshots. Non-algebraic names such as FlowField are excluded. All backend variants remain in this raw inventory.

## linear-algebra @ e0cfa95c2c544c9d8d4b070a47e7f5bfa0ff3926

- `src/mutable/lu_internal_js.mbt:10`: `fn[T : Compare + Field + Num + Tolerance] Matrix::lu_decompose_internal(`
- `src/mutable/lu_internal_js.mbt:88`: `fn[T : Compare + Field + Num + Tolerance] LuDecomposition::solve_internal(`
- `src/mutable/lu_internal_js.mbt:136`: `fn[T : Compare + Field + Num + Tolerance] LuDecomposition::solve_identity_internal(`
- `src/mutable/matrix_wasm.mbt:1316`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::reduce_row_elimination(`
- `src/mutable/matrix_wasm.mbt:1368`: `fn[T : Compare + Field + Num + Tolerance] Matrix::power_method_seed(`
- `src/mutable/matrix_wasm.mbt:1392`: `fn[T : Compare + Field + Num + Tolerance] Matrix::initialize_power_method_vector(`
- `src/mutable/matrix_wasm.mbt:1687`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::rank(`
- `src/mutable/matrix_wasm.mbt:1898`: `pub fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::eigen(`
- `src/mutable/matrix_wasm.mbt:1920`: `fn[T : Compare + Field + Num + Sqrt + Tolerance] qr_algorithm(`
- `src/mutable/matrix_wasm.mbt:1938`: `fn[T : Compare + Field + Num + Sqrt + Tolerance] householder_tridiagonalize(`
- `src/mutable/matrix_wasm.mbt:2029`: `fn[T : Compare + Field + Num + Sqrt] symmetric_tridiagonal_eigen(`
- `src/mutable/matrix_wasm.mbt:2118`: `fn[T : Compare + Field + Num + Sqrt + Tolerance] qr_decomposition(`
- `src/mutable/matrix_wasm.mbt:2217`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::power_method(`
- `src/mutable/matrix_wasm.mbt:2360`: `fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::eigen_2x2(`
- `src/mutable/matrix_wasm.mbt:2485`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::determinant(`
- `src/mutable/matrix_wasm.mbt:2495`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::unchecked_determinant(`
- `src/mutable/matrix_wasm.mbt:2558`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::inverse(`
- `src/mutable/matrix_wasm.mbt:2577`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::unchecked_inverse(`
- `src/mutable/matrix_wasm.mbt:2643`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::is_invertible(`
- `src/mutable/matrix_wasm.mbt:2653`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::unchecked_is_invertible(`
- `src/mutable/matrix_wasm.mbt:2663`: `pub fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::cholesky_decomposition(`
- `src/mutable/matrix_wasm.mbt:2744`: `pub fn[T : Field] Matrix::mean(`
- `src/mutable/matrix_wasm.mbt:2758`: `pub fn[T : Field] Matrix::unchecked_mean(self : Matrix[T]) -> T {`
- `src/mutable/matrix_wasm.mbt:2787`: `pub fn[T : Field] Matrix::variance(`
- `src/mutable/matrix_wasm.mbt:2801`: `pub fn[T : Field] Matrix::unchecked_variance(self : Matrix[T]) -> T {`
- `src/mutable/matrix_wasm.mbt:2834`: `pub fn[T : Field + Sqrt] Matrix::std_dev(`
- `src/mutable/matrix_wasm.mbt:2848`: `pub fn[T : Field + Sqrt] Matrix::unchecked_std_dev(self : Matrix[T]) -> T {`
- `src/mutable/matrix_wasm.mbt:3011`: `pub fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::is_positive_definite(`
- `src/mutable/lu_internal_native.mbt:10`: `fn[T : Compare + Field + Num + Tolerance] Matrix::lu_decompose_internal(`
- `src/mutable/lu_internal_native.mbt:88`: `fn[T : Compare + Field + Num + Tolerance] LuDecomposition::solve_internal(`
- `src/mutable/lu_internal_native.mbt:136`: `fn[T : Compare + Field + Num + Tolerance] LuDecomposition::solve_identity_internal(`
- `src/mutable/matrix_js.mbt:1331`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::reduce_row_elimination(`
- `src/mutable/matrix_js.mbt:1387`: `fn[T : Compare + Field + Num + Tolerance] Matrix::power_method_seed(`
- `src/mutable/matrix_js.mbt:1411`: `fn[T : Compare + Field + Num + Tolerance] Matrix::initialize_power_method_vector(`
- `src/mutable/matrix_js.mbt:1706`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::rank(`
- `src/mutable/matrix_js.mbt:1933`: `pub fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::eigen(`
- `src/mutable/matrix_js.mbt:1967`: `fn[T : Compare + Field + Num + Sqrt + Tolerance] qr_algorithm(`
- `src/mutable/matrix_js.mbt:1985`: `fn[T : Compare + Field + Num + Sqrt + Tolerance] householder_tridiagonalize(`
- `src/mutable/matrix_js.mbt:2076`: `fn[T : Compare + Field + Num + Sqrt] symmetric_tridiagonal_eigen(`
- `src/mutable/matrix_js.mbt:2165`: `fn[T : Compare + Field + Num + Sqrt + Tolerance] qr_decomposition(`
- `src/mutable/matrix_js.mbt:2264`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::power_method(`
- `src/mutable/matrix_js.mbt:2407`: `fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::eigen_2x2(`
- `src/mutable/matrix_js.mbt:2532`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::determinant(`
- `src/mutable/matrix_js.mbt:2542`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::unchecked_determinant(`
- `src/mutable/matrix_js.mbt:2634`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::inverse(`
- `src/mutable/matrix_js.mbt:2653`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::unchecked_inverse(`
- `src/mutable/matrix_js.mbt:2719`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::is_invertible(`
- `src/mutable/matrix_js.mbt:2729`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::unchecked_is_invertible(`
- `src/mutable/matrix_js.mbt:2739`: `pub fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::cholesky_decomposition(`
- `src/mutable/matrix_js.mbt:2820`: `pub fn[T : Field] Matrix::mean(`
- `src/mutable/matrix_js.mbt:2834`: `pub fn[T : Field] Matrix::unchecked_mean(self : Matrix[T]) -> T {`
- `src/mutable/matrix_js.mbt:2863`: `pub fn[T : Field] Matrix::variance(`
- `src/mutable/matrix_js.mbt:2877`: `pub fn[T : Field] Matrix::unchecked_variance(self : Matrix[T]) -> T {`
- `src/mutable/matrix_js.mbt:2910`: `pub fn[T : Field + Sqrt] Matrix::std_dev(`
- `src/mutable/matrix_js.mbt:2924`: `pub fn[T : Field + Sqrt] Matrix::unchecked_std_dev(self : Matrix[T]) -> T {`
- `src/mutable/matrix_js.mbt:2967`: `fn[T : Compare + Field] normalize_diagonal_rref_js(matrix : Matrix[T]) -> Unit {`
- `src/mutable/matrix_js.mbt:3100`: `pub fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::is_positive_definite(`
- `src/mutable/lu_internal_wasm.mbt:10`: `fn[T : Compare + Field + Num + Tolerance] Matrix::lu_decompose_internal(`
- `src/mutable/lu_internal_wasm.mbt:88`: `fn[T : Compare + Field + Num + Tolerance] LuDecomposition::solve_internal(`
- `src/mutable/lu_internal_wasm.mbt:136`: `fn[T : Compare + Field + Num + Tolerance] LuDecomposition::solve_identity_internal(`
- `src/mutable/lu_internal_wasm_gc.mbt:10`: `fn[T : Compare + Field + Num + Tolerance] Matrix::lu_decompose_internal(`
- `src/mutable/lu_internal_wasm_gc.mbt:86`: `fn[T : Compare + Field + Num + Tolerance] LuDecomposition::solve_identity_internal(`
- `src/mutable/alias.mbt:9`: `trait Field,`
- `src/mutable/matrix_wasm_gc.mbt:1316`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::reduce_row_elimination(`
- `src/mutable/matrix_wasm_gc.mbt:1371`: `fn[T : Compare + Field + Num + Tolerance] Matrix::power_method_seed(`
- `src/mutable/matrix_wasm_gc.mbt:1395`: `fn[T : Compare + Field + Num + Tolerance] Matrix::initialize_power_method_vector(`
- `src/mutable/matrix_wasm_gc.mbt:1690`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::rank(`
- `src/mutable/matrix_wasm_gc.mbt:1901`: `pub fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::eigen(`
- `src/mutable/matrix_wasm_gc.mbt:1923`: `fn[T : Compare + Field + Num + Sqrt + Tolerance] qr_algorithm(`
- `src/mutable/matrix_wasm_gc.mbt:1941`: `fn[T : Compare + Field + Num + Sqrt + Tolerance] householder_tridiagonalize(`
- `src/mutable/matrix_wasm_gc.mbt:2032`: `fn[T : Compare + Field + Num + Sqrt] symmetric_tridiagonal_eigen(`
- `src/mutable/matrix_wasm_gc.mbt:2121`: `fn[T : Compare + Field + Num + Sqrt + Tolerance] qr_decomposition(`
- `src/mutable/matrix_wasm_gc.mbt:2220`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::power_method(`
- `src/mutable/matrix_wasm_gc.mbt:2363`: `fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::eigen_2x2(`
- `src/mutable/matrix_wasm_gc.mbt:2488`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::determinant(`
- `src/mutable/matrix_wasm_gc.mbt:2498`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::unchecked_determinant(`
- `src/mutable/matrix_wasm_gc.mbt:2561`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::inverse(`
- `src/mutable/matrix_wasm_gc.mbt:2580`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::unchecked_inverse(`
- `src/mutable/matrix_wasm_gc.mbt:2646`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::is_invertible(`
- `src/mutable/matrix_wasm_gc.mbt:2656`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::unchecked_is_invertible(`
- `src/mutable/matrix_wasm_gc.mbt:2666`: `pub fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::cholesky_decomposition(`
- `src/mutable/matrix_wasm_gc.mbt:2747`: `pub fn[T : Field] Matrix::mean(`
- `src/mutable/matrix_wasm_gc.mbt:2761`: `pub fn[T : Field] Matrix::unchecked_mean(self : Matrix[T]) -> T {`
- `src/mutable/matrix_wasm_gc.mbt:2790`: `pub fn[T : Field] Matrix::variance(`
- `src/mutable/matrix_wasm_gc.mbt:2804`: `pub fn[T : Field] Matrix::unchecked_variance(self : Matrix[T]) -> T {`
- `src/mutable/matrix_wasm_gc.mbt:2837`: `pub fn[T : Field + Sqrt] Matrix::std_dev(`
- `src/mutable/matrix_wasm_gc.mbt:2851`: `pub fn[T : Field + Sqrt] Matrix::unchecked_std_dev(self : Matrix[T]) -> T {`
- `src/mutable/matrix_wasm_gc.mbt:3014`: `pub fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::is_positive_definite(`
- `src/mutable/matrix_native.mbt:1331`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::reduce_row_elimination(`
- `src/mutable/matrix_native.mbt:1383`: `fn[T : Compare + Field + Num + Tolerance] Matrix::power_method_seed(`
- `src/mutable/matrix_native.mbt:1407`: `fn[T : Compare + Field + Num + Tolerance] Matrix::initialize_power_method_vector(`
- `src/mutable/matrix_native.mbt:1702`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::rank(`
- `src/mutable/matrix_native.mbt:1913`: `pub fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::eigen(`
- `src/mutable/matrix_native.mbt:1935`: `fn[T : Compare + Field + Num + Sqrt + Tolerance] qr_algorithm(`
- `src/mutable/matrix_native.mbt:1953`: `fn[T : Compare + Field + Num + Sqrt + Tolerance] householder_tridiagonalize(`
- `src/mutable/matrix_native.mbt:2044`: `fn[T : Compare + Field + Num + Sqrt] symmetric_tridiagonal_eigen(`
- `src/mutable/matrix_native.mbt:2133`: `fn[T : Compare + Field + Num + Sqrt + Tolerance] qr_decomposition(`
- `src/mutable/matrix_native.mbt:2232`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::power_method(`
- `src/mutable/matrix_native.mbt:2375`: `fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::eigen_2x2(`
- `src/mutable/matrix_native.mbt:2500`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::determinant(`
- `src/mutable/matrix_native.mbt:2510`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::unchecked_determinant(`
- `src/mutable/matrix_native.mbt:2603`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::inverse(`
- `src/mutable/matrix_native.mbt:2622`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::unchecked_inverse(`
- `src/mutable/matrix_native.mbt:2688`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::is_invertible(`
- `src/mutable/matrix_native.mbt:2698`: `pub fn[T : Compare + Field + Num + Tolerance] Matrix::unchecked_is_invertible(`
- `src/mutable/matrix_native.mbt:2708`: `pub fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::cholesky_decomposition(`
- `src/mutable/matrix_native.mbt:2789`: `pub fn[T : Field] Matrix::mean(`
- `src/mutable/matrix_native.mbt:2803`: `pub fn[T : Field] Matrix::unchecked_mean(self : Matrix[T]) -> T {`
- `src/mutable/matrix_native.mbt:2832`: `pub fn[T : Field] Matrix::variance(`
- `src/mutable/matrix_native.mbt:2846`: `pub fn[T : Field] Matrix::unchecked_variance(self : Matrix[T]) -> T {`
- `src/mutable/matrix_native.mbt:2879`: `pub fn[T : Field + Sqrt] Matrix::std_dev(`
- `src/mutable/matrix_native.mbt:2893`: `pub fn[T : Field + Sqrt] Matrix::unchecked_std_dev(self : Matrix[T]) -> T {`
- `src/mutable/matrix_native.mbt:3026`: `pub fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::is_positive_definite(`
- `src/perf_support/perf_support.mbt:3`: `using @lf_alg {trait AddMonoid, trait Field, trait Num}`
- `src/perf_support/perf_support.mbt:195`: `fn[T : AddMonoid + Field + Num] require_numeric_traits(value : T) -> T {`

## luna-complex @ 4d1b5ec0f0326593c56e53451d491d0648110c54

- `src/complex_traits.mbt:63`: `pub impl[T : Field] Div for Complex[T] with fn div(`
- `src/complex_traits.mbt:75`: `pub impl[T : Field] Inverse for Complex[T] with fn inv(self : Complex[T]) -> Complex[`
- `src/complex_traits.mbt:98`: `pub impl[T : Field] MulGroup for Complex[T]`
- `src/complex_traits.mbt:101`: `pub impl[T : Field] Field for Complex[T]`
- `src/alias.mbt:6`: `trait Field,`
- `src/float_backend/float_backend_traits.mbt:2`: `pub(open) trait FloatingAnalyticScalar: @luna-generic.Field + @luna-generic.Num + Compare + Constants + Sqrt + Exponential + Logarithmic + Trigonometric + InverseTrigonometric + Hyperbolic + InverseHyperbolic {`

## luna-generic @ 18a633c237cc4759d617e546b23d1c969f09a5b8

- `src/impl_float.mbt:20`: `pub impl Field for Float`
- `src/trait_test.mbt:77`: `fn[T : Field] field_roundtrip(x : T) -> T {`
- `src/impl_dbl.mbt:20`: `pub impl Field for Double`
- `src/structure.mbt:26`: `/// noncommutative division ring must not implement `Field`.`
- `src/structure.mbt:27`: `pub(open) trait Field: Ring + Inverse + Div {}`

## luna-poly @ fc22d48cff09e61f670f12638ab9f82f2ff36f7f

- `src/mutable/alias.mbt:32`: `trait Field,`
- `src/immut/alias.mbt:32`: `trait Field,`
