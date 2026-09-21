# Constitutional history spike

This directory isolates the constitutional-history redesign before any migration
of the real Govenv kernel.

## Variants

- `ConstitutionalHistory.agda`: behavioral baseline. It intentionally keeps
  manual Boolean/list machinery and snapshot-like helpers for comparison.
- `ConstitutionalHistoryStdlib.agda`: stdlib-backed V2. It replaces bespoke
  equality, membership, uniqueness, traversal, and set-like coverage helpers.
- `ConstitutionalHistoryPropositional.agda`: preferred V3. Constitutional
  predicates are propositions in `Set`, decidability is separate in `Dec`,
  and Boolean values are only executable projections where needed.
- Matching `*Scenarios.agda` files preserve the canonical compile-time cases.
- `EcosystemReuse.agda` records the stdlib APIs verified against the pinned
  Agda ecosystem.

## V3 conclusions

The preferred layering is:

```text
formal property (Set)
        ↓
decision procedure (Dec)
        ↓
Boolean/check/materializer projection
```

History is append-only. Lifecycle facts such as `Pending`, `Active`, and
termination are derived from history rather than stored as mutable state.

Current responsibility is exposed semantically as `ResponsibleTo h g p`.
The internal `Maybe Nat` fold is private implementation machinery. A future
query API may totalize this relation for live propositions if a consumer needs
that shape.

Embedded establishments in an atomic supersession are validated as real
establishments: they must be pending before the cutover, unique, and used by a
reformulation.

## Validation

The baseline, stdlib V2, and proposition-first V3 scenario modules must all
typecheck. V3 additionally proves rejection of duplicate declaration IDs,
duplicate disposition subjects, duplicate embedded establishments, and attempts
to re-establish an already-active proposition.
