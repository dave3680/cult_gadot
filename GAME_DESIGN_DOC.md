# Cult of Accumulation — Game Design Reference

> Every claim is sourced directly from the codebase. No design intent is documented — only what the code does.

---

## Table of Contents

1. [Run Structure](#1-run-structure)
2. [Follower System](#2-follower-system)
3. [Scoring Pipeline](#3-scoring-pipeline)
4. [Weekly Target Curve](#4-weekly-target-curve)
5. [Breeding System](#5-breeding-system)
6. [Lineage System](#6-lineage-system)
7. [Pool System](#7-pool-system)
8. [Blood Economy](#8-blood-economy)
9. [Shop System](#9-shop-system)
10. [Relic System](#10-relic-system)
11. [Trait Reference](#11-trait-reference)
12. [Key Constants](#12-key-constants)

---

## 1. Run Structure

### Scene Flow

```
MainMenu → DoctrineSelect → [NestSelect → RunGame] × N → Breeding → Shop → ... → Victory / GameOver
```

- **DoctrineSelect:** Player picks doctrine (FLESH / RUIN / SILENCE), calls `reset_run()`, `init_starting_pool(doctrine)`, `start_week()`, then changes to `RunGame.tscn`.
- **RunGame:** Battle scene. Week label displays `"Week X/10 (Round Y/2)"`.
- **NestSelect:** Appears before each RunGame. Player assigns parents to nest slots.
- **Breeding:** Shown after a passed week (except week 1). Reveals offspring.
- **Shop:** Follows Breeding (or directly from RunGame on week 1 pass).
- **Victory / GameOver:** Victory on week 10 pass; GameOver on round 2 fail.

### Week / Round Loop

Each week has exactly **2 rounds**.

| Event | Trigger |
|-------|---------|
| Round 1 **pass** (`week_total_devotion >= target`) | Early win bonus fired; on-win relics; `perform_weekly_breeding`; → Breeding (or Shop on week 1) |
| Round 2 **pass** | Same as above |
| Round 2 **fail** | → `GameOver.tscn` |

Round 1 fail → `week_round = 2`, redraw hand, play again. The Awakening Bell (relic) clears exhaustion when round advances.

At round fail transition: `reset_doctrine_for_play()` and `draw_hand_from_pool()` are called.

At shop exit: `boost_pool_tiers_weekly()`, `current_week += 1`, `start_week()`, → `NestSelect.tscn`.

### `boost_pool_tiers_weekly()`

Every non-VOID follower in the pool gets `tier += 1` (capped at `MAX_TIER=10`).

---

## 2. Follower System

### Follower Object Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | int | Unique run-scoped ID, increments from 1 |
| `trait` | String | `"BLOOD"`, `"BONE"`, `"VOID"`, or `"SOUL"` |
| `tier` | int | 0–MAX_TIER (10) |
| `rarity` | String | `"COMMON"`, `"RARE"`, `"LEGENDARY"` |
| `trait_id` | String | Primary trait ID (empty = no trait) |
| `trait_ids` | Array[String] | Extra trait IDs beyond primary slot |
| `exhausted` | bool | Cannot be sacrificed this play |
| `origin_tag` | String | `"start"`, `"nest_bred"`, `"wild_bred"`, `"shop"`, etc. |

### Hand

Six followers drawn from pool at each round start (`draw_hand_from_pool()`).

### Sacrifice Limits per Play

| Condition | Max sacrifices |
|-----------|---------------|
| Default | 3 |
| Black Contract owned (once per week) | 4 |
| The Expanding Contract owned (once per week) | 5 (must sacrifice exactly 5) |

Exhausted followers cannot be placed in the altar. SOUL followers contribute 0 base score.

### Doctrine Action (once per play)

Doctrine button enabled while `!doctrine_used_this_play`. Requires exactly 1 follower selected from hand (not in altar):

| Doctrine | Action | Notes |
|----------|--------|-------|
| **FLESH** | Convert selected follower's `trait` to `"BLOOD"` | |
| **RUIN** | `tier = min(6, tier + 1)`, set `exhausted = true` | Cannot increase above tier 6 |
| **SILENCE** | Remove selected from hand; replace with random non-nested pool follower | Pool shrinks by 1 |

### Trait Slot Cap

```
max_trait_slots = min(6, 1 + floor(current_week / floor(max_weeks / 5)))
```

At `max_weeks=10`, divisor = `floor(10/5) = 2`. Progression: week 1 → 1 slot, weeks 2–3 → 2, weeks 4–5 → 3, weeks 6–7 → 4, weeks 8–9 → 5, week 10 → 6.

### Starting Pool by Doctrine

All pools contain 16 followers. Trait rolls per follower: LEGENDARY=2%, RARE=16%, COMMON=72%, no trait=10%.

| Doctrine | BLOOD tiers | BONE tiers | VOID tiers |
|----------|------------|-----------|-----------|
| FLESH | 4,4,5,5,5,5,6,6,5,6 (10) | 5,5,6,5 (4) | 0,0 (2) |
| RUIN | 4,5,5,5,6,6,5 (7) | 4,5,5,5,6,5,6 (7) | 0,0 (2) |
| SILENCE | 4,4,5,5,5,6,6,5 (8) | 4,5,6,5 (4) | 0,0,0,0 (4) |

---

## 3. Scoring Pipeline

All scoring runs through `_score_selected_internal(indices, apply_currency, write_breakdown, write_log)`. Called by `score_selected` (applies currency) and `preview_selected` (dry run).

### Step-by-Step

#### Step 1 — Ritual Knife / Third Knife

- **Ritual Knife** owned: first sacrifice gets `effective_tier = tier * 2`. Delta added to `relic_additive_total`.
- **The Third Knife** owned: first 3 sacrifices get `effective_tier = tier * 2`.

#### Step 2 — Base Contribution (per follower)

| Type | `base_contrib` |
|------|----------------|
| BLOOD | `tier` |
| BONE | `tier * 2` (or `tier + 2` with Whetted Bone) |
| SOUL | `0` |
| VOID | `0` (contributes to multiplier base; tier > 0 = "refined") |

`followers_subtotal = sum(base_contrib)`

BONE terms use `effective_tier * (2 + bone_copies)` in the logged breakdown but `base_contrib` uses un-doubled tier.

#### Step 3 — PRE_ADD Relic Hooks

`_apply_relic_scoring_hooks("PRE_ADD", ctx)` fires. Context carries `sacrificed_info`, type counts, `relic_additive_total`, `relic_blood_bonus`, `polisher_total`.

Key PRE_ADD relics (see RELIC_DEFS for full list):

| Relic | Condition | Effect |
|-------|-----------|--------|
| Crimson Book | any BLOOD | `+copies` per BLOOD sacrificed |
| Bone Idol | any BONE | `+copies` per BONE sacrificed |
| Calcify | any BONE | `+2 × bone_count × copies` |
| Quick Chant | any sacrifice | `+3 × copies` |
| Thin Blade | exactly 1 sac | `+8 × copies` |
| Ossuary Standard | ≥2 BONE | `+10 × copies` if bone_count ≥ 2 |
| Bone Polisher | any BONE | `polisher_total += tier × copies` per BONE |
| Ritual Symmetry | even sac count > 0 | `+12 × copies` |
| Prayer Beads | any sacrifice | additive |
| Wax Seal / Choir Robes | conditions | additive |
| Triune Reliquary | BLOOD+BONE+VOID play | additive |
| Bloodright Almanac | highest-tier conditions | additive |
| Bone Saw / Iron Reliquary / Ivory Throne | conditions | additive |
| Ascendant Mark / The Summit / Apex Covenant | top-tier conditions | additive |
| Obsidian Conduit | conditions | additive |

Additional PRE_ADD evaluated after hook dispatch:

| Relic | Condition | Effect |
|-------|-----------|--------|
| The Bleeding Edge | any | `+15 × copies` additive (−3 × copies Blood on fail) |
| The Cursed Offering | any | `+20 × copies` additive; reduces a random pool follower tier −1 |
| The Drawn Curtain | doctrine used this play | `+5 × copies` additive |
| Crimson Ledger | any BLOOD | `+stacks` additive |
| The Triad Compact | 3 sacrifices | `+copies` (accumulates each qualifying round) |
| The Expanding Rite | 4 sacrifices | `+2 × copies` (accumulates) |
| The Ossuary Engine | ≥2 BONE, on pass | `+ossuary_engine_bonus` (accrues) |
| The Skeleton Archive | BONE majority or RUIN, week ≥ 5 | `+copies` (once per run) |
| Ossuary Standards | any BONE | `+bone_count × ossuary_standards_bonus` |
| The Calcified Gate | any | `+floor(tier/3) × copies` per non-sacrificed BONE in pool |
| The Foursome | exactly 4 sacs | `+10 × copies` |
| The Expanding Contract | 5th sac present | `+tier × 3` for 5th sacrifice |
| Minimalist Doctrine | exactly 1 sac | `+base_contrib` (doubles single sac base) |
| Marrow Charter | all-BONE, exactly 3 sacs | `+tier_sum × copies` Blood (not additive) |
| Bone Standard | ≥2 BONE | `+highest_bone_base_contrib × copies` |
| Bone Chorus | all-BONE, all same tier | `+30 × copies` additive, `+3 × copies` Blood |
| The Red Tithe | all-BLOOD, 3 sacs, tier_sum ≥ 18 | `+15 × copies` |
| The Sanguine Engine | any BLOOD | `+floor(highest_pool_BLOOD_tier / 2) × copies` |
| The Concordat | BLOOD+BONE+VOID | `+3 × indices.size() × copies` |
| Threefold Brand | triune, triune seen this run | `+5 × copies` |
| The Sacred Triangle | BLOOD+BONE+VOID | `+best_BLOOD_base + best_BONE_base + best_VOID_base` |
| Covenant of Three | triune, tier_sum ≥ 15 | `+12 × copies` additive, `+2 × copies` Blood |
| Lineage Harvest | bred sacrifices | `+5 × bred_count × copies` |
| Nursery Ledger | bred sacrifices | `+bred_count × copies` Blood |
| Crimson Pact | any BLOOD in pool | `+highest_pool_BLOOD_tier` additive, +1 Blood; destroys that follower (once/week) |
| Soul Tithe | SOUL in pool | `+soul_pool_count × copies` Blood |
| Ritual Card (Anoint) | held Anoint | `+15` additive |

#### Step 4 — Trait Additive / Multiplier Effects

All trait IDs from each sacrificed follower (primary + extra from `trait_ids`) are evaluated. Effects applied per-follower. **Multiplier traits** count against `multiplier_trait_cap = 2` (disabled by Bloodfire Compact when conditions met).

See [Section 11](#11-trait-reference) for individual trait effects.

#### Step 5 — Doctrine Additive

`target = get_week_target(current_week)`

| Doctrine | Condition | Effect |
|----------|-----------|--------|
| FLESH | ≥3 BLOOD sacrificed | `+floor(target × 0.08)` |
| FLESH | 0 BLOOD sacrificed | `−floor(target × 0.04)` |
| FLESH | 1–2 BLOOD | +0 |
| RUIN | Highest-tier sacrifice is BONE | `+floor(target × 0.10) + highest_bone_tier × 2` |
| RUIN | Highest-tier not BONE | +0 |
| SILENCE | any | +0 (SILENCE only boosts multiplier exponent) |

#### Step 6 — Additive Total

```
additive_total = followers_subtotal + doctrine_additive + relic_additive_total + trait_additive_total
additive_total = max(0, additive_total)
```

#### Step 7 — PRE_MULT Relic Hooks

`_apply_relic_scoring_hooks("PRE_MULT", ctx)` — can modify `additive_total`:

| Relic | Condition | Effect |
|-------|-----------|--------|
| Sacrificial Order | exactly 3 sacs | `additive_total *= 2^order_copies` |
| Balanced Offering | BLOOD+BONE+VOID | `additive_total *= 2^balanced_copies` |
| The Peaked Rite | all-BLOOD, conditions | bonus |

Post-hook special:
- **Crypt Standard:** 2 BONE, 0 VOID → `additive_total *= 2`

#### Step 8 — Multiplier Calculation

```
effective_void = void_count
             + prism_copies              (Void Prism: +1 effective VOID per copy)
             + ritual_void_bonus         (Ritual Card Silence: +1)
             + void_count × sovereign_bonus  (Annihilation Compact sovereign active)
             + void_count × deepest_void_copies  (The Deepest Void)

empty_pyre_base_bonus = sum of max(0, void_tier − 1) for each tiered VOID  (The Empty Pyre)

base = 1 + effective_void + trait_base_bonus + empty_pyre_base_bonus
     + dyad_mark_copies  (if exactly 2 sacs, The Dyad Mark)
     + 5 × last_rung_copies per tier-10 sacrifice  (The Last Rung)
base = max(2, base)  if Cold Incense or White Wall (BONE×3, VOID=0) applies
base = max(1 + trait_black_candlebearer_count, base)  if black_candlebearer trait
base += sanguine_chord_copies  if tier straight 3+  (The Sanguine Chord)

MULTIPLIER_ADJUST hooks fire here (Hollow Abacus, Ectoplasm Jar, Hollow Chant, Void Prism, Black Candle, Cold Incense)

exponent = 1               (default, no Hollow Chant)
exponent = hollow_copies + 1  (Hollow Chant owned)
exponent += hollow_pact_copies        (The Hollow Pact)
exponent += 2 × final_silence_copies  (The Final Silence, if VOID=1)
exponent += (2 if Final Silence also owned else 1)  (SILENCE doctrine, if VOID=1)
exponent += hollow_register_stacks    (The Hollow Register, accrues weekly on VOID sac)
exponent += trait_exponent_bonus      (from blood_prophet, straight_rite, crimson_revelation)

multiplier = int(pow(base, exponent))
```

#### Step 9 — Refined VOID Bonus

```
refined_step = 0.5 + (0.2 × refinery_copies)   # 0.5 default
multiplier_bonus_factor = 1.0 + (refined_step × refined_void_count)
```

`refined_void_count` = count of sacrificed VOID with `tier > 0`.
- **The Absent Crown:** if void_count=2, both treated as refined.
- **Refinery of Silence:** if void_count > 0 and refined_void_count=0, treat 1 as refined.

#### Step 10 — Void Resonance

```
if void_count >= 2:
    void_resonance_factor = 1.0 + 0.25 × (void_count − 1)
```

| VOID count | Factor |
|-----------|--------|
| 0–1 | 1.00 |
| 2 | 1.25 |
| 3 | 1.50 |

#### Step 11 — Intermediate Final Devotion

```
final_devotion = int(additive_total × multiplier × multiplier_bonus_factor × void_resonance_factor)
```

#### Step 12 — Lineage Multiplier

```
bred_count = count of sacrificed followers with origin_tag in {"nest_bred", "wild_bred"}
if bred_count > 0:
    lineage_mult = 1.0 + (0.15 × bred_count)
    final_devotion = int(floor(final_devotion × lineage_mult))
```

#### Step 13 — Post-Lineage Final Multipliers

Applied in this order:

| Relic/Trait | Condition | Factor |
|------------|-----------|--------|
| The Count Absolute | exactly 1 sac, tier ≥ 10 | ×2.0 |
| Crimson Absolute | all-BLOOD, tier_sum ≥ 24 | ×1.5 |
| The Absolute Trinity | triune, BLOOD.best_tier == BONE.best_tier | ×2.0 |
| The Last Sacrifice | non-SOUL pool count < 5 | ×2.0 |
| The Hungry Altar | always | ×2.0 |
| The Trinity Engine + triune_champion in sac | triune | ×1.25 additional |
| The Trinity Engine + triune_heir in sac | triune | ×1.35 additional |
| `trait_final_mult_factor` (triune_champion=1.25, triune_heir=1.35, triune_cataclysm) | BLOOD+BONE+VOID | max of factors |

#### Step 14 — Round Devotion Cap

`round_devotion_cap_mult = 0.0` by default (inactive). If > 0:

```
round_cap = floor(target × cap_mult)
final_devotion = min(final_devotion, round_cap)
```

The Ossuary Absolute bypasses this cap when 3 all-BONE sacrifices each have tier ≥ 7.

#### Step 15 — Blood Income

```
blood_gain = blood_count × (2 + Blood_Abacus_copies) + trait_blood_bonus + relic_blood_bonus
if apply_currency: add_blood(blood_gain)
```

#### Step 16 — POST_RESOLVE Hooks (apply_currency only)

`_apply_relic_scoring_hooks("POST_RESOLVE", ctx)` fires, then:

- Resilient trait: each affected follower has 35% chance to return to pool
- Gilded Offering: tier-10 sacrifices forced back to pool
- Void Cradle: sacrificed VOID returned to pool
- Gravetide trait / grave_engine combo: spawn T1 BONE into pool per occurrence
- Gravewright relic: 25% per BONE sacrifice → spawn T2 BONE
- The Running Red: on pass + all-BLOOD + 3 sacs → spawn T3 BLOOD
- The Pared Offering: if exactly 1 sac → spawn T2 of same type
- Void Recursion: once/week, copy highest VOID sacrifice at T0 into pool
- The Cursed Offering: reduce random pool follower's tier by 1

#### Step 17 — Week Devotion Cap (at RunGame)

```
week_cap = floor(target × week_devotion_cap_mult)   # = 2× target
week_total_devotion = min(week_total_devotion, week_cap)
```

#### Step 18 — Overflow Blood (at RunGame)

```
overflow = max(0, week_total_devotion − target)
overflow_blood = floor(overflow / overflow_devotion_per_blood)   # 1 devotion per Blood
overflow_blood = min(overflow_blood, floor(target × overflow_cap_target_mult))  # cap = 0.5× target
```

---

## 4. Weekly Target Curve

### Formula

```gdscript
func get_week_target(week: int) -> int:
    if overrides.has(week): return overrides[week]
    return int(round(40.0 * pow(1.38, week - 1) / 5.0)) * 5
```

### Target Table

| Week | Raw value | Target |
|------|-----------|--------|
| 1 | 40.0 | **40** |
| 2 | 55.2 | **55** |
| 3 | 76.2 | **75** |
| 4 | 105.1 | **105** |
| 5 | 145.0 | **145** |
| 6 | 200.1 | **200** |
| 7 | 276.2 | **275** |
| 8 | override | **400** |
| 9 | override | **620** |
| 10 | override | **1000** |

### Win Condition

`week_total_devotion >= target` at any point in the week. Both rounds' devotion accumulates into `week_total_devotion`, capped at `floor(target × 2.0)`.

---

## 5. Breeding System

`perform_weekly_breeding(week)` → `perform_nest_breeding()` then `perform_wild_breeding(week)`.

### Nest Breeding

**Nest capacity:** `STARTING_NESTS(2)` + 1 if `relic_inventory["The Deep Pool"] >= 2`.

**NestSelect focus costs** (paid on "Continue to Battle"):

| Focus | Cost | Effect |
|-------|------|--------|
| NONE | 0 | No modifier |
| FAMILY | 2 | Offspring inherits parent's lineage affinity |
| RARITY | 3 | Boosts RARE/LEGENDARY trait chance |
| TIER | 3 | +1 to offspring tier |

**Offspring type:** parent A's `trait`.

**Offspring tier:**

```
raw = floor((a_tier + b_tier) / 2)
roll = randf()
if roll < 0.20: raw += 1
elif roll < 0.30: raw -= 1
final = clamp(raw, 1, MAX_TIER)
```

Exception: VOID+VOID both at tier ≤ 0 → offspring spawns at tier 1 minimum.

**Trait inheritance:**
1. Combo trait check first: if both parents share combo-eligible trait_ids → generate combo trait
2. Else: `randf() < 0.80` → assign a trait:
   - LEGENDARY: 8% chance (implied: 1 − 0.70 − 0.22)
   - RARE: 22% (`BREEDING_RARE_CHANCE`)
   - COMMON: 70% (`BREEDING_COMMON_CHANCE`)
3. Two-LEGENDARY-parent rule: 65% chance to demote offspring LEGENDARY → RARE
4. One-LEGENDARY-parent rule: 55% chance to demote offspring LEGENDARY → RARE

### Wild Breeding

Base chance per pair:

| Pair type | Base chance |
|-----------|------------|
| VOID + VOID | 0.30 |
| One VOID | 0.20 |
| No VOID | 0.45 |

Modified: `+ 0.10 × Fertility_Idol_copies + 0.05 × Brood_Compact_copies`, max 0.95.

Wild offspring get `origin_tag = "wild_bred"`. Pairs drawn randomly from non-nested pool followers.

---

## 6. Lineage System

`LINEAGE_MULT_PER_BRED = 0.15` (GameState.gd:3600).

```
bred_count = count of sacrificed followers with origin_tag in {"nest_bred", "wild_bred"}
lineage_mult = 1.0 + (0.15 × bred_count)
final_devotion = int(floor(final_devotion × lineage_mult))
```

| Bred sacrifices | Multiplier |
|----------------|-----------|
| 0 | 1.00× |
| 1 | 1.15× |
| 2 | 1.30× |
| 3 | 1.45× |

Related relics: **Lineage Harvest** (+5 × bred_count × copies additive), **Nursery Ledger** (+bred_count × copies Blood).

---

## 7. Pool System

### Pool Cap

```
cap = POOL_CAP (1000)
cap += 4 × Salt_Circle_copies
cap += 6 × Deep_Pool_copies
cap -= 6 × Ectoplasm_Jar_copies
if Hollow_Pact_owned: cap = floor(cap / 2)
cap = max(10, cap)
```

`get_pool_load_for_cap()` counts non-nested pool followers against cap. Overflow is trimmed during breeding.

### Hand Draw

`draw_hand_from_pool()` fills 6 slots from pool (respecting nest assignments). `ensure_pool_minimum_for_draw()` called first.

### Nest Capacity

```
nests = STARTING_NESTS (2)
if relic_inventory["The Deep Pool"] >= 2: nests += 1
```

### Pool Operations Available in Shop

| Action | Cost | Limit |
|--------|------|-------|
| Cull selected | 0 | Once per shop visit |
| Ascend selected | varies | — |
| Set Apostle (favored_a / favored_b) | 0 | — |
| Rotary Swap | 0 | — |
| Relic Pack | varies | — |

---

## 8. Blood Economy

### Starting Blood

`reset_run()` → `blood_currency = 5`.

### Blood Sources

| Source | Amount | Trigger |
|--------|--------|---------|
| Per BLOOD sacrificed | `2 + Blood_Abacus_copies` | Each scoring round |
| Trait blood bonuses | varies | Per-trait effects |
| Relic blood bonuses | varies | PRE_ADD effects |
| Early win bonus | 20 | Round 1 pass (once/week) |
| Overflow devotion | `floor(overflow / 1)`, max `floor(target × 0.5)` | Post-round if `week_total > target` |
| Iron Tithe | `copies × current_week` | `start_week()` |
| Crimson Interest | `floor(blood / (5 − compound_copies)) × copies` | Shop exit (Usurer's Mark adds extra fires) |
| The Waiting Bell | 10 | Shop exit, no purchase made |
| Spare Chalice | 2 | Shop entry if `blood = 0` |
| Ceremonial Cup | +1 per copy | Week pass |
| Blasphemous Geometry | +3 per copy | Week pass |
| Brass Tithe Bowl | +1 per copy | Week pass |
| The Red Covenant | +30 | Week pass (if active week) |
| Copper Tithe | +copies | Round pass |
| Null Covenant | `+base × copies` | Multiplier calc if base ≥ 5 |

### Blood Costs

| Purchase | Cost |
|----------|------|
| COMMON relic | 10 |
| UNCOMMON relic | 20 |
| RARE relic | 30 |
| LEGENDARY relic | 40 |
| Tithe Discount modifier | −1 from all costs above |
| Minimum relic cost | 2 |
| Shop recruit | 1 |
| Ritual card | 2 |
| Reroll relics | 5 (free: Sharpened Chalk or flag) |
| Nest RARITY focus | 3 |
| Nest TIER focus | 3 |
| Nest FAMILY focus | 2 |

### Blood Debt

Two relics add `next_round_additive_penalty` (deducted from additive total next round):
- **Debt Scripture:** limit 2 copies
- **The Debt Engine:** limit 6 copies

---

## 9. Shop System

### Entry

`start_shop_visit()` fires SHOP_ENTRY hooks. `shop_rerolls_used`, `shop_cull_used`, `shop_copy_used` reset each visit.

### Relic Offers

Default **3 slots**; **4 slots** with Blood Market Stall.

**Rarity roll** per slot:

```
legendary_chance = min(0.08, 0.02 + 0.01 × (week − 1))
rare_chance      = min(0.30, 0.15 + 0.02 × (week − 1))

roll = randf()
if roll < legendary_chance:               → LEGENDARY
elif roll < legendary_chance + rare_chance: → RARE
elif guarantee_rare_slot:                 → RARE
else: randf() < 0.35 → UNCOMMON, else COMMON
```

| Week | Legendary chance | Rare chance |
|------|-----------------|-------------|
| 1 | 2.0% | 15.0% |
| 5 | 6.0% | 23.0% |
| 10 | 8.0% (capped) | 30.0% (capped) |

**Guaranteed legendary:** If `!legendary_seen_in_shop` and `current_week >= 6`, one slot is force-replaced with a legendary pick.

**Reroll:** 1 per visit. Cost: 5 Blood (free with Sharpened Chalk or `shop_free_reroll_available`). The Faithful Scribe relic raises rarity floor of rerolled offers by its copy count.

### Recruits

`generate_shop_recruits()` fills `shop_recruit_offers`. Default 3 slots (4 with Blood Market Stall). Each recruit costs 1 Blood. Trine Offering grants free recruits after triune plays.

### Ritual Cards

Requires **Scarlet Planetarium**. Costs **2 Blood**. One held at a time. Activated via "Ritual Use" before confirming sacrifice.

| Card | Effect during scoring |
|------|-----------------------|
| Anoint | `+15` additive |
| Silence | `effective_void += 1` (multiplier base +1) |
| Rebirth | Returns 1 sacrificed follower to pool (`ritual_rebirth_pending = true`) |

### Director's Cut Relic

At shop: can reroll next week's target within ±`get_directors_cut_range_pct()` percent of formula value. Result rounded to nearest 5. Stored in `next_week_target_overrides`.

### Shop Exit

```
1. Crimson Interest fires (+ Usurer's Mark extra fires)
2. The Waiting Bell check
3. finalize_shop_visit()
4. boost_pool_tiers_weekly()   # all non-VOID: tier += 1
5. current_week += 1
6. start_week()                # fires WEEK_START relic hooks
7. → NestSelect.tscn
```

---

## 10. Relic System

Relics defined in `RELIC_DEFS` (GameState.gd). All relic names in `RELICS` array. Inventory in `relic_inventory` (count per name).

### Rarity / Cost

| Rarity | Cost |
|--------|------|
| COMMON | 10 Blood |
| UNCOMMON | 20 Blood |
| RARE | 30 Blood |
| LEGENDARY | 40 Blood |

Tithe Discount reduces all costs by 1 (min 2). `get_shop_cost(week, rarity)` ignores week in cost formula (only rarity matters).

### Stacking

Most relics: `stacks: false` → inventory capped at 1. Stackable relics (e.g., Crimson Book, Bone Idol, Blood Abacus, Hollow Chant, Fertility Idol, etc.) have `stacks: true` and accrue additional effect per copy.

### Scoring Hook Phases

| Phase | Timing |
|-------|--------|
| `PRE_ADD` | After follower base contributions, before additive total |
| `PRE_MULT` | After additive total, before multiplier |
| `MULTIPLIER_ADJUST` | During multiplier computation |
| `POST_RESOLVE` | After all scoring, `apply_currency=true` only |

### Non-Scoring Hook Phases

| Phase | Timing |
|-------|--------|
| `WEEK_START` | `start_week()` each week |
| `SHOP_ENTRY` | `start_shop_visit()` |
| `ON_WIN` | After round pass |
| `POST_SACRIFICE` | Part of resolve flow |

### Notable Relics (selected)

| Relic | Rarity | Category | Key effect |
|-------|--------|----------|------------|
| Blood Abacus | COMMON | BLOOD | +1 Blood per BLOOD sac (stackable) |
| Crimson Book | COMMON | BLOOD | +N additive per BLOOD (stackable) |
| Bone Idol | COMMON | BONE | +N additive per BONE (stackable) |
| Hollow Chant | COMMON | VOID | exponent = copies + 1 (stackable) |
| Fertility Idol | COMMON | LINEAGE | +10% wild breed chance/copy (stackable) |
| Sharpened Chalk | COMMON | — | First shop reroll free |
| Ritual Knife | COMMON | — | First sac: effective_tier ×2 |
| Black Contract | UNCOMMON | — | Once/week: 4th sacrifice allowed |
| Marrow Charter | UNCOMMON | BONE | All-BONE 3-sac: blood = tier_sum |
| The Hollow Pact | RARE | VOID | Pool cap halved; exponent +1/copy |
| The Deep Pool | RARE | LINEAGE | +6 pool cap/copy; 2 copies → 3rd nest |
| Scarlet Planetarium | RARE | — | Unlocks ritual card system |
| The Third Knife | LEGENDARY | — | First 3 sacs: effective_tier ×2 |
| The Expanding Contract | LEGENDARY | — | Once/week: allow 5th sacrifice |
| Bloodfire Compact | LEGENDARY | — | All-BLOOD×3+MULTIPLIER: disables trait cap |
| The Hungry Altar | LEGENDARY | — | ×2 final devotion always |

---

## 11. Trait Reference

Traits defined in `TRAIT_REGISTRY`. Types: `ADDITIVE`, `MULTIPLIER`, `BLOOD_ECON`, `SPAWN`, `PASSIVE`.

### Combo Trait Templates (ComboTraitGenerator.gd)

50 combo seeds (`combo_001`–`combo_050`). 8 templates. Rarity-scaled effects:

| Template | Condition | RARE | LEGENDARY |
|----------|-----------|------|-----------|
| `blood_straight_exalt` | blood_count == 3 | +2 Blood, exponent+1 | +3 Blood, exponent+2 |
| `blood_economy_forge` | blood_count ≥ 2 | +12 additive, +2 Blood | +18 additive, +3 Blood |
| `bone_citadel` | bone_count ≥ 2, void=0 | +20 additive | +30 additive |
| `void_edge` | void_count == 1 | +10 additive, base+1 | +14 additive, base+2 |
| `pair_execution` | pair tier exists | +base_contrib + 6 | +base_contrib + 10 |
| `nest_dynasty` | always | nest breeding bonus (parent) | nest breeding bonus |
| `triune_cataclysm` | BLOOD+BONE+VOID | final ×1.25 | final ×1.35 |
| `grave_engine` | always | +8 additive, +2 Blood, spawn T1 BONE | +12 additive, +3 Blood, spawn T1 BONE |

All multiplier effects count against `MULTIPLIER_TRAIT_CAP`.

### Individual Traits

| Trait ID | Rarity | Condition | Additive | Blood | Multiplier / Other |
|----------|--------|-----------|----------|-------|--------------------|
| devout | COMMON | always | +2 | — | — |
| stalwart | COMMON | BONE type | +4 | — | — |
| fervent | COMMON | 3 sacs | — | +2 | — |
| twinborn | COMMON | same-tier pair | +5 | — | — |
| blood_oathling | COMMON | BLOOD + ≥2 BLOOD | +5 | — | — |
| void_spark | COMMON | VOID + exactly 2 VOID | — | +2 | — |
| high_chanter | COMMON | highest tier | +5 | — | — |
| low_chanter | COMMON | lowest tier | +4 | — | — |
| bloodbrand | RARE | BLOOD + ≥2 BLOOD | +7 | — | — |
| ossuary_laborer | RARE | BONE + ≥2 BONE | +7 | — | — |
| void_entrant | RARE | VOID + exactly 1 VOID | +6 | +1 | — |
| triune_acolyte | RARE | BLOOD+BONE+VOID | +10 | — | — |
| zealot_ledger | RARE | 3 sacs | — | +2 | — |
| bone_tithe | RARE | ≥2 BONE | — | +2 | — |
| pair_hunter | RARE | pair tier exists | +6 | — | — |
| apex_rite | RARE | highest tier | +6 | — | — |
| abyss_rite | RARE | lowest tier | +5 | — | — |
| rite_channeler | RARE | 3 sacs, 0 VOID | +8 | — | — |
| ember_saint | RARE | BLOOD, tier ≥ 4 | +6 | — | — |
| marrow_mason | RARE | BONE, tier ≥ 4 | +8 | — | — |
| resilient | RARE | always | — | — | 35% chance: return to pool |
| ossuary_king | RARE | ≥2 BONE | +18 | — | — |
| gravetide | RARE | always | — | — | spawn T1 BONE |
| martyrs_ledger | RARE | always | — | +3 | — |
| chosen_veil | RARE | always | +4 | — | — |
| sanguine_conductor | RARE | BLOOD + ≥2 BLOOD | +16 | — | — |
| ossuary_archon | RARE | BONE + ≥2 BONE | +20 | — | — |
| hush_matron | RARE | VOID + exactly 1 VOID | +12 | +2 | — |
| paired_sigil | RARE | same-tier pair | base_contrib + 4 | — | — |
| votive_executor | RARE | BONE + highest BONE | +14 | +2 | — |
| sanguine_overseer | RARE | BLOOD + ≥3 BLOOD | +24 | — | — |
| ossuary_overseer | RARE | BONE + ≥3 BONE, 0 VOID | +28 | — | — |
| hush_executor | RARE | VOID + exactly 1 VOID | +14 | +2 | base+1 (cap limited) |
| triune_champion | RARE | BLOOD+BONE+VOID | — | — | final ×1.25 |
| grave_banker | RARE | always | — | +3 | spawn T1 BONE |
| brood_sovereign | RARE | always | +8 | +2 | — |
| brood_keeper | RARE | always | +6 | — | — |
| lineage_tutor | RARE | always | +4 | +2 | — |
| whispered | RARE | exactly 1 VOID | — | — | base+1 (cap limited) |
| blood_prophet | RARE | blood_count == 3 | — | — | exponent+1 (cap limited) |
| straight_rite | RARE | tier straight, ≥3 sacs | — | — | exponent+2 (cap limited) |
| void_herald | RARE | exactly 1 VOID | — | — | base+2 (cap limited) |
| black_candlebearer | RARE | 0 VOID | — | — | base ≥ 1+count (cap limited) |
| crimson_ascendant | RARE | 3 BLOOD, exactly 3 sacs | — | +3 | base+2 (cap limited) |
| ossuary_oracle | RARE | BONE + ≥2 BONE, 0 VOID | +24 | — | — |
| void_crown | RARE | VOID + exactly 1 VOID | +10 | — | base+2 (cap limited) |
| triune_heir | LEGENDARY | BLOOD+BONE+VOID | — | — | final ×1.35 |
| apostolic_womb | LEGENDARY | always | +12 | +2 | — |
| crimson_revelation | LEGENDARY | 3 BLOOD, exactly 3 sacs | — | +4 | exponent+2 (cap limited) |
| ossuary_titan | LEGENDARY | BONE + ≥3 BONE, 0 VOID | +36 | — | — |

**Multiplier trait cap:** `MULTIPLIER_TRAIT_CAP = 2`. At most 2 multiplier-type effects take effect per play. Bloodfire Compact (LEGENDARY relic) disables the cap when sacrifice is all-BLOOD × 3 with ≥1 MULTIPLIER trait.

---

## 12. Key Constants

### Core

| Constant | Value | File:Line |
|----------|-------|-----------|
| `MAX_TIER` | 10 | GameState.gd |
| `POOL_CAP` | 1000 | GameState.gd |
| `STARTING_NESTS` | 2 | GameState.gd |
| `MULTIPLIER_TRAIT_CAP` | 2 | GameState.gd |
| `LINEAGE_MULT_PER_BRED` | 0.15 | GameState.gd:3600 |
| Starting blood | 5 | `reset_run()` |

### RUN_CONFIG_DEFAULT

| Key | Value |
|-----|-------|
| `max_weeks` | 10 |
| `target_base` | 40 |
| `target_growth` | 1.38 |
| `overflow_devotion_per_blood` | 1 |
| `overflow_blood_per_devotion` | 1 |
| `overflow_cap_target_mult` | 0.5 |
| `early_win_bonus` | 20 |
| `round_devotion_cap_mult` | 0.0 (inactive) |
| `week_devotion_cap_mult` | 2.0 |
| `week_target_overrides` | `{8: 400, 9: 620, 10: 1000}` |

### Starting Pool Trait Chances

| Constant | Value |
|----------|-------|
| `STARTING_LEGENDARY_TRAIT_CHANCE` | 0.02 |
| `STARTING_RARE_TRAIT_CHANCE` | 0.16 |
| `STARTING_COMMON_TRAIT_CHANCE` | 0.72 |
| No trait (implied) | 0.10 |

### Breeding Chances

| Constant | Value |
|----------|-------|
| `BREEDING_ANY_TRAIT_CHANCE` | 0.80 |
| `BREEDING_COMMON_CHANCE` | 0.70 |
| `BREEDING_RARE_CHANCE` | 0.22 |
| Legendary (implied) | 0.08 |
| `NEST_LEGENDARY_TO_RARE_CHANCE` | 0.65 |
| `NEST_SINGLE_RARE_TO_RARE_CHANCE` | 0.55 |
| Wild VOID+VOID base chance | 0.30 |
| Wild one VOID base chance | 0.20 |
| Wild no VOID base chance | 0.45 |
| Wild max chance | 0.95 |

### Shop Rarity Roll Constants

| Constant | Value |
|----------|-------|
| `SHOP_RARE_BASE` | 0.15 |
| `SHOP_RARE_PER_WEEK` | 0.02 |
| `SHOP_RARE_MAX` | 0.30 |
| `SHOP_LEGENDARY_BASE` | 0.02 |
| `SHOP_LEGENDARY_PER_WEEK` | 0.01 |
| `SHOP_LEGENDARY_MAX` | 0.08 |
| `SHOP_UNCOMMON_CHANCE` | 0.35 |

### Offspring Tier Variance

| Outcome | Probability | Formula |
|---------|------------|---------|
| Base | 70% | `floor((a_tier + b_tier) / 2)` |
| +1 | 20% | |
| −1 | 10% | |
| Clamp | always | `[1, MAX_TIER]` |
