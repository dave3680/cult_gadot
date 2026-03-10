# Slice 2: Trait & Relic Power Pass

## Objective
Make traits and relics feel meaningfully powerful without breaking the curve or forcing specific combinations.

## Systems Introduced Or Modified
- Trait effects (common + rare) and trigger thresholds.
- Relic additive/multiplier bonuses and stacking rules.
- Multiplier trait cap consistency and logging.

## Why This Slice Is Sequenced Here
Once the baseline curve is stable, we can safely raise power and still track difficulty.

## Detailed System Description
- Buff and normalize weak traits/relics:
  - Ensure every common trait and relic has a noticeable impact in typical hands.
  - Bring underperforming relics in line via additive/multiplier adjustments.
- Guard against runaway stacking:
  - Set soft caps or diminishing returns on extreme additive/multiplier stacking.
  - Keep the “one multiplier trait per play” cap but clarify precedence.
- Improve clarity:
  - Ensure all triggered effects appear in breakdown logs.

## Required Data Model Changes
- Optional: data table for trait/relic deltas and stack caps.

## UI Implications
- No layout changes. Ensure tooltip and breakdown consistency.

## Risk Analysis (Balance Dangers)
- Risk: buffs invalidate difficulty curve.
- Mitigation: re-run sim after each tuning pass and adjust targets if needed.

## Interaction With Existing Systems
- Scoring pipeline directly consumes trait/relic modifiers.

## Done Criteria
- Average runs feel stronger without trivializing week targets.
- No relic/trait dominates across common hand compositions.
- Breakdown shows clear attribution for every effect.
