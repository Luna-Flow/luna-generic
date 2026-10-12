#!/usr/bin/env python3
"""Historical APIs must compile on the pinned pre-G2 base.

New Model/Law APIs did not exist on that base. Those cases use head positive
controls rather than claiming that a new certificate can compile on old code.
"""
from pathlib import Path
import io
import subprocess
import tarfile
import tempfile

root = Path(__file__).resolve().parents[1]
base = "18a633c237cc4759d617e546b23d1c969f09a5b8"
cases = ("float_field_law", "double_field_law", "inventory_float_field_bound",
         "removed_num", "removed_hom_from_integer", "removed_hom_from_nat",
         "removed_hom_from_integral")
archive = subprocess.run(["git", "archive", base], cwd=root, check=True, capture_output=True).stdout
with tempfile.TemporaryDirectory(prefix="luna-generic-baseline-") as directory:
    temp = Path(directory)
    with tarfile.open(fileobj=io.BytesIO(archive)) as contents:
        contents.extractall(temp, filter="data")
    packages = []
    for case in cases:
        package = temp / "src/baseline" / case
        package.mkdir(parents=True)
        (package / "moon.pkg").write_text('import { "Luna-Flow/luna-generic" @lf_alg, }\n')
        (package / "fixture.mbt").write_text((root / "src/compile_fail/cases" / case / "fixture.mbt").read_text())
        packages.append(str(package.relative_to(temp)))
    for target in ("wasm", "wasm-gc", "js", "native"):
        result = subprocess.run(["moon", "check", *packages, "--target", target], cwd=temp, capture_output=True, text=True)
        if result.returncode:
            print(result.stdout + result.stderr)
            raise SystemExit(result.returncode)
        print(f"{target}: {len(cases)} historical API fixtures compile on {base}")
