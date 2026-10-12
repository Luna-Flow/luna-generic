# G2 Implementation Audit

Scope: `Luna-Flow/luna-generic` only. Downstream G3 migrations remain out of
scope until this change is merged.

## Issue Matrix

| Issue | Contract | Evidence | Acceptance |
| --- | --- | --- | --- |
| Operation/law split | Operation bundles carry capabilities only; law traits require an opaque `Law[Th, Self]` method with no default. | `src/structure.mbt`, `src/law_instances.mbt`; `forge_law`, `missing_law_method`, `invalid_weakening` fixtures. | `moon check --target all --deny-warn`; fixtures reject forged/omitted/invalid laws. |
| Float/Double | Floating types retain operation bundles and `RoundedArithmetic`, with no exact law instances. | `src/impl_float.mbt`, `src/impl_dbl.mbt`; `float_field_law`, `double_field_law`, `inventory_float_field_bound`. | Four backend compile-fail runner and positive operation fixture pass. |
| Num removal | `Num` is removed; `NumOps` is operation-only. | `src/structure.mbt`, numeric implementations; `removed_num`. | Old `Num` bound fails; rounded operation fixture passes. |
| Checked construction | `Algebra::make` and `Model::make` return `Result`; negative arity is `InvalidArity` before ID allocation. | `src/hom.mbt`, `src/structure.mbt`, white-box arity test. | Unit tests and API fixture pass on all four targets. |
| Custom IDs | Serialized process-local `UInt64` counter, pre-increment exhaustion abort, no wrap/reuse, no physical equality. | `src/structure.mbt`, exhaustion guard, `doc/trust-audit.md`. | Guard test and four target checks pass; concurrency and exhaustion are documented separately. |
| Canonical IDs | Kernel-owned nominal signature labels are stable across calls and packages. | `Model::canonical` factories use fixed labels; no caller label or `physical_equal`. | Canonical identities compose; generated interface exposes factories. |
| Opaque IDs | `ModelKey` representation and the former `Model::key` accessor are absent from the public API; callers compare exact Models only with `Model::same_identity`. | `src/structure.mbt`, `model_key_forge`, `model_key_private` fixtures, generated `.mbti`. | Key variants and mutable lineage are unavailable to downstream code. |
| Runtime Hom | Hom stores source/target Models; `then_checked` checks the middle key and returns `IdentityMismatch`. | `src/hom.mbt`; `removed_unchecked_then` and the runtime fixture's matching/mismatched composition cases. | Matching composition succeeds; mismatched composition fails as data. |
| Product models | `Model::prod` returns a fresh product identity; pair and projections reuse one explicit product Model and return `Result`. | `src/structure.mbt`, `src/hom.mbt`; runtime pair/projection mismatch test. | Shared product passes; different component/product identities fail. |
| Reducts | Built-in reducts project operation tables, preserve custom lineage, and return `InvalidOperationTable` for malformed tables; `refl` preserves the table/key. | `src/hom.mbt`; refl, malformed-table and distinct-lineage tests. | `Hom::forget` and `Model::forget` return checked Results. |
| Exact integer Hom | Old conversion Hom constructors are removed. `from_integer_exact` requires `FromInteger` plus `LawfulModel[IntegerHomomorphismTh, SemiringSig, R]`; no injectivity claim. | `src/hom.mbt`, `src/integer_law_instances.mbt`; `rounded_integer_exact` negative and fixed-width positive fixtures. | Rounded targets cannot use a Semiring law as the exact premise; fixed-width mappings pass exact checks. |
| Strict upgrades | `to_add_group`/`to_ring` consume law-bound Models, read the opaque law, validate reduced endpoint identities, and return `Result`. | `src/hom.mbt`, `src/section.mbt`, positive hom/section tests. | Canonical law-bound upgrades pass; mismatched endpoints return `IdentityMismatch`. |
| Diagnostics | Algebra-only `check`/`check_by` remain finite diagnostics; model-bound `check_models`/`check_models_by` validate exact endpoint identity and return `Result[Bool, ModelMismatch]`. | `src/hom.mbt`; `diagnostic_not_hom`, `diagnostic_tolerance_not_hom`; runtime model-bound mismatch tests. | Bool cannot be assigned to Hom; tolerance checks stay outside strict composition; unrelated Models return `Err(ModelMismatch)`. |
| API fixtures | Every §8 row has a negative fixture and positive coverage. | 18 compile-fail cases, each with a positive twin in `src/compile_fail/cases`, runtime mismatch fixture, four positive tests in `src/api_fixture_positive`. | Runner passes all fixtures on wasm, wasm-gc, JS and native. |
| Complex boundary | `FieldTh` alone cannot imply `OrderedFieldTh`; exact Complex instance is downstream G3. | `field_law_not_ordered` fixture and inventory rows 116-121. | Generic package rejects invalid theory weakening; no G3 files changed. |
| Inventory | Every one of the 128 pinned rows is classified and anchor-checked. | `doc/g2-field-bound-inventory-audit.md`; IDs 001-128 each occur once. | Audit reports `128/128` verified and worktree changes remain in luna-generic. |
| Docs/interfaces | Public docs, generated `.mbti`, trust audit, changelog and locales describe the implemented API. | `moon info`, `doc/manual/*`, `doc/locale/*`, `doc/trust-audit.md`. | Localization update/check, `msgfmt`, diff review and API scan pass. |

