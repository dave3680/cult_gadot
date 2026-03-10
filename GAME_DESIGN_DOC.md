# Cult of Accumulation — Game Design Document
*Living document. Last updated March 2026.*

---

## Overview

Cult of Accumulation is a single-player roguelike card game in the tradition of Balatro. The player leads a cult through a 10-week run, sacrificing followers each week to generate devotion. Devotion must exceed a rising weekly target or the run ends. Between weeks the player manages a shop (relics, recruits), a breeding program (follower offspring), and a pool of living followers.

Three doctrines give each run a distinct identity: FLESH rewards blood-follower density, RUIN rewards bone-follower investment, and SILENCE rewards patient VOID exponent building. All three share the same scoring formula but reach high numbers through different paths.

The game has no permanent upgrades. The only meta-layer is the Codex, a read-only discovery log of every relic, trait, and combo trait the player has ever encountered. Discovery is the hook; strategy is the repeat content.

---

## Core Loop

### The Run (10 Weeks)

```
Doctrine Select → [Week Loop × 10] → Victory / Game Over
```

### The Week

```
Week Start (blood income, tier boosts)
  → Round 1: Draw hand → Sacrifice 3 → Score
  → Wild Breeding (30% chance per eligible pair)
  → Round 2: Draw hand → Sacrifice 3 → Score
  → Week total devotion capped at floor(target × 2.0)
  → Check pass/fail vs. weekly target
  → If pass: Shop → Nest Select → Breeding results → next week
  → If fail: Game Over
```

### The Round

1. **Draw** 6 followers from pool into hand (exhausted followers excluded)
2. **Select** 3 followers as sacrifices (drop into the pit)
3. **Resolve** the doctrine button (FLESH: confirm for % bonus; RUIN: confirm; SILENCE: confirm 1 VOID check)
4. **Score**: formula runs → devotion added to weekly total
5. After round 1, exhausted followers reset. Wild breeding fires. Round 2 begins.

---

## Scoring Formula

```
Final Devotion = clamp(Additive × Multiplier_Base ^ Exponent, 0, ∞)
```

Every hook below runs in sequence on the sacrifice of 3 followers.

### Step 1 — Base Follower Contribution (Additive)

| Trait | Per-Follower Value |
|-------|--------------------|
| BLOOD | tier × 1 |
| BONE  | tier × 2 |
| VOID  | +1 (fixed; tier contributes to Refined VOID bonus only) |
| SOUL  | tier × 1 (rare; typically used as BLOOD substitute) |

### Step 2 — Trait Additive Bonuses

Each follower's `trait_id` may add to the additive total. Examples:

| Rarity | Example Trait | Effect |
|--------|---------------|--------|
| Common | devout | +2 additive |
| Common | fervent | +2 additive, +1 blood |
| Rare | ossuary_king | +14 additive if 2+ BONE |
| Rare | blood_prophet | +1 exponent (multiplier trait) |
| Legendary | crimson_ascendant | +2 multiplier base if all BLOOD |
| Legendary | ossuary_oracle | +36 additive, +1 exponent if 2+ BONE |

Up to **MULTIPLIER_TRAIT_CAP = 2** multiplier traits may fire per play. Additional multiplier traits are ignored (silent). Some relics override or raise this cap.

### Step 3 — Doctrine Additive Bonus

Each week the player selects one doctrine action. Only one fires per play.

| Doctrine | Condition | Effect |
|----------|-----------|--------|
| FLESH | 3+ BLOOD sacrificed | +floor(target × 0.08) |
| FLESH | 0 BLOOD sacrificed | −floor(target × 0.04) penalty |
| FLESH | 1–2 BLOOD | +0 |
| RUIN | BONE present + top BONE condition | +floor(target × 0.10) + (highest_bone_tier × 2) |
| RUIN | No BONE | +0 |
| SILENCE | Exactly 1 VOID | +1 exponent (applied at Step 5) |
| SILENCE | Any other | +0 |

### Step 4 — Relic PRE_MULT Hooks

Some relics multiply the additive total before the exponent fires:
- **Sacrificial Order** (Legendary): ×2 if exactly 3 sacrifices
- **Balanced Offering** (Rare): ×2 if BLOOD + BONE + VOID all present
- **The Peaked Rite** (Rare): ×1.5 if average tier of 3 sacrifices > 7

### Step 5 — Multiplier Base

Starts at 1. Relics and traits push it higher:

