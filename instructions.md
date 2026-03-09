# Cult of Accumulation: Current State, Systems, and Codex Operations Guide

## 1) Game Overview

Cult of Accumulation is a run-based, score-chasing strategy game with roguelite progression across weeks. Each week has a devotion target. The player builds a follower pool, chooses sacrifices each round, and combines:
- follower main traits (`BLOOD`, `BONE`, `VOID`, `SOUL`),
- follower sub-traits (common/rare/legendary + combo traits),
- doctrine effects,
- relic effects,
- economy decisions in shop,
- breeding outcomes (nest + wild).

The run ends on failure (after round 2 miss) or victory at max week.

## 2) Core Loop and Scene Flow

Current default scene flow:
1. `MainMenu` -> 2. `DoctrineSelect` -> 3. `RunGame`
4. On week clear: `Breeding` (results summary) -> `Shop` -> `NestSelect` -> next `RunGame`
5. On fail: `GameOver`
6. On final clear: `Victory`

Main files:
- `res://scripts/MainMenu.gd`
- `res://scripts/DoctrineSelect.gd`
- `res://scripts/RunGame.gd`
- `res://scripts/Breeding.gd`
- `res://scripts/Shop.gd`
- `res://scripts/NestSelect.gd`
- `res://scripts/GameOver.gd`
- `res://scripts/Victory.gd`

## 3) What the Player Is Optimizing

Primary objective:
- Meet weekly devotion target in up to 2 rounds.

Secondary objectives:
- Maximize blood income and conversion efficiency.
- Maintain strong pool quality (tier and trait quality).
- Build relic engine with correct rarity/value purchases.
- Use nests for deterministic/high-value breeding while preserving combat depth.

## 4) Global State Model

`GameState.gd` is the source of truth.

Important state domains:
- Run progression: `current_week`, `week_round`, `week_total_devotion`.
- Economy: `blood_currency`, `blood_debt`, overflow/early-win tracking.
- Combat state: `current_hand`, pending resolve buffers.
- Pool state: follower dictionaries with id/tier/trait/trait_id.
- Meta systems: relic inventory, doctrine, ritual state.
- Breeding state: nest assignments, last nest results, breeding summaries.
- Balance config: `run_config` seeded from `RUN_CONFIG_DEFAULT`.

## 5) Scoring System (Combat)

A round score is built as:
1. Additive subtotal:
- base follower contributions
- doctrine additive
- relic additive hooks
- trait additive hooks

2. Multiplier:
- base derived largely from void count and effects
- exponent from relics/doctrine/traits
- additional factors (e.g. refined-void scaling)

3. Final devotion:
- `final_devotion = additive_total * multiplier * extra_factors`
- then optional round cap from `run_config.round_devotion_cap_mult`

Blood gain per round:
- base from blood sacrifices + trait/relic blood bonuses.

Week-level extras:
- overflow conversion is active via `GameState.apply_overflow_blood_for_target(...)`:
  - default conversion is 1 overflow devotion -> 1 Blood,
  - `run_config.overflow_weekly_cap` only applies when > 0 (default is 0 = no cap),
  - tracked incrementally per week.
- early win bonus is active when week is cleared in round 1.

## 6) Targets, Growth, and Economy Config

Default run config currently:
- `max_weeks = 10`
- `target_base = 40`
- `target_growth = 1.5`
- `overflow_devotion_per_blood = 1`
- `overflow_blood_per_devotion = 1` (historical compatibility setting; overflow conversion now uses `overflow_devotion_per_blood` in `GameState`)
- `overflow_weekly_cap = 0`
- `early_win_bonus = 20`
- `round_devotion_cap_mult = 1.25`

Weekly target formula:
- `raw = base * growth^(week-1)`
- rounded to nearest integer,
- then rounded to nearest multiple of 5.

Shop relic cost formula:
- `COMMON = 10`, `UNCOMMON = 20`, `RARE = 30`, `LEGENDARY = 40`
- i.e. +10 per rarity step (before discounts).

## 7) Traits System

Current trait counts:
- 15 common
- 15 rare
- 5 legendary

Trait data lives in `TRAIT_REGISTRY` in `GameState.gd`.

Trait effects are evaluated in combat scoring and can influence:
- additive devotion,
- multiplier base/exponent,
- blood currency,
- pool events (e.g., spawning followers),
- breeding-specific outcomes (selected traits).

## 8) Combo Traits System

