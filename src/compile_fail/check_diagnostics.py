"""Match compiler diagnostics, never source context or process failures."""
import json
import sys
from pathlib import Path

log, code, fragment = sys.argv[1:]
if not fragment.strip() or not code.isdigit() or int(code) in (3002, 4074):
    raise SystemExit("invalid expected diagnostic")
errors = []
for line in Path(log).read_text().splitlines():
    try:
        diagnostic = json.loads(line)
    except ValueError:
        continue
    if diagnostic.get("level") == "error":
        errors.append(diagnostic)
if not errors or any(e["error_code"] in (3002, 4074) for e in errors):
    raise SystemExit("missing diagnostics or unrelated syntax/type errors")
if any(e["error_code"] != int(code) and not (int(code) == 4036 and e["error_code"] == 4033) for e in errors):
    raise SystemExit("unrelated compiler errors")
if not any(e["error_code"] == int(code) and fragment in e["message"] for e in errors):
    raise SystemExit("expected diagnostic not found")