| Source | Effect |
|--------|--------|
| Black Candle | base = max(base, 2) |
| Void Prism | +1 per VOID sacrificed |
| crimson_ascendant (trait) | +2 if all BLOOD |
| void_crown (trait) | +2 if exactly 1 VOID |
| Various BLOOD/BONE relics | +1 conditionally |

Multiplier base is floored at 1.

### Step 6 — Exponent

Starts at 1. Each source below adds to it:

| Source | Condition | Bonus |
|--------|-----------|-------|
| Hollow Chant (stacking relic) | always | +1 per copy |
| straight_rite (trait) | 3 consecutive-tier sacrifices | +2 |
| blood_prophet (trait) | all 3 BLOOD | +1 |
| SILENCE doctrine | exactly 1 VOID | +1 |
| The Final Silence (relic) | SILENCE + VOID tier 5+ | +2 total instead of +1 |
| Ectoplasm Jar (relic) | always (costs −6 pool cap) | +1 per copy |

### Final: Refined VOID Bonus

If any VOID follower in the sacrifice is "refined" (tier > 0, or Soul Lantern used, or certain relics apply), the final devotion is multiplied by (1.5 × refined_void_count). This is SILENCE's endgame scaling.

---

## Doctrines

The doctrine is chosen once at run start and defines the starting pool.

### Path of Flesh

**Identity**: Flood the sacrifice with BLOOD followers. Use the per-week additive bonus as a reliable floor.

**Starting Pool**: 9 BLOOD (tiers 4–6), 3 BONE, 2 VOID
- 1 rare follower guaranteed; ~2% chance of legendary

**Doctrine Bonus**: 3+ BLOOD → +8% of weekly target (additive). Penalty: 0 BLOOD → −4%.

**Scaling Path**: Stack BLOOD relics (Crimson Book, Blood Abacus, Sanguine series). Leverage multiplier traits (blood_prophet, crimson_ascendant). Late-game goal is multiplier base 3+ with exponent 2–3.

**Risk**: Overbuilding additive while neglecting multiplier. Without a multiplier chain, devotion plateaus at week 6–7.

---

### Path of Ruin

**Identity**: BONE followers contribute tier × 2. Build a few very high-tier BONE followers for a large, stable additive floor.

**Starting Pool**: 5 BLOOD, 6 BONE (tiers 4–6), 2 VOID
- Higher average starting tier than FLESH

**Doctrine Bonus**: Top BONE present → +10% of target + (highest_bone_tier × 2). No BONE = 0%.

**Scaling Path**: Nest-breed BONE pairs toward tier 8–10. Ossuary relics (Bone Idol, Calcify, Ossuary Engine, Skeleton Archive) stack with tier. Late-game BONE at tier 10 + doctrine bonus can carry weeks 8–10.

**Risk**: Pool becomes BONE-heavy with low multiplier potential. RUIN doctrine requires at least 1 BONE per sacrifice — flexible selection is constrained.

---

### Path of Silence

**Identity**: VOID followers contribute +1 additive regardless of tier, but refined VOID (tier > 0) multiplies final devotion by ×1.5 each. Exponent is the scaling axis.

**Starting Pool**: 5 BLOOD, 3 BONE, 4 VOID (all tier 0)

**Doctrine Bonus**: Exactly 1 VOID sacrificed → +1 exponent for that play.

**Scaling Path**: Route tier into VOID followers via VOID-VOID breeding (now produces tier 1+ offspring post-Phase-2), Void Cradle relic (tier on sacrifice), and The Final Silence. Each refined VOID in sacrifice multiplies the final devotion by 1.5×.

**Risk**: Slowest early game — VOID tier 0 contributes almost nothing in weeks 1–3. Requires patient relic investment. Soul Lantern (once-per-run ascension) remains the fastest route to refined VOID but all blood is spent.

---

## Followers

### Structure

```
{
  id: int,           # Unique within run
  trait: String,     # "BLOOD", "BONE", "VOID", "SOUL"
  trait_id: String,  # Specific named trait (e.g. "blood_prophet")
  tier: int,         # 0–10
  rarity: String,    # "COMMON", "UNCOMMON", "RARE", "LEGENDARY"
  exhausted: bool,   # True after sacrifice; reset before round 2
}
```

### Traits

**Common (25 traits)**: Additive bonuses of +2–+6. Economy traits (fervent: +1 blood, zealot_ledger: +2 blood). Pool-manipulation traits (resilient: 20% chance to return from sacrifice). Some are conditional (bloodbrand: +4 if 2+ BLOOD total).

