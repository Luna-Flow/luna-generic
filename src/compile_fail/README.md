# Compile-fail API fixtures

Each subdirectory of cases contains a standalone downstream package that must
be rejected by the MoonBit checker. Fixtures stay outside the module source
tree in this checkout so the ordinary package build remains valid. The runner
copies luna-generic into a temporary module, materializes the fixture as a
downstream package, and checks it against the current source API.

Each case contains:

- fixture.mbt: the rejected downstream program;
- expected.txt: `ERROR_CODE|diagnostic fragment`. The runner requires both the
  structured compiler error code and the diagnostic text, so source echo and
  unrelated syntax errors cannot make a fixture pass.

Run bash src/compile_fail/run.sh from the module root. A fixture passes only
when compilation fails and the expected diagnostic fragment is present. The
runner checks all four supported backends.
