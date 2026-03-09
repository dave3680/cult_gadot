# Cult of Accumulation — Game Design Reference Document

> **Purpose:** Comprehensive briefing for AI-assisted content design and rebalancing. All numbers, formulas, and system descriptions are sourced directly from the live codebase (Godot 4.4 / GDScript). References cite `GameState.gd` (GS), `Shop.gd`, `RunGame.gd`, `TestRunner.gd` (TR), and `ComboTraitGenerator.gd` (CTG) by line number where useful.
>
> **Engine:** Godot 4.4 — GDScript. Autoloads: `GameState`, `GlobalMenuOverlay`.

---

## 1. Core Loop — One Full Run Step-by-Step

A run lasts up to **10 weeks**. Each week has up to **2 rounds**. Failure across 2 rounds in the same week ends the run.

```
[START RUN]
  → DoctrineSelect (choose FLESH / RUIN / SILENCE)
    → init_starting_pool(doctrine)        ← 16 followers placed in pool

  [WEEK LOOP — weeks 1..10]
    → NestSelect                          ← drag followers into 2 nest slots (A+B each)
    → RunGame (Round 1)
        draw_hand_from_pool()             ← 6 non-nested pool followers drawn, removed from pool
        [player selects 1–3 (or 4 w/ Black Contract) followers]
        [optional: use Doctrine Action once per week]
        [optional: activate held Ritual Card]
        score_selected(indices)
          → blood gained, devotion scored, pool effects applied
          → resolve_play_and_update_pool() ← non-selected hand returns to pool, sacrificed removed (with exceptions)
        apply_overflow_blood_for_target() ← excess devotion → blood
        [if weekly target met]:
          → early_win_bonus (+20 blood) if round 1
          → success relics fire (Ceremonial Cup, Blasphemous Geometry, Brass Tithe Bowl)
          → perform_weekly_breeding()     ← nest + wild breeding executes
          → if week == 10: Victory screen
          → else: Breeding.tscn (display results)
               → Shop.tscn
                    → generate_shop_recruits()
                    → roll 3 relic offers
                    → player buys relics / recruits / ritual card / uses Director's Cut
                    → Crimson Interest fires on shop exit
                    → boost_pool_tiers_weekly()  ← every non-VOID pool member +1 tier
                    → current_week += 1
                    → goto NestSelect
        [if target NOT met and round == 1]:
          → reset_doctrine_for_play()
          → draw_hand_from_pool() again
          → RunGame (Round 2)
              [same flow]
              [if target still not met]: GameOver screen

[VICTORY — week 10 cleared]
[GAME OVER — week failed]
```

### Key invariants
- **Hand draw removes followers from pool** for the duration of the round; non-sacrificed followers return afterward.
- **Nested followers are excluded** from hand draws.
- **Pool is boosted +1 tier** (all non-VOID) each time the shop is exited.
- **Breeding fires once per cleared week**, after combat resolves and before the shop.

---

## 2. Systems Inventory

### 2.1 Combat / Scoring System
Executed in `GameState._score_selected_internal()` (~800 lines). A single "play" computes devotion from the selected followers in four ordered phases:

| Phase | What runs |
|-------|-----------|
| 1. Base follower contributions | BLOOD = tier; BONE = tier × 2; VOID/SOUL = 0 |
| 2. PRE_ADD hooks | Relic additive effects, Ritual Knife/Third Knife doubling |
| 3. Doctrine additive modifier | Applied after relics, before multiplier |
| 4. Trait additive & economy effects | Per-follower trait bonuses |
| 5. PRE_MULT hooks | Sacrificial Order, Balanced Offering (double additive_total) |
| 6. Multiplier calculation | `base ^ exponent` (VOID-driven) |
| 7. MULTIPLIER_ADJUST hooks | Hollow Abacus, Ectoplasm Jar, Black Candle, Cold Incense |
| 8. Refined VOID bonus | `× (1 + 0.5 × refined_void_count)` |
| 9. Trait final multiplier | triune_cataclysm / triune_champion / triune_heir (×1.25 or ×1.35) |
| 10. Round cap | `min(devotion, floor(weekly_target × 1.25))` |

Blood gain from a play: `(blood_count × per_blood) + trait_blood_bonus + relic_blood_bonus`
where `per_blood = 2 + Blood_Abacus_copies`.

### 2.2 Multiplier System
```
effective_void   = void_count + Void_Prism_copies + ritual_void_bonus (Silence card)
base             = 1 + effective_void + trait_base_bonus
                   (forced ≥ 2 by Black Candle, Cold Incense, or black_candlebearer trait)
exponent         = 1   (baseline)
                   + hollow_chant_copies   (direct, not hook)
                   + Silence doctrine bonus (+1 if exactly 1 VOID)
                   + Hollow Abacus copies  (if exactly 1 VOID; hook)
                   + Ectoplasm Jar copies  (unconditional; hook)
                   + trait_exponent_bonus  (blood_prophet, straight_rite, crimson_ascendant, crimson_revelation)
multiplier       = base ^ exponent
```

**Important nuance:** The Hollow Chant and Void Prism hooks (`MULTIPLIER_ADJUST` phase) log text only; their actual numerical effects are already applied directly before hooks run. Only Black Candle, Cold Incense, Hollow Abacus, and Ectoplasm Jar hooks modify `ctx`.

**Multiplier trait cap:** `MULTIPLIER_TRAIT_CAP = 1`. Only one trait can contribute to the multiplier per round. Additional multiplier traits are noted as "skipped" in the breakdown.

### 2.3 Pool System
- The **pool** is the persistent collection of followers across an entire run.
- Pool followers have: `{id, tier, trait, trait_id, trait_rarity, exhausted, origin_tag}`
- **VOID followers always have tier 0** (enforced in `_make_specific_follower` and `make_random_follower`). The only exception: Soul Lantern ascension produces a VOID with `tier += 2`.
- **Pool cap:** `max(10, 1000 + 4×Salt_Circle_copies − 6×Ectoplasm_Jar_copies)`
- **Weekly tier boost:** all non-VOID pool followers gain +1 tier on shop exit, capped at MAX_TIER (10).
- If pool has fewer than 6 available (non-nested) followers, SOUL placeholders are added.

### 2.4 Breeding System
Executes in `perform_weekly_breeding()` after each cleared week (not after game-over weeks).

**Nest Breeding** (`resolve_nest_breeding`):
- Each of the 2 nests runs if both parent slots are filled with non-SOUL pool followers.
- Base tier = `floor((tier_A + tier_B) / 2)`, then ±1 (20% chance +1, 10% chance −1).
- Baby trait (type): inherited from either parent (50/50); if one parent is VOID, VOID wins only 30% of the time.
- `trait_id` resolved via `_resolve_nest_trait_id()` — checks for Seal of Inheritance, combo traits, rarity targeting.

**Wild Breeding** (`resolve_wild_breeding`):
- All non-nested, non-SOUL pool followers are randomly shuffled and paired.
- Each pair has a base breeding chance (see §5 table).
- Favored pair: +20%, capped at 95%.
- Tier and trait inheritance uses the same formulas as nest breeding.
- Wild breeding trait rolls use `_roll_wild_breeding_trait()` (different from nest).

