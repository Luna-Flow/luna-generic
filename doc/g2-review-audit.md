# G2 PR review follow-up

Review sources: [round one](https://github.com/Luna-Flow/luna-generic/pull/21#issuecomment-6111979187) and [round two](https://github.com/Luna-Flow/luna-generic/pull/21#issuecomment-6120435848), reviewed heads 0a26144 and 81a3454 ([round three](https://github.com/Luna-Flow/luna-generic/pull/21)).

| ID | Class | Contract / change | Acceptance | Status |
|---|---|---|---|---|
| R1 | test gap | Structured compile-fail diagnostics, positive twins, baseline probes | Four backend fixture gates reject only intended diagnostics | complete; re-run after this revision |
| R2 | documentation gap | Correct Japanese msgid alignment and the reported Chinese entry; remove stale previous msgids | Both catalogs 472/472; `lunadoc check` clean; `msgfmt` parses both | complete |
| R3 | test gap | Compile and execute all MoonBit documentation examples | Four-backend doc example gate | complete; re-run after this revision |
| R4 | documentation gap | Distinguish unbound Algebra diagnostics from model-bound checks | Source and API docs agree | complete |
| R5 | metadata gap | Put the breaking marker and complete removal list on the commit that introduces the API break | Commit marker and CHANGELOG review | in progress |
| R6 | test gap | Independent endpoint, product, reduct and error-code regressions | Mutation checks kill every listed mutation | complete; CI gate added in this revision |
| R7 | API boundary | Eq + Debug and two valid weakenings are confirmed; Show and describe are deferred. `ModelMismatch` is split into the payload-free `IdentityMismatch`, `SignatureMismatch` and `NotProductModel` (D-G1b/D-G1e); `ModelConstructionError::InvalidOperationTable` is unchanged | One test per variant that also asserts the other two do not occur; 11 variant-swap mutations killed | complete: split per the maintainer decision (round three); see [#20 comment](https://github.com/Luna-Flow/luna-generic/issues/20#issuecomment-6123022875) |
| R8 | documentation gap | Empty phantom tables remain allowed per #20; postulate is an explicit trust entry | Boundary documented; fixture coverage | complete |
| R9 | audit gap | Correct Complex MulGroup classification; refresh source pin and keep broader candidate inventory scoped to G3 | 128 per-row classifications, decisions and anchors verified; downstream source untouched | complete |
| R10 | documentation gap | Document missing Model factories, LawfulModel factory and derived error methods | Generated interface cross-check | complete; `moon info` reports no interface drift |
| R11 | integration gap | Run source tests, fixtures, docs and mutation checks in CI | CI gate contains all commands | in progress; mutation gate added in this revision |
| R12 | API boundary | `Model::describe` conflicts with the confirmed `same_identity`-only API | Defer describe in G2 | complete; confirmed in #20 |
| R13 | documentation gap | Describe canonical reduct convergence separately from custom lineage | Trust audit matches implementation | complete |
| R14 | docs/CI | Add second-round catalog, error-shape and API-doc findings | No unresolved catalog/API mismatch | in progress |
| R15 | CI reproducibility | Pin the MoonBit installer version | Toolchain install must resolve a versioned binary | blocked by upstream artifact availability: pinned binary and core URLs return HTTP 403; latest URLs return HTTP 200 |

The approved #20 contract explicitly permits Algebra::make operation tables
that do not match a phantom signature. Model::make delegates to it. This
review does not silently add built-in signature validation. G3 migrations
remain deferred until G2 merges. New API shapes require a #19/#20 decision.
