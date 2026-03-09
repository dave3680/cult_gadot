# Game System Documentation

This document is generated from the current repository contents and reflects implemented gameplay systems only. Systems marked as partial are implemented but incomplete or have obvious missing hooks.

---

# Master System Index

## System Dependency Graph (Text)
- UI scenes (`MainMenu.tscn`, `DoctrineSelect.tscn`, `RunGame.tscn`, `Shop.tscn`, `Victory.tscn`, `GameOver.tscn`) depend on the `GameState` autoload for all gameplay state and rules.
- `GameState.gd` owns core systems: run lifecycle, scoring, traits/beliefs, relics, economy, pool/hand, breeding, shop recruits, and week targets.
- `Shop.gd` depends on `GameState` for relic definitions, costs, eligibility, and pool actions.
- `RunGame.gd` depends on `GameState` for scoring, doctrine actions, pool handling, and overflow/early win bonuses.
- `TestRunner.gd` instantiates `GameState` directly to validate scoring, traits, relics, breeding, and balance simulation.
- No NavMesh or pathfinding integration is present.

## Gameplay Loop Breakdown
1. Main menu starts a run.
2. Doctrine selection initializes `GameState` and starting pool.
3. Week play (up to two rounds): select sacrifices, score devotion, earn blood.
4. If target met, shop phase: buy relics, recruits, and perform pool actions.
5. Breeding and weekly pool tier boosts occur after shop.
6. Repeat until victory (week cap) or failure.

## Technical Loop Breakdown
1. `MainMenu.gd` -> `DoctrineSelect.gd` -> `GameState.reset_run()` and `init_starting_pool()`.
2. `RunGame.gd` drives selections, calls `GameState.score_selected()` and `resolve_play_and_update_pool()`.
3. Overflow devotion converts to blood; early win bonus applied if cleared on round 1.
4. `Shop.gd` rolls relic offers and recruits using `GameState` data and RNG.
5. Pool actions (cull/favored/ascend/apostle) call into `GameState`.
6. `GameState.perform_weekly_breeding()` and `boost_pool_tiers_weekly()` are applied on shop exit.

## Risk Assessment Summary
- Tight coupling: `GameState` is a monolith that owns rule logic, RNG, and UI-facing breakdown strings.
- Difficulty mismatch: run victory still locked to week 5 in `RunGame.gd`, while targets are now formulaic and support more weeks.
- Economy volatility: many systems modify blood (overflow, early win, relics, traits) without a centralized budget model.
- Pool growth risk: breeding and weekly tier boosts can outrun balance without explicit cap logic beyond pool cap.

## Missing but Expected Systems
- Save/load or meta-progression persistence.
- Tutorial or onboarding.
- Audio/feedback systems.
- Localization/strings table.
- Analytics/telemetry.
- Combat or encounter system (none implemented; scoring is the core resolution mechanic).
- NavMesh/pathfinding (not present).

## Refactor Recommendations
1. Split `GameState.gd` into subsystem modules (scoring, economy, pool, breeding, shop rules) to reduce coupling.
2. Extract balance constants and target curve into a dedicated config file.
3. Introduce a system-level event log interface instead of building UI breakdown strings inside core logic.
4. Normalize run-length logic (targets, UI labels, victory conditions, test loops) into a single source of truth.

---

# Systems

## Run Lifecycle & State Management

### 1. Purpose
Owns the authoritative game state across scenes, including week progression, blood, pool, relics, and active run flags.

### 2. Core Mechanics
- Inputs: doctrine selection, UI interactions, relic purchases, recruit purchases, pool actions.
- Outputs: updated state, breakdown text, logs, blood counts, pool contents.
- State transitions: reset -> initialize pool -> week rounds -> shop -> next week -> victory or game over.
- Player-facing effects: week progression, visible blood amount, pool contents, relic effects.

### 3. Technical Architecture
- Main script: `scripts/GameState.gd` (autoload in `project.godot`).
- Key classes: `GameState` (extends `Node`).
- Signals used: none custom; UI uses button `pressed` signals.
- Data structures: arrays of follower dictionaries, relic inventory dictionary, trait registry dictionary.
- Scene nodes involved: none directly; UI scenes read/write to autoload.