**Pool cap enforcement:** if `pool.size() >= get_pool_cap()`, newborn is discarded (trimmed).

### 2.5 Shop System
Runs after each cleared week's breeding phase.

- 3 relic offers (4 if Blood Market Stall owned); each slot rolls rarity independently via `roll_shop_rarity()`.
- 3 or 4 recruit offers; each costs 1 blood.
- 1 ritual card offer (if Scarlet Planetarium owned), costs 2 blood.
- Reroll: costs 5 blood (free once if Sharpened Chalk owned or Clean Hands triggered); max 1 reroll per shop.
- Director's Cut button (if relic owned): rerolls next week's target ±15%, rounded to nearest 5.
- Relic Pack: sacrifice 10 pool followers → choose 1 of 2 relic offers (rarity boosted by average tier of sacrificed followers).
- Pool management actions: Cull (free with Culling Knife, once/shop), Set Favored Breeders (requires Selective Breeding Scroll), Ascend (requires Soul Lantern, once/run, drains all blood), Set Apostle (requires First Apostle, once/run).
- Crimson Interest fires on shop exit: `floor(blood / 5) × copies` blood gained.

### 2.6 Doctrine System
Chosen once at run start; cannot change.

| Doctrine | Trigger | Effect |
|----------|---------|--------|
| **FLESH** | 3+ BLOOD sacrificed | +6 additive |
| **FLESH** | 0 BLOOD sacrificed | −6 additive |
| **FLESH** | 1–2 BLOOD sacrificed | +0 |
| **RUIN** | Highest-tier sacrifice is BONE and ≥1 BONE sacrificed | +8 additive |
| **RUIN** | Otherwise | +0 |
| **SILENCE** | Exactly 1 VOID sacrificed | +1 exponent to multiplier |
| **SILENCE** | Otherwise | +0 |

Doctrine has one **active action** per week (once per round, `doctrine_used_this_play` resets per round):
- FLESH: Convert 1 selected hand follower to BLOOD.
- RUIN: +1 tier (max 6 via Doctrine), mark that follower exhausted this round.
- SILENCE: Banish 1 selected follower, replace with a random new follower.

### 2.7 Difficulty & Progression System
- **Weekly devotion targets** grow exponentially: `round(target_base × growth^(week−1))` rounded to nearest 5.
- Default: `target_base = 40`, `growth = 1.5`.
- **Round cap:** single-round devotion capped at `1.25 × weekly_target`, preventing early-game combos from snowballing unchecked.
- Harder weeks require either more rounds of sacrifice or better relics/followers.
- No permanent "difficulty scaling" beyond the target formula and relic shop progression (rarer relics available later).

### 2.8 Blood Economy
Blood is the sole currency; it does not persist across runs.

| Source | Amount |
|--------|--------|
| Each BLOOD sacrificed | `2 + Blood_Abacus_copies` |
| Trait bonuses (varies) | +1 to +4 per trait |
| Relic bonuses (varies) | +1 to +3 per relic |
| Early win bonus | +20 blood (round 1 only) |
| Ceremonial Cup (on win) | +1 blood per copy |
| Blasphemous Geometry (on win) | +3 blood per copy |
| Brass Tithe Bowl (on win) | +1 blood per copy |
| Overflow devotion | `floor((devotion − target) / 1)` blood (default rate) |
| Crimson Interest (on shop exit) | `floor(blood / 5) × copies` |
| Spare Chalice (if 0 blood entering shop) | +2 blood |

| Expense | Amount |
|---------|--------|
| Recruit from shop | 1 blood each |
| Relic: COMMON | 10 blood (9 with Tithe Discount) |
| Relic: UNCOMMON | 20 blood (19 with Tithe Discount) |
| Relic: RARE | 30 blood (29 with Tithe Discount) |
| Relic: LEGENDARY | 40 blood (39 with Tithe Discount) |
| Ritual Card | 2 blood |
| Reroll shop offers | 5 blood (free once/shop with Sharpened Chalk or Clean Hands) |
| Relic Pack | sacrifice 10 pool followers |

Debt Scripture allows purchases up to 2 blood in debt; debt repaid from next gains.

---

## 3. Data & Content

### 3.1 Follower Entity

| Attribute | Type | Notes |
|-----------|------|-------|
| `id` | int | Auto-incrementing, unique per run |
| `tier` | int | 1–10; VOID is always 0 (exception: Soul Lantern ascension) |
| `trait` | String | `BLOOD`, `BONE`, `VOID`, `SOUL` |
| `trait_id` | String | Key into TRAIT_REGISTRY or combo catalog; may be `""` |
| `trait_rarity` | String | `""`, `COMMON`, `RARE`, `LEGENDARY` |
| `exhausted` | bool | Cannot be selected for sacrifice this play |
| `origin_tag` | String | `start`, `recruit_shop`, `nest_bred`, `wild_bred`, `grave_spawn`, `soul`, `random` |

### 3.2 Starting Pools by Doctrine

All doctrines start with **16 followers** (VOID tiers in source are irrelevant; VOID always spawns at tier 0):

| Doctrine | BLOOD | BONE | VOID | BLOOD tiers | BONE tiers |
|----------|-------|------|------|-------------|------------|
| FLESH | 10 | 4 | 2 | 4,4,5,5,5,5,6,6,5,6 | 5,5,6,5 |
| RUIN | 7 | 7 | 2 | 4,5,5,5,6,6,5 | 4,5,5,5,6,5,6 |
| SILENCE | 8 | 4 | 4 | 4,4,5,5,5,6,6,5 | 4,5,6,5 |

Each starting follower rolls for a trait independently: 2% LEGENDARY, 16% RARE, 72% COMMON, 10% none.

### 3.3 Follower Trait Types (Main Trait)

| Type | Base devotion contribution |
|------|---------------------------|
| BLOOD | `+tier` additive |
| BONE | `+tier × 2` additive |
| VOID | Adds 1 to multiplier base; zero additive |
| SOUL | Zero contribution; filler |

### 3.4 Ritual Cards (requires Scarlet Planetarium relic)

| Card | Effect |
|------|--------|
| Anoint | +15 additive this play |
| Silence | +1 effective VOID this play (multiplier base +1) |
| Rebirth | Return 1 random sacrificed follower to pool after resolve |

---

## 4. Trait System (Sub-Traits / Beliefs)

### 4.1 Common Traits (25)

