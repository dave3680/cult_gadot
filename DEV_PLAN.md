# Cult of Accumulation — Development Plan
*Updated March 2026. See GAME_DESIGN_DOC.md for full mechanical reference.*

---

## Current State

### What's Done

**Phase 1 — Stabilise** ✅
- Deleted all dead code stubs (`draw_new_hand`, `get_shop_rarity_slots`, `_deferred_change_scene`)
- Set `RUN_ONLY_SIM = false` (mechanical unit tests now run)
- Fixed Soul Lantern description (hidden blood drain was undocumented)
- Fixed Hollow Chant description (exponent mechanic now stated clearly)
- Fixed `chosen_veil` type: BREEDING → HYBRID
- Differentiated Bone Idol from Ossuary Standards
- Implemented `_offer_legendary_if_needed()` (guaranteed legendary at week 6 if none seen)

**Phase 2 — Core Rebalance** ✅
- Target growth: 1.50 → 1.38; week 8–10 manual overrides (400/620/1000)
- Starting blood: 0 → 5
- Overflow blood capped at `floor(target × 0.50)`
- Doctrine scaling: FLESH/RUIN now percentage-of-target (was flat additive)
- Per-round devotion cap → per-week devotion cap (`2.0 × target`)
- VOID tier fix: VOID-VOID pairs now produce tier 1+ offspring (was always tier 0)
- `MULTIPLIER_TRAIT_CAP` raised from 1 to 2

**Phase 3 — Relic Expansion** ✅ (implemented, partially tested)
- 100 new relics across 10 archetypes added to GameState
- Codex system: persistent discovery log across runs
- Shop UI overhaul: 5 offer slots (was 3), rotary swap, hover effects, multi-trait display

### Test Status (as of Phase 2 fixup, commit `aca497a`)

```
Mechanical tests:  44,576 / 44,576 PASS
Balance sim:       34 FAIL  (target: 0 failures)
Warnings:          38 (non-blocking)
```

---

## Balance Sim Failures — Diagnosis

The simulation runs 600 games per profile (expert / average) × 3 doctrines = 3,600 total.

### Pattern A — Early weeks too easy (weeks 1–4)

| Check | Expected | Actual |
|-------|----------|--------|
| Expert week 1 pass rate | 0.90–0.99 | **1.00** |
| Expert week 2 pass rate | 0.87–0.97 | **1.00** |
| Average week 1 pass rate | 0.75–0.92 | **0.98** |
| Expert week 1 avg devotion | 38–54 | **69.74** |
| Expert week 4 avg devotion | 95–142 | **146.66** |

**Root cause**: Per-round scoring is higher than calibrated. With `MULTIPLIER_TRAIT_CAP = 2` and the new relic pool, builds regularly score 1.5–1.7× the weekly target in early weeks. The 2× weekly cap doesn't constrain them because they're under the cap — they just score high and pass easily.

### Pattern B — Late weeks too hard (weeks 5–10)

| Check | Expected | Actual |
|-------|----------|--------|
| Expert week 5 pass rate | 0.77–0.93 | **0.70** |
| Expert week 7 pass rate | 0.70–0.90 | **0.42** |
| Expert week 10 pass rate | 0.60–0.85 | **0.19** |
| Average week 4 pass rate | 0.58–0.80 | **0.46** |
| Average week 10 pass rate | 0.25–0.55 | **0.03** |

**Root cause**: The exponential target curve (×1.38/week) outpaces player devotion growth, which is roughly linear after week 4. Critically: runs that DO survive to weeks 7–10 score well per-surviving-run (expert week 7 survivors average ~375 devotion vs. a 275 target — comfortably above). The problem is **too few runs survive to those weeks** because the weeks 5–7 wall is too steep.

### Insight: Conditional Pass Rates vs. Cumulative

Conditional pass rates (given a run reaches that week) look much better:
- Week 6: ~80% of runs that reach it pass → within band
- Week 7: ~75% of runs that reach it pass → within band
- Week 8: ~76% of runs that reach it pass → within band

The cumulative pass rate failures cascade from week 5 (70% conditional, need 77%). Fix week 5 → fix all downstream failures.

---

## Immediate Priority: Balance Tuning

### Proposed Changes

