#!/usr/bin/env python3
"""Review regressions must detect independently removed checks.

Mutations run in disposable copies, never in the working tree. A compiler
error is not a killed runtime mutation: every mutant must type-check first.
"""
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def run(temp, *arguments):
    return subprocess.run(["moon", *arguments], cwd=temp, capture_output=True, text=True)


def drop_identity_check(source, method, occurrence):
    start = source.index(f"Hom::{method}(")
    positions = list(re.finditer(r"same_model_key\(", source[start:]))
    position = start + positions[occurrence].start()
    end = position + len("same_model_key(")
    depth = 1
    while depth:
        if source[end] == "(":
            depth += 1
        elif source[end] == ")":
            depth -= 1
        end += 1
    return source[:position] + "true" + source[end:]


mutations = []
for method, count in (("to_ring", 2), ("to_add_group", 2), ("pair", 3),
                      ("check_models", 2), ("check_models_by", 2)):
    for occurrence in range(count):
        mutations.append((f"{method}-check-{occurrence}", "src/hom.mbt",
                          lambda source, m=method, n=occurrence: drop_identity_check(source, m, n)))
for method in ("pair", "fst", "snd"):
    def accept_nonproduct(source, method=method):
        start = source.index(f"Hom::{method}(")
        end = source.find("\n///|", start)
        segment = source[start:end]
        if method == "pair":
            segment = segment.replace("None => return Err(ModelMismatch)", "None => ()")
        else:
            field, component = ("fst", "left") if method == "fst" else ("snd", "right")
            segment = segment.replace("None => Err(ModelMismatch)",
                                      f"None => Ok({{ source: product, target: {component}, f: p => p.{field}, }})")
        return source[:start] + segment + source[end:]
    mutations.append((f"{method}-nonproduct", "src/hom.mbt", accept_nonproduct))
mutations.extend([
    ("reduct-index-composition", "src/hom.mbt",
     lambda source: source.replace("next.indices.map(index => self.indices[index])", "next.indices")),
    ("product-constant-id", "src/structure.mbt",
     lambda source: source.replace("key: Custom(next_custom_identity(), []),\n        product_origin: Some", "key: Custom(0UL, []),\n        product_origin: Some")),
    ("forget-error-code", "src/hom.mbt",
     lambda source: source.replace("return Err(InvalidOperationTable)", "return Err(InvalidArity)")),
])

for name, path, mutate in mutations:
    with tempfile.TemporaryDirectory(prefix="luna-generic-mutation-") as directory:
        temp = Path(directory)
        shutil.copy(ROOT / "moon.mod", temp)
        shutil.copytree(ROOT / "src", temp / "src")
        file = temp / path
        source = file.read_text()
        changed = mutate(source)
        if changed == source:
            raise SystemExit(f"mutation did not apply: {name}")
        file.write_text(changed)
        checked = run(temp, "check", "src/api_fixture_runtime", "--target", "native")
        if checked.returncode:
            print(checked.stdout + checked.stderr)
            raise SystemExit(f"mutation did not type-check: {name}")
        tested = run(temp, "test", "src/api_fixture_runtime", "--target", "native")
        if not tested.returncode or "failed: 0" in tested.stdout:
            raise SystemExit(f"mutation survived: {name}\n{tested.stdout}{tested.stderr}")
        print(f"killed: {name}", flush=True)

# These two API mutations formerly survived because syntax errors hid the API.
for name, path, addition, case in (
    ("restore-Float-Field", "src/impl_float.mbt",
     "\n///|\npub impl Field for Float with fn field_law() { Law::postulate() }\n", "float_field_law"),
    ("restore-Num", "src/structure.mbt", "\n///|\npub(open) trait Num: NumOps {}\n", "removed_num"),
):
    with tempfile.TemporaryDirectory(prefix="luna-generic-api-mutation-") as directory:
        temp = Path(directory)
        shutil.copy(ROOT / "moon.mod", temp)
        shutil.copytree(ROOT / "src", temp / "src")
        file = temp / path
        file.write_text(file.read_text() + addition)
        package = temp / "src/mutation_probe"
        package.mkdir()
        (package / "moon.pkg").write_text('import { "Luna-Flow/luna-generic" @lf_alg, }\n')
        shutil.copy(ROOT / "src/compile_fail/cases" / case / "fixture.mbt", package / "fixture.mbt")
        checked = run(temp, "check", "src/mutation_probe", "--target", "native")
        if checked.returncode:
            raise SystemExit(f"API mutation still rejected (false negative fixture): {name}\n{checked.stdout}{checked.stderr}")
        print(f"killed: {name} (negative fixture now compiles)", flush=True)

print(f"Verified {len(mutations) + 2} review mutations on native")
