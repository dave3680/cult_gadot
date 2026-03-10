# Slice 4: Pool Growth, Breeding, and Synergy

## Objective
Make pool growth and breeding feel like a strategic engine that amplifies strong builds without breaking balance.

## Systems Introduced Or Modified
- Breeding chance tuning and inheritance rules.
- Pool cap behavior and overflow prevention.
- Apostles, favored breeders, and ascension effects.

## Why This Slice Is Sequenced Here
After power and economy are stabilized, pool growth becomes the main long-term amplifier.

## Detailed System Description
- Breeding tuning:
  - Adjust base breeding chance and Void penalties for stable growth.
  - Define deterministic inheritance ordering when parents have traits.
- Pool cap behavior:
  - Prevent additions at cap; avoid destructive deletion.
  - Improve logging of trims and outcomes.
- Agency upgrades:
  - Validate relic-gated actions (cull, favor, ascend, apostle) for meaningful value.

## Required Data Model Changes
- Add breeding summary counters for telemetry and tuning.

## UI Implications
- Optional: show weekly breeding summary in pool UI.

## Risk Analysis (Balance Dangers)
- Risk: breeding becomes too powerful or too weak to matter.
- Mitigation: target modest net growth with occasional spikes.

## Interaction With Existing Systems
- Relics and traits influence breeding outcomes.
- Pool growth feeds hand quality and scoring.

## Done Criteria
- Pool growth is noticeable and controllable.
- Breeding outcomes align with player agency and relic investment.
- Pool cap prevents runaway without feeling punitive.