**Rare (18 traits)**: Additive bonuses +12–+28 with conditions. Multiplier traits (blood_prophet, straight_rite, void_herald, void_crown). Breeding traits (lineage_tutor: +35% rarity-up; brood_sovereign: bonus offspring). Mixed effects.

**Legendary (7 traits)**: crimson_ascendant (+2 multiplier base, all-BLOOD), ossuary_oracle (+36 additive + exponent), void_crown (+2 multiplier base, 1 VOID), apostolic_womb (breeding), triune_heir (triune conditions), crimson_revelation, ossuary_titan.

**Combo Traits (50 traits)**: Produced only when two specific parent traits are both present in offspring. Naming convention: "Red Catechism" (blood_prophet + straight_rite), "Ossuary Mantle" (ossuary_king + stalwart), etc. Effects: often +1 exponent or high additive (+24–+40) or breeding bonuses. The discovery of combo traits drives Codex completion.

### Tier

- Range: 0–10
- VOID followers start at 0; all other recruits arrive at tiers 4–6
- **Tier Boost**: Each week, the game applies a random +1 tier boost to some pool followers (scales with week number and relics)
- **Cap**: Tier is clamped to 10
- **Dynasty Seal** (relic): Offspring of two tier-8+ parents spawn at tier 6

### Rarity

| Rarity | Starting Pool | Shop Recruits |
|--------|---------------|---------------|
| Common | 72% | 60% |
| Uncommon | — | 20% |
| Rare | 16% | 16% |
| Legendary | 2% | 4% |

Breeding can push rarity upward (rarity-up pressure). The Selective Breeding Scroll, lineage_tutor trait, and brood_sovereign trait all increase rarity-up probability.

---

## Breeding System

### Nest Breeding

- **Capacity**: 2 nests (3 with 2+ Deep Pool relics equipped)
- **Assignment**: Any 2 pool followers (not exhausted) can be paired in a nest via the NestSelect screen
- **Each Week**: 50% chance per nest produces 1 offspring
- **Parents**: Return to pool unchanged (not consumed)
- **Focus**: Each nest has a Focus setting (RARITY, TIER, FAMILY, NONE) that costs 2–3 blood and biases offspring properties
- **Offspring Tier**: floor((parent_a_tier + parent_b_tier) / 2) ± 1 variance, clamped 0–10; VOID-VOID floor is 1 (post-Phase-2 fix)
- **Offspring Trait**: Inherited or randomized based on parent traits, rarity-up pressure, and lineage relics

### Wild Breeding

- **Trigger**: After round 1 resolves, between rounds
- **Eligibility**: Non-nested, non-exhausted pairs that share a compatible configuration
- **Chance**: 20% per eligible pair (+ 10% per Fertility Idol copy)
- **VOID-VOID Special**: 30% chance but now produces tier 1+ offspring (was broken: always tier 0)
- **Limit**: 1–2 wild breeding events per week depending on relics

### Breeding Results Screen

After the week resolves, a dedicated Breeding.tscn scene shows any offspring produced that week. Parents are shown with their offspring.

---

## Relic System

### Overview

Relics are passive items acquired in the shop. They modify scoring, economy, breeding, pool management, or special actions. Each has a rarity (Common/Rare/Legendary), a cost (typically 3–6 blood), and a hook that fires at specific points in the resolution pipeline.

**Current Pool**: 150 relics total.
- 50 original relics (present at start of Phase 2)
- 100 new relics added across 10 archetypes (Phase 3 expansion)

### Hook Points

| Hook | Fires When |
|------|------------|
| WEEK_START | Beginning of week, before rounds |
| PRE_ADD | Before adding follower base contribution |
| POST_ADD | After all additive is summed |
| PRE_MULT | Before multiplier base is applied (can multiply additive) |
| MULTIPLIER_ADJUST | When determining multiplier base |
| EXPONENT_ADJUST | When determining exponent |
| POST_RESOLVE | After devotion is finalized (economy, pool effects) |
| SHOP_ENTER | When entering shop |
| SHOP_EXIT | When leaving shop |
| BREED | When an offspring is produced |

### Relic Archetypes

**Tier Scaling (12)**: Reward high-tier followers. Iron Reliquary (+20 if top tier ≥ 8), Ivory Throne (+5 per tier above 7), Crown of Tiers (once/week: promote +3 tier for 5 blood), Dynasty Seal, The Last Rung.

**VOID Investment (12)**: Build the VOID endgame. Void Cradle (VOID sacrificed → +1 tier after resolve), Refinery of Silence (×(1.5 + 0.2×copies) per refined VOID), The Absent Crown (2 VOID → both count as refined), Annihilation Compact, The Final Silence.