**Lower `target_growth` from 1.38 → 1.30 and reduce week 8–10 overrides.**

| Week | Current | Proposed |
|------|---------|---------|
| 1 | 40 | 40 |
| 2 | 55 | 52 |
| 3 | 75 | 68 |
| 4 | 105 | 88 |
| 5 | 145 | 114 |
| 6 | 200 | 148 |
| 7 | 275 | 193 |
| 8 | 400 | **310** (override) |
| 9 | 620 | **455** (override) |
| 10 | 1000 | **700** (override) |

**Effect**:
- Week 5 target drops 145 → 114 (−21%). More runs survive.
- Weeks 8–10 become achievable for a broader range of builds (not just lucky multiplier chains).
- Week 10 at 700 is still a meaningful challenge (survivors currently average ~361/week).
- Early weeks (1–4) remain very accessible, but some fraction of average-profile runs should start failing weeks 3–4 as targets rise above 88.

**Files to change**:
- `scripts/GameState.gd`: `RUN_CONFIG_DEFAULT["target_growth"] = 1.30` and update `week_target_overrides`

**Re-run sim after** to verify. If expert week 1–2 pass rate is still 1.00 (not yet causing early failures), consider raising `target_base` from 40 to 46–50 on a second iteration.

**Alternative approach** (if the above still leaves weeks 1–2 at 100%):
- Raise `target_base` to 50 simultaneously: week 1 = 50 → some expert runs will fail early (pass rate ~93%), bringing it into the 90–99% band.
- Only do this if the first change alone doesn't fix weeks 1–2.

---

## Next Priorities (in order)

### 1. Verify Shop.gd Compatibility with GameState

The Shop.gd overhaul (Phase 3) references several GameState methods that need to exist:

```
gs.start_shop_visit()
gs.finalize_shop_visit()
gs.guaranteed_rare_next_shop
gs.tithe_accelerator_interest_bonus
gs.shop_any_purchase_this_visit
gs.codex_mark_relic_seen()
gs.is_pool_at_capacity()
gs.get_pool_load_for_cap()
gs.get_directors_cut_max_uses()
gs.get_directors_cut_range_pct()
gs.pruning_hook_used_shop
gs.rotary_used_shop
gs.use_rotary_swap()
gs.director_uses_this_shop
```

**Action**: Read Shop.gd and GameState.gd side-by-side. For each Shop reference, verify the GameState method/property exists. Stub any missing ones. Run the game (not headless) and navigate to the Shop to confirm no runtime errors.

The test count drop (45,081 → 44,576 = 505 fewer tests) may be related to this — if Shop.gd has parse errors or references to undefined methods, some scene-dependent tests may be skipped.

### 2. Third Nest Slot

As described in the DevPlan (§3.3): add a purchasable third nest slot.

- **Unlock**: Week 5+ shop; costs 25 blood; one-time purchase
- **Alternative**: Automatic at 2+ Deep Pool relics (currently implemented? Verify)
- **Motivation**: Breeding-focused players plateau at 2 nests by week 6

**Implementation**: Add `nest_slot_3_unlocked: bool` to GameState. Add shop offer in `_roll_offers()` or as a special voucher slot. Update NestSelect UI to show third slot when unlocked.

### 3. Free Ritual Card at Week 3

Currently ritual cards are gated behind Scarlet Planetarium (a Rare relic that may never appear). Many players finish runs without knowing ritual cards exist.

- **Change**: At week 3 shop entry, if player has no ritual cards and no Scarlet Planetarium, offer 1 free ritual card choice (Anoint / Silence / Rebirth).
- **Planetarium then becomes**: "permanent access to ritual cards every week" rather than "first access".

**Implementation**: Add `free_ritual_card_offered_week3: bool` flag to GameState. In `_ready()` of Shop.gd (or `start_shop_visit()`), check if week == 3 and flag not set → inject one free ritual card slot.

### 4. Sound & VFX Polish

No audio system currently exists. High-impact plays (multiplier base 4+, exponent 3+) produce no feedback.

Priority moments for SFX/VFX:
1. Sacrifice resolve: devotion number fly-up
2. High-multiplier "big number" moment (some visual flash or screen shake)
3. Week clear / fail
4. Relic acquisition (satisfying chime)
5. Breeding reveal (offspring animation)