| ID | Name | Type | Effect |
|----|------|------|--------|
| devout | Devout | ADDITIVE | When sacrificed: +2 additive |
| stalwart | Stalwart | ADDITIVE | If this is BONE: +4 additive |
| fervent | Fervent | ECONOMY | If exactly 3 sacrificed: +2 blood |
| twinborn | Twinborn | ADDITIVE | If another sacrifice shares tier: +5 additive |
| whispered | Whispered | MULTIPLIER | If exactly 1 VOID: multiplier base +1 |
| resilient | Resilient | POOL | When sacrificed: 35% chance return to pool |
| blood_oathling | Blood Oathling | ADDITIVE | If BLOOD and 2+ BLOOD sacrificed: +5 additive |
| void_spark | Void Spark | ECONOMY | If VOID and exactly 2 VOID sacrificed: +2 blood |
| high_chanter | High Chanter | ADDITIVE | If this has highest tier: +5 additive |
| low_chanter | Low Chanter | ADDITIVE | If this has lowest tier: +4 additive |
| bloodbrand | Bloodbrand | ADDITIVE | If BLOOD and 2+ BLOOD sacrificed: +7 additive |
| ossuary_laborer | Ossuary Laborer | ADDITIVE | If BONE and 2+ BONE sacrificed: +7 additive |
| void_entrant | Void Entrant | HYBRID | If VOID and exactly 1 VOID: +6 additive, +1 blood |
| triune_acolyte | Triune Acolyte | ADDITIVE | If BLOOD+BONE+VOID sacrificed: +10 additive |
| zealot_ledger | Zealot Ledger | ECONOMY | If exactly 3 sacrificed: +2 blood |
| bone_tithe | Bone Tithe | ECONOMY | If 2+ BONE sacrificed: +2 blood |
| pair_hunter | Pair Hunter | ADDITIVE | If any two share tier: +6 additive |
| apex_rite | Apex Rite | ADDITIVE | If this has highest tier: +6 additive |
| abyss_rite | Abyss Rite | ADDITIVE | If this has lowest tier: +5 additive |
| rite_channeler | Rite Channeler | ADDITIVE | If exactly 3 and 0 VOID: +8 additive |
| ember_saint | Ember Saint | ADDITIVE | If BLOOD and tier ≥ 4: +6 additive |
| marrow_mason | Marrow Mason | ADDITIVE | If BONE and tier ≥ 4: +8 additive |
| chosen_veil | Veiled Bloodline | BREEDING | When sacrificed: +4 additive; as nest parent pushes rarity upward |
| brood_keeper | Brood Keeper | BREEDING | When sacrificed: +6 additive; as nest parent: newborn +1 tier |
| lineage_tutor | Lineage Tutor | BREEDING | When sacrificed: +4 additive, +2 blood; as nest parent: +35% rarity-up chance |

### 4.2 Rare Traits (18)

| ID | Name | Type | Effect |
|----|------|------|--------|
| blood_prophet | Blood Prophet | MULTIPLIER | All 3 are BLOOD: exponent +1 |
| straight_rite | Straight Rite | MULTIPLIER | All 3 BLOOD with consecutive tiers: exponent +2 |
| ossuary_king | Ossuary King | ADDITIVE | 2+ BONE: +18 additive |
| gravetide | Gravetide | POOL | When sacrificed: spawn T1 BONE in pool |
| void_herald | Void Herald | MULTIPLIER | Exactly 1 VOID: multiplier base +2 |
| black_candlebearer | Black Candlebearer | MULTIPLIER | 0 VOID: multiplier base forced ≥ 2 |
| martyrs_ledger | Martyr's Ledger | ECONOMY | When sacrificed: +3 blood |
| sanguine_conductor | Sanguine Conductor | ADDITIVE | If BLOOD and 2+ BLOOD: +16 additive |
| ossuary_archon | Ossuary Archon | ADDITIVE | If BONE and 2+ BONE: +20 additive |
| hush_matron | Hush Matron | HYBRID | If VOID and exactly 1 VOID: +12 additive, +2 blood |
| paired_sigil | Paired Sigil | ADDITIVE | If same-tier partner exists: double base contribution + 4 additive |
| votive_executor | Votive Executor | HYBRID | If BONE and highest-tier sacrifice is BONE: +14 additive, +2 blood |
| sanguine_overseer | Sanguine Overseer | ADDITIVE | If BLOOD and 3+ BLOOD: +24 additive |
| ossuary_overseer | Ossuary Overseer | ADDITIVE | If BONE and 3+ BONE and 0 VOID: +28 additive |
| hush_executor | Hush Executor | HYBRID | If VOID and exactly 1 VOID: +14 additive, +2 blood, multiplier base +1 |
| triune_champion | Triune Champion | MULTIPLIER | If BLOOD+BONE+VOID present: final devotion ×1.25 |
| grave_banker | Grave Banker | POOL | When sacrificed: +3 blood, spawn T1 BONE |
| brood_sovereign | Brood Sovereign | BREEDING | When sacrificed: +8 additive, +2 blood; as nest parent: +1 tier, better rarity |

### 4.3 Legendary Traits (7)

| ID | Name | Type | Effect |
|----|------|------|--------|
| crimson_ascendant | Crimson Ascendant | HYBRID | If BLOOD and all 3 are BLOOD: exponent +2, +3 blood |
| ossuary_oracle | Ossuary Oracle | ADDITIVE | If BONE and 2+ BONE and 0 VOID: +24 additive |
| void_crown | Void Crown | HYBRID | If VOID and exactly 1 VOID: +10 additive, multiplier base +2 |
| apostolic_womb | Apostolic Womb | BREEDING | When sacrificed: +12 additive, +2 blood; as nest parent: newborn inherits a parent trait, +2 tier |
| triune_heir | Triune Heir | MULTIPLIER | If BLOOD+BONE+VOID present: final devotion ×1.35 |
| crimson_revelation | Crimson Revelation | HYBRID | If BLOOD and all 3 are BLOOD: exponent +2, +4 blood |
| ossuary_titan | Ossuary Titan | ADDITIVE | If BONE and 3+ BONE and 0 VOID: +36 additive |

---

## 5. Relic / Modifier System

### 5.1 Storage
`relic_inventory: Dictionary` in GameState — a flat key-value map of `{relic_name: int_count}`. Initialized to 0 for all 50 relics at run start. Relics that `stacks: false` cap at 1.

### 5.2 Hook Architecture
Four hook phases fire during `_score_selected_internal()`:

```
RELIC_SCORING_HOOKS = {
  "PRE_ADD":         { ... 16 relics ... },
  "PRE_MULT":        { "Sacrificial Order", "Balanced Offering" },
  "MULTIPLIER_ADJUST": { "Hollow Abacus", "Ectoplasm Jar", "Hollow Chant", "Void Prism",
                          "Black Candle", "Cold Incense" },
  "POST_RESOLVE":    { "Red Thread" },
}
```

Hooks receive a `ctx` dictionary and `copies` (stack count). Each hook method name is stored in the hook map and called via `call(method_name, ctx, copies)`. Hooks modify `ctx` in place.

**Important:** The `MULTIPLIER_ADJUST` hooks for `Hollow Chant` and `Void Prism` are log-only — they append description text but do not modify `ctx["exponent"]` or `ctx["base"]` because those effects are applied directly before the hook phase runs. All other hooks in this phase do modify ctx.