### 4. Dependencies
- Depends on: Godot autoload system.
- Depended on by: all gameplay scenes and test runner.

### 5. Data Flow
1. `reset_run()` clears all run data.
2. `init_starting_pool()` seeds initial followers by doctrine.
3. `start_week()` initializes week state and clears hand.
4. Scoring and economy modify `blood_currency` and `week_total_devotion`.
5. Shop and breeding update pool state.

### 6. Current Limitations
- Monolithic file and shared mutable state.
- UI-facing strings and logs are created in core logic.
- Victory condition and UI labels still fixed to 5 weeks.

### 7. Expansion Hooks
- Add a run config struct for week cap, target curve, and rule variants.
- Introduce save/load serialization on `GameState` fields.

---

## Doctrine System

### 1. Purpose
Provides per-run doctrine choice that affects a single action per play and scoring modifiers.

### 2. Core Mechanics
- Inputs: doctrine selection and a single selected follower.
- Outputs: follower mutation (convert/refine/banish) and scoring modifiers.
- State transitions: doctrine selection -> per-play doctrine use -> reset each play.
- Player-facing effects: card text updates, doctrine action button, scoring bonuses.

### 3. Technical Architecture
- Scripts: `scripts/DoctrineSelect.gd`, `scripts/RunGame.gd`, `scripts/GameState.gd`.
- Key data: `GameState.selected_doctrine`, `GameState.doctrine_used_this_play`.
- Scene nodes: doctrine UI panel in `RunGame.tscn`.

### 4. Dependencies
- Depends on: hand/pool system and scoring system.
- Depended on by: scoring calculations and UI feedback.

### 5. Data Flow
1. `DoctrineSelect.gd` sets doctrine in `GameState`.
2. `RunGame.gd` applies per-play doctrine action on selected follower.
3. `GameState._score_selected_internal()` applies doctrine additive/multiplier effects.

### 6. Current Limitations
- Only one doctrine action per play; no upgrade paths.
- Doctrine effects are hard-coded in scoring logic.

### 7. Expansion Hooks
- Add doctrine upgrade tiers or alternative action modes.
- Externalize doctrine rules to data tables.

---

## Hand & Pool System

### 1. Purpose
Manages the follower pool, hand draw, sacrifice resolution, and retention mechanics.

### 2. Core Mechanics
- Inputs: selected sacrifices, pool actions (cull, ascend, favored, apostle), relic effects.
- Outputs: updated pool, exhausted states, survivors returned.
- State transitions: pool -> hand -> selected sacrifices -> pool updates.
- Player-facing effects: available followers, pool overlay, recruit purchases.

### 3. Technical Architecture
- Scripts: `scripts/GameState.gd`, `scripts/RunGame.gd`, `scripts/Shop.gd`.
- Data structures: `pool` array, `current_hand` array, follower dictionaries.
- Scene nodes: hand buttons, pool overlay, shop pool list.

### 4. Dependencies
- Depends on: relic system (resilient, rebirth), doctrine system.
- Depended on by: scoring, breeding, shop recruits.

### 5. Data Flow
1. `draw_hand_from_pool()` shuffles and draws 6 followers.
2. `score_selected()` uses selected indices.
3. `resolve_play_and_update_pool()` returns survivors and applies rebirth/resilient.

### 6. Current Limitations
- Pool minimum fill uses hard-coded recruit logic.
- Exhausted state is reset globally rather than per follower timer.

### 7. Expansion Hooks
- Add per-follower lifecycle states (wounds, cooldowns).
- Add pool filters or tagging for build archetypes.

---

## Scoring & Devotion System

### 1. Purpose
Computes devotion for a play using additive + multiplier model and applies blood rewards.

### 2. Core Mechanics
- Inputs: selected sacrifices, traits, relic inventory, doctrine, ritual cards.
- Outputs: `final_devotion`, `blood_gain`, breakdown text.
- State transitions: none; pure computation plus currency side effects.
- Player-facing effects: pass/fail outcome, breakdown UI, blood gain.

### 3. Technical Architecture
- Script: `scripts/GameState.gd` (`_score_selected_internal`).
- Data structures: arrays of lines for breakdown, trait/relic counters.
- Scene nodes: breakdown UI label in `RunGame.tscn`.

