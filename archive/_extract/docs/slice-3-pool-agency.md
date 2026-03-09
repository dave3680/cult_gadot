# Slice 3: Economy & Shop Gamification

## Objective
Make the shop feel like a meaningful reward loop with consistent purchasing power and exciting choices.

## Systems Introduced Or Modified
- Relic pricing curve by week.
- Recruit pricing and tier weighting.
- Reroll costs and voucher interactions.

## Why This Slice Is Sequenced Here
Once power is tuned, the economy can be shaped to deliver progression and choice density.

## Detailed System Description
- Relic economy:
  - Scale relic costs by week to preserve tension and growth.
  - Align cost curve with early win and overflow blood rates.
- Reroll game feel:
  - Set reroll costs to keep rerolling optional, not mandatory.
  - Balance Sharpened Chalk and free reroll effects.
- Recruit value:
  - Adjust recruit tier distributions to feel impactful but not outpace relics.

## Required Data Model Changes
- Introduce a shop economy table (costs, reroll scaling, recruit odds).

## UI Implications
- Update cost labels to reflect week scaling.

## Risk Analysis (Balance Dangers)
- Risk: economy too stingy removes choice, too generous removes tension.
- Mitigation: target 1–2 meaningful purchases per shop, plus occasional high-roll.

## Interaction With Existing Systems
- Blood gain from scoring feeds the shop; relics feed back into scoring.

## Done Criteria
- Shops regularly offer a real choice between relics and recruits.
- Rerolls are valuable but not dominant.
- Economy supports late-week scaling without runaway.