**BONE Fortress (10)**: Amplify BONE density. Bone Standard (top BONE tier doubled), The White Wall (3 BONE, 0 VOID → base = 2), Gravewright (BONE sacrifice 25% chance T2 spawn), Ossuary Absolute.

**BLOOD Tempo (10)**: BLOOD synergy and exponent access. Bloodfire Compact (3 BLOOD → multiplier trait cap raised by 1), The Arterial Rite, Crimson Absolute.

**Triune / Mixed (8)**: Reward sacrifice of all 3 trait types simultaneously. The Concordat, Trinity Engine (all three → cap raised), The Sacred Triangle.

**Pool Manipulation (10)**: Change pool composition. The Pruning Hook (cull 1 follower, gain 2 blood, once/shop), The Rotary (swap 2 pool followers, once/shop), The Deep Pool (+6 pool cap, enables 3rd nest at 2 copies), Warden of the Fold.

**Economy / Blood (10)**: Blood generation and compound interest. Crimson Interest (after shop: +floor(blood / 5)), Crimson Compound (improves divisor), Usurer's Mark (interest fires multiple times), The Iron Tithe (blood at week start scales with week).

**Sacrifice Count (10)**: Modify how many followers are sacrificed. Single Rite (1 sacrifice, 3× additive), The Count Absolute (4 sacrifices), The Expanding Contract (5 sacrifices).

**Breeding Amplifiers (10)**: Enhance offspring. The Womb of Ages (stacking rarity-up), Nursery Ledger (weekly spawn guarantee), The Dynasty Forge, The Eternal Line.

**High-Risk / Cursed (8)**: Strong effects with trade-offs. The Bleeding Edge, The Hungry Altar (massive bonus, pool reduced), The Damnation Seal.

### Relic Shop