### 4. Dependencies
- Depends on: traits, relics, doctrines, ritual cards, economy.
- Depended on by: week progression and shop access.

### 5. Data Flow
1. Build sacrifice info and base additive values.
2. Apply relic additive effects and trait modifiers.
3. Apply doctrine additive and multiplier effects.
4. Compute multiplier base/exponent; compute final devotion.
5. Apply blood gain and side effects (resilient, rebirth, red thread).

### 6. Current Limitations
- Breakdown assembly is embedded in the scoring function.
- Modifier caps are hard-coded (e.g., one multiplier trait).
- Formula constants are embedded in code, not data.

### 7. Expansion Hooks
- Externalize scoring rules to data tables or scriptable effects.
- Add damage/mitigation layers or separate multiplier channels.

---

## Trait / Belief System

### 1. Purpose
Adds per-follower modifiers affecting scoring, economy, pool, and breeding.

### 2. Core Mechanics
- Inputs: trait IDs on followers, trait registry data.
- Outputs: additive/multiplier/blood effects, pool changes.
- State transitions: traits inherited via breeding or assigned via shop/omen.
- Player-facing effects: tooltips, trait rarity color, breakdown lines.

### 3. Technical Architecture
- Script: `scripts/GameState.gd`.
- Data structures: `TRAIT_REGISTRY`, `COMMON_TRAIT_IDS`, `RARE_TRAIT_IDS`.
- Scene nodes: card buttons and pool list labels for display.

### 4. Dependencies
- Depends on: scoring and breeding systems.
- Depended on by: economy and pool updates.

### 5. Data Flow
1. Trait registry provides name/rarity/desc.
2. Scoring checks trait IDs and applies effects.
3. Breeding and shop recruit generation assign trait IDs.

### 6. Current Limitations
- Trait effects are fully hard-coded in scoring logic.
- No stacking rules per trait beyond global multiplier cap.

### 7. Expansion Hooks
- Add trait effect descriptors or scripted hooks.
- Introduce trait leveling or mutation rules.

---

## Relic System

### 1. Purpose
Provides run-wide modifiers that affect scoring, economy, shop behavior, and pool rules.

### 2. Core Mechanics
- Inputs: relic purchases and inventory counts.
- Outputs: scoring modifiers, economy bonuses, shop rules, pool cap changes.
- State transitions: relic inventory increases via shop purchases.
- Player-facing effects: relic offer UI, breakdown lines, shop controls.

### 3. Technical Architecture
- Scripts: `scripts/GameState.gd`, `scripts/Shop.gd`, `scripts/RunGame.gd`.
- Data structures: `RELICS`, `RELIC_DEFS`, `relic_inventory`.
- Scene nodes: relic offer panels and buy buttons.

### 4. Dependencies
- Depends on: shop system for acquisition.
- Depended on by: scoring, economy, pool, breeding, rituals.

### 5. Data Flow
1. `Shop.gd` rolls offers based on rarity slots.
2. Purchase calls `GameState.add_relic()`.
3. Scoring and economy read `relic_inventory` during plays.

### 6. Current Limitations
- No persistence or relic history tracking.
- Some relics are vouchers/consumables but treated uniformly.

### 7. Expansion Hooks
- Add relic rarity weighting or pity systems.
- Support relic removal or upgrading.

---

## Ritual Card System (Partial)

### 1. Purpose
Provides a temporary, single-play modifier purchased from the shop.

### 2. Core Mechanics
- Inputs: ritual card purchase and manual activation.
- Outputs: additive bonus, VOID bonus, or rebirth effect.
- State transitions: offer -> slot -> active -> cleared after use.
- Player-facing effects: ritual panel in shop and use button in run.

### 3. Technical Architecture
- Scripts: `scripts/Shop.gd`, `scripts/RunGame.gd`, `scripts/GameState.gd`.
- Data structures: `RITUAL_CARDS`, `ritual_card_offer`, `ritual_card_slot`, `ritual_card_active`.

### 4. Dependencies
- Depends on: relic `Scarlet Planetarium` to enable offers.
- Depended on by: scoring and pool resolution (rebirth).

### 5. Data Flow
1. Shop offers ritual if relic present.
2. Player buys and stores in slot.
3. `RunGame.gd` activates and scoring consumes it.