## Localization and scope evidence

Documentation root: `doc/manual`; source locale is English Markdown; published
package path is `manual`; locale trees are `doc/locale/zh_CN` and
`doc/locale/ja_JP`; gettext catalog is `manual.po`. Navigation continues via
`doc/manual/index.md`. Counterparts are synchronized: each has 468/468 entries,
zero untranslated, fuzzy, or English-identical entries. `lunadoc check .
--compile` reports zero errors/warnings; `msgfmt` warns only that catalog header
metadata fields are absent. Every `moonbit` block compiles and 42 embedded tests
pass per backend. Markdown pages remain ordinary site navigation entries.

## Review follow-up

All PR #21 review items are tracked in `doc/g2-review-audit.md`. The approved
API additions are `Eq + Debug` for both errors and the actual weakenings
`CommRingTh -> RingTh` and `IntegralDomainTh -> RingTh`. `Model::describe` is
deferred per the maintainer's #20 decision; `same_identity` remains the only
identity API. Operation table arity is validated, while phantom-signature
shape remains unchecked by the explicit #20 contract.

The Section 8 fixture map now has 18 negative cases, each with a compiling
positive control. The legacy API baseline runner proves 7 pre-G2 APIs compile
on pinned origin/main; current-only Model/Law fixtures have positive twins.
Nineteen mutation checks are killed on native, including independently
removed endpoints and the earlier Float Field / Num fixture survivors.
Every `moonbit` documentation fence across four pages is compiled and its
42 embedded tests run on all four targets in CI. `mbti` blocks are signature
notation, not source programs.

## Section 8 Fixture Map

| Acceptance row | Negative fixture(s) | Positive coverage |
| --- | --- | --- |
| Float/Double laws | `float_field_law`, `double_field_law`, `inventory_float_field_bound` | `api_fixture_positive` rounded operation test |
| Rounded integer conversion | `removed_hom_from_integer`, `rounded_integer_exact` | fixed-width `from_integer_exact` positive test |
| Law opacity | `forge_law`, `missing_law_method` | explicit `Law::postulate` positive test |
| Theory tags | `invalid_weakening`, `field_law_not_ordered` | Field-to-Ring weakening positive test |
| Model binding | `removed_unchecked_then`; `model_key_forge`, `model_key_private`; `src/api_fixture_runtime/fixture.mbt` checks mismatched composition, pairing, projections, diagnostics, and law-bound upgrades | shared-model Hom tests |
| Diagnostics | `diagnostic_not_hom`, `diagnostic_tolerance_not_hom`; runtime endpoint mismatch assertions | exact, lax, and model-bound finite checks |
| Complex | `field_law_not_ordered` | operation/law boundary documented; Complex migration is G3 |
| Inventory | `inventory_float_field_bound` plus pinned 128-row audit | inventory audit checker |

## Resolved G2 boundaries

The maintainer decisions recorded in luna-generic #20 make `ModelKey` an
internal opaque representation and add `Hom::check_models` /
`Hom::check_models_by` for endpoint-bound finite diagnostics. No public key
constructor or accessor exists; model identity is observed only through
`Model::same_identity`.
