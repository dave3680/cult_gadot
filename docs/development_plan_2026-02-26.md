# Development Plan (Actionable)

Date: 2026-02-26
Scope: rebalance power curve and make trait/breeding systems feel impactful without rewriting core architecture.

## Outcome Goals
- Keep current systems and scene flow intact.
- Remove correctness mismatches that distort balance data.
- Increase trait and breeding agency/potency so choices feel run-defining.
- Complete a relic usefulness pass with measurable before/after evidence.

## Phase 0 - Correctness Stabilization (Blocker for tuning)
Priority: P0

Tasks:
1. Centralize overflow conversion in `GameState` and reuse in both runtime and sim.
2. Make Director's Cut truly +/-15% (or update text to match intended behavior).
3. Fix relic buy button signal wiring in `Shop` to avoid repeated connects.
4. Decide favored breeder path:
- integrate effect into breeding resolution, or
- remove/disable affordance until implemented.
5. Add deterministic shuffle helper for simulation paths.

Acceptance:
- Same seed => stable repeated sim outputs (within expected floating variation only).
- Runtime and TestRunner overflow behavior match exactly.
- No duplicate purchase callbacks from rerendered offers.

## Phase 1 - Instrumentation and Baseline Data
Priority: P0

Tasks:
1. Run doctrine coverage across `FLESH`, `RUIN`, `SILENCE`.
2. Add telemetry columns for:
- trait trigger rate and contribution by week
- relic pick rate and marginal score delta
- nest usage rate and newborn quality (tier/rarity)
3. Keep existing balance bands, but add a "power-feel" report section.

Acceptance:
- One report captures all doctrines in one run.
- We can identify bottom 25% relics/traits by usage and impact.

## Phase 2 - Trait Purpose Pass
Priority: P1

Tasks:
1. Define trait role buckets:
- Common: reliable, frequent, small-to-medium value
- Rare: build-defining conditional spikes
- Legendary: run-shaping moments with clear conditions
2. Enforce trigger-frequency targets:
- common traits trigger often
- rare traits trigger regularly in intended builds
- legendary traits create visible spike moments
3. Add/adjust trait effects to strengthen archetypes (Blood/Bone/Void, and hybrid lines).
4. Ensure trait text exactly matches implementation behavior.

Acceptance:
- Trait impact table has fewer "flat" entries.
- Runs show distinguishable build identity by week 3-4.

## Phase 3 - Breeding Agency Pass
Priority: P1

Tasks:
1. Make nesting choices strategic, not cosmetic:
- favored breeder implementation
- nest focus actions (rarity focus / tier focus / family focus) with explicit costs
2. Add nest preview info in `NestSelect`:
- offspring rarity odds
- combo eligibility
- blocked reasons
3. Add breeding telemetry:
- expected vs actual newborn rarity/tier
- contribution to pass rates

Acceptance:
- Nesting decisions measurably change outcomes.
- Breeding contributes to mid-run stability instead of noise.

## Phase 4 - Relic Usefulness Pass
Priority: P1

Tasks:
1. Classify relics by function (economy, additive, multiplier, breeding, control).
2. Buff underperformers and trim outliers based on telemetry.
3. Preserve distinct identity so relics are not interchangeable.

Acceptance:
- Bottom-quartile relics improve in pick rate and/or impact.
- No single relic class dominates all successful runs.

## Phase 5 - Balance Tuning Loop
Priority: P2

Tasks:
1. Add config sweep utility in `TestRunner` for:
- `target_base`, `target_growth`
- overflow/early bonus settings
- round cap multiplier
2. Rank candidate configs by objective score:
- pass bands fit
- smoother week-to-week dropoff
- economy stability
3. Lock one baseline config and snapshot metrics.

Acceptance:
- Week 1-10 curve is challenging but non-cliffing.
- Runs do not collapse by week 3 under normal profiles.

## Execution Order (Recommended)
1. Phase 0
2. Phase 1
3. Phase 2 + Phase 3 in short alternating loops
4. Phase 4
5. Phase 5 final lock

## Immediate Next Sprint (Concrete)
1. Implement Phase 0 fixes.
2. Run full doctrine sim baseline.
3. Deliver ranked list:
- bottom 10 relics
- bottom 10 traits
- top 5 breeding levers to tune first.