Combo trait generation:
- Implemented in `scripts/ComboTraitGenerator.gd`.
- Current curated seeds: 50 combo traits, mostly rare/legendary combos.
- Catalog loaded at runtime into `combo_trait_catalog`.
- Indexed by normalized parent pair key for breeding lookup.

UI compatibility:
- Combo traits now resolve through fallback lookup in gameplay/shop/nest UI.
- Tooltips and rarity marks support combo traits (not only base registry traits).

## 9) Breeding System (Current)

Breeding now has two channels each cleared week:
1. Nest breeding (guaranteed per active nest pair, subject to validity/cap checks)
2. Wild breeding (reintroduced; uses non-nested pool members)

### Nest breeding behavior
- Nests are assigned in `NestSelect` (drag followers into parent slots A/B).
- Nested followers do not appear in battle.
- Each valid nest pair attempts a birth.
- Trait selection for nest births follows rarity-aware rules:
  - two legendary parents -> legendary target rarity
  - two rare parents -> rare target rarity
  - one legendary present -> minimum rare, with chance to become legendary
  - one rare present -> chance to be rare (else common)
- Pair-specific combo trait is preferred when available for selected rarity.
- Fallback is parent-matching rarity or random trait of target rarity.

### Wild breeding behavior
- Uses only non-nested, non-`SOUL` followers.
- Randomly shuffled into pairs.
- Pair success chance from `_breeding_chance(...)`.
- Trait roll can be blank (no trait), by design.

### Additional breeding modifiers still active
- `brood_keeper`, `lineage_tutor`, `apostolic_womb`, apostle logic, pool-cap trim behavior.

## 10) Nest UX and Breeding UX

Nest workflow:
- `NestSelect` shows pool list, drag-drop parent assignment, and nested markers.
- Continue from NestSelect starts next `RunGame` week.

Breeding update scene:
- `Breeding` currently summarizes nest outcomes and total breeding summary before shop.

## 11) Shop System

Shop responsibilities:
- Roll and render relic offers by rarity curve.
- Recruit offers and purchases.
- Reroll logic + free-reroll interactions.
- Ritual card offer/buy/use setup.
- Pool management actions (cull/ascend/apostle/pack actions).
- End-of-shop progression -> boosts pool tiers, increments week, enters `NestSelect`.

## 12) Window, Menu, and Runtime UI State

Display/runtime settings currently:
- viewport and override: `1920x1080`
- mode: fullscreen (`display/window/size/mode=3`)

Global always-on menu:
- `GlobalMenuOverlay` autoload creates a persistent top-right `Menu` button.
- Popup options include `Main Menu`, `Exit Game`, `Close`.

Main menu also has settings popup with exit.

## 13) Simulation and Validation System

### What TestRunner does
`scenes/TestRunner.tscn` + `scripts/TestRunner.gd` run simulation-heavy balance validation and write reports.

Main outputs:
- Console report of per-week metrics.
- Fail/warn summary against configured balance bands.
- Text report under: `docs/test_reports/exhaustive_report_*.txt`
- CSV metrics under: `docs/test_reports/sim_metrics_*.csv`

Core metrics captured:
- pass rate per week
- average round devotion
- average weekly devotion
- overflow blood / early bonus contribution
- avg blood earned/spent
- avg pool size
- avg relic count (wins/losses/end-week)
- shop entry blood
- relic impact ranking
- trait impact ranking

Balance bands are profile-based (`expert`, `average`) in `BALANCE_TARGETS`.

### How pass/fail works
- `TestRunner` exits non-zero when failures exist.
- Non-zero does not necessarily mean crash; it commonly means band mismatch.

## 14) How Codex Should Run the Simulation

### Canonical headless command (Windows, current environment)
Use:

```powershell
& "C:\Users\david\Desktop\misc\Godot net\Godot_v4.4-stable_mono_win64\Godot_v4.4-stable_mono_win64_console.exe" --headless --scene res://scenes/TestRunner.tscn
```

### Operational notes for Codex
- Expect runtime in seconds to minutes depending on run counts.
- If command fails due sandbox/permission constraints, request escalated execution approval and rerun the same command.
- Treat parse errors as blocking correctness failures.
- Treat balance-band failures as tuning feedback, not runtime failure.
- After each run, summarize:
  - week-by-week pass rates,
  - avg blood earned/spent,
  - where runs die,
  - relic/trait impact shifts,
  - whether failures are now earlier or later.