### 6. Current Limitations
- Only three ritual types.
- No UI feedback for remaining uses beyond slot.

### 7. Expansion Hooks
- Add more ritual types or multi-use variants.
- Add ritual rarity or selection choice.

---

## Economy & Blood System

### 1. Purpose
Governs blood currency gains and spending for relics and recruits.

### 2. Core Mechanics
- Inputs: blood gain per sacrifice, overflow, early win bonus, relic/trait effects.
- Outputs: blood currency changes, debt tracking.
- State transitions: gains on scoring, spends on shop purchases.
- Player-facing effects: blood label, shop affordability.

### 3. Technical Architecture
- Script: `scripts/GameState.gd`.
- Supporting scripts: `RunGame.gd`, `Shop.gd`.
- Data structures: `blood_currency`, `blood_debt`.

### 4. Dependencies
- Depends on: scoring system and relic/trait effects.
- Depended on by: shop purchase logic.

### 5. Data Flow
1. `score_selected()` awards blood based on traits and relics.
2. Overflow devotion converts to blood in `RunGame.gd`.
3. Early win grants +20 blood in `RunGame.gd`.
4. `Shop.gd` spends blood for relics/recruits and applies interest.

### 6. Current Limitations
- Multiple independent sources of blood without a centralized budget model.
- Debt rules apply only to relic purchases.

### 7. Expansion Hooks
- Add weekly stipend or scaling income.
- Add explicit economy balance tables.

---

## Shop & Recruit System

### 1. Purpose
Provides post-week purchases of relics, recruits, and ritual cards.

### 2. Core Mechanics
- Inputs: blood currency, shop rolls, relic effects (discounts, rerolls).
- Outputs: relic inventory increases, pool recruits, ritual cards.
- State transitions: offers rolled -> purchases -> shop exit.
- Player-facing effects: offer panels, recruit cards, pool management.

### 3. Technical Architecture
- Scripts: `scripts/Shop.gd`, `scripts/GameState.gd`.
- Data structures: `shop_recruit_offers`, `shop_recruit_purchased`, `offers`.
- Scene nodes: offer panels, recruit panels, pool list.

### 4. Dependencies
- Depends on: relic definitions, economy, pool system.
- Depended on by: run power growth and pool quality.

### 5. Data Flow
1. `Shop.gd` rolls relic offers by rarity slots.
2. Recruits generated via `GameState.generate_shop_recruits()`.
3. Purchases update blood and pool state.
4. Shop exit triggers breeding and next week start.

### 6. Current Limitations
- Relic cost is fixed and does not scale by week.
- Recruit tier odds are hard-coded.

### 7. Expansion Hooks
- Add dynamic pricing or tier-based recruit costs.
- Add reroll limits or pity mechanics.

---

## Breeding System

### 1. Purpose
Generates new followers from the pool each week, with trait inheritance and relic modifiers.

### 2. Core Mechanics
- Inputs: pool pairs, breeding chance, favored breeders, relic modifiers.
- Outputs: new followers appended to pool.
- State transitions: pairs -> chance roll -> newborn creation -> pool cap trim.
- Player-facing effects: pool growth and trait propagation.

### 3. Technical Architecture
- Script: `scripts/GameState.gd`.
- Data structures: `favored_breeder_ids`, `apostle_id`, `pool`.

### 4. Dependencies
- Depends on: trait registry and relics (Fertility Idol, Seal of Inheritance, Chosen of the Veil, First Apostle).
- Depended on by: pool size and build shaping.

### 5. Data Flow
1. Shuffle pool and optionally prioritize favored breeders.
2. Pair followers and roll breeding chance.
3. Inherit trait and compute newborn tier.
4. Enforce pool cap by trimming newborns.

### 6. Current Limitations
- No visible UI feedback for breeding results in run scene.
- Trait inheritance prioritizes parents with any trait before random roll.

### 7. Expansion Hooks
- Add breeding result summaries in UI.
- Add trait mutation or hybridization rules.

---

## Pool Agency & Special Actions

### 1. Purpose
Allows player to manipulate pool via relic-enabled actions.

### 2. Core Mechanics
- Inputs: pool selection, relic gates (Culling Knife, Selective Breeding Scroll, Soul Lantern, First Apostle).
- Outputs: pool removals, favored breeders, ascension, apostle assignment.
- State transitions: select -> action -> update pool.
- Player-facing effects: pool list actions in shop.