### 5.3 Non-Scoring Hooks
Effects outside the scoring pipeline are implemented procedurally:
- **POST_RESOLVE/Red Thread:** after scoring, if 3 BLOOD sacrificed, boosts tier of a random BLOOD pool follower by 1 per copy.
- **Grave Ledger:** applied in `buy_shop_recruit()` — first recruit purchase each shop gets `+copies` tier.
- **Omen Deck:** applied in `buy_shop_recruit()` — 10% × copies chance to override recruit trait with a RARE one.
- **Spare Chalice:** fires at shop start if blood == 0.
- **Crimson Interest:** fires at shop exit.
- **Salt Circle / Ectoplasm Jar:** modify pool cap in `get_pool_cap()`.
- **Tithe Discount:** applied in `get_shop_cost()`.
- **Black Contract:** gates 4-sacrifice mode (once per week).
- **Clean Hands:** triggers `free_reroll_next_shop = true` if week cleared with 0 VOID.
- **Selective Breeding Scroll:** enables favored breeder UI; also applies +15% to `single_rare_chance` and `common_to_rare_chance` in nest rarity resolution.
- **Seal of Inheritance:** in `_resolve_nest_trait_id()` and `_roll_wild_breeding_trait()`, causes immediate parent trait inheritance (skips combo/rarity resolution).
- **Fertility Idol:** `base_wild_chance += 0.10 × copies` for non-VOID pairs.
- **Director's Cut:** in Shop UI, rerolls `next_week_target_overrides[next_week]`.
- **Votive Mirror:** allows buying one already-purchased recruit a second time.
- **Blood Market Stall:** recruits increased from 3 → 4.
- **Soul Lantern:** converts a pool follower to VOID, +2 tier, **drains all blood** to 0. Once per run.
- **First Apostle:** sets `apostle_id`; apostle parent in nest forces trait inheritance and +1 tier on offspring.

### 5.4 All Relics — Complete Reference

#### COMMON (10 blood / 9 with Tithe Discount)

| Relic | Stacks | Category | Effect |
|-------|--------|----------|--------|
| Ceremonial Cup | Yes | RELIC | On win: +1 blood per copy |
| Thin Blade | Yes | RELIC | If exactly 1 sacrifice: +8 additive per copy |
| Bone Polisher | Yes | RELIC | If 1+ BONE: +[highest BONE tier] additive per copy |
| Ritual Symmetry | Yes | RELIC | If even number of sacrifices (2 or 4): +12 additive per copy |
| Calcify | Yes | RELIC | +2 × bone_count × copies additive |
| Crimson Interest | Yes | RELIC | On shop exit: `floor(blood/5)×copies` blood |
| Brass Tithe Bowl | Yes | RELIC | On win: +1 blood per copy |
| Culling Knife | No | RELIC | Once per shop: free cull one pool follower |
| Salt Circle | Yes | VOUCHER | Pool cap +4 per copy |
| Spare Chalice | No | RELIC | If entering shop with 0 blood: +2 blood |
| Blood Market Stall | No | RELIC | Shop recruits: 3 → 4 |
| Votive Mirror | No | RELIC | Once per shop: buy one recruit twice |
| Fertility Idol | Yes | RELIC | Wild breeding chance +10% per copy (non-VOID pairs only) |
| Selective Breeding Scroll | No | RELIC | Nest rarity-up +15%; enables favored breeder UI |
| Triune Reliquary | Yes | RELIC | If exactly 3 and BLOOD+BONE+VOID: +12 additive per copy |
| Bloodright Almanac | Yes | RELIC | If 3 BLOOD with consecutive tiers (blood straight): +10 additive and +2 blood per copy |
| Clean Hands | No | RELIC | If week cleared with 0 VOID: 1 free reroll next shop |
| Debt Scripture | No | VOUCHER | Buy relics up to 2 blood short (debt repaid from future gains) |

#### UNCOMMON (20 blood / 19 with Tithe Discount)

| Relic | Stacks | Category | Effect |
|-------|--------|----------|--------|
| Bone Idol | Yes | RELIC | Each BONE: +[tier × copies] additive |
| Crimson Book | Yes | RELIC | Each BLOOD: +[1 × copies] additive |
| Quick Chant | Yes | RELIC | Any sacrifice: +3 × copies additive |
| Tithe Discount | No | VOUCHER | All relic costs −1 (min 2) |
| Ossuary Standard | Yes | RELIC | If 2+ BONE: +10 × copies additive |
| Sharpened Chalk | No | VOUCHER | First reroll each shop is free |
| Prayer Beads | Yes | RELIC | If all 3 sacrifice same type: +6 × copies additive |
| Bone Saw | Yes | RELIC | If 2+ BONE: +1 × copies blood |
| Red Thread | Yes | RELIC | If 3 BLOOD sacrificed: random BLOOD in pool +1 tier per copy (POST_RESOLVE) |
| Grave Ledger | Yes | RELIC | First recruit bought each shop: +copies tier (non-VOID; max tier 10) |
| Wax Seal | Yes | RELIC | If any two sacrifices share tier: +8 × copies additive |
| Choir Robes | Yes | RELIC | If exactly 3 and all different tiers: +5 × copies additive |
| Ossuary Standards | Yes | RELIC | Each BONE: +[tier × copies] additive (same formula as Bone Idol — stacks additively with it) |
| Hollow Abacus | Yes | RELIC | If exactly 1 VOID: exponent +copies |
| Black Contract | No | RELIC | Once per week: sacrifice 4 instead of 3 |

#### RARE (30 blood / 29 with Tithe Discount)

| Relic | Stacks | Category | Effect |
|-------|--------|----------|--------|
| Ritual Knife | No | RELIC | First selected follower counts as double tier |
| Hollow Chant | Yes | RELIC | Multiplier exponent = copies + 1 (baseline becomes copies+1, not 1) |
| Balanced Offering | Yes | RELIC | If BLOOD+BONE+VOID present: multiply additive_total by 2^copies |
| Blasphemous Geometry | Yes | RELIC | On win: +3 × copies blood |
| Wax Seal | Yes | RELIC | If any pair of equal tiers: +8 × copies additive |
| Cold Incense | No | RELIC | If 0 VOID: multiplier base forced ≥ 2, once per week |
| Omen Deck | Yes | RELIC | Per recruit bought: 10% × copies chance to override trait with a RARE |
| Director's Cut | No | VOUCHER | Once per shop: reroll next week's target ±15% (rounded to nearest 5) |
| Scarlet Planetarium | No | CONSUMABLE | Adds Ritual Card slot; shop offers 1 ritual card each week |
| Seal of Inheritance | No | RELIC | Both nest and wild offspring inherit a parent trait (if either parent has one) |
| Black Contract | No | RELIC | Once per week: may sacrifice 4 instead of 3 |

#### LEGENDARY (40 blood / 39 with Tithe Discount)

| Relic | Stacks | Category | Effect |
|-------|--------|----------|--------|
| Sacrificial Order | Yes | RELIC | If exactly 3 sacrificed: multiply additive_total by 2^copies |
| Void Prism | Yes | RELIC | Each copy adds +1 to effective_void (multiplier base +1 per copy) |
| Black Candle | No | RELIC | Multiplier base always ≥ 2 |
| The Third Knife | No | RELIC | First 3 followers selected count as double tier |
| Ectoplasm Jar | Yes | VOUCHER | Exponent +copies; pool cap −6 per copy |
| The Soul Lantern | No | RELIC | Once per run: ascend pool follower to VOID + 2 tier; drains all blood to 0 |
| First Apostle | No | RELIC | Designate one pool follower as Apostle; as nest parent, forces trait inheritance and +1 tier on offspring |

### 5.5 Shop Rarity Probabilities

Each of the 3 shop offer slots rolls independently using `roll_shop_rarity(week, rng)`:

```
legendary_chance = min(0.08,  0.02 + 0.01 × (week−1))
rare_chance      = min(0.30,  0.15 + 0.02 × (week−1))
uncommon_chance  = 0.35   (of non-legendary/rare rolls)
common_chance    = 0.65   (of non-legendary/rare rolls)
```

