# Slice 1: Core Power Curve & Target Alignment

Status note (2026-02-26): this file is a planning snapshot, not the current tuned config source.
For repository-accurate live values, use `scripts/GameState.gd` (`RUN_CONFIG_DEFAULT`) and `docs/Game_System_Documentation.md`.
Current code values are `target_base=40`, `target_growth=1.5`, `overflow_weekly_cap=4`, `early_win_bonus=20`.

## Objective
Establish a validated baseline power curve and target alignment for the run, so later balance slices are tuned against stable, measurable goals.

## Implementation Plan (Balance Focus)

### 1) Define balance targets
- Document explicit power bands per week:
  - Expected devotion range (per round and per week).
  - Acceptable win/loss rates by week.
  - Desired Blood gain per week (including overflow and early win bonuses).
- Specify target bands for “expert play” vs “average play.”

### 2) Introduce a Run Config object
- Create a config struct/data resource for all curve constants:
  - `max_weeks`, `target_base`, `target_growth`.
  - `overflow_blood_per_devotion`, `overflow_weekly_cap`.
  - `early_win_bonus`.
- Ensure all references in `GameState.gd` read from this config.

### 3) Integrate config into GameState
- Refactor:
  - `get_week_target()`
  - `get_max_weeks()`
  - Overflow and early win logic
  - Week init logic
- Allow injecting config for simulation and tuning.

### 4) Expand simulation metrics
- Add per-week outputs:
  - Devotion achieved
  - Overflow gained
  - Blood earned/spent
  - Win/loss outcome
  - Pool size
- Produce per-week min/avg/max summaries.

### 5) Add validation checks
- Implement automated checks in `TestRunner.gd` against the balance targets.
- Fail the output if any week falls outside target bands.

### 6) Run tuning passes
- Iterate on `TARGET_BASE` / `TARGET_GROWTH` and bonus caps using the new metrics.
- Lock in constants once targets are met.

### 7) Document results
- Update `docs/Game_System_Documentation.md` with the final targets and config structure.
- Add a “Slice 1 Balance Spec” section with current numbers and rationale.

## Balance Targets (Slice 1 Spec)

### Run Config (Current)
- `max_weeks`: 10
- `target_base`: 18.0
- `target_growth`: 1.45
- `overflow_blood_per_devotion`: 1
- `overflow_weekly_cap`: 24
- `early_win_bonus`: 15

### Pass Rate Bands (Linear Over Weeks)
- Expert: 90–99% (Week 1) → 60–85% (Week 10)
- Average: 75–92% (Week 1) → 25–55% (Week 10)

### Devotion Output Bands
- Avg week devotion:
  - Expert: 0.95–1.35× target
  - Average: 0.80–1.15× target
- Avg round devotion:
  - Expert: 0.55–0.90× target
  - Average: 0.40–0.70× target

### Economy Bands (Avg Blood Earned / Week)
- Expert: 5–14 (Week 1) → 8–22 (Week 10)
- Average: 3–10 (Week 1) → 5–16 (Week 10)

## Done Criteria
- Target curve hits defined win/loss rates in simulation for both expert and average profiles.
- Overflow and early win bonuses support progression without runaway economy.
- All week targets and caps are driven by the run config (no hard-coded constants in gameplay code).