Godot's `AudioStreamPlayer` + `Tween` nodes would handle most of this. No external dependencies needed.

### 5. Codex Trophy System

The Codex currently tracks discoveries only. Add trophies for:

- Clearing week 10 with a cursed relic equipped (e.g., The Hungry Altar)
- Clearing week 10 with Path of Silence with 3+ refined VOID
- Breeding a combo trait from a specific pair
- Winning with all 3 doctrines (three separate trophies)

Trophy data persists in `codex_data.json`. Display in the Codex browser.

### 6. Tutorial Week 1

The game drops the player directly into sacrifice selection with no guidance. Add an optional tutorial overlay for week 1:

- Step 1: Explain followers (BLOOD / BONE / VOID)
- Step 2: Explain the pit (drag 3 to sacrifice)
- Step 3: Explain devotion vs. target
- Step 4: Explain the shop (buy relics)

Tutorial can be skipped. Offer at run start: "Play Tutorial?" Yes/No. Track `tutorial_completed: bool` in Codex save data; don't offer again if completed.

---

## Open Questions / Design Decisions

### Should week 10 stay at 1000?

The current data shows expert survivors at week 10 average ~361 devotion/week. The 1000 target requires roughly 3× more output. Only top-1% builds (strong multiplier chains) hit it consistently. This feels intentional — week 10 should require a real build — but 19% expert pass rate (target: 60–85%) suggests the target is too high for the current relic/trait pool.

**Decision point**: Keep 1000 after 100-relic expansion gives players more tools, OR lower now to 700–800 to hit balance targets with current content. Recommend lowering to 700 initially and revisiting post-relic-balancing.

### How many relics should be in a typical run?

At week 10, expert runs average 32 relics. Average-profile runs that reach week 10 have 30+. This is a lot of state to track and display. The RelicDrawer sidebar may become overwhelming. Consider:
- Maximum relic slots (e.g., 30) with a choice when full
- Relic "slots" that allow upgrades rather than new purchases

### SOUL trait — currently unused in doctrine

SOUL followers exist in the pool but no doctrine directly rewards SOUL composition. They function as BLOOD substitutes (tier × 1 additive). Options:
- Leave as-is (SOUL = flexible filler)
- Add a SOUL-specific doctrine or relic archetype
- Remove SOUL entirely and consolidate into BLOOD

### Pool feels passive in mid-game

By week 5, players have 25–40 followers in pool and mostly ignore the non-nested ones. The breeding system doesn't feel like "active management." Consider:
- Followers degrade if not sacrificed in N weeks (creates pressure to rotate)
- Pool followers gain "experience" from being in hand (tier growth for used followers)
- Culling bonuses (Pruning Hook) more prominent in shop UI

---

## Technical Debt

| Item | Priority | Notes |
|------|----------|-------|
| Shop.gd ↔ GameState.gd API surface | High | Verify all references; stub missing methods |
| Test count drop (505 tests) | Medium | Likely Shop.gd parse issue; investigate |
| Balance sim 34 failures | High | Fix with target_growth adjustment (see above) |
| No audio system | Medium | Start with SFX stubs; add assets later |
| NestSelect performance | Low | Large pools (500+) may lag during drag-and-drop; profile and optimize if needed |
| Godot path not in bash PATH | Low | Must invoke via PowerShell: `powershell.exe -Command "& 'C:\Users\david\Desktop\misc\Godot net\Godot_v4.4-stable_mono_win64\Godot.exe' ..."` |

---

## Testing Protocol

After any balance or scoring change:

```powershell
powershell.exe -Command "& 'C:\Users\david\Desktop\misc\Godot net\Godot_v4.4-stable_mono_win64\Godot.exe' --headless --path 'C:/Users/david/Documents/cult' --scene 'res://scenes/TestRunner.tscn'" > test_out.log 2>&1
```

Check:
1. `Tests: N` == `Passing: N` (all mechanical tests pass)
2. `Failures: 0` (balance sim in band)
3. No `WARN` lines for `avg_round_devotion` outside band (warns only, non-blocking)

After any Shop or UI change, run the game interactively and navigate through: week 1 → shop → NestSelect → Breeding → week 2.
