# G2 Field Bound Inventory Audit

Audited on 2026-10-11 against every pinned source commit in codex-plans/reference/19-field-bound-inventory.md. For each raw row, the file at the pinned commit was loaded with git show <commit>:<path> and the recorded line excerpt was matched at the recorded line number. All 128 anchor checks passed. This audit classifies downstream evidence only; G2 changes this repository alone, and G3 updates downstream packages after G2 is merged.

## Classification rule

Use the accepted G1 design draft section 6: numerical algorithms and floating analytic capabilities need operation bundles and rounded semantics, not exact field laws; only the exact Complex[T] Field instance needs an OrderedFieldTh premise. Aliases and compile probes are recorded separately so G3 cannot omit them.

## linear-algebra at 2ce90eeceb1a367d5e84f32b8388d6eb6e43346f

| # | Source anchor | Inventory declaration | Classification | Anchor |
|---:|---|---|---|---|
| 001 | <code>src/mutable/lu_internal_js.mbt:10</code> | <code>fn[T : Compare + Field + Num + Tolerance] Matrix::lu_decompose_internal(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 002 | <code>src/mutable/lu_internal_js.mbt:88</code> | <code>fn[T : Compare + Field + Num + Tolerance] LuDecomposition::solve_internal(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 003 | <code>src/mutable/lu_internal_js.mbt:136</code> | <code>fn[T : Compare + Field + Num + Tolerance] LuDecomposition::solve_identity_internal(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 004 | <code>src/mutable/matrix_wasm.mbt:1316</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::reduce_row_elimination(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 005 | <code>src/mutable/matrix_wasm.mbt:1368</code> | <code>fn[T : Compare + Field + Num + Tolerance] Matrix::power_method_seed(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 006 | <code>src/mutable/matrix_wasm.mbt:1392</code> | <code>fn[T : Compare + Field + Num + Tolerance] Matrix::initialize_power_method_vector(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 007 | <code>src/mutable/matrix_wasm.mbt:1687</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::rank(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 008 | <code>src/mutable/matrix_wasm.mbt:1898</code> | <code>pub fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::eigen(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 009 | <code>src/mutable/matrix_wasm.mbt:1920</code> | <code>fn[T : Compare + Field + Num + Sqrt + Tolerance] qr_algorithm(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 010 | <code>src/mutable/matrix_wasm.mbt:1938</code> | <code>fn[T : Compare + Field + Num + Sqrt + Tolerance] householder_tridiagonalize(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 011 | <code>src/mutable/matrix_wasm.mbt:2029</code> | <code>fn[T : Compare + Field + Num + Sqrt] symmetric_tridiagonal_eigen(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 012 | <code>src/mutable/matrix_wasm.mbt:2118</code> | <code>fn[T : Compare + Field + Num + Sqrt + Tolerance] qr_decomposition(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 013 | <code>src/mutable/matrix_wasm.mbt:2217</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::power_method(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 014 | <code>src/mutable/matrix_wasm.mbt:2360</code> | <code>fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::eigen_2x2(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 015 | <code>src/mutable/matrix_wasm.mbt:2485</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::determinant(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 016 | <code>src/mutable/matrix_wasm.mbt:2495</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::unchecked_determinant(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 017 | <code>src/mutable/matrix_wasm.mbt:2558</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::inverse(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 018 | <code>src/mutable/matrix_wasm.mbt:2577</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::unchecked_inverse(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 019 | <code>src/mutable/matrix_wasm.mbt:2643</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::is_invertible(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 020 | <code>src/mutable/matrix_wasm.mbt:2653</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::unchecked_is_invertible(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 021 | <code>src/mutable/matrix_wasm.mbt:2663</code> | <code>pub fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::cholesky_decomposition(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 022 | <code>src/mutable/matrix_wasm.mbt:2744</code> | <code>pub fn[T : Field] Matrix::mean(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 023 | <code>src/mutable/matrix_wasm.mbt:2758</code> | <code>pub fn[T : Field] Matrix::unchecked_mean(self : Matrix[T]) -> T {</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 024 | <code>src/mutable/matrix_wasm.mbt:2787</code> | <code>pub fn[T : Field] Matrix::variance(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 025 | <code>src/mutable/matrix_wasm.mbt:2801</code> | <code>pub fn[T : Field] Matrix::unchecked_variance(self : Matrix[T]) -> T {</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 026 | <code>src/mutable/matrix_wasm.mbt:2834</code> | <code>pub fn[T : Field + Sqrt] Matrix::std_dev(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 027 | <code>src/mutable/matrix_wasm.mbt:2848</code> | <code>pub fn[T : Field + Sqrt] Matrix::unchecked_std_dev(self : Matrix[T]) -> T {</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 028 | <code>src/mutable/matrix_wasm.mbt:3011</code> | <code>pub fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::is_positive_definite(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 029 | <code>src/mutable/lu_internal_native.mbt:10</code> | <code>fn[T : Compare + Field + Num + Tolerance] Matrix::lu_decompose_internal(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 030 | <code>src/mutable/lu_internal_native.mbt:88</code> | <code>fn[T : Compare + Field + Num + Tolerance] LuDecomposition::solve_internal(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 031 | <code>src/mutable/lu_internal_native.mbt:136</code> | <code>fn[T : Compare + Field + Num + Tolerance] LuDecomposition::solve_identity_internal(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 032 | <code>src/mutable/matrix_js.mbt:1331</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::reduce_row_elimination(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 033 | <code>src/mutable/matrix_js.mbt:1387</code> | <code>fn[T : Compare + Field + Num + Tolerance] Matrix::power_method_seed(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 034 | <code>src/mutable/matrix_js.mbt:1411</code> | <code>fn[T : Compare + Field + Num + Tolerance] Matrix::initialize_power_method_vector(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 035 | <code>src/mutable/matrix_js.mbt:1706</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::rank(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 036 | <code>src/mutable/matrix_js.mbt:1933</code> | <code>pub fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::eigen(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 037 | <code>src/mutable/matrix_js.mbt:1967</code> | <code>fn[T : Compare + Field + Num + Sqrt + Tolerance] qr_algorithm(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 038 | <code>src/mutable/matrix_js.mbt:1985</code> | <code>fn[T : Compare + Field + Num + Sqrt + Tolerance] householder_tridiagonalize(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 039 | <code>src/mutable/matrix_js.mbt:2076</code> | <code>fn[T : Compare + Field + Num + Sqrt] symmetric_tridiagonal_eigen(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 040 | <code>src/mutable/matrix_js.mbt:2165</code> | <code>fn[T : Compare + Field + Num + Sqrt + Tolerance] qr_decomposition(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 041 | <code>src/mutable/matrix_js.mbt:2264</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::power_method(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 042 | <code>src/mutable/matrix_js.mbt:2407</code> | <code>fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::eigen_2x2(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 043 | <code>src/mutable/matrix_js.mbt:2532</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::determinant(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 044 | <code>src/mutable/matrix_js.mbt:2542</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::unchecked_determinant(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 045 | <code>src/mutable/matrix_js.mbt:2634</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::inverse(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 046 | <code>src/mutable/matrix_js.mbt:2653</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::unchecked_inverse(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 047 | <code>src/mutable/matrix_js.mbt:2719</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::is_invertible(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 048 | <code>src/mutable/matrix_js.mbt:2729</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::unchecked_is_invertible(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 049 | <code>src/mutable/matrix_js.mbt:2739</code> | <code>pub fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::cholesky_decomposition(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 050 | <code>src/mutable/matrix_js.mbt:2820</code> | <code>pub fn[T : Field] Matrix::mean(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 051 | <code>src/mutable/matrix_js.mbt:2834</code> | <code>pub fn[T : Field] Matrix::unchecked_mean(self : Matrix[T]) -> T {</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 052 | <code>src/mutable/matrix_js.mbt:2863</code> | <code>pub fn[T : Field] Matrix::variance(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 053 | <code>src/mutable/matrix_js.mbt:2877</code> | <code>pub fn[T : Field] Matrix::unchecked_variance(self : Matrix[T]) -> T {</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 054 | <code>src/mutable/matrix_js.mbt:2910</code> | <code>pub fn[T : Field + Sqrt] Matrix::std_dev(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 055 | <code>src/mutable/matrix_js.mbt:2924</code> | <code>pub fn[T : Field + Sqrt] Matrix::unchecked_std_dev(self : Matrix[T]) -> T {</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 056 | <code>src/mutable/matrix_js.mbt:2967</code> | <code>fn[T : Compare + Field] normalize_diagonal_rref_js(matrix : Matrix[T]) -> Unit {</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 057 | <code>src/mutable/matrix_js.mbt:3100</code> | <code>pub fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::is_positive_definite(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 058 | <code>src/mutable/lu_internal_wasm.mbt:10</code> | <code>fn[T : Compare + Field + Num + Tolerance] Matrix::lu_decompose_internal(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 059 | <code>src/mutable/lu_internal_wasm.mbt:88</code> | <code>fn[T : Compare + Field + Num + Tolerance] LuDecomposition::solve_internal(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 060 | <code>src/mutable/lu_internal_wasm.mbt:136</code> | <code>fn[T : Compare + Field + Num + Tolerance] LuDecomposition::solve_identity_internal(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 061 | <code>src/mutable/lu_internal_wasm_gc.mbt:10</code> | <code>fn[T : Compare + Field + Num + Tolerance] Matrix::lu_decompose_internal(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 062 | <code>src/mutable/lu_internal_wasm_gc.mbt:86</code> | <code>fn[T : Compare + Field + Num + Tolerance] LuDecomposition::solve_identity_internal(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 063 | <code>src/mutable/alias.mbt:9</code> | <code>trait Field,</code> | operation alias inventory; exact Field alias deferred to G3 | verified |
| 064 | <code>src/mutable/matrix_wasm_gc.mbt:1316</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::reduce_row_elimination(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 065 | <code>src/mutable/matrix_wasm_gc.mbt:1371</code> | <code>fn[T : Compare + Field + Num + Tolerance] Matrix::power_method_seed(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 066 | <code>src/mutable/matrix_wasm_gc.mbt:1395</code> | <code>fn[T : Compare + Field + Num + Tolerance] Matrix::initialize_power_method_vector(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 067 | <code>src/mutable/matrix_wasm_gc.mbt:1690</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::rank(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 068 | <code>src/mutable/matrix_wasm_gc.mbt:1901</code> | <code>pub fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::eigen(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 069 | <code>src/mutable/matrix_wasm_gc.mbt:1923</code> | <code>fn[T : Compare + Field + Num + Sqrt + Tolerance] qr_algorithm(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 070 | <code>src/mutable/matrix_wasm_gc.mbt:1941</code> | <code>fn[T : Compare + Field + Num + Sqrt + Tolerance] householder_tridiagonalize(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 071 | <code>src/mutable/matrix_wasm_gc.mbt:2032</code> | <code>fn[T : Compare + Field + Num + Sqrt] symmetric_tridiagonal_eigen(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 072 | <code>src/mutable/matrix_wasm_gc.mbt:2121</code> | <code>fn[T : Compare + Field + Num + Sqrt + Tolerance] qr_decomposition(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 073 | <code>src/mutable/matrix_wasm_gc.mbt:2220</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::power_method(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 074 | <code>src/mutable/matrix_wasm_gc.mbt:2363</code> | <code>fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::eigen_2x2(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 075 | <code>src/mutable/matrix_wasm_gc.mbt:2488</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::determinant(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 076 | <code>src/mutable/matrix_wasm_gc.mbt:2498</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::unchecked_determinant(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 077 | <code>src/mutable/matrix_wasm_gc.mbt:2561</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::inverse(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 078 | <code>src/mutable/matrix_wasm_gc.mbt:2580</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::unchecked_inverse(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 079 | <code>src/mutable/matrix_wasm_gc.mbt:2646</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::is_invertible(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 080 | <code>src/mutable/matrix_wasm_gc.mbt:2656</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::unchecked_is_invertible(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 081 | <code>src/mutable/matrix_wasm_gc.mbt:2666</code> | <code>pub fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::cholesky_decomposition(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 082 | <code>src/mutable/matrix_wasm_gc.mbt:2747</code> | <code>pub fn[T : Field] Matrix::mean(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 083 | <code>src/mutable/matrix_wasm_gc.mbt:2761</code> | <code>pub fn[T : Field] Matrix::unchecked_mean(self : Matrix[T]) -> T {</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 084 | <code>src/mutable/matrix_wasm_gc.mbt:2790</code> | <code>pub fn[T : Field] Matrix::variance(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 085 | <code>src/mutable/matrix_wasm_gc.mbt:2804</code> | <code>pub fn[T : Field] Matrix::unchecked_variance(self : Matrix[T]) -> T {</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 086 | <code>src/mutable/matrix_wasm_gc.mbt:2837</code> | <code>pub fn[T : Field + Sqrt] Matrix::std_dev(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 087 | <code>src/mutable/matrix_wasm_gc.mbt:2851</code> | <code>pub fn[T : Field + Sqrt] Matrix::unchecked_std_dev(self : Matrix[T]) -> T {</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 088 | <code>src/mutable/matrix_wasm_gc.mbt:3014</code> | <code>pub fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::is_positive_definite(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 089 | <code>src/mutable/matrix_native.mbt:1331</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::reduce_row_elimination(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 090 | <code>src/mutable/matrix_native.mbt:1383</code> | <code>fn[T : Compare + Field + Num + Tolerance] Matrix::power_method_seed(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 091 | <code>src/mutable/matrix_native.mbt:1407</code> | <code>fn[T : Compare + Field + Num + Tolerance] Matrix::initialize_power_method_vector(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 092 | <code>src/mutable/matrix_native.mbt:1702</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::rank(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 093 | <code>src/mutable/matrix_native.mbt:1913</code> | <code>pub fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::eigen(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 094 | <code>src/mutable/matrix_native.mbt:1935</code> | <code>fn[T : Compare + Field + Num + Sqrt + Tolerance] qr_algorithm(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 095 | <code>src/mutable/matrix_native.mbt:1953</code> | <code>fn[T : Compare + Field + Num + Sqrt + Tolerance] householder_tridiagonalize(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 096 | <code>src/mutable/matrix_native.mbt:2044</code> | <code>fn[T : Compare + Field + Num + Sqrt] symmetric_tridiagonal_eigen(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 097 | <code>src/mutable/matrix_native.mbt:2133</code> | <code>fn[T : Compare + Field + Num + Sqrt + Tolerance] qr_decomposition(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 098 | <code>src/mutable/matrix_native.mbt:2232</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::power_method(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 099 | <code>src/mutable/matrix_native.mbt:2375</code> | <code>fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::eigen_2x2(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 100 | <code>src/mutable/matrix_native.mbt:2500</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::determinant(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 101 | <code>src/mutable/matrix_native.mbt:2510</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::unchecked_determinant(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 102 | <code>src/mutable/matrix_native.mbt:2603</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::inverse(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 103 | <code>src/mutable/matrix_native.mbt:2622</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::unchecked_inverse(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 104 | <code>src/mutable/matrix_native.mbt:2688</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::is_invertible(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 105 | <code>src/mutable/matrix_native.mbt:2698</code> | <code>pub fn[T : Compare + Field + Num + Tolerance] Matrix::unchecked_is_invertible(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 106 | <code>src/mutable/matrix_native.mbt:2708</code> | <code>pub fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::cholesky_decomposition(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 107 | <code>src/mutable/matrix_native.mbt:2789</code> | <code>pub fn[T : Field] Matrix::mean(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 108 | <code>src/mutable/matrix_native.mbt:2803</code> | <code>pub fn[T : Field] Matrix::unchecked_mean(self : Matrix[T]) -> T {</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 109 | <code>src/mutable/matrix_native.mbt:2832</code> | <code>pub fn[T : Field] Matrix::variance(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 110 | <code>src/mutable/matrix_native.mbt:2846</code> | <code>pub fn[T : Field] Matrix::unchecked_variance(self : Matrix[T]) -> T {</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 111 | <code>src/mutable/matrix_native.mbt:2879</code> | <code>pub fn[T : Field + Sqrt] Matrix::std_dev(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 112 | <code>src/mutable/matrix_native.mbt:2893</code> | <code>pub fn[T : Field + Sqrt] Matrix::unchecked_std_dev(self : Matrix[T]) -> T {</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 113 | <code>src/mutable/matrix_native.mbt:3026</code> | <code>pub fn[T : Compare + Field + Num + Sqrt + Tolerance] Matrix::is_positive_definite(</code> | operation-only numerical algorithm; no exact FieldTh requirement | verified |
| 114 | <code>src/perf_support/perf_support.mbt:3</code> | <code>using @lf_alg {trait AddMonoid, trait Field, trait Num}</code> | operation-only compile probe; convert Field/Num bounds in G3 | verified |
| 115 | <code>src/perf_support/perf_support.mbt:195</code> | <code>fn[T : AddMonoid + Field + Num] require_numeric_traits(value : T) -> T {</code> | operation-only compile probe; convert Field/Num bounds in G3 | verified |

## luna-complex at 4d1b5ec0f0326593c56e53451d491d0648110c54

| # | Source anchor | Inventory declaration | Classification | Anchor |
|---:|---|---|---|---|
| 116 | <code>src/complex_traits.mbt:63</code> | <code>pub impl[T : Field] Div for Complex[T] with fn div(</code> | complex arithmetic operation implementation; operations only, no field-law proof | verified |
| 117 | <code>src/complex_traits.mbt:75</code> | <code>pub impl[T : Field] Inverse for Complex[T] with fn inv(self : Complex[T]) -> Complex[</code> | complex arithmetic operation implementation; operations only, no field-law proof | verified |
| 118 | <code>src/complex_traits.mbt:98</code> | <code>pub impl[T : Field] MulGroup for Complex[T]</code> | complex arithmetic operation implementation; operations only, no field-law proof | verified |
| 119 | <code>src/complex_traits.mbt:101</code> | <code>pub impl[T : Field] Field for Complex[T]</code> | exact Complex Field instance; requires OrderedFieldTh | verified |
| 120 | <code>src/alias.mbt:6</code> | <code>trait Field,</code> | law-bearing Field re-export; downstream alias update deferred to G3 | verified |
| 121 | <code>src/float_backend/float_backend_traits.mbt:2</code> | <code>pub(open) trait FloatingAnalyticScalar: @luna-generic.Field + @luna-generic.Num + Compare + Constants + Sqrt + Exponential + Logarithmic + Trigonometric + InverseTrigonometric + Hyperbolic + InverseHyperbolic {</code> | rounded floating operation capability; use ops plus rounded marker in G3 | verified |

## luna-generic at 18a633c237cc4759d617e546b23d1c969f09a5b8

| # | Source anchor | Inventory declaration | Classification | Anchor |
|---:|---|---|---|---|
| 122 | <code>src/impl_float.mbt:20</code> | <code>pub impl Field for Float</code> | remove automatic exact Field instance; retain operation bundles and rounded marker | verified |
| 123 | <code>src/trait_test.mbt:77</code> | <code>fn[T : Field] field_roundtrip(x : T) -> T {</code> | replace exact Field roundtrip probe with positive exact and negative floating API fixtures | verified |
| 124 | <code>src/impl_dbl.mbt:20</code> | <code>pub impl Field for Double</code> | remove automatic exact Field instance; retain operation bundles and rounded marker | verified |
| 125 | <code>src/structure.mbt:26</code> | <code>/// noncommutative division ring must not implement `Field`.</code> | Field law documentation; revise to explicit certificate contract | verified |
| 126 | <code>src/structure.mbt:27</code> | <code>pub(open) trait Field: Ring + Inverse + Div {}</code> | law-bearing Field contract; add mandatory Law[FieldTh, Self] method | verified |

## luna-poly at fc22d48cff09e61f670f12638ab9f82f2ff36f7f

| # | Source anchor | Inventory declaration | Classification | Anchor |
|---:|---|---|---|---|
| 127 | <code>src/mutable/alias.mbt:32</code> | <code>trait Field,</code> | law-bearing Field re-export; downstream alias update deferred to G3 | verified |
| 128 | <code>src/immut/alias.mbt:32</code> | <code>trait Field,</code> | law-bearing Field re-export; downstream alias update deferred to G3 | verified |