### For parameter tuning loops
When tuning is requested:
1. Change only clearly scoped constants/config values.
2. Run full sim.
3. Record deltas against previous run.
4. Iterate with small step sizes unless directed otherwise.

## 15) Recent Implementation Changes (Current State)

Recent major changes now present in codebase:
- Fullscreen/window standardization to 1920x1080.
- Persistent global menu button and menu popup (main menu + in-run access).
- Nest selection phase as explicit scene; nesting removed from shop pool view.
- Breeding update scene before shop that reports outcomes.
- Trait system expanded to 15 common / 15 rare / 5 legendary.
- Combo trait catalog/generator added with 50 curated rare+legendary combinations.
- UI trait display/tooltip fallback updated to support combo traits.
- Target progression set to base 40 and growth 1.5 with target rounding to nearest multiple of 5.
- Relic pricing changed to +10 per rarity tier.
- Nest breeding and wild breeding now both active after each cleared week.
- Wild breeding restored with chance of no trait.
- Nest breeding updated with rarity-aware parent outcome rules and combo preference.

## 16) Known Current State of Balance

Latest test run indicates:
- Simulation executes successfully.
- Balance bands are currently failing heavily in later weeks.
- Typical pattern: strong early success, steep collapse by weeks 3-5 under current tuning.

Interpretation:
- Runtime mechanics are operating.
- Balance still requires iterative tuning of economy growth, devotion scaling, and long-run engine sustain.

## 17) Future Implementation Roadmap

### A) Follower/Breeding Depth (highest priority)
1. Expand nest strategy UI clarity:
- show projected offspring rarity/trait odds per pair,
- show blocked pair reasons inline,
- show historical offspring log per nest.

2. Improve breeding agency:
- optional nest actions (focus rarity, focus tier, focus trait family) with explicit cost.

3. Add stronger follower lifecycle:
- age/cooldown/fertility states to create meaningful long-horizon roster planning.

### B) Balance and Progression
1. Tune week pacing to avoid hard cliff after week 3.
2. Re-check blood income vs spend pressure curve.
3. Reassess round cap multiplier and multiplicative scaling pressure.
4. Add explicit balancing profile presets in run config.

### C) Tooling and Simulation
1. Add first-class run-config sweep utility inside `TestRunner`:
- iterate over base/growth/bonuses/caps,
- output ranked candidate configs by objective function,
- include top-N recommendation printout.

2. Add deterministic scenario tests for nesting rarity rules and combo fallback.
3. Add regression snapshots for key metrics by date/commit marker.

### D) UX and Explainability
1. Add in-game concise formula panel for current sacrifice.
2. Add richer post-week summary with economy decomposition.
3. Improve shop readability for relic/recruit opportunity cost.

## 18) Practical Codex Workflow for This Project

When asked to balance/tune:
1. Inspect `GameState.gd` constants and `run_config` values.
2. Make minimal edits.
3. Run headless TestRunner.
4. Report concrete metrics and failures.
5. Iterate.

When asked to implement systems:
1. Edit system source (`GameState` first for rules).
2. Update scene scripts for flow/UI alignment (`RunGame`, `Shop`, `NestSelect`, `Breeding`).
3. Validate with TestRunner and (if requested) interactive run.
4. Summarize both behavior changes and risk areas.

When encountering permission/memory-read issues:
- Request escalated command execution for Godot headless runs.
- Do not continue assuming results if the run did not complete.

## 19) File Map (Most Relevant)

- Core game state and mechanics:
  - `scripts/GameState.gd`
- Combat loop UI and progression trigger:
  - `scripts/RunGame.gd`
- Shop and between-week progression:
  - `scripts/Shop.gd`
- Nest assignment UX:
  - `scripts/NestSelect.gd`
- Breeding results summary scene:
  - `scripts/Breeding.gd`
- Trait combo generation:
  - `scripts/ComboTraitGenerator.gd`
- Simulation and balance validation:
  - `scripts/TestRunner.gd`
- Persistent runtime menu:
  - `scripts/GlobalMenuOverlay.gd`
- Project display settings:
  - `project.godot`

## 20) Definition of Done for Next Major Milestone

The next milestone should be considered complete when:
- breeding/nest depth creates clear strategic decisions across multiple weeks,
- simulation pass-rate bands are within target across most of the run,
- economy and devotion curves are stable without early collapse,
- TestRunner includes automated multi-parameter sweep and ranking,
- UI clearly communicates why runs succeed/fail and what to adjust.