| Week | Legendary % | Rare % | Uncommon % (of remainder) | Common % |
|------|-------------|--------|--------------------------|----------|
| 1 | 2.0% | 15.0% | ~29% | ~54% |
| 2 | 3.0% | 17.0% | ~28% | ~52% |
| 3 | 4.0% | 19.0% | ~28% | ~49% |
| 5 | 6.0% | 23.0% | ~26% | ~45% |
| 8 | 8.0% (cap) | 29.0% | ~22% | ~41% |
| 10 | 8.0% (cap) | 30.0% (cap) | ~22% | ~40% |

Relic Pack offers use the same formula with `rare_bonus` and `legendary_bonus` added based on average tier of sacrificed followers:
- `rare_bonus      = clamp((avg_tier − 5.0) × 0.02, 0.0, 0.10)`
- `legendary_bonus = clamp((avg_tier − 7.0) × 0.01, 0.0, 0.04)`

---

## 6. Combo Trait System

Combo traits are produced by the `ComboTraitGenerator`. They exist in a separate catalog (`combo_trait_catalog`) and are indexed by parent trait-ID pair (`combo_trait_pair_index`).

### 6.1 Templates

| Template ID | Rarity | Trigger | Effect |
|-------------|--------|---------|--------|
| `blood_straight_exalt` | RARE | All 3 sacrificed are BLOOD | Exponent +1, +2 blood |
| `blood_straight_exalt` | LEGENDARY | All 3 sacrificed are BLOOD | Exponent +2, +3 blood |
| `blood_economy_forge` | RARE | 2+ BLOOD sacrificed | +12 additive, +2 blood |
| `blood_economy_forge` | LEGENDARY | 2+ BLOOD sacrificed | +18 additive, +3 blood |
| `bone_citadel` | RARE | 2+ BONE and 0 VOID | +20 additive |
| `bone_citadel` | LEGENDARY | 2+ BONE and 0 VOID | +30 additive |
| `void_edge` | RARE | Exactly 1 VOID | Multiplier base +1, +10 additive |
| `void_edge` | LEGENDARY | Exactly 1 VOID | Multiplier base +2, +14 additive |
| `pair_execution` | RARE | Any two sacrifices share tier | Double this follower's base contribution, +6 additive |
| `pair_execution` | LEGENDARY | Any two sacrifices share tier | Double this follower's base contribution, +10 additive |
| `nest_dynasty` | RARE | This follower is a nest parent | Newborn +1 tier, strong rarity-up pressure |
| `nest_dynasty` | LEGENDARY | This follower is a nest parent | Newborn +2 tier, strong rarity-up pressure |
| `triune_cataclysm` | RARE | BLOOD+BONE+VOID all sacrificed | Final devotion ×1.25 |
| `triune_cataclysm` | LEGENDARY | BLOOD+BONE+VOID all sacrificed | Final devotion ×1.35 |
| `grave_engine` | RARE | This follower is sacrificed | +8 additive, +2 blood, spawn T1 BONE |
| `grave_engine` | LEGENDARY | This follower is sacrificed | +12 additive, +3 blood, spawn T1 BONE |

**Note:** Multiplier traits from combos are subject to the same `MULTIPLIER_TRAIT_CAP = 1` as regular traits. Only `blood_straight_exalt` and `void_edge` are multiplier combo templates.

### 6.2 All 50 Combo Seeds

30 RARE combos, 20 LEGENDARY combos. All share the pair-key format `parent_a|parent_b` (sorted lexicographically).

| ID | Name | Rarity | Parents | Template |
|----|------|--------|---------|----------|
| combo_001 | Red Catechism | RARE | blood_prophet + straight_rite | blood_straight_exalt |
| combo_002 | Sanguine Thesis | RARE | blood_prophet + sanguine_conductor | blood_economy_forge |
| combo_003 | Martyr's Communion | RARE | blood_prophet + martyrs_ledger | blood_economy_forge |
| combo_004 | Severed Sequence | RARE | straight_rite + paired_sigil | pair_execution |
| combo_005 | Ivory Dominion | RARE | ossuary_king + ossuary_archon | bone_citadel |
| combo_006 | Execution Gallery | RARE | ossuary_king + votive_executor | bone_citadel |
| combo_007 | Nursery of Dust | RARE | gravetide + brood_keeper | grave_engine |
| combo_008 | Lineage Catacomb | RARE | gravetide + lineage_tutor | nest_dynasty |
| combo_009 | Hushed Aperture | RARE | void_herald + hush_matron | void_edge |
| combo_010 | Candle Fracture | RARE | void_herald + black_candlebearer | void_edge |
| combo_011 | Black Matins | RARE | black_candlebearer + hush_matron | void_edge |
| combo_012 | Tithe Execution | RARE | martyrs_ledger + votive_executor | blood_economy_forge |
| combo_013 | Veiled Tutorium | RARE | chosen_veil + lineage_tutor | nest_dynasty |
| combo_014 | Veil of Broods | RARE | chosen_veil + brood_keeper | nest_dynasty |
| combo_015 | Conductor's Knot | RARE | sanguine_conductor + paired_sigil | pair_execution |
| combo_016 | Archon's Knot | RARE | ossuary_archon + paired_sigil | pair_execution |
| combo_017 | Silent Knot | RARE | hush_matron + paired_sigil | pair_execution |
| combo_018 | Executor's Knot | RARE | votive_executor + paired_sigil | pair_execution |
| combo_019 | Dynasty Scroll | RARE | brood_keeper + lineage_tutor | nest_dynasty |
| combo_020 | Ledger of Graves | RARE | martyrs_ledger + gravetide | grave_engine |
| combo_021 | Archon's Writ | RARE | ossuary_archon + votive_executor | bone_citadel |
| combo_022 | Conductor's Writ | RARE | sanguine_conductor + martyrs_ledger | blood_economy_forge |
| combo_023 | Rite Ledger | RARE | straight_rite + martyrs_ledger | blood_straight_exalt |
| combo_024 | Prophet's Veil | RARE | blood_prophet + chosen_veil | blood_straight_exalt |
| combo_025 | Kingmaker Nursery | RARE | ossuary_king + brood_keeper | nest_dynasty |
| combo_026 | Void Pedagogy | RARE | void_herald + lineage_tutor | nest_dynasty |
| combo_027 | Executor's Candle | RARE | black_candlebearer + votive_executor | bone_citadel |
| combo_028 | Hushed Veil | RARE | chosen_veil + hush_matron | void_edge |
| combo_029 | Bonefall Charter | RARE | gravetide + ossuary_archon | grave_engine |
| combo_030 | Crimson Aperture | RARE | sanguine_conductor + void_herald | void_edge |
| combo_031 | Ascendant Prophet | LEGENDARY | crimson_ascendant + blood_prophet | blood_straight_exalt |
| combo_032 | Ascendant Rite | LEGENDARY | crimson_ascendant + straight_rite | blood_straight_exalt |
| combo_033 | Ascendant Conductor | LEGENDARY | crimson_ascendant + sanguine_conductor | blood_economy_forge |
| combo_034 | Oracle King | LEGENDARY | ossuary_oracle + ossuary_king | bone_citadel |
| combo_035 | Oracle Archon | LEGENDARY | ossuary_oracle + ossuary_archon | bone_citadel |
| combo_036 | Crowned Herald | LEGENDARY | void_crown + void_herald | void_edge |
| combo_037 | Crowned Hush | LEGENDARY | void_crown + hush_matron | void_edge |
| combo_038 | Apostolic Veil | LEGENDARY | apostolic_womb + chosen_veil | nest_dynasty |
| combo_039 | Apostolic Brood | LEGENDARY | apostolic_womb + brood_keeper | nest_dynasty |
| combo_040 | Apostolic Tutor | LEGENDARY | apostolic_womb + lineage_tutor | nest_dynasty |
| combo_041 | Triune Herald | LEGENDARY | triune_heir + void_herald | triune_cataclysm |
| combo_042 | Triune Conductor | LEGENDARY | triune_heir + sanguine_conductor | triune_cataclysm |
| combo_043 | Triune Archon | LEGENDARY | triune_heir + ossuary_archon | triune_cataclysm |
| combo_044 | Triune Sigil | LEGENDARY | triune_heir + paired_sigil | triune_cataclysm |
| combo_045 | Ascendant Heir | LEGENDARY | crimson_ascendant + triune_heir | triune_cataclysm |
| combo_046 | Oracle Heir | LEGENDARY | ossuary_oracle + triune_heir | triune_cataclysm |
| combo_047 | Crowned Heir | LEGENDARY | void_crown + triune_heir | triune_cataclysm |
| combo_048 | Apostolic Heir | LEGENDARY | apostolic_womb + triune_heir | triune_cataclysm |
| combo_049 | Crimson Crown | LEGENDARY | crimson_ascendant + void_crown | void_edge |
| combo_050 | Apostolic Oracle | LEGENDARY | ossuary_oracle + apostolic_womb | nest_dynasty |

