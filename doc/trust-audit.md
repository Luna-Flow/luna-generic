# G2 trust audit

This page records assumptions and partiality at the law-certificate and
runtime-identity boundaries. Opaque `Law[Theory, Carrier]` values identify an
assumed theory; they do not prove its equations.

## Explicit law assumptions

| Carrier | Directly postulated theory | Weakened/derived theories | Basis |
| --- | --- | --- | --- |
| BigInt | `RingTh`, `CommRingTh`, `IntegralDomainTh`, `IntegralTh`, `IntegerHomomorphismTh` | `SemiringTh`, `AddGroupTh`, `AddMonoidTh`, `MulMonoidTh` | Mathematical integer operations; normalization is identity and conversion is exact. |
| Int, Int16, Int64 | `RingTh`, `CommRingTh`, `IntegralTh`, `IntegerHomomorphismTh` | `SemiringTh`, `AddGroupTh`, `AddMonoidTh`, `MulMonoidTh` | Fixed-width arithmetic is interpreted modulo its word size, giving `Z/(2^k)`; normalization chooses signed representatives. |
| UInt, UInt16, UInt64 | `SemiringTh`, `NatTh`, `IntegralTh`, `IntegerHomomorphismTh` | `AddMonoidTh`, `MulMonoidTh` | Fixed-width arithmetic is interpreted modulo its word size; normalization chooses nonnegative representatives. |
| Float, Double | none | none | Only operation bundles and `RoundedArithmetic` are implemented. Integer conversion is rounded and does not supply `IntegerHomomorphismTh`. |

Every law-bearing trait method has no default implementation. A downstream
implementation can use `Law::postulate()` explicitly; this is a trusted
assumption, not a machine-checked proof. `LawfulModel::postulate(model)` binds
such an assumption to a particular runtime Model. `Hom::postulate` and
`Section::postulate` similarly record caller obligations for maps. Finite
checks do not prove universal laws.

## Kernel rules

The kernel exposes these theory implications:

- `SemiringTh -> AddMonoidTh` and `SemiringTh -> MulMonoidTh`;
- `CommRingTh -> RingTh` and `IntegralDomainTh -> RingTh`;
- `RingTh -> SemiringTh` and `RingTh -> AddGroupTh`;
- `AddGroupTh -> AddMonoidTh`;
- `FieldTh -> RingTh`, `CommRingTh`, `IntegralDomainTh`, and `SemiringTh`;
- `OrderedFieldTh -> FieldTh`.

Product certificates for `AddMonoidTh`, `MulMonoidTh`, `AddGroupTh`,
`SemiringTh`, and `RingTh` are derived componentwise. There is no rule from
`RingTh` to `CommRingTh` or `FieldTh`. The Complex field instance requires an
`OrderedFieldTh` premise in the downstream `luna-complex` migration; this G2
package only supplies the tag and implication API.

## Runtime identity boundary

Canonical Models use kernel-fixed nominal labels per signature. Their
operation tables come from the corresponding operation traits, so a canonical
factory has stable identity across calls and packages. Custom Models use a
process-local `UInt64` counter and begin with an empty lineage path. Construction
is not thread-safe: callers must serialize custom Model and product Model
construction on native multi-threaded runtimes.

Before increment, the allocator checks for `UInt64::max`. Exhaustion aborts
with an explicit internal-invariant message and never wraps or reuses an ID.
No `ModelIdExhausted` result is added; ordinary invalid operation arity is
reported as `InvalidArity`. A white-box test sets the counter near its maximum
and verifies the last valid allocation and the exhausted guard predicate. It
does not invoke the aborting branch in-process. This physically unreachable
invariant abort is audited separately from the non-thread-safe construction
limitation.

Built-in Reducts carry fixed markers that name the mapping itself, project the
operation table, and append their marker to custom Model lineage. `refl`
leaves operation table, identity and path unchanged. Different custom reduct paths remain distinct; composing two mappings and a
separately defined direct mapping need not produce the same custom identity.
Canonical reducts instead use the fixed target-signature label and can converge
to the same identity through different paths. Invalid or incomplete source
tables return `InvalidOperationTable`, not `ModelMismatch`. No custom Reduct
constructor ships in this release because none of the pinned 128 inventory
rows requires one. Program identity never uses `physical_equal`.

## Constructor trust points

`Hom::from_integer_exact` requires `FromInteger` plus
`LawfulModel[IntegerHomomorphismTh, SemiringSig, R]`. The law means the
conversion preserves zero, one, addition and multiplication; it does not
assert injectivity. The shipped fixed-width instances are valid modular
homomorphisms. A caller can explicitly postulate this theory for any carrier,
including a rounded one, but then owns the false-law risk; rounded types do
not receive it automatically. The binary32 witness is:

```text
f(16777217) = 16777216
f(16777217) + f(1) = 16777216
f(16777218) = 16777218
```

`Section::of_integral` consumes `IntegralTh` and the carrier's explicit
`IntegerHomomorphismTh` instance. `to_add_group` and `to_ring` consume
law-bound Models, validate the relevant reduct endpoint identity, and return
`Result`; they do not manufacture law certificates.

## Finite diagnostics and identity API

`Hom::check` and `check_by` are finite diagnostics over caller-supplied
operation tables and samples; even a tolerance relation creates no certificate.
`Hom::check_models` and `check_models_by` first compare the exact source and
target Model identities and return `Err(ModelMismatch)` on either mismatch,
then delegate to those finite checks. Their `Ok(Bool)` result remains a
diagnostic and cannot create a certificate.

The internal identity decomposition is `Canonical(String) | Custom(UInt64,
path)`. It is package-private: callers cannot construct, inspect, or mutate a
key or lineage path. `Model::same_identity` is the only public identity
operation, and program identity never uses `physical_equal`.
