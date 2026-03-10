# Slice 5: Late-Game Scaling & Run Completion

## Objective
Finalize the core loop for 10-week runs with late-game scaling, victory conditions, and stability controls.

## Systems Introduced Or Modified
- Week cap and victory conditions for 10 weeks.
- Late-game target scaling tuning.
- Soft caps for additive and multiplier stacking.

## Why This Slice Is Sequenced Here
Once early/mid-game balance is stable, late-game pacing can be tuned without masking core issues.

## Detailed System Description
- Week cap alignment:
  - Ensure UI, victory, and test runner respect the 10-week run length.
- Late-game tuning:
  - Validate week 6–10 targets with simulated high-power builds.
  - Adjust exponent growth or additive soft caps to prevent runaway.
- Completion flow:
  - Ensure victory state triggers at week 10 with clean handoff to end scene.

## Required Data Model Changes
- Add `max_weeks` to run config and propagate to UI and tests.

## UI Implications
- Week label should show `/10` and update dynamically from config.

## Risk Analysis (Balance Dangers)
- Risk: late game becomes unwinnable without specific relics.
- Mitigation: validate with high-power but not perfect builds.

## Interaction With Existing Systems
- Scoring, relics, traits, and pool growth must remain viable through week 10.

## Done Criteria
- Runs can reasonably complete 10 weeks with strong builds.
- Late-game scaling feels challenging but fair.
- Victory condition is consistent across UI, logic, and tests.