---

## 7. Balance Parameters — All Hardcoded Numbers

### 7.1 Run Configuration

```gdscript
RUN_CONFIG_DEFAULT = {
  "max_weeks": 10,
  "target_base": 40,
  "target_growth": 1.5,
  "overflow_devotion_per_blood": 1,   # 1 devotion over target = 1 blood
  "overflow_blood_per_devotion": 1,   # legacy alias
  "overflow_weekly_cap": 0,            # 0 = no cap on overflow blood per week
  "early_win_bonus": 20,               # blood for clearing in round 1
  "round_devotion_cap_mult": 1.25,     # single-round devotion capped at target × 1.25
}
```

### 7.2 Weekly Devotion Targets

Formula: `round(40 × 1.5^(week−1))` rounded to nearest 5.

| Week | Raw | Rounded |
|------|-----|---------|
| 1 | 40.00 | 40 |
| 2 | 60.00 | 60 |
| 3 | 90.00 | 90 |
| 4 | 135.00 | 135 |
| 5 | 202.50 | 205 |
| 6 | 303.75 | 305 |
| 7 | 455.63 | 455 |
| 8 | 683.44 | 685 |
| 9 | 1025.16 | 1025 |
| 10 | 1537.74 | 1540 |

Round cap per week = `floor(target × 1.25)`:
Week 1 = 50, Week 5 = 256, Week 10 = 1925.

### 7.3 Pool Constants

| Constant | Value |
|----------|-------|
| `POOL_CAP` | 1000 |
| `MAX_TIER` | 10 |
| `STARTING_NESTS` | 2 |
| `MULTIPLIER_TRAIT_CAP` | 1 (per round) |

### 7.4 Tier Weights (for weighted random tier rolls)

| Tier | Weight | % of total (27) |
|------|--------|-----------------|
| 1 | 1 | 3.7% |
| 2 | 2 | 7.4% |
| 3 | 3 | 11.1% |
| 4 | 4 | 14.8% |
| 5 | 6 | 22.2% |
| 6 | 4 | 14.8% |
| 7 | 3 | 11.1% |
| 8 | 2 | 7.4% |
| 9 | 1 | 3.7% |
| 10 | 1 | 3.7% |

### 7.5 Trait Sub-Trait Probabilities

| Context | COMMON | RARE | LEGENDARY | None |
|---------|--------|------|-----------|------|
| Starting pool | 72% | 16% | 2% | 10% |
| Shop recruit | 60% | 16% | 4% | 20% |
| Breeding (wild, if trait rolls at all) | 70% | 22% | 8% | — |

Wild breeding: 80% chance any trait at all; 20% chance none (unless parent has `chosen_veil` or `brood_sovereign`).

### 7.6 Recruit Follower Type Distribution (Shop)

| Type | Chance |
|------|--------|
| BLOOD | 70% |
| BONE | 25% |
| VOID | 5% |

### 7.7 Hand Drawing Follower Type Distribution (Legacy `draw_new_hand`)

Note: This function exists but is no longer called — `draw_hand_from_pool()` is used instead. Preserved here for reference:
- BLOOD: 60%, BONE: 30%, VOID: 10%

### 7.8 Wild Breeding Chances

