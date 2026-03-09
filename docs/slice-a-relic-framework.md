# Slice A: Relic Content Expansion Framework

## Objective
Create an extensible relic-effect hook system so new relics can be added without further bloating `GameState._score_selected_internal`.

## Scope Implemented
- Added a phase-based relic hook registry in `GameState.gd`.
- Added a central dispatcher that calls hook methods for owned relics.
- Migrated scoring relic behavior into hook methods across phases:
  - `PRE_ADD` (additive and blood-bonus effects)
  - `PRE_MULT` (additive multipliers before final multiplier calc)
  - `MULTIPLIER_ADJUST` (base/exponent and multiplier log effects)
  - `POST_RESOLVE` (post-score pool mutations)
- Kept existing target/balance config unchanged.

## Why This Completes Slice A
- New relic effects can now be introduced by:
  1. Adding a relic definition.
  2. Registering a hook in `RELIC_SCORING_HOOKS`.
  3. Implementing one hook method.
- Core round scoring no longer requires large inline conditional blocks for each relic.

## Validation
- Ran full headless test runner scene to validate parse/runtime path:
  - `Godot_v4.4-stable_mono_win64_console.exe --headless --scene res://scenes/TestRunner.tscn`
- Run completed without parser/runtime script errors.
