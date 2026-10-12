# G2 PR review follow-up

Review source: [PR #21 comment](https://github.com/Luna-Flow/luna-generic/pull/21#issuecomment-6111979187), head b924e01.

| ID | Class | Contract / change | Acceptance | Status |
|---|---|---|---|---|
| R1 | test gap | Fix invalid fixture syntax; structured diagnostic matching; nonempty expectations; positive twins and baseline probes | Four backend fixture gates reject only intended diagnostics; mutation checks | in progress |
| R2 | documentation gap | Audit and realign Japanese catalog by msgid | Translation and code-span alignment checks | pending |
| R3 | test gap | Fix doc imports, Result handling and I8 law method; compile every MoonBit doc page in CI | All examples compile and tests execute | pending |
| R4 | documentation gap | Explicitly distinguish unbound Algebra diagnostics from model-bound checks | Source and API docs agree | pending |
| R5 | metadata gap | Add scoped breaking commit and migration table | Commit marker and CHANGELOG review | pending |
| R6 | test gap | Independent endpoint, product, reduct and error-code regressions | Tests detect each listed mutation | pending |
| R7 | API boundary | Internal types priv; error Eq/Debug/Show and extra weakening methods need contract review | No unapproved public shape | pending decision |
| R8 | documentation gap | Empty phantom tables remain allowed per #20; postulate is explicit trust | Boundary documented and exercised | pending |
| R9 | audit gap | Correct Complex MulGroup classification; inventory decisions and broader G3 search | 128 decisions checked, pinned anchors, downstream source untouched | pending |
| R10 | documentation gap | Complete missing public-name documentation | Generated interface cross-check | pending |
| R11 | integration gap | Run source tests, fixtures, docs in CI | CI gate contains all commands | pending |
| R12 | API boundary | describe request conflicts with latest same_identity-only decision | #20 decision or evidence-backed omission | pending |
| R13 | documentation gap | Canonical reduct path collapse documented separately from custom lineage | Trust audit matches implementation | pending |

The approved #20 contract explicitly permits Algebra::make operation tables
that do not match a phantom signature. Model::make delegates to it. This
review does not silently add built-in signature validation. G3 migrations
remain deferred until G2 merges. New API shapes require a #19/#20 decision.