| Pair | Base Chance | With 1× Fertility Idol | With 2× |
|------|-------------|----------------------|---------|
| Both VOID | 30% | 30% (idol doesn't apply) | 30% |
| One VOID | 20% | 20% (idol doesn't apply) | 20% |
| Other × Other | 45% | 55% | 65% |

Favored pair bonus: +20% (capped at 95%).

### 7.9 Nest Breeding Rarity Resolution — Base Probabilities

| Situation | Target Rarity |
|-----------|---------------|
| Both parents LEGENDARY | Always LEGENDARY |
| Both parents RARE | Always RARE |
| One parent LEGENDARY | RARE with 65% chance, else LEGENDARY |
| One parent RARE | RARE with 55% chance, else COMMON |
| Both COMMON | COMMON (unless common_to_rare_chance > 0) |

Modifiers (additive unless noted):

| Effect | `single_rare_chance` | `rare_from_legendary_chance` | `common_to_rare_chance` |
|--------|----------------------|------------------------------|------------------------|
| lineage_tutor parent | +35% | −10% | +35% |
| nest_dynasty combo | +15% | −10% | +20% |
| legendary nest_dynasty | +10% | −5% | +10% |
| brood_sovereign parent | +20% | −10% | +20% |
| chosen_veil parent | max(current, 75%) | −15% | max(current, 35%) |
| Selective Breeding Scroll | +15% | −10% | +15% |
| Favored parent | +10% | −5% | +10% |

All three values are clamped: `single_rare_chance ∈ [0.25, 0.95]`, `rare_from_legendary_chance ∈ [0.05, 0.95]`, `common_to_rare_chance ∈ [0.0, 0.80]`.

### 7.10 Nest Tier Variance

| Roll | Probability | Effect |
|------|-------------|--------|
| < 0.20 | 20% | +1 tier |
| 0.20–0.30 | 10% | −1 tier |
| > 0.30 | 70% | ±0 |

### 7.11 Wild Breeding Trait Inheritance (if trait rolls)

| Condition | Inherited bias |
|-----------|---------------|
| brood_sovereign parent | 60% chance to inherit parent trait |
| Otherwise | 35% chance to inherit parent trait |

If Seal of Inheritance is owned: always inherit a parent trait (if any parent has one); bypasses all other logic.

### 7.12 Shop Rarity Constants

```gdscript
SHOP_RARE_BASE     = 0.15
SHOP_RARE_PER_WEEK = 0.02
SHOP_RARE_MAX      = 0.30
SHOP_LEGENDARY_BASE     = 0.02
SHOP_LEGENDARY_PER_WEEK = 0.01
SHOP_LEGENDARY_MAX      = 0.08
SHOP_UNCOMMON_CHANCE    = 0.35
```

### 7.13 Shop Costs (Blood)

| Rarity | Base | With Tithe Discount | Min |
|--------|------|---------------------|-----|
| COMMON | 10 | 9 | 2 |
| UNCOMMON | 20 | 19 | 2 |
| RARE | 30 | 29 | 2 |
| LEGENDARY | 40 | 39 | 2 |

### 7.14 Scoring — Relic Additive Values

| Relic | Trigger | Additive per copy |
|-------|---------|-------------------|
| Thin Blade | 1 sacrifice | +8 |
| Quick Chant | Any sacrifice | +3 |
| Calcify | Per BONE | +2 |
| Ossuary Standard | 2+ BONE | +10 |
| Bone Polisher | Best BONE tier | +(tier) |
| Ritual Symmetry | Even count (2 or 4) | +12 |
| Crimson Book | Per BLOOD | +1 |
| Bone Idol | Per BONE | +(tier) |
| Ossuary Standards | Per BONE | +(tier) |
| Prayer Beads | All 3 same type | +6 |
| Wax Seal | Any tier pair | +8 |
| Choir Robes | 3 different tiers | +5 |
| Triune Reliquary | 3 with BLOOD+BONE+VOID | +12 |
| Bloodright Almanac | Blood straight (consecutive) | +10 (also +2 blood) |

### 7.15 Scoring — Relic PRE_MULT Multipliers

| Relic | Trigger | Effect |
|-------|---------|--------|
| Sacrificial Order | Exactly 3 sacrificed | additive_total × 2^copies |
| Balanced Offering | BLOOD+BONE+VOID present | additive_total × 2^copies |

### 7.16 Scoring — Blood Economy from Relics

| Relic | Trigger | Blood per copy |
|-------|---------|---------------|
| Blood Abacus | Each BLOOD sacrifice | +1 per BLOOD (adds to per_blood rate) |
| Bone Saw | 2+ BONE | +1 |
| Bloodright Almanac | Blood straight | +2 |
| Bone Saw (2 copies) | 2+ BONE | +2 |

### 7.17 Lineage Tutor Modifiers in Nest Breeding

| Context | Value |
|---------|-------|
| Base lineage_tutor rarity-up chance (in fallback trait roll) | 55% if legendary nest_dynasty, else 35% |
| When trait_id == "" after apostolic_womb overrides | N/A |
| brood_sovereign empty trait → rare chance | 40% |

### 7.18 Balance Simulation Targets (TestRunner)

```
RUNS_PER_DOCTRINE = 600    (600 × 3 doctrines × 2 profiles = 3600 total)

BALANCE_TARGETS = {
  "expert": {
    pass_rate_start:        min 90%, max 99%    (weeks 1–2)
    pass_rate_end:          min 60%, max 85%    (late weeks)
    avg_week_target_mult:   min 0.95×, max 1.35×
    avg_round_target_mult:  min 0.55×, max 0.90×
    blood_earned_start:     min 5, max 14
    blood_earned_end:       min 8, max 22
  },
  "average": {
    pass_rate_start:        min 75%, max 92%
    pass_rate_end:          min 25%, max 55%
    avg_week_target_mult:   min 0.80×, max 1.15×
    avg_round_target_mult:  min 0.40×, max 0.70×
    blood_earned_start:     min 3, max 10
    blood_earned_end:       min 5, max 16
  }
}
```

The "expert" profile buys relics during simulation; "average" does not.

---

## 8. Progression & Difficulty

### 8.1 How Difficulty Increases
1. **Exponential target growth** (×1.5/week) is the primary driver. The gap between rounds 1–4 is significant; a player needs fundamentally better followers or combos, not just marginal gains.
2. **Round cap (×1.25)** prevents any single round from carrying the entire week's devotion requirement. Catching up is always a two-round game in hard weeks.
3. **Pool tier boost (+1/week)** partially counterbalances by making the pool stronger over time, but this approaches diminishing returns as followers hit tier 10.
4. **Rarity of relics offered increases** across weeks (see §7.12), meaning more powerful tools become available mid-to-late run.

### 8.2 What the Player Gains Over a Run
- **Relics** (bought with blood): accumulated across weeks, persistent.
- **Pool tier growth**: passive +1 per week per follower.
- **Breeding offspring**: offspring tier grows via brood_keeper, nest_dynasty, apostolic_womb, and weekly tier boosts. This is the primary "engine building" mechanic.
- **Combo traits**: bred followers with matching parent trait pairs can produce combo traits, enabling more specialized scoring strategies.
- **Blood economy**: relics like Crimson Interest and overflow conversion build a compounding blood reserve.

### 8.3 There Is No Meta-Progression
There are no persistent unlocks, no "run currency," and no carry-over between runs. Each run starts fresh with a doctrine choice and a fixed starting pool.

### 8.4 Doctrine Interaction With Scaling
- FLESH's −6 penalty for 0 BLOOD is meaningful in early weeks (−6 on a target of 40 is 15%) but trivial late game.
- RUIN's +8 BONE bonus is fixed additive and loses relative power as targets grow exponentially.
- SILENCE's +1 exponent is multiplicative and scales well — but requires exactly 1 VOID, which constrains hand composition.

---

## 9. Known Gaps & TODOs

### 9.1 Dead / Stub Code
1. **`_offer_legendary_if_needed()` in Shop.gd** (line 200–201): Empty function that immediately returns. No behavior implemented. It appears to be a placeholder for forcing a legendary offer under certain conditions.
2. **`get_shop_rarity_slots(week)` in GameState.gd** (line 1548–1551): Returns `["COMMON", "COMMON", "UNCOMMON"]` (weeks 1–2) or `["COMMON", "UNCOMMON", "RARE"]` (weeks 3+). **This function is never called anywhere in the active game code.** Shop.gd uses `roll_shop_rarity()` per-slot with no guaranteed-slot logic. The function may have been an earlier approach superseded by the probability system.
3. **`draw_new_hand()`** (line 498–502): Generates a random hand from scratch (not from pool). It's never called by any scene — only `draw_hand_from_pool()` is used. Dead code.

### 9.2 Description / Behavior Mismatches
4. **Hollow Chant description** says "VOID sacrifices boost your multiplier harder." Actual effect: `exponent = hollow_copies + 1` unconditionally — VOID count is completely irrelevant to Hollow Chant. The description is misleading.
5. **`chosen_veil` type** is `"BREEDING"` in TRAIT_REGISTRY but it delivers `+4 additive` when sacrificed (in the scoring match block). Its type should be `"HYBRID"` since it has both scoring and breeding effects.
6. **`Tithe Discount` minimum cost** is documented as "min 2" in the description and enforced in code, but the UI shows the discounted cost without clearly communicating the floor.
7. **`Bone Idol` and `Ossuary Standards`** share the same formula: each adds `tier × copies` per BONE sacrifice. They are functionally identical and stack with each other. The distinction exists in name/flavor but not mechanic.

### 9.3 Hook Architecture Inconsistency
8. **Hollow Chant and Void Prism hooks** (lines 1772–1778) only append log lines to `relic_multiplier_lines`; they do not modify `ctx["exponent"]` or `ctx["base"]`. Their numerical effects are applied directly before hooks run. This inconsistency means MULTIPLIER_ADJUST hooks have mixed responsibilities — some are purely descriptive (Hollow Chant, Void Prism) while others are operative (Black Candle, Cold Incense, Hollow Abacus, Ectoplasm Jar). Any future relic using the hook system for exponent/base modification should be handled operatively.

### 9.4 Balance Concerns (from code analysis)
9. **Soul Lantern drains ALL blood to 0** (line 1413). This is not mentioned anywhere in the relic description and is an extremely severe hidden cost. Whether intentional or a bug is unclear.
10. **Pool tier capping**: All non-VOID followers gain +1 tier per week. By week 7+, many followers likely approach tier 10. The weekly boost provides diminishing returns for high-tier followers, and `min(MAX_TIER, tier + 1)` silently clamps. No mechanism to "re-express" tier growth once capped.
11. **Overflow blood cap** is 0 by default (no cap). Very large overflow devotion can generate large blood windfalls; this is not currently limited except by the round cap.
12. **VOID followers always spawn at tier 0** (including shop recruits, wild breeding, nest breeding). Only Soul Lantern-ascended followers can be VOID with a tier > 0. This means `refined_void_count` (the bonus `× (1 + 0.5 × refined_void_count)`) is almost never nonzero in practice without the Soul Lantern.

### 9.5 Simulation / Testing Flags
13. **`RUN_ONLY_SIM = true`** in TestRunner.gd (line 6): All unit tests (`test_relic_scoring_exhaustive`, `test_trait_effects`, etc.) are skipped when this is true. Currently set to `true`, so exhaustive mechanical tests do not run.
14. **Lineage Tutor chance condition** (line 952): `var tutor_chance: float = 0.55 if has_legendary_nest_dynasty else 0.35` — this logic path only executes if `trait_id == ""` AFTER the apostolic_womb override. Given the override forces a non-empty trait_id, lineage_tutor's empty-trait-fallback is effectively unreachable when apostolic_womb is also a parent.

### 9.6 Development Comments Left in Production Code
15. Lines 2512–2516 in GameState.gd contain inline developer notes ("Sanity scenarios for breakdown output") referencing named trait IDs (`Fickle`, `Zealous`) that don't exist in the current TRAIT_REGISTRY. These may reference an earlier trait naming scheme.

### 9.7 Missing / Unimplemented Mechanics
16. **Favored breeders reset each week**: `favored_breeder_ids.clear()` is called in `perform_weekly_breeding()`. The Shop UI allows resetting favored breeders, but any selections carry only for one breeding cycle, not persistently.
17. **`_deferred_change_scene`** in RunGame.gd (line 700–701) is a no-op stub: `pass`. Appears to be an unused deferred scene transition mechanism.
18. **No "miss" counter**: The game ends on a **single failed week** (two consecutive rounds not meeting target). The instructions.md document mentions "failure after 2 missed weeks" but the code shows game over after 1 failed week. This may be a discrepancy between design intent and implementation, or "2 rounds = 1 week" is the intended framing.

---

## 10. Open Questions

1. **Is the Soul Lantern blood drain intentional?** The relic description says "ascend a follower" with no mention of cost beyond "once per run." Draining all blood to 0 is an enormous economic penalty undocumented in the UI. Was this the intended tradeoff for the powerful effect?

2. **What is the intended role of `get_shop_rarity_slots()`?** Should guaranteed slot distributions (COMMON/UNCOMMON/RARE by week bracket) be enforced? The current pure-probability system means week 1 could theoretically offer three LEGENDARY relics (astronomically unlikely but possible), and also means early shops are much less predictable in rarity distribution.

3. **Is the round cap (×1.25) per round or per week?** Currently it's per individual round — you can score at most `floor(target × 1.25)` in one round. But two rounds of that cap means a player could accumulate `floor(target × 2.5)` total devotion per week. If the intent was to limit total weekly devotion, a weekly cap would be needed separately.

4. **What is the VOID tier in starting pool entries supposed to represent?** The starting pool entries for VOID followers have `"tier": _rng.randi_range(1, 2)`, but all VOID followers are forced to `tier = 0` in `_make_specific_follower`. The tier values (1 or 2) are silently discarded. Was this a mistake, or is there a planned mechanic where VOID can have a meaningful starting tier?

5. **What did `_offer_legendary_if_needed()` do before it became a stub?** And under what conditions should it trigger? A guarantee mechanic (e.g., "if player has not seen a legendary by week X, guarantee one") would be a common roguelite pattern.

6. **Is `draw_new_hand()` (pool-independent hand generation) intentionally retired?** If so, should it be removed? Keeping it risks future confusion about which function is canonical.

7. **What is the intended "average profile" vs "expert profile" distinction in the simulation?** Currently `include_relics: profile == "expert"` is the only mechanical distinction. The "average" profile simulates runs without relic purchases. Is this the right proxy for player skill levels? A more nuanced model (e.g., suboptimal picks, partial relic use) might better represent the actual player population.

8. **Does `chosen_veil` being listed as type `"BREEDING"` affect anything mechanically?** Trait type strings are stored but not filtered or branched on in any game logic — the actual effects are all in the match block. So the type is only cosmetic/descriptive today. However, if sorting, filtering, or type-based effects are added in the future, this mismatch would matter.

9. **Is the Multiplier Trait Cap (1 per round) working as intended?** Multiple high-value traits like `blood_prophet`, `void_herald`, and `crimson_ascendant` all compete for the single multiplier slot. The cap prevents "multiplier stacking" but also makes having multiple of these traits in a sacrifice feel wasteful. Should the cap apply only to the base/exponent effects and not to final-multiplier effects (`triune_champion`, `triune_heir`, `triune_cataclysm`)?

10. **Is Hollow Chant's description meant to be rewritten, or should the mechanic be changed?** Either the description should say "each copy adds +1 to multiplier exponent unconditionally" or the mechanic should be changed to gate the bonus on VOID count (which would align with the flavored wording).

11. **Why does the Relic Pack bonus cap at `rare_bonus = 0.10` and `legendary_bonus = 0.04`?** These correspond to average tiers of 10 and 11 respectively for the caps. Since max tier is 10, the legendary bonus cap is unreachable in practice (`(10 − 7) × 0.01 = 0.03`, not 0.04). This is a minor dead parameter.

12. **Should `refined_void_count` (VOID with tier > 0) be a meaningful design axis?** Currently almost never nonzero without Soul Lantern. If this mechanic is intended to synergize with VOID builds, there may need to be more ways to produce refined VOID followers beyond the single one-time Soul Lantern.

---

*Document generated from codebase snapshot: 2026-03-09. All values extracted from `scripts/` directory — `GameState.gd`, `Shop.gd`, `RunGame.gd`, `TestRunner.gd`, `ComboTraitGenerator.gd`.*
