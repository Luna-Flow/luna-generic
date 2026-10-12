#!/usr/bin/env python3
"""Compile and execute all moonbit fences, with each page as one package.

A page's declarations are shared across its blocks, as stated by the manual.
Only moonbit fences are executable; mbti/math/text fences are API notation.
"""
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

def run(command, cwd):
    result = subprocess.run(command, cwd=cwd, capture_output=True, text=True)
    if result.returncode:
        print(result.stdout + result.stderr)
        raise SystemExit(result.returncode)
    summaries = [line for line in result.stdout.splitlines() if line.startswith("Total tests:")]
    print(" ".join(command) + ": passed " + "; ".join(summaries), flush=True)

root = Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix="luna-generic-doc-examples-") as directory:
    temp = Path(directory)
    shutil.copy(root / "moon.mod", temp)
    shutil.copytree(root / "src", temp / "src")
    pages = 0
    packages = []
    for page in sorted((root / "doc/manual").rglob("*.md")):
        blocks = re.findall(r"^```moonbit\s*\n(.*?)^```\s*$", page.read_text(), re.M | re.S)
        if not blocks:
            continue
        pages += 1
        package = temp / "src/doc_examples" / page.relative_to(root / "doc/manual").with_suffix("")
        package.mkdir(parents=True)
        packages.append(str(package.relative_to(temp)))
        (package / "moon.pkg").write_text('import { "Luna-Flow/luna-generic" @lf_alg, }\n')
        (package / "examples.mbt").write_text("\n\n".join(blocks))
        print(f"{page.relative_to(root)}: {len(blocks)} executable blocks", flush=True)
    if not pages:
        raise SystemExit("no executable documentation found")
    for target in ("wasm", "wasm-gc", "js", "native"):
        run(["moon", "check", *packages, "--target", target], temp)
        run(["moon", "test", *packages, "--target", target], temp)
    print(f"Verified {pages} documentation pages on four backends")
