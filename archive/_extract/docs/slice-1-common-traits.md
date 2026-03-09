# Slice 1: Core Power Curve & Target Alignment

## Objective
Lock a fun, powerful-feeling baseline for followers, traits, and relics while ensuring week targets match expected output.

## Systems Introduced Or Modified
- Week target curve (base, growth, week cap integration).
- Early win and overflow blood tuning.
- Base follower tier distributions and trait chance tuning (start + shop).

## Why This Slice Is Sequenced Here
All later balance work depends on a stable power baseline. If the curve is wrong, every other system will be tuned against noise.

## Detailed System Description
- Establish a target power band per week:
  - Define expected devotion per round and per week for baseline hands.
  - Validate average devotion with and without 1–2 common relics.
- Rebalance base values:
  - Adjust week targets to hit desired clear rates (e.g., W1 75–85%, W5 35–50% for average play).
  - Validate early win bonus and overflow conversion against relic pricing.
- Ensure UI and logic read from a single week-cap configuration.

## Required Data Model Changes
- Introduce a run config structure for week cap and curve parameters.

## UI Implications
- Update week label to read from week cap.
- Ensure preview uses new target values and remaining target logic.

## Risk Analysis (Balance Dangers)
- Risk: targets too high make relic luck mandatory.
- Mitigation: validate with balance sim and deterministic test hands.

## Interaction With Existing Systems
- Scoring and economy directly depend on target curve and overflow rules.

## Done Criteria
- Week target curve produces desired clear rates in simulation.
- Early win/overflow produce meaningful but not runaway economy.
- UI displays correct week count and target values.