- **5 slots offered per week** (3 base, +rerolls with Reroll Scroll or Director's Addendum)
- **Guaranteed Legendary**: If no legendary has been seen by week 6, one slot forces legendary
- **Legendary Guarantee**: tracked via `legendary_seen_in_shop` flag
- **Rarity Distribution at Week 10**: 40% Common, 35% Uncommon, 23% Rare, 8% Legendary (ramping through run)
- **Rotary Swap**: The Rotary relic enables a once-per-shop swap between offered slots and pool followers (post-Phase 3 UI addition)
- **Codex Integration**: First time a relic is seen in shop, it's logged to Codex

---

## Blood Currency

### Generation

| Source | Amount |
|--------|--------|
| Run start | 5 blood |
| Week clear (early win, week 1) | +20 bonus |
| Ceramic Cup / Brass Tithe Bowl | +1 per copy per week cleared |
| Trait: fervent, bone_tithe, zealot_ledger | +1–2 per play |
| Crimson Interest (relic) | floor(blood / 5) after shop |
| Overflow conversion | Excess devotion → blood (capped at 50% of target) |

### Spending

| Action | Cost |
|--------|------|
| Buy relic | 3–6 blood (default 4; reduced by Tithe Discount) |
| Recruit follower | 1 blood each |
| Nest focus change (RARITY/TIER) | 2–3 blood |
| Crown of Tiers promotion | 5 blood |
| Debt Scripture | Borrow 2 blood (repaid from earned blood) |

### Overflow Blood Cap (Phase 2)

When weekly devotion exceeds the target, excess converts to blood at 1:1 (or relic-modified ratio). This overflow is capped at `floor(target × 0.5)` per week:

| Week | Target | Max Overflow Blood |
|------|--------|--------------------|
| 1 | 40 | 20 |
| 5 | 145 | 72 |
| 10 | 1000 | 500 |

---

## Weekly Target Curve

| Week | Target | Formula / Override |
|------|--------|--------------------|
| 1 | 40 | 40 × 1.38^0 |
| 2 | 55 | 40 × 1.38^1 |
| 3 | 75 | 40 × 1.38^2 |
| 4 | 105 | 40 × 1.38^3 |
| 5 | 145 | 40 × 1.38^4 |
| 6 | 200 | 40 × 1.38^5 |
| 7 | 275 | 40 × 1.38^6 |
| 8 | 400 | **Override** |
| 9 | 620 | **Override** |
| 10 | 1000 | **Override** |

Targets are rounded to the nearest 5. The week 8–10 overrides create a steeper final ramp to preserve late-game tension while weeks 1–7 follow the formula.

**Per-Week Devotion Cap**: `floor(target × 2.0)` — limits total devotion earned across both rounds of a week. This prevents a single massive round from making the second round irrelevant and eliminates extreme snowballing.

---

## Ritual Cards

Ritual cards are single-use modifiers that apply to the next round only.

| Card | Effect |
|------|--------|
| Anoint | +15 additive this round |
| Silence | +1 effective VOID count this round (helps Path of Silence doctrine) |
| Rebirth | One sacrificed follower returns to pool after resolve |

**Access**: Requires the Scarlet Planetarium (Rare) relic. Once held, one ritual card is offered in the shop each week. Future plan: offer 1 free ritual card at week 3 to teach the mechanic before gating it behind the relic.

---

## Codex (Meta-Progression)

The Codex is a persistent across-runs discovery log. It tracks:

- **Relics**: Unlocks full description after first purchase
- **Traits**: Logs on first encounter (sacrifice or recruit)
- **Combo Traits**: Logs on first breed

The Codex has no gameplay bonuses. Discovery is the reward. It solves two problems:
1. **Retention**: Completionists have something to pursue across runs
2. **Information Asymmetry**: New players can revisit relic descriptions after the fact instead of memorising them in-shop

Codex data is saved to `user://codex_data.json` and persists across sessions.

---

## Pool Management

### Pool

The follower pool holds all living followers not currently in hand or exhausted. Followers in the pool can be:
- Drawn into hand for sacrifice
- Assigned to nests for breeding
- Culled (manually in shop, or automatically when pool exceeds cap)

**Default Cap**: 1000 followers
**Expansion**: Salt Circle (+4 cap per copy), Deep Pool (+6 cap per copy)
**Culling Priority**: Lowest-tier, non-nested, non-exhausted followers are removed first when cap is exceeded

### Hand

- 6 followers drawn from pool each round
- Only non-exhausted followers are eligible
- If pool is small, all non-exhausted followers may appear in hand

### The Pit

The pit is the sacrifice area. Followers are dragged from hand to pit. Standard selection is 3; relics can change this (1, 2, 4, or 5).

---

## Balance Targets

The TestRunner simulates 600 runs per profile per doctrine (3600 total) and checks:

| Profile | Week 1 Pass Rate | Week 10 Pass Rate | Avg Devotion (relative to target) |
|---------|-----------------|-------------------|------------------------------------|
| Expert | 0.90–0.99 | 0.60–0.85 | 0.95–1.35× |
| Average | 0.75–0.92 | 0.25–0.55 | 0.80–1.15× |

**Expert** profile: plays each doctrine optimally (picks best relics, optimal sacrifice selection).
**Average** profile: semi-random selection, represents a median player.

As of Phase 2 completion, **44,576 / 44,576 mechanical unit tests pass**. 34 balance simulation checks remain outside target bands (see DEV_PLAN.md for details and proposed fixes).

---

## Scenes & UI

| Scene | Purpose |
|-------|---------|
| MainMenu | Start / Codex / Exit |
| DoctrineSelect | Choose FLESH / RUIN / SILENCE |
| RunGame | Core sacrifice loop (hand, pit, breakdown panel) |
| Shop | Relic offers, recruit offers, pool view, ritual card |
| NestSelect | Assign followers to nests, set focus, review pool |
| Breeding | Reveal offspring from this week's breeding |
| CodexMenu | Full Codex browser (relics, traits, combos) |
| GlobalMenuOverlay | In-game menu button (available in all game scenes) |
| GameOver / Victory | End-of-run screens |

**Drag-and-drop** is the primary interaction model: followers drag from hand to pit, pool rows drag to nest slots.

**Color Language**: BLOOD = red, BONE = white/grey, VOID = dark purple, SOUL = pale/silver.

---

## Key Constants

```gdscript
MAX_TIER           = 10
POOL_CAP           = 1000
STARTING_NESTS     = 2
MULTIPLIER_TRAIT_CAP = 2          # Max multiplier traits per play
DOCTRINES          = ["FLESH", "RUIN", "SILENCE"]

RUN_CONFIG_DEFAULT = {
    "max_weeks":                10,
    "target_base":              40,
    "target_growth":            1.38,
    "overflow_cap_target_mult": 0.5,     # Overflow blood cap = 50% of target
    "early_win_bonus":          20,      # Blood for clearing week 1
    "week_devotion_cap_mult":   2.0,     # Weekly devotion cap = 2× target
    "week_target_overrides":    {8: 400, 9: 620, 10: 1000},
}
```