### 3. Technical Architecture
- Scripts: `scripts/Shop.gd`, `scripts/GameState.gd`.
- Scene nodes: pool action buttons in `Shop.tscn`.

### 4. Dependencies
- Depends on: relic inventory and pool data.
- Depended on by: breeding and pool balance.

### 5. Data Flow
1. Select a pool entry in shop.
2. Action buttons enabled based on relics and state.
3. `GameState` mutates pool accordingly.

### 6. Current Limitations
- No multi-select or bulk actions.
- Actions are hard-gated by relic presence without alternative costs.

### 7. Expansion Hooks
- Add costs for actions without relics.
- Add undo or confirmation steps.

---

## Week Targeting & Difficulty Curve

### 1. Purpose
Defines devotion targets per week and scales difficulty.

### 2. Core Mechanics
- Inputs: week number, Director's Cut overrides.
- Outputs: numeric target used by scoring.
- State transitions: optional override stored for next week.
- Player-facing effects: target label and preview calculation.

### 3. Technical Architecture
- Script: `scripts/GameState.gd`.
- Data: formulaic curve using `base_target` and `growth`.

### 4. Dependencies
- Depends on: none.
- Depended on by: scoring and UI display.

### 5. Data Flow
1. `get_week_target()` returns formula-based value.
2. `Shop.gd` may override next week via Director's Cut.

### 6. Current Limitations
- Run victory condition still hard-coded to 5 weeks in `RunGame.gd`.
- UI label still displays `Week %d/5`.

### 7. Expansion Hooks
- Add explicit week cap in `GameState` and bind UI to it.
- Add per-week target table for tuning.

---

## Test & Balance Simulation System

### 1. Purpose
Runs automated validation of relics, traits, breeding, and balance simulations.

### 2. Core Mechanics
- Inputs: deterministic seed, exhaustive hands, random simulations.
- Outputs: report files and console logs.
- State transitions: none; test harness only.
- Player-facing effects: none (developer tooling).

### 3. Technical Architecture
- Script: `scripts/TestRunner.gd`.
- Scene: `scenes/TestRunner.tscn`.
- Outputs: `docs/test_reports/exhaustive_report_*.txt`.

### 4. Dependencies
- Depends on: `GameState` logic.
- Depended on by: balancing workflow.

### 5. Data Flow
1. Instantiate `GameState` with deterministic seed.
2. Run assertion suites for relics and traits.
3. Run balance simulation with random picks and shop model.
4. Write report to `docs/test_reports`.

### 6. Current Limitations
- Simulation uses simplified shop behavior.
- Intentional failure test always fails (requires manual removal to pass all tests).

### 7. Expansion Hooks
- Add configurable sim parameters.
- Add performance regression tracking.

---

# Architecture Summary

- Overall architecture pattern: centralized state singleton (`GameState`) with scene controllers for UI and flow.
- State management model: mutable global state with immediate side effects; no event bus.
- Procedural generation integration: RNG in `GameState` for followers, shop recruits, breeding, and relic offer rolls.
- Scoring integration with relics/traits/beliefs: all effects applied inside `_score_selected_internal()` with additive and multiplier phases.
- Performance risk areas: scoring and exhaustive tests scale with combinations; breakdown string construction is heavy.
- Coupling analysis: UI scenes are thin but highly dependent on `GameState` internals.

---

# Slice Readiness Analysis

## Stable Systems
- Core scoring pipeline (additive + multiplier).
- Relic inventory and offer generation.
- Basic shop and recruit purchase flow.

## Fragile Systems
- Week progression logic (week cap vs target curve mismatch).
- Economy balance (many overlapping sources of blood gains).
- Breeding growth vs pool cap tuning.

## Systems Needing Refactor
- `GameState.gd` monolith.
- Breakdown/log generation inside scoring logic.
- UI references to hard-coded week counts.

## Recommended Next 3 Safe Development Slices
1. Unify run-length configuration (week cap, target curve, UI labels, tests) into a single config object.
2. Extract scoring modifiers into a data-driven ruleset to enable tuning without code edits.
3. Add breeding and economy telemetry (counts and averages) to support balance passes.
