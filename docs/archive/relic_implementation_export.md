# Relic Implementation Export

Generated from current codebase (`scripts/GameState.gd`, `scripts/Shop.gd`, `scripts/RunGame.gd`).

## Scope
- Total relic definitions in `RELIC_DEFS`: **160**
- Includes catalog data + touchpoints + exact behavior rules extracted from code blocks

## Legend
- `Exact Behavior (Code Rules)` contains concrete trigger/effect statements with file+line.
- These are intended to be portable context for another model without loading the full project.

## 1. Annihilation Compact
- **Rarity:** `LEGENDARY`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Designate a Null Sovereign; while in pool, VOID scores as +1 tier.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Has purchase-time side effects
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:676` `if int(relic_inventory.get("Annihilation Compact", 0)) <= 0:`
  - `scripts/GameState.gd:677` `annihilation_sovereign_id = -1`
  - `scripts/GameState.gd:696` `if int(relic_inventory.get("Annihilation Compact", 0)) <= 0:`
  - `scripts/GameState.gd:697` `return false`
  - `scripts/GameState.gd:2713` `if name == "Annihilation Compact":`
- **Code Touchpoints:**
  - `scripts/GameState.gd:676` in `_ensure_annihilation_sovereign`
  - `scripts/GameState.gd:696` in `_has_active_annihilation_sovereign`
  - `scripts/GameState.gd:2713` in `add_relic`

## 2. Apex Covenant
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Highest-tier follower in hand adds floor(tier/2) additive per copy.
- **Hook Phase:** `PRE_ADD`
- **Hook Function:** `_hook_pre_add_apex_covenant`
- **Functionality In Code/In Game:** Scoring hook `PRE_ADD` via `_hook_pre_add_apex_covenant`
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2918` `if current_hand.is_empty():`
  - `scripts/GameState.gd:2923` `if highest_tier <= 0:`
  - `scripts/GameState.gd:2926` `if delta <= 0:`
  - `scripts/GameState.gd:2928` `_hook_additive_delta(ctx, "Apex Covenant (x%d): +%d" % [copies, delta], delta)`
- **Code Touchpoints:**
  - `scripts/GameState.gd:458` in `(top-level)`

## 3. Ascendant Mark
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** If all 3 sacrifices are same type and all tier 6+, +25 additive.
- **Hook Phase:** `PRE_ADD`
- **Hook Function:** `_hook_pre_add_ascendant_mark`
- **Functionality In Code/In Game:** Scoring hook `PRE_ADD` via `_hook_pre_add_ascendant_mark`
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2898` `var indices: Array = ctx["indices"]`
  - `scripts/GameState.gd:2899` `if indices.size() != 3:`
  - `scripts/GameState.gd:2901` `if not bool(ctx.get("same_trait", false)):`
  - `scripts/GameState.gd:2903` `var sacrificed_info: Array = ctx["sacrificed_info"]`
  - `scripts/GameState.gd:2905` `if int(info.get("tier", 0)) < 6:`
  - `scripts/GameState.gd:2907` `_hook_additive_delta(ctx, "Ascendant Mark: +25", 25)`
- **Code Touchpoints:**
  - `scripts/GameState.gd:456` in `(top-level)`

## 4. Balanced Offering
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** If you offer BLOOD, BONE, and VOID, devotion is doubled.
- **Hook Phase:** `PRE_MULT`
- **Hook Function:** `_hook_pre_mult_balanced_offering`
- **Functionality In Code/In Game:** Scoring hook `PRE_MULT` via `_hook_pre_mult_balanced_offering`; Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2961` `if not bool(ctx.get("has_blood", false)) or not bool(ctx.get("has_bone", false)) or not bool(ctx.get("has_void", false)):`
  - `scripts/GameState.gd:2966` `ctx["additive_total"] = additive_total * mult`
  - `scripts/GameState.gd:2967` `ctx["relic_additive_total"] = int(ctx.get("relic_additive_total", 0)) + delta`
  - `scripts/GameState.gd:2968` `var relic_lines: Array = ctx["relic_lines"]`
  - `scripts/GameState.gd:2969` `relic_lines.append("Balanced Offering (x%d): +%d" % [mult, delta])`
  - `scripts/GameState.gd:3083` `var prayer_copies: int = relic_inventory["Prayer Beads"]`
- **Code Touchpoints:**
  - `scripts/GameState.gd:463` in `(top-level)`
  - `scripts/GameState.gd:3082` in `_score_selected_internal`

## 5. Black Candle
- **Rarity:** `LEGENDARY`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Your multiplier never starts below 2.
- **Hook Phase:** `MULTIPLIER_ADJUST`
- **Hook Function:** `_hook_multiplier_black_candle`
- **Functionality In Code/In Game:** Scoring hook `MULTIPLIER_ADJUST` via `_hook_multiplier_black_candle`; Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3017` `if base_before_candle < 2:`
  - `scripts/GameState.gd:3018` `var relic_multiplier_lines: Array = ctx["relic_multiplier_lines"]`
  - `scripts/GameState.gd:3019` `relic_multiplier_lines.append("Black Candle: multiplier base at least 2")`
  - `scripts/GameState.gd:3082` `var balanced_copies: int = relic_inventory["Balanced Offering"]`
- **Code Touchpoints:**
  - `scripts/GameState.gd:471` in `(top-level)`
  - `scripts/GameState.gd:3081` in `_score_selected_internal`

## 6. Black Contract
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Once per week, you may sacrifice 4 instead of 3.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/RunGame.gd:825` `var has_five: bool = gs.relic_inventory.get("The Expanding Contract", 0) > 0`
  - `scripts/RunGame.gd:826` `if not has_four and not has_five:`
  - `scripts/RunGame.gd:834` `elif has_four:`
  - `scripts/RunGame.gd:843` `var has_five: bool = gs.relic_inventory.get("The Expanding Contract", 0) > 0`
  - `scripts/RunGame.gd:844` `if not has_four and not has_five:`
- **Code Touchpoints:**
  - `scripts/RunGame.gd:824` in `_on_contract_toggle`
  - `scripts/RunGame.gd:842` in `_update_contract_ui`

## 7. Blasphemous Geometry
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** On a win, gain a large Blood bonus before the shop.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:769` `gained = int(relic_inventory.get("Blasphemous Geometry", 0)) * 3`
  - `scripts/GameState.gd:771` `gained = int(relic_inventory.get("Brass Tithe Bowl", 0))`
  - `scripts/RunGame.gd:664` `var bonus_bowl: int = gs.relic_inventory["Brass Tithe Bowl"]`
- **Code Touchpoints:**
  - `scripts/GameState.gd:768` in `fire_relic_on_win_effect`
  - `scripts/GameState.gd:769` in `fire_relic_on_win_effect`
  - `scripts/RunGame.gd:663` in `_proceed_after_confirm`

## 8. Blood Abacus
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** BLOOD sacrifices give extra Blood currency (does not change devotion).
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:4124` `blood_gain = (blood_count * per_blood) + trait_blood_bonus + relic_blood_bonus`
  - `scripts/GameState.gd:4369` `lines.append("Blood gain: %d (per %d) Blood total: %d" % [blood_gain, per_blood, blood_currency])`
- **Code Touchpoints:**
  - `scripts/GameState.gd:4123` in `_score_selected_internal`
  - `scripts/GameState.gd:4368` in `_write_debug_log`

## 9. Blood Market Stall
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Shop recruit offers become 4 instead of 3.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Affects recruit shop flow
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:1547` `var desired: int = 4 if relic_inventory["Blood Market Stall"] > 0 else 3`
  - `scripts/GameState.gd:1548` `var free_slots: int = max(0, trine_offering_free_recruits_pending)`
- **Code Touchpoints:**
  - `scripts/GameState.gd:1547` in `generate_shop_recruits`

## 10. Bloodfire Compact
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** 3 BLOOD with a multiplier trait bypasses multiplier trait cap.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3116` `var arterial_rite_copies: int = int(relic_inventory.get("The Arterial Rite", 0))`
  - `scripts/GameState.gd:3342` `if bloodfire_compact_copies > 0 and blood_count == indices.size() and indices.size() == 3:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3115` in `_score_selected_internal`

## 11. Bloodline Register
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** When a pool follower reaches tier 10, gain +1 Blood per copy (one-time per follower).
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Has purchase-time side effects
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2472` `if copies <= 0:`
  - `scripts/GameState.gd:2485` `gained += copies`
  - `scripts/GameState.gd:2706` `if name == "Bloodline Register" and previous_count == 0:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:2471` in `_refresh_bloodline_registers`
  - `scripts/GameState.gd:2706` in `add_relic`

## 12. Bloodline Theorem
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Returning BLOOD followers gain tier on return.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Applies during post-play hand/pool resolution
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:1665` `var consume_fifth_idx: int = -1`
  - `scripts/GameState.gd:1691` `if theorem_copies > 0 and str(f.get("trait", "")) == "BLOOD":`
  - `scripts/GameState.gd:1692` `f["tier"] = min(MAX_TIER, int(f.get("tier", 0)) + theorem_copies)`
- **Code Touchpoints:**
  - `scripts/GameState.gd:1664` in `resolve_play_and_update_pool`

## 13. Bloodright Almanac
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** If Blood Straight triggers, +10 additive and +2 Blood per copy.
- **Hook Phase:** `PRE_ADD`
- **Hook Function:** `_hook_pre_add_bloodright_almanac`
- **Functionality In Code/In Game:** Scoring hook `PRE_ADD` via `_hook_pre_add_bloodright_almanac`; Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2862` `var indices: Array = ctx["indices"]`
  - `scripts/GameState.gd:2863` `if indices.size() != 3 or not bool(ctx.get("blood_straight", false)):`
  - `scripts/GameState.gd:2866` `_hook_additive_delta(ctx, "Bloodright Almanac (x%d): +%d" % [copies, add_delta], add_delta)`
  - `scripts/GameState.gd:2868` `ctx["relic_blood_bonus"] = int(ctx.get("relic_blood_bonus", 0)) + blood_delta`
  - `scripts/GameState.gd:2869` `var relic_lines: Array = ctx["relic_lines"]`
  - `scripts/GameState.gd:2870` `relic_lines.append("Bloodright Almanac (x%d): +%d Blood" % [copies, blood_delta])`
  - `scripts/GameState.gd:3093` `var ectoplasm_copies: int = relic_inventory["Ectoplasm Jar"]`
  - `scripts/GameState.gd:3216` `bloodright_copies = 0`
- **Code Touchpoints:**
  - `scripts/GameState.gd:452` in `(top-level)`
  - `scripts/GameState.gd:3092` in `_score_selected_internal`
  - `scripts/GameState.gd:3215` in `_score_selected_internal`

## 14. Bone Chorus
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** All-BONE same tier: +30 additive and +3 Blood.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3112` `var ossuary_absolute_copies: int = int(relic_inventory.get("Ossuary Absolute", 0))`
  - `scripts/GameState.gd:3464` `if bone_chorus_copies > 0 and is_all_bone and tier_counts.keys().size() == 1:`
  - `scripts/GameState.gd:3465` `relic_additive_total += 30 * bone_chorus_copies`
  - `scripts/GameState.gd:3466` `relic_blood_bonus += 3 * bone_chorus_copies`
  - `scripts/GameState.gd:3467` `relic_lines.append("Bone Chorus: +%d and +%d Blood" % [30 * bone_chorus_copies, 3 * bone_chorus_copies])`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3111` in `_score_selected_internal`

## 15. Bone Idol
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** BONE followers are worth more.
- **Hook Phase:** `PRE_ADD`
- **Hook Function:** `_hook_pre_add_bone_idol`
- **Functionality In Code/In Game:** Scoring hook `PRE_ADD` via `_hook_pre_add_bone_idol`; Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2749` `if bone_count <= 0:`
  - `scripts/GameState.gd:2751` `var sacrificed_info: Array = ctx["sacrificed_info"]`
  - `scripts/GameState.gd:2754` `if str(info.get("trait", "")) == "BONE":`
  - `scripts/GameState.gd:2756` `_hook_additive_delta(ctx, "Bone Idol (x%d): +%d" % [copies, delta], delta)`
  - `scripts/GameState.gd:3071` `var crimson_copies: int = relic_inventory["Crimson Book"]`
  - `scripts/GameState.gd:3204` `bone_copies = 0`
- **Code Touchpoints:**
  - `scripts/GameState.gd:439` in `(top-level)`
  - `scripts/GameState.gd:3070` in `_score_selected_internal`
  - `scripts/GameState.gd:3203` in `_score_selected_internal`

## 16. Bone Polisher
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Your strongest BONE adds extra devotion.
- **Hook Phase:** `PRE_ADD`
- **Hook Function:** `_hook_pre_add_bone_polisher`
- **Functionality In Code/In Game:** Scoring hook `PRE_ADD` via `_hook_pre_add_bone_polisher`; Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2795` `if bone_count <= 0:`
  - `scripts/GameState.gd:2798` `var sacrificed_info: Array = ctx["sacrificed_info"]`
  - `scripts/GameState.gd:2800` `if str(info.get("trait", "")) == "BONE":`
  - `scripts/GameState.gd:2803` `ctx["polisher_total"] = delta`
  - `scripts/GameState.gd:2804` `_hook_additive_delta(ctx, "Bone Polisher (x%d): +%d" % [copies, delta], delta)`
  - `scripts/GameState.gd:3078` `var symmetry_copies: int = relic_inventory["Ritual Symmetry"]`
- **Code Touchpoints:**
  - `scripts/GameState.gd:445` in `(top-level)`
  - `scripts/GameState.gd:3077` in `_score_selected_internal`

## 17. Bone Saw
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** If 2+ BONE are sacrificed, gain +1 Blood per copy.
- **Hook Phase:** `PRE_ADD`
- **Hook Function:** `_hook_pre_add_bone_saw`
- **Functionality In Code/In Game:** Scoring hook `PRE_ADD` via `_hook_pre_add_bone_saw`; Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2874` `if bone_count < 2:`
  - `scripts/GameState.gd:2876` `ctx["relic_blood_bonus"] = int(ctx.get("relic_blood_bonus", 0)) + copies`
  - `scripts/GameState.gd:2877` `var relic_lines: Array = ctx["relic_lines"]`
  - `scripts/GameState.gd:2878` `relic_lines.append("Bone Saw (x%d): +%d Blood" % [copies, copies])`
  - `scripts/GameState.gd:3085` `var red_thread_copies: int = relic_inventory["Red Thread"]`
- **Code Touchpoints:**
  - `scripts/GameState.gd:453` in `(top-level)`
  - `scripts/GameState.gd:3084` in `_score_selected_internal`

## 18. Bone Standard
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** With 2+ BONE, highest BONE contribution is doubled.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3108` `var white_wall_copies: int = int(relic_inventory.get("The White Wall", 0))`
  - `scripts/GameState.gd:3455` `if bone_standard_copies > 0 and bone_count >= 2:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3107` in `_score_selected_internal`

## 19. Brass Tithe Bowl
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** On week success, gain +1 Blood per copy.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:771` `gained = int(relic_inventory.get("Brass Tithe Bowl", 0))`
  - `scripts/GameState.gd:773` `gained = 0`
  - `scripts/RunGame.gd:665` `var bonus_total: int = bonus_cup + (bonus_geo * 3) + bonus_bowl`
- **Code Touchpoints:**
  - `scripts/GameState.gd:770` in `fire_relic_on_win_effect`
  - `scripts/GameState.gd:771` in `fire_relic_on_win_effect`
  - `scripts/RunGame.gd:664` in `_proceed_after_confirm`

## 20. Calcify
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Each BONE sacrifice adds extra devotion.
- **Hook Phase:** `PRE_ADD`
- **Hook Function:** `_hook_pre_add_calcify`
- **Functionality In Code/In Game:** Scoring hook `PRE_ADD` via `_hook_pre_add_calcify`; Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2767` `if bone_count <= 0:`
  - `scripts/GameState.gd:2770` `_hook_additive_delta(ctx, "Calcify (x%d): +%d" % [copies, delta], delta)`
  - `scripts/GameState.gd:3080` `var prism_copies: int = relic_inventory["Void Prism"]`
  - `scripts/GameState.gd:3212` `calcify_copies = 0`
- **Code Touchpoints:**
  - `scripts/GameState.gd:441` in `(top-level)`
  - `scripts/GameState.gd:3079` in `_score_selected_internal`
  - `scripts/GameState.gd:3211` in `_score_selected_internal`

## 21. Ceremonial Cup
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** On a win, gain extra Blood before the shop.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:767` `gained = int(relic_inventory.get("Ceremonial Cup", 0))`
  - `scripts/GameState.gd:769` `gained = int(relic_inventory.get("Blasphemous Geometry", 0)) * 3`
  - `scripts/RunGame.gd:663` `var bonus_geo: int = gs.relic_inventory["Blasphemous Geometry"]`
- **Code Touchpoints:**
  - `scripts/GameState.gd:766` in `fire_relic_on_win_effect`
  - `scripts/GameState.gd:767` in `fire_relic_on_win_effect`
  - `scripts/RunGame.gd:662` in `_proceed_after_confirm`

## 22. Choir Robes
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** If all 3 sacrifices have different tiers, +5 additive per copy.
- **Hook Phase:** `PRE_ADD`
- **Hook Function:** `_hook_pre_add_choir_robes`
- **Functionality In Code/In Game:** Scoring hook `PRE_ADD` via `_hook_pre_add_choir_robes`; Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2836` `var indices: Array = ctx["indices"]`
  - `scripts/GameState.gd:2837` `if indices.size() != 3:`
  - `scripts/GameState.gd:2839` `var tier_counts: Dictionary = ctx["tier_counts"]`
  - `scripts/GameState.gd:2840` `if tier_counts.keys().size() != 3:`
  - `scripts/GameState.gd:2843` `_hook_additive_delta(ctx, "Choir Robes (x%d): +%d" % [copies, delta], delta)`
  - `scripts/GameState.gd:3089` `var ossuary_standards: int = relic_inventory["Ossuary Standards"]`
- **Code Touchpoints:**
  - `scripts/GameState.gd:449` in `(top-level)`
  - `scripts/GameState.gd:3088` in `_score_selected_internal`

## 23. Clean Hands
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** If you clear a week with 0 VOID, gain 1 free relic reroll next shop.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/RunGame.gd:600` `if gs.relic_inventory["Clean Hands"] > 0 and gs.week_total_devotion >= int(result["target"]) and int(result["void_count"]) == 0:`
  - `scripts/RunGame.gd:601` `gs.free_reroll_next_shop = true`
- **Code Touchpoints:**
  - `scripts/RunGame.gd:600` in `_on_confirm_pressed`

## 24. Cold Incense
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** If 0 VOID, multiplier base at least 2 once per week.
- **Hook Phase:** `MULTIPLIER_ADJUST`
- **Hook Function:** `_hook_multiplier_cold_incense`
- **Functionality In Code/In Game:** Scoring hook `MULTIPLIER_ADJUST` via `_hook_multiplier_cold_incense`; Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3025` `if void_count == 0 and used_week != current_w:`
  - `scripts/GameState.gd:3026` `ctx["base"] = max(2, int(ctx.get("base", 1)))`
  - `scripts/GameState.gd:3027` `ctx["cold_incense_applied"] = true`
  - `scripts/GameState.gd:3028` `var relic_multiplier_lines: Array = ctx["relic_multiplier_lines"]`
  - `scripts/GameState.gd:3029` `relic_multiplier_lines.append("Cold Incense: multiplier base at least 2 (weekly)")`
  - `scripts/GameState.gd:3087` `var wax_seal_copies: int = relic_inventory["Wax Seal"]`
- **Code Touchpoints:**
  - `scripts/GameState.gd:472` in `(top-level)`
  - `scripts/GameState.gd:3086` in `_score_selected_internal`

## 25. Covenant of Three
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** High-tier triune gains additive and Blood.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3123` `var trinity_engine_copies: int = int(relic_inventory.get("The Trinity Engine", 0))`
  - `scripts/GameState.gd:3500` `if covenant_of_three_copies > 0 and is_triune_play and tier_sum >= 15:`
  - `scripts/GameState.gd:3503` `relic_blood_bonus += 2 * covenant_of_three_copies`
  - `scripts/GameState.gd:3504` `relic_lines.append("Covenant of Three: +%d and +%d Blood" % [cov_delta, 2 * covenant_of_three_copies])`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3122` in `_score_selected_internal`

## 26. Crimson Absolute
- **Rarity:** `LEGENDARY`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** High-tier all-BLOOD plays multiply final devotion.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3119` `var concordat_copies: int = int(relic_inventory.get("The Concordat", 0))`
  - `scripts/GameState.gd:4061` `if crimson_absolute_copies > 0 and is_all_blood and tier_sum >= 24:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3118` in `_score_selected_internal`

## 27. Crimson Book
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Each BLOOD sacrifice adds a small bonus.
- **Hook Phase:** `PRE_ADD`
- **Hook Function:** `_hook_pre_add_crimson_book`
- **Functionality In Code/In Game:** Scoring hook `PRE_ADD` via `_hook_pre_add_crimson_book`; Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2742` `if blood_count <= 0:`
  - `scripts/GameState.gd:2745` `_hook_additive_delta(ctx, "Crimson Book (x%d): +%d" % [copies, delta], delta)`
  - `scripts/GameState.gd:3072` `var hollow_copies: int = relic_inventory["Hollow Chant"]`
  - `scripts/GameState.gd:3202` `crimson_copies = 0`
- **Code Touchpoints:**
  - `scripts/GameState.gd:438` in `(top-level)`
  - `scripts/GameState.gd:3071` in `_score_selected_internal`
  - `scripts/GameState.gd:3201` in `_score_selected_internal`

## 28. Crimson Compound
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Improves Crimson Interest divisor.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/Shop.gd:357` `var usurer_copies: int = int(gs.relic_inventory.get("Usurer's Mark", 0))`
- **Code Touchpoints:**
  - `scripts/Shop.gd:356` in `_finish_shop`

## 29. Crimson Interest
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** After the shop, earn bonus Blood based on your stash.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/Shop.gd:356` `var crimson_compound_copies: int = int(gs.relic_inventory.get("Crimson Compound", 0))`
  - `scripts/Shop.gd:359` `if interest_copies > 0:`
- **Code Touchpoints:**
  - `scripts/Shop.gd:355` in `_finish_shop`

## 30. Crimson Ledger
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** 3 BLOOD plays build a permanent additive stack.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3911` `if int(relic_inventory.get("Crimson Ledger", 0)) > 0 and is_all_blood and indices.size() == 3:`
  - `scripts/GameState.gd:3912` `crimson_ledger_stacks += int(relic_inventory.get("Crimson Ledger", 0))`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3911` in `_score_selected_internal`
  - `scripts/GameState.gd:3912` in `_score_selected_internal`

## 31. Crimson Pact
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Once per week, consume extra BLOOD from pool for additive and Blood.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3525` `if crimson_pact_used_week != current_week and int(relic_inventory.get("Crimson Pact", 0)) > 0:`
  - `scripts/GameState.gd:3526` `var blood_pool_candidates: Array[Dictionary] = []`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3525` in `_score_selected_internal`

## 32. Crown of Tiers
- **Rarity:** `LEGENDARY`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Once per week: promote a pool follower by +3 tier (max 10), costs 5 Blood.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2437` `if relic_inventory.get("Crown of Tiers", 0) <= 0:`
  - `scripts/GameState.gd:2438` `return {"ok": false, "reason": "Crown of Tiers not owned."}`
  - `scripts/RunGame.gd:925` `if gs.relic_inventory.get("Crown of Tiers", 0) > 0:`
  - `scripts/RunGame.gd:926` `var crown_btn: Button = Button.new()`
- **Code Touchpoints:**
  - `scripts/GameState.gd:2437` in `use_crown_of_tiers`
  - `scripts/RunGame.gd:925` in `_refresh_pool_overlay`

## 33. Crypt Standard
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Exactly 2 BONE and 0 VOID doubles additive total.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3110` `var calcified_gate_copies: int = int(relic_inventory.get("The Calcified Gate", 0))`
  - `scripts/GameState.gd:3968` `if crypt_standard_copies > 0 and bone_count == 2 and void_count == 0:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3109` in `_score_selected_internal`

## 34. Culling Knife
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Once per shop, cull a follower from the pool for free.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/Shop.gd:563` `var pruning_hook_ok: bool = gs.relic_inventory.get("The Pruning Hook", 0) > 0 and not gs.pruning_hook_used_shop`
  - `scripts/Shop.gd:584` `if gs.relic_inventory.get("Culling Knife", 0) > 0 and not gs.shop_cull_used:`
  - `scripts/Shop.gd:585` `gs.shop_cull_used = true`
- **Code Touchpoints:**
  - `scripts/Shop.gd:562` in `_update_pool_actions`
  - `scripts/Shop.gd:584` in `_on_pool_cull`

## 35. Debt Ledger
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Shop entry with 15+ Blood converts 10 Blood into permanent additive.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Applies on shop entry
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:735` `if int(relic_inventory.get("Debt Ledger", 0)) > 0 and debt_ledger_applied_shop_week != current_week and blood_currency >= 15:`
  - `scripts/GameState.gd:736` `blood_currency -= 10`
- **Code Touchpoints:**
  - `scripts/GameState.gd:735` in `start_shop_visit`

## 36. Debt Scripture
- **Rarity:** `COMMON`
- **Category:** `VOUCHER`
- **Stacks:** `No`
- **Description (Catalog):** You may buy relics up to 2 Blood short; debt is repaid from gains.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2582` `if int(relic_inventory.get("Debt Scripture", 0)) > 0:`
  - `scripts/GameState.gd:2583` `debt_limit = 2`
  - `scripts/GameState.gd:2596` `if int(relic_inventory.get("Debt Scripture", 0)) > 0:`
  - `scripts/GameState.gd:2597` `debt_limit = 2`
- **Code Touchpoints:**
  - `scripts/GameState.gd:2582` in `can_afford_relic`
  - `scripts/GameState.gd:2596` in `spend_blood_for_relic`

## 37. Director's Addendum
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Director's Cut range widens and gains an extra use.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:758` `return 2 if int(relic_inventory.get("Director's Addendum", 0)) > 0 else 1`
  - `scripts/GameState.gd:761` `return 0.25 if int(relic_inventory.get("Director's Addendum", 0)) > 0 else 0.15`
- **Code Touchpoints:**
  - `scripts/GameState.gd:758` in `get_directors_cut_max_uses`
  - `scripts/GameState.gd:761` in `get_directors_cut_range_pct`

## 38. Director's Cut
- **Rarity:** `RARE`
- **Category:** `VOUCHER`
- **Stacks:** `No`
- **Description (Catalog):** Once per week in shop, reroll next week target within +/-15%.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/Shop.gd:278` `if gs.relic_inventory["Director's Cut"] <= 0:`
  - `scripts/Shop.gd:279` `directors_cut.visible = false`
  - `scripts/Shop.gd:293` `if gs.relic_inventory["Director's Cut"] <= 0:`
  - `scripts/Shop.gd:294` `return`
- **Code Touchpoints:**
  - `scripts/Shop.gd:278` in `_update_directors_cut`
  - `scripts/Shop.gd:293` in `_on_directors_cut`

## 39. Dynasty Seal
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Offspring of two tier-8+ parents spawn at tier 6 before other modifiers.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Applies in nest breeding; Applies in wild breeding
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:1820` `if dynasty_seal_copies > 0 and int(a.get("tier", 0)) >= 8 and int(b.get("tier", 0)) >= 8:`
  - `scripts/GameState.gd:2004` `if dynasty_seal_copies > 0 and int(a.get("tier", 0)) >= 8 and int(b.get("tier", 0)) >= 8:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:1819` in `resolve_nest_breeding`
  - `scripts/GameState.gd:2003` in `resolve_wild_breeding`

## 40. Ectoplasm Jar
- **Rarity:** `LEGENDARY`
- **Category:** `VOUCHER`
- **Stacks:** `Yes`
- **Description (Catalog):** +1 multiplier exponent per copy; pool cap -6 per copy.
- **Hook Phase:** `MULTIPLIER_ADJUST`
- **Hook Function:** `_hook_multiplier_ectoplasm_jar`
- **Functionality In Code/In Game:** Scoring hook `MULTIPLIER_ADJUST` via `_hook_multiplier_ectoplasm_jar`; Evaluated inside core scoring pass; Affects pool-cap accounting
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2541` `var deep_pool_copies: int = int(relic_inventory.get("The Deep Pool", 0))`
  - `scripts/GameState.gd:3003` `ctx["exponent"] = int(ctx.get("exponent", 1)) + copies`
  - `scripts/GameState.gd:3004` `var relic_multiplier_lines: Array = ctx["relic_multiplier_lines"]`
  - `scripts/GameState.gd:3005` `relic_multiplier_lines.append("Ectoplasm Jar (x%d): multiplier exponent +%d" % [copies, copies])`
  - `scripts/GameState.gd:3094` `var whetted_bone_copies: int = int(relic_inventory.get("Whetted Bone", 0))`
- **Code Touchpoints:**
  - `scripts/GameState.gd:468` in `(top-level)`
  - `scripts/GameState.gd:2540` in `get_pool_cap`
  - `scripts/GameState.gd:3093` in `_score_selected_internal`

## 41. Fertility Idol
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Wild breeding chance +10% per copy for couples with no VOID.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2050` `var brood_copies: int = int(relic_inventory.get("The Brood Compact", 0))`
- **Code Touchpoints:**
  - `scripts/GameState.gd:2049` in `_breeding_chance`

## 42. First Apostle
- **Rarity:** `LEGENDARY`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Choose a follower as Apostle; it shapes breeding outcomes.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):** None found outside declarations.
- **Code Touchpoints:**
  - `scripts/Shop.gd:572` in `_update_pool_actions`

## 43. Grave Compact
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Culls increase next bred offspring tier bonus.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2410` `if int(relic_inventory.get("Grave Compact", 0)) > 0:`
  - `scripts/GameState.gd:2411` `grave_compact_buffer += 0.5 * float(int(relic_inventory.get("Grave Compact", 0)))`
- **Code Touchpoints:**
  - `scripts/GameState.gd:2410` in `cull_follower_by_id`
  - `scripts/GameState.gd:2411` in `cull_follower_by_id`

## 44. Grave Ledger
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** First recruit you buy each shop gets +1 tier per copy (cap 4).
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Affects recruit shop flow
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:1609` `if relic_inventory["Grave Ledger"] > 0 and not shop_first_recruit_boost_used and f["trait"] != "VOID":`
  - `scripts/GameState.gd:1610` `var boosted: int = min(MAX_TIER, int(f["tier"]) + relic_inventory["Grave Ledger"])`
  - `scripts/GameState.gd:1611` `f["tier"] = boosted`
- **Code Touchpoints:**
  - `scripts/GameState.gd:1609` in `buy_shop_recruit`
  - `scripts/GameState.gd:1610` in `buy_shop_recruit`

## 45. Gravewright
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Sacrificed BONE may spawn T2 BONE in pool.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:4177` `if int(relic_inventory.get("Gravewright", 0)) > 0:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:4177` in `_score_selected_internal`

## 46. Hollow Abacus
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** If exactly 1 VOID is sacrificed, exponent +1 per copy.
- **Hook Phase:** `MULTIPLIER_ADJUST`
- **Hook Function:** `_hook_multiplier_hollow_abacus`
- **Functionality In Code/In Game:** Scoring hook `MULTIPLIER_ADJUST` via `_hook_multiplier_hollow_abacus`; Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2996` `if void_count != 1:`
  - `scripts/GameState.gd:2998` `ctx["exponent"] = int(ctx.get("exponent", 1)) + copies`
  - `scripts/GameState.gd:2999` `var relic_multiplier_lines: Array = ctx["relic_multiplier_lines"]`
  - `scripts/GameState.gd:3000` `relic_multiplier_lines.append("Hollow Abacus (x%d): multiplier exponent +%d" % [copies, copies])`
  - `scripts/GameState.gd:3091` `var triune_copies: int = relic_inventory["Triune Reliquary"]`
- **Code Touchpoints:**
  - `scripts/GameState.gd:467` in `(top-level)`
  - `scripts/GameState.gd:3090` in `_score_selected_internal`

## 47. Hollow Chant
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Each copy adds +1 to multiplier exponent (unconditional).
- **Hook Phase:** `MULTIPLIER_ADJUST`
- **Hook Function:** `_hook_multiplier_hollow_chant`
- **Functionality In Code/In Game:** Scoring hook `MULTIPLIER_ADJUST` via `_hook_multiplier_hollow_chant`; Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3008` `var relic_multiplier_lines: Array = ctx["relic_multiplier_lines"]`
  - `scripts/GameState.gd:3009` `relic_multiplier_lines.append("Hollow Chant (x%d): multiplier exponent +%d" % [copies, copies])`
  - `scripts/GameState.gd:3073` `var order_copies: int = relic_inventory["Sacrificial Order"]`
- **Code Touchpoints:**
  - `scripts/GameState.gd:469` in `(top-level)`
  - `scripts/GameState.gd:3072` in `_score_selected_internal`

## 48. Iron Reliquary
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** If highest-tier sacrifice is tier 8+, +20 additive.
- **Hook Phase:** `PRE_ADD`
- **Hook Function:** `_hook_pre_add_iron_reliquary`
- **Functionality In Code/In Game:** Scoring hook `PRE_ADD` via `_hook_pre_add_iron_reliquary`
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2882` `if highest_tier_sac < 8:`
  - `scripts/GameState.gd:2884` `_hook_additive_delta(ctx, "Iron Reliquary: +20", 20)`
- **Code Touchpoints:**
  - `scripts/GameState.gd:454` in `(top-level)`

## 49. Ivory Throne
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Each sacrifice above tier 7: +5 additive per tier above 7.
- **Hook Phase:** `PRE_ADD`
- **Hook Function:** `_hook_pre_add_ivory_throne`
- **Functionality In Code/In Game:** Scoring hook `PRE_ADD` via `_hook_pre_add_ivory_throne`
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2887` `var sacrificed_info: Array = ctx["sacrificed_info"]`
  - `scripts/GameState.gd:2891` `if tier > 7:`
  - `scripts/GameState.gd:2893` `if delta <= 0:`
  - `scripts/GameState.gd:2895` `_hook_additive_delta(ctx, "Ivory Throne: +%d" % delta, delta)`
- **Code Touchpoints:**
  - `scripts/GameState.gd:455` in `(top-level)`

## 50. Lineage Harvest
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Sacrificed bred followers gain additive and return to pool.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass; Applies during post-play hand/pool resolution
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:1664` `var theorem_copies: int = int(relic_inventory.get("Bloodline Theorem", 0))`
  - `scripts/GameState.gd:1684` `if lineage_harvest_active:`
  - `scripts/GameState.gd:3139` `var pared_offering_copies: int = int(relic_inventory.get("The Pared Offering", 0))`
  - `scripts/GameState.gd:3505` `if lineage_harvest_copies > 0:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:1663` in `resolve_play_and_update_pool`
  - `scripts/GameState.gd:3138` in `_score_selected_internal`

## 51. Marrow Charter
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** If 3 BONE are sacrificed, gain Blood from their total tier.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3107` `var bone_standard_copies: int = int(relic_inventory.get("Bone Standard", 0))`
  - `scripts/GameState.gd:3218` `marrow_charter_copies = 0`
  - `scripts/GameState.gd:3451` `if marrow_charter_copies > 0 and is_all_bone and indices.size() == 3:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3106` in `_score_selected_internal`
  - `scripts/GameState.gd:3217` in `_score_selected_internal`

## 52. Mass Offering
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** 4-sacrifice plays return all sacrificed followers to pool.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Applies during post-play hand/pool resolution
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:1663` `var lineage_harvest_active: bool = int(relic_inventory.get("Lineage Harvest", 0)) > 0`
  - `scripts/GameState.gd:1682` `if mass_offering_active:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:1662` in `resolve_play_and_update_pool`

## 53. Minimalist Doctrine
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** 1-sacrifice base calculation treats tier as doubled.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3130` `var count_absolute_copies: int = int(relic_inventory.get("The Count Absolute", 0))`
  - `scripts/GameState.gd:3447` `if minimalist_doctrine_copies > 0 and indices.size() == 1 and sacrificed_info.size() == 1:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3129` in `_score_selected_internal`

## 54. Null Covenant
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** If multiplier base reaches 5+, gain Blood equal to base value.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3104` `var final_silence_copies: int = int(relic_inventory.get("The Final Silence", 0))`
  - `scripts/GameState.gd:4039` `if null_covenant_copies > 0 and base >= 5:`
  - `scripts/GameState.gd:4040` `relic_blood_bonus += base * null_covenant_copies`
  - `scripts/GameState.gd:4041` `relic_multiplier_lines.append("Null Covenant: +%d Blood" % (base * null_covenant_copies))`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3103` in `_score_selected_internal`

## 55. Nursery Ledger
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Sacrificing bred offspring grants extra Blood.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3138` `var lineage_harvest_copies: int = int(relic_inventory.get("Lineage Harvest", 0))`
  - `scripts/GameState.gd:3515` `if nursery_ledger_copies > 0:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3137` in `_score_selected_internal`

## 56. Obsidian Conduit
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Each sacrificed VOID adds additive equal to VOID count in pool.
- **Hook Phase:** `PRE_ADD`
- **Hook Function:** `_hook_pre_add_obsidian_conduit`
- **Functionality In Code/In Game:** Scoring hook `PRE_ADD` via `_hook_pre_add_obsidian_conduit`
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2931` `var sacrificed_info: Array = ctx["sacrificed_info"]`
  - `scripts/GameState.gd:2934` `if str(f.get("trait", "")) == "VOID":`
  - `scripts/GameState.gd:2936` `if pool_void_count <= 0:`
  - `scripts/GameState.gd:2940` `if str(info.get("trait", "")) != "VOID":`
  - `scripts/GameState.gd:2944` `if delta <= 0:`
  - `scripts/GameState.gd:2946` `_hook_additive_delta(ctx, "Obsidian Conduit: +%d" % delta, delta)`
- **Code Touchpoints:**
  - `scripts/GameState.gd:459` in `(top-level)`

## 57. Omen Deck
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Recruits have +10% per copy chance to spawn with a RARE trait.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Affects recruit shop flow
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:1575` `var omen_ledger_copies: int = int(relic_inventory.get("The Omen Ledger", 0))`
- **Code Touchpoints:**
  - `scripts/GameState.gd:1574` in `generate_shop_recruits`

## 58. Ossuary Absolute
- **Rarity:** `LEGENDARY`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** 3 high-tier BONE ignore devotion cap this play.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3113` `var red_tithe_copies: int = int(relic_inventory.get("The Red Tithe", 0))`
  - `scripts/GameState.gd:4102` `if ossuary_absolute_copies > 0 and bone_count == 3 and void_count == 0:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3112` in `_score_selected_internal`

## 59. Ossuary Standard
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Sacrifice at least 2 BONE to gain bonus devotion.
- **Hook Phase:** `PRE_ADD`
- **Hook Function:** `_hook_pre_add_ossuary_standard`
- **Functionality In Code/In Game:** Scoring hook `PRE_ADD` via `_hook_pre_add_ossuary_standard`; Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2788` `if bone_count < 2:`
  - `scripts/GameState.gd:2791` `_hook_additive_delta(ctx, "Ossuary Standard (x%d): +%d" % [copies, delta], delta)`
  - `scripts/GameState.gd:3077` `var polisher_copies: int = relic_inventory["Bone Polisher"]`
- **Code Touchpoints:**
  - `scripts/GameState.gd:444` in `(top-level)`
  - `scripts/GameState.gd:3076` in `_score_selected_internal`

## 60. Ossuary Standards
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** +5 additive per BONE sacrificed per copy (flat, not tier-scaled).
- **Hook Phase:** `PRE_ADD`
- **Hook Function:** `_hook_pre_add_ossuary_standards`
- **Functionality In Code/In Game:** Scoring hook `PRE_ADD` via `_hook_pre_add_ossuary_standards`; Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2760` `if bone_count <= 0:`
  - `scripts/GameState.gd:2763` `_hook_additive_delta(ctx, "Ossuary Standards (x%d): +%d" % [copies, delta], delta)`
  - `scripts/GameState.gd:3090` `var hollow_abacus_copies: int = relic_inventory["Hollow Abacus"]`
  - `scripts/GameState.gd:3214` `ossuary_standards = 0`
- **Code Touchpoints:**
  - `scripts/GameState.gd:440` in `(top-level)`
  - `scripts/GameState.gd:3089` in `_score_selected_internal`
  - `scripts/GameState.gd:3213` in `_score_selected_internal`

## 61. Prayer Beads
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** If all 3 sacrifices share a main trait, +6 additive per copy.
- **Hook Phase:** `PRE_ADD`
- **Hook Function:** `_hook_pre_add_prayer_beads`
- **Functionality In Code/In Game:** Scoring hook `PRE_ADD` via `_hook_pre_add_prayer_beads`; Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2814` `var indices: Array = ctx["indices"]`
  - `scripts/GameState.gd:2815` `if indices.size() != 3:`
  - `scripts/GameState.gd:2818` `if not same_trait:`
  - `scripts/GameState.gd:2821` `_hook_additive_delta(ctx, "Prayer Beads (x%d): +%d" % [copies, delta], delta)`
  - `scripts/GameState.gd:3084` `var bone_saw_copies: int = relic_inventory["Bone Saw"]`
- **Code Touchpoints:**
  - `scripts/GameState.gd:447` in `(top-level)`
  - `scripts/GameState.gd:3083` in `_score_selected_internal`

## 62. Quick Chant
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Any sacrifice grants a small devotion boost.
- **Hook Phase:** `PRE_ADD`
- **Hook Function:** `_hook_pre_add_quick_chant`
- **Functionality In Code/In Game:** Scoring hook `PRE_ADD` via `_hook_pre_add_quick_chant`; Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2780` `var indices: Array = ctx["indices"]`
  - `scripts/GameState.gd:2781` `if indices.is_empty():`
  - `scripts/GameState.gd:2784` `_hook_additive_delta(ctx, "Quick Chant (x%d): +%d" % [copies, delta], delta)`
  - `scripts/GameState.gd:3075` `var thin_copies: int = relic_inventory["Thin Blade"]`
  - `scripts/GameState.gd:3206` `quick_copies = 0`
- **Code Touchpoints:**
  - `scripts/GameState.gd:443` in `(top-level)`
  - `scripts/GameState.gd:3074` in `_score_selected_internal`
  - `scripts/GameState.gd:3205` in `_score_selected_internal`

## 63. Red Thread
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** If 3 BLOOD are sacrificed, random BLOOD in pool +1 tier per copy.
- **Hook Phase:** `POST_RESOLVE`
- **Hook Function:** `_hook_post_resolve_red_thread`
- **Functionality In Code/In Game:** Scoring hook `POST_RESOLVE` via `_hook_post_resolve_red_thread`; Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3033` `var indices: Array = ctx["indices"]`
  - `scripts/GameState.gd:3035` `if not apply_currency or blood_count != 3 or indices.size() != 3:`
  - `scripts/GameState.gd:3040` `if str(f.get("trait", "")) == "BLOOD":`
  - `scripts/GameState.gd:3041` `blood_ids.append(int(f.get("id", -1)))`
  - `scripts/GameState.gd:3042` `if blood_ids.is_empty():`
  - `scripts/GameState.gd:3047` `if int(pool[p].get("id", -1)) == pick_id:`
  - `scripts/GameState.gd:3086` `var cold_incense_copies: int = relic_inventory["Cold Incense"]`
- **Code Touchpoints:**
  - `scripts/GameState.gd:451` in `(top-level)`
  - `scripts/GameState.gd:475` in `(top-level)`
  - `scripts/GameState.gd:3085` in `_score_selected_internal`

## 64. Refinery of Silence
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Refined VOID bonus improves by +0.2 per copy.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3100` `var void_cradle_copies: int = int(relic_inventory.get("Void Cradle", 0))`
  - `scripts/GameState.gd:4047` `if refinery_copies > 0 and void_count > 0 and refined_void_count == 0:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3099` in `_score_selected_internal`

## 65. Ritual Knife
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** The first follower you choose each week counts as double tier.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3069` `var third_knife: int = relic_inventory["The Third Knife"]`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3068` in `_score_selected_internal`

## 66. Ritual Symmetry
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Even-numbered sacrifices gain bonus devotion.
- **Hook Phase:** `PRE_ADD`
- **Hook Function:** `_hook_pre_add_ritual_symmetry`
- **Functionality In Code/In Game:** Scoring hook `PRE_ADD` via `_hook_pre_add_ritual_symmetry`; Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2807` `var indices: Array = ctx["indices"]`
  - `scripts/GameState.gd:2808` `if indices.size() <= 0 or indices.size() % 2 != 0:`
  - `scripts/GameState.gd:2811` `_hook_additive_delta(ctx, "Ritual Symmetry (x%d): +%d" % [copies, delta], delta)`
  - `scripts/GameState.gd:3079` `var calcify_copies: int = relic_inventory["Calcify"]`
  - `scripts/GameState.gd:3210` `symmetry_copies = 0`
- **Code Touchpoints:**
  - `scripts/GameState.gd:446` in `(top-level)`
  - `scripts/GameState.gd:3078` in `_score_selected_internal`
  - `scripts/GameState.gd:3209` in `_score_selected_internal`

## 67. Sacrificial Order
- **Rarity:** `LEGENDARY`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Exactly 3 sacrifices? Big devotion bonus.
- **Hook Phase:** `PRE_MULT`
- **Hook Function:** `_hook_pre_mult_sacrificial_order`
- **Functionality In Code/In Game:** Scoring hook `PRE_MULT` via `_hook_pre_mult_sacrificial_order`; Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2949` `var indices: Array = ctx["indices"]`
  - `scripts/GameState.gd:2950` `if indices.size() != 3:`
  - `scripts/GameState.gd:2955` `ctx["additive_total"] = additive_total * mult`
  - `scripts/GameState.gd:2956` `ctx["relic_additive_total"] = int(ctx.get("relic_additive_total", 0)) + delta`
  - `scripts/GameState.gd:2957` `var relic_lines: Array = ctx["relic_lines"]`
  - `scripts/GameState.gd:2958` `relic_lines.append("Sacrificial Order (x%d): +%d" % [mult, delta])`
  - `scripts/GameState.gd:3074` `var quick_copies: int = relic_inventory["Quick Chant"]`
- **Code Touchpoints:**
  - `scripts/GameState.gd:462` in `(top-level)`
  - `scripts/GameState.gd:3073` in `_score_selected_internal`

## 68. Salt Circle
- **Rarity:** `COMMON`
- **Category:** `VOUCHER`
- **Stacks:** `Yes`
- **Description (Catalog):** Increase pool cap by +4 per copy.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Affects pool-cap accounting
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2540` `var ecto_copies: int = relic_inventory["Ectoplasm Jar"]`
- **Code Touchpoints:**
  - `scripts/GameState.gd:2539` in `get_pool_cap`

## 69. Scarlet Planetarium
- **Rarity:** `RARE`
- **Category:** `CONSUMABLE`
- **Stacks:** `No`
- **Description (Catalog):** Adds a Ritual Card slot; shop offers 1 Ritual Card.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/RunGame.gd:867` `ritual_use.visible = true`
  - `scripts/Shop.gd:230` `if gs.relic_inventory["Scarlet Planetarium"] <= 0:`
  - `scripts/Shop.gd:231` `ritual_desc.text = "Locked: Requires Scarlet Planetarium."`
- **Code Touchpoints:**
  - `scripts/RunGame.gd:866` in `_update_ritual_ui`
  - `scripts/Shop.gd:230` in `_setup_ritual_offer`

## 70. Seal of Inheritance
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** If either parent has a trait, newborn inherits one parent trait (nest and wild).
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2115` `if relic_inventory["Seal of Inheritance"] > 0:`
  - `scripts/GameState.gd:2116` `var inherited_probs := {"common": 0.0, "rare": 0.0, "legendary": 0.0}`
  - `scripts/GameState.gd:2246` `if relic_inventory["Seal of Inheritance"] > 0:`
  - `scripts/GameState.gd:2247` `var inherited: String = _pick_parent_trait_id(parent_a_tid, parent_b_tid)`
  - `scripts/GameState.gd:2328` `if relic_inventory["Seal of Inheritance"] > 0:`
  - `scripts/GameState.gd:2329` `var inherited: String = _pick_parent_trait_id(parent_a_trait, parent_b_trait)`
  - `scripts/GameState.gd:2356` `if relic_inventory["Seal of Inheritance"] > 0:`
  - `scripts/GameState.gd:2357` `var inherited: String = _pick_parent_trait_id(parent_a_tid, parent_b_tid)`
- **Code Touchpoints:**
  - `scripts/GameState.gd:2115` in `_compute_nest_rarity_probabilities`
  - `scripts/GameState.gd:2246` in `_resolve_nest_trait_id`
  - `scripts/GameState.gd:2328` in `_roll_breeding_trait`
  - `scripts/GameState.gd:2356` in `_roll_wild_breeding_trait`

## 71. Selective Breeding Scroll
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Nest offspring rarity-up chance +15%.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:1360` `var has_favored_parent: bool = _is_favored_breeder(parent_a_id) or _is_favored_breeder(parent_b_id)`
  - `scripts/Shop.gd:569` `pool_fav_a.disabled = pack_select_mode or not can_set_favored`
  - `scripts/Shop.gd:592` `if gs.relic_inventory["Selective Breeding Scroll"] <= 0:`
  - `scripts/Shop.gd:593` `return`
  - `scripts/Shop.gd:600` `if gs.relic_inventory["Selective Breeding Scroll"] <= 0:`
  - `scripts/Shop.gd:601` `return`
- **Code Touchpoints:**
  - `scripts/GameState.gd:1359` in `_nest_parent_flags`
  - `scripts/Shop.gd:568` in `_update_pool_actions`
  - `scripts/Shop.gd:592` in `_on_pool_favored_a`
  - `scripts/Shop.gd:600` in `_on_pool_favored_b`

## 72. Sharpened Chalk
- **Rarity:** `UNCOMMON`
- **Category:** `VOUCHER`
- **Stacks:** `No`
- **Description (Catalog):** First relic reroll each shop costs 0.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/Shop.gd:177` `if gs.shop_rerolls_used == 0 and (gs.relic_inventory["Sharpened Chalk"] > 0 or gs.shop_free_reroll_available):`
  - `scripts/Shop.gd:178` `reroll_cost = 0`
  - `scripts/Shop.gd:253` `if gs.shop_rerolls_used == 0 and (gs.relic_inventory["Sharpened Chalk"] > 0 or gs.shop_free_reroll_available):`
  - `scripts/Shop.gd:254` `reroll_cost = 0`
- **Code Touchpoints:**
  - `scripts/Shop.gd:177` in `_update_reroll_button`
  - `scripts/Shop.gd:253` in `_on_reroll_pressed`

## 73. Single Rite
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Exactly 1 sacrifice: additive and Blood.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3127` `var dyad_mark_copies: int = int(relic_inventory.get("The Dyad Mark", 0))`
  - `scripts/GameState.gd:3226` `single_rite_copies = 0`
  - `scripts/GameState.gd:3432` `if single_rite_copies > 0 and indices.size() == 1:`
  - `scripts/GameState.gd:3433` `relic_additive_total += 10 * single_rite_copies`
  - `scripts/GameState.gd:3434` `relic_blood_bonus += 2 * single_rite_copies`
  - `scripts/GameState.gd:3435` `relic_lines.append("Single Rite: +%d and +%d Blood" % [10 * single_rite_copies, 2 * single_rite_copies])`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3126` in `_score_selected_internal`
  - `scripts/GameState.gd:3225` in `_score_selected_internal`

## 74. Soul Tithe
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Each SOUL in pool grants Blood each round.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:4115` `if soul_tithe_copies > 0:`
  - `scripts/GameState.gd:4121` `relic_blood_bonus += soul_count_pool * soul_tithe_copies`
  - `scripts/GameState.gd:4122` `relic_lines.append("Soul Tithe: +%d Blood" % (soul_count_pool * soul_tithe_copies))`
- **Code Touchpoints:**
  - `scripts/GameState.gd:4114` in `_score_selected_internal`

## 75. Spare Chalice
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** If you enter shop with 0 Blood, gain +2 Blood.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/Shop.gd:124` `if gs.relic_inventory["Spare Chalice"] > 0 and gs.blood_currency == 0:`
  - `scripts/Shop.gd:125` `gs.add_blood(2)`
- **Code Touchpoints:**
  - `scripts/Shop.gd:124` in `_ready`

## 76. The Absent Crown
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Exactly 2 VOID sacrifices are treated as refined VOID.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3099` `var refinery_copies: int = int(relic_inventory.get("Refinery of Silence", 0))`
  - `scripts/GameState.gd:4044` `if absent_crown_copies > 0 and void_count == 2 and indices.size() > 0:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3098` in `_score_selected_internal`

## 77. The Absolute Trinity
- **Rarity:** `LEGENDARY`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Triune with matching BLOOD and BONE highest tiers doubles final devotion.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3125` `var copper_tithe_copies: int = int(relic_inventory.get("The Copper Tithe", 0))`
  - `scripts/GameState.gd:4064` `if absolute_trinity_copies > 0 and is_triune_play:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3124` in `_score_selected_internal`

## 78. The Archive Key
- **Rarity:** `LEGENDARY`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Codex utility unlock (information only).
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** No runtime logic found outside catalog/inventory declarations.
- **Exact Behavior (Code Rules):** None found outside declarations.
- **Code Touchpoints:** None outside catalog/inventory declarations.

## 79. The Arterial Rite
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** 3 BLOOD with no trait triggers grants big additive.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3117` `var sanguine_engine_copies: int = int(relic_inventory.get("The Sanguine Engine", 0))`
  - `scripts/GameState.gd:3894` `if arterial_rite_copies > 0 and is_all_blood and indices.size() == 3:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3116` in `_score_selected_internal`

## 80. The Awakening Bell
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Once per week before round 2, clear exhausted status.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/RunGame.gd:718` `if gs.relic_inventory.get("The Awakening Bell", 0) > 0 and gs.awakening_bell_used_week != gs.current_week:`
  - `scripts/RunGame.gd:720` `gs.awakening_bell_used_week = gs.current_week`
- **Code Touchpoints:**
  - `scripts/RunGame.gd:718` in `_proceed_after_confirm`

## 81. The Bleeding Edge
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Big additive each play; failed play loses Blood.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3132` `var cursed_offering_copies: int = int(relic_inventory.get("The Cursed Offering", 0))`
  - `scripts/GameState.gd:3390` `if bleeding_edge_copies > 0:`
  - `scripts/RunGame.gd:596` `if gs.relic_inventory.get("The Bleeding Edge", 0) > 0 and int(result.get("final_devotion", 0)) < int(result.get("target", 0)):`
  - `scripts/RunGame.gd:597` `var bleed_loss: int = 3 * int(gs.relic_inventory.get("The Bleeding Edge", 0))`
  - `scripts/RunGame.gd:598` `gs.blood_currency = max(0, gs.blood_currency - bleed_loss)`
  - `scripts/RunGame.gd:599` `gs.last_breakdown_text += "\nThe Bleeding Edge: -%d Blood (failed target)" % bleed_loss`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3131` in `_score_selected_internal`
  - `scripts/RunGame.gd:596` in `_on_confirm_pressed`
  - `scripts/RunGame.gd:597` in `_on_confirm_pressed`

## 82. The Bloodline Compact
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Legendary offspring weeks grant Blood and offspring tier bonus.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Applies in nest breeding; Applies in wild breeding
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:1745` `if bloodline_compact_legendary_seen_week == week_cleared and int(relic_inventory.get("The Bloodline Compact", 0)) > 0:`
  - `scripts/GameState.gd:1746` `var compact_gain: int = 3 * int(relic_inventory.get("The Bloodline Compact", 0))`
  - `scripts/GameState.gd:1747` `add_blood(compact_gain)`
  - `scripts/GameState.gd:1748` `bloodline_compact_bonus_pending += compact_gain`
  - `scripts/GameState.gd:1776` `var primogeniture_copies: int = int(relic_inventory.get("The Primogeniture", 0))`
  - `scripts/GameState.gd:1864` `if bloodline_compact_copies > 0 and str(baby.get("trait", "")) != "VOID" and _trait_rarity(str(baby.get("trait_id", ""))) == "LEGENDARY":`
  - `scripts/GameState.gd:1882` `if bloodline_compact_copies > 0 and str(extra_baby.get("trait", "")) != "VOID" and _trait_rarity(str(extra_baby.get("trait_id", ""))) == "LEGENDARY":`
  - `scripts/GameState.gd:2011` `if int(relic_inventory.get("The Bloodline Compact", 0)) > 0 and str(baby.get("trait", "")) != "VOID" and _trait_rarity(str(baby.get("trait_id", ""))) == "LEGENDARY":`
  - `scripts/GameState.gd:2012` `baby["tier"] = min(MAX_TIER, int(baby.get("tier", 0)) + 1)`
- **Code Touchpoints:**
  - `scripts/GameState.gd:1745` in `perform_weekly_breeding`
  - `scripts/GameState.gd:1746` in `perform_weekly_breeding`
  - `scripts/GameState.gd:1775` in `resolve_nest_breeding`
  - `scripts/GameState.gd:2011` in `resolve_wild_breeding`

## 83. The Breeding Engine
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Once per week, run a second wild breeding phase.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:1735` `if int(relic_inventory.get("The Breeding Engine", 0)) > 0 and breeding_engine_used_week != week_cleared:`
  - `scripts/GameState.gd:1736` `var wild_extra: Dictionary = resolve_wild_breeding(week_cleared)`
- **Code Touchpoints:**
  - `scripts/GameState.gd:1735` in `perform_weekly_breeding`

## 84. The Brood Compact
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Wild non-VOID breeding chance +5% per copy.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2053` `if brood_copies > 0:`
  - `scripts/GameState.gd:2054` `base += 0.05 * float(brood_copies)`
- **Code Touchpoints:**
  - `scripts/GameState.gd:2050` in `_breeding_chance`

## 85. The Calcified Gate
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** BONE in pool adds floor(tier/3) additive per copy.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3111` `var bone_chorus_copies: int = int(relic_inventory.get("Bone Chorus", 0))`
  - `scripts/GameState.gd:3417` `if calcified_gate_copies > 0:`
  - `scripts/GameState.gd:3428` `gate_delta += int(floor(float(int(f.get("tier", 0))) / 3.0)) * calcified_gate_copies`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3110` in `_score_selected_internal`

## 86. The Compound Covenant
- **Rarity:** `LEGENDARY`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Once per run, doubles held Blood (week 5+ shop only).
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Has purchase-time side effects
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2628` `if name == "The Compound Covenant" and current_week < 5:`
  - `scripts/GameState.gd:2629` `return false`
  - `scripts/GameState.gd:2715` `if name == "The Compound Covenant" and not compound_covenant_used_run and current_week >= 5:`
  - `scripts/GameState.gd:2716` `blood_currency *= 2`
- **Code Touchpoints:**
  - `scripts/GameState.gd:2628` in `can_offer_relic`
  - `scripts/GameState.gd:2715` in `add_relic`

## 87. The Concordat
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Triune plays gain additive per sacrifice.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3120` `var threefold_brand_copies: int = int(relic_inventory.get("Threefold Brand", 0))`
  - `scripts/GameState.gd:3222` `concordat_copies = 0`
  - `scripts/GameState.gd:3480` `if concordat_copies > 0 and is_triune_play:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3119` in `_score_selected_internal`
  - `scripts/GameState.gd:3221` in `_score_selected_internal`

## 88. The Copper Tithe
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Each cleared round grants +copies Blood.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3126` `var single_rite_copies: int = int(relic_inventory.get("Single Rite", 0))`
  - `scripts/GameState.gd:3224` `copper_tithe_copies = 0`
  - `scripts/GameState.gd:4128` `if copper_tithe_copies > 0 and play_passed:`
  - `scripts/GameState.gd:4129` `add_blood(copper_tithe_copies)`
  - `scripts/GameState.gd:4130` `relic_lines.append("The Copper Tithe: +%d Blood" % copper_tithe_copies)`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3125` in `_score_selected_internal`
  - `scripts/GameState.gd:3223` in `_score_selected_internal`

## 89. The Count Absolute
- **Rarity:** `LEGENDARY`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Single tier-10 sacrifice doubles final devotion.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3131` `var bleeding_edge_copies: int = int(relic_inventory.get("The Bleeding Edge", 0))`
  - `scripts/GameState.gd:4058` `if count_absolute_copies > 0 and indices.size() == 1 and highest_tier_sac >= 10:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3130` in `_score_selected_internal`

## 90. The Cursed Offering
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Additive boost, but random pool follower loses tier after play.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3133` `var hollow_pact_copies: int = int(relic_inventory.get("The Hollow Pact", 0))`
  - `scripts/GameState.gd:3394` `if cursed_offering_copies > 0:`
  - `scripts/GameState.gd:4185` `if cursed_offering_copies > 0 and not pool.is_empty():`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3132` in `_score_selected_internal`

## 91. The Damnation Seal
- **Rarity:** `LEGENDARY`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Week 10 target is doubled.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Affects weekly target calculation
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2652` `if int(relic_inventory.get("The Damnation Seal", 0)) > 0 and week == get_max_weeks():`
  - `scripts/GameState.gd:2653` `computed *= 2`
- **Code Touchpoints:**
  - `scripts/GameState.gd:2652` in `get_week_target`

## 92. The Debt Engine
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Extend debt limit; unpaid debt converts to next-round additive penalty.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Applies on shop exit
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:753` `if int(relic_inventory.get("The Debt Engine", 0)) > 0 and blood_debt > 0:`
  - `scripts/GameState.gd:754` `next_round_additive_penalty += blood_debt`
  - `scripts/GameState.gd:2584` `if int(relic_inventory.get("The Debt Engine", 0)) > 0:`
  - `scripts/GameState.gd:2585` `debt_limit = 6`
  - `scripts/GameState.gd:2598` `if int(relic_inventory.get("The Debt Engine", 0)) > 0:`
  - `scripts/GameState.gd:2599` `debt_limit = 6`
- **Code Touchpoints:**
  - `scripts/GameState.gd:753` in `finalize_shop_visit`
  - `scripts/GameState.gd:2584` in `can_afford_relic`
  - `scripts/GameState.gd:2598` in `spend_blood_for_relic`

## 93. The Deep Pool
- **Rarity:** `UNCOMMON`
- **Category:** `VOUCHER`
- **Stacks:** `Yes`
- **Description (Catalog):** Pool cap +6 per copy; 2+ copies unlock third nest.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Affects pool-cap accounting
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:1191` `if int(relic_inventory.get("The Deep Pool", 0)) >= 2:`
  - `scripts/GameState.gd:1192` `extra = 1`
  - `scripts/GameState.gd:2542` `var hollow_pact_copies: int = int(relic_inventory.get("The Hollow Pact", 0))`
  - `scripts/GameState.gd:2544` `cap += (6 * deep_pool_copies)`
- **Code Touchpoints:**
  - `scripts/GameState.gd:1191` in `_get_nest_capacity`
  - `scripts/GameState.gd:2541` in `get_pool_cap`

## 94. The Deepest Void
- **Rarity:** `LEGENDARY`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Each sacrificed VOID adds +1 effective VOID per copy.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3106` `var marrow_charter_copies: int = int(relic_inventory.get("Marrow Charter", 0))`
  - `scripts/GameState.gd:3980` `if deepest_void_copies > 0 and void_count > 0:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3105` in `_score_selected_internal`

## 95. The Drawn Curtain
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Doctrine action used this round grants additive.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3137` `var nursery_ledger_copies: int = int(relic_inventory.get("Nursery Ledger", 0))`
  - `scripts/GameState.gd:3398` `if drawn_curtain_copies > 0 and doctrine_used_this_play:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3136` in `_score_selected_internal`

## 96. The Dyad Mark
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Exactly 2 sacrifices: additive bonus.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3128` `var foursome_copies: int = int(relic_inventory.get("The Foursome", 0))`
  - `scripts/GameState.gd:3436` `if dyad_mark_copies > 0 and indices.size() == 2:`
  - `scripts/GameState.gd:3437` `relic_additive_total += 18 * dyad_mark_copies`
  - `scripts/GameState.gd:3438` `relic_lines.append("The Dyad Mark: +%d" % (18 * dyad_mark_copies))`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3127` in `_score_selected_internal`

## 97. The Dynasty Forge
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Once per run designate a permanent wild breeding pair.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Applies in wild breeding
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:703` `if int(relic_inventory.get("The Dynasty Forge", 0)) <= 0:`
  - `scripts/GameState.gd:704` `return`
  - `scripts/GameState.gd:1946` `if int(relic_inventory.get("The Dynasty Forge", 0)) > 0 and dynasty_forge_set_run:`
  - `scripts/GameState.gd:1947` `favored_a_id = int(dynasty_forge_pair[0])`
- **Code Touchpoints:**
  - `scripts/GameState.gd:703` in `_ensure_dynasty_forge_pair`
  - `scripts/GameState.gd:1946` in `resolve_wild_breeding`

## 98. The Empty Pyre
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Each sacrificed VOID adds +1 extra effective VOID.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3098` `var absent_crown_copies: int = int(relic_inventory.get("The Absent Crown", 0))`
  - `scripts/GameState.gd:3984` `if empty_pyre_copies > 0 and void_count > 0:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3097` in `_score_selected_internal`

## 99. The Eternal Line
- **Rarity:** `LEGENDARY`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Bred offspring do not count toward pool cap.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Affects pool-cap accounting
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2551` `if int(relic_inventory.get("The Eternal Line", 0)) <= 0:`
  - `scripts/GameState.gd:2552` `return true`
- **Code Touchpoints:**
  - `scripts/GameState.gd:2551` in `_counts_toward_pool_cap`

## 100. The Expanding Contract
- **Rarity:** `LEGENDARY`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Once per week, 5-sacrifice play enabled; 5th gives tierx3 and is consumed.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass; Applies during post-play hand/pool resolution
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:1666` `if int(relic_inventory.get("The Expanding Contract", 0)) > 0 and selected_indices.size() >= 5:`
  - `scripts/GameState.gd:1667` `consume_fifth_idx = int(selected_indices[selected_indices.size() - 1])`
  - `scripts/GameState.gd:3442` `if int(relic_inventory.get("The Expanding Contract", 0)) > 0 and indices.size() >= 5 and sacrificed_info.size() >= 5:`
  - `scripts/GameState.gd:3443` `var fifth_info: Dictionary = sacrificed_info[sacrificed_info.size() - 1]`
  - `scripts/RunGame.gd:826` `if not has_four and not has_five:`
  - `scripts/RunGame.gd:828` `if has_five and gs.contract_five_used_week == gs.current_week:`
  - `scripts/RunGame.gd:830` `if has_five:`
  - `scripts/RunGame.gd:844` `if not has_four and not has_five:`
  - `scripts/RunGame.gd:852` `if has_five:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:1666` in `resolve_play_and_update_pool`
  - `scripts/GameState.gd:3442` in `_score_selected_internal`
  - `scripts/RunGame.gd:825` in `_on_contract_toggle`
  - `scripts/RunGame.gd:843` in `_update_contract_ui`

## 101. The Expanding Rite
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** 4-sacrifice plays build persistent additive bonus.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3915` `if int(relic_inventory.get("The Expanding Rite", 0)) > 0 and indices.size() == 4:`
  - `scripts/GameState.gd:3916` `expanding_rite_bonus += 2 * int(relic_inventory.get("The Expanding Rite", 0))`
  - `scripts/GameState.gd:3919` `var target: int = get_week_target(current_week)`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3915` in `_score_selected_internal`
  - `scripts/GameState.gd:3916` in `_score_selected_internal`

## 102. The Faithful Scribe
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Shop rerolls have elevated minimum rarity.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/Shop.gd:391` `if gs.shop_rerolls_used > 0 and gs.relic_inventory.get("The Faithful Scribe", 0) > 0:`
  - `scripts/Shop.gd:392` `rarity = _raise_rarity_floor(rarity, int(gs.relic_inventory.get("The Faithful Scribe", 0)))`
  - `scripts/Shop.gd:393` `var pick: String = _pick_from_rarity(rarity, chosen)`
- **Code Touchpoints:**
  - `scripts/Shop.gd:391` in `_roll_offers`
  - `scripts/Shop.gd:392` in `_roll_offers`

## 103. The Final Silence
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Exactly 1 VOID grants stronger exponent bonuses.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3105` `var deepest_void_copies: int = int(relic_inventory.get("The Deepest Void", 0))`
  - `scripts/GameState.gd:4012` `if final_silence_copies > 0 and void_count == 1:`
  - `scripts/GameState.gd:4013` `exponent += 2 * final_silence_copies`
  - `scripts/GameState.gd:4014` `relic_multiplier_lines.append("The Final Silence: multiplier exponent +%d" % (2 * final_silence_copies))`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3104` in `_score_selected_internal`

## 104. The Foursome
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** 4-sacrifice plays gain additive per copy.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3129` `var minimalist_doctrine_copies: int = int(relic_inventory.get("Minimalist Doctrine", 0))`
  - `scripts/GameState.gd:3439` `if foursome_copies > 0 and indices.size() == 4:`
  - `scripts/GameState.gd:3440` `relic_additive_total += 10 * foursome_copies`
  - `scripts/GameState.gd:3441` `relic_lines.append("The Foursome: +%d" % (10 * foursome_copies))`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3128` in `_score_selected_internal`

## 105. The Generation Mark
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Nest offspring from high-tier parents gain starting tier bonus.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Applies in nest breeding
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:1775` `var bloodline_compact_copies: int = int(relic_inventory.get("The Bloodline Compact", 0))`
  - `scripts/GameState.gd:1814` `if generation_mark_copies > 0 and int(a.get("tier", 0)) >= 5 and int(b.get("tier", 0)) >= 5:`
  - `scripts/GameState.gd:1815` `base_tier = min(MAX_TIER, base_tier + generation_mark_copies)`
- **Code Touchpoints:**
  - `scripts/GameState.gd:1774` in `resolve_nest_breeding`

## 106. The Gilded Offering
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Tier-10 sacrificed followers return to pool after resolve.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3096` `var last_rung_copies: int = int(relic_inventory.get("The Last Rung", 0))`
  - `scripts/GameState.gd:4144` `if gilded_offering_copies > 0:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3095` in `_score_selected_internal`

## 107. The Great Cull
- **Rarity:** `LEGENDARY`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Once per run, keep only 8 followers; survivors gain +2 tier.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Applies on shop entry
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:741` `if int(relic_inventory.get("The Great Cull", 0)) > 0 and not great_cull_used_run:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:741` in `start_shop_visit`

## 108. The Hollow Pact
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Multiplier exponent bonus; pool cap halved.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass; Affects pool-cap accounting
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2543` `cap += (4 * salt_copies)`
  - `scripts/GameState.gd:2546` `if hollow_pact_copies > 0:`
  - `scripts/GameState.gd:3134` `var last_sacrifice_copies: int = int(relic_inventory.get("The Last Sacrifice", 0))`
  - `scripts/GameState.gd:4006` `if hollow_pact_copies > 0:`
  - `scripts/GameState.gd:4007` `exponent += hollow_pact_copies`
  - `scripts/GameState.gd:4008` `relic_multiplier_lines.append("The Hollow Pact: multiplier exponent +%d" % hollow_pact_copies)`
- **Code Touchpoints:**
  - `scripts/GameState.gd:2542` in `get_pool_cap`
  - `scripts/GameState.gd:3133` in `_score_selected_internal`

## 109. The Hollow Register
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Once per week, a play with exactly 1 VOID gains stacks; each stack adds +1 exponent permanently.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3102` `var void_recursion_copies: int = int(relic_inventory.get("Void Recursion", 0))`
  - `scripts/GameState.gd:4159` `if hollow_register_copies > 0 and void_count == 1 and hollow_register_awarded_week != current_week:`
  - `scripts/GameState.gd:4160` `hollow_register_stacks += max(1, hollow_register_copies)`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3101` in `_score_selected_internal`

## 110. The Hungry Altar
- **Rarity:** `LEGENDARY`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Scoring doubles; after play, one random pool follower is consumed.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass; Applies during post-play hand/pool resolution
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:1717` `if int(relic_inventory.get("The Hungry Altar", 0)) > 0:`
  - `scripts/GameState.gd:1718` `var non_nested: Array[int] = []`
  - `scripts/GameState.gd:3136` `var drawn_curtain_copies: int = int(relic_inventory.get("The Drawn Curtain", 0))`
  - `scripts/GameState.gd:4081` `if hungry_altar_copies > 0:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:1717` in `resolve_play_and_update_pool`
  - `scripts/GameState.gd:3135` in `_score_selected_internal`

## 111. The Inheritance Forge
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Each nest gets extra breeding attempts per week.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Applies in nest breeding
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:1774` `var generation_mark_copies: int = int(relic_inventory.get("The Generation Mark", 0))`
- **Code Touchpoints:**
  - `scripts/GameState.gd:1773` in `resolve_nest_breeding`

## 112. The Iron Tithe
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Start week: gain Blood equal to copies x week.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Applies at week start
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:1096` `if int(relic_inventory.get("The Iron Tithe", 0)) > 0:`
  - `scripts/GameState.gd:1097` `add_blood(int(relic_inventory.get("The Iron Tithe", 0)) * current_week)`
- **Code Touchpoints:**
  - `scripts/GameState.gd:1096` in `start_week`
  - `scripts/GameState.gd:1097` in `start_week`

## 113. The Last Rung
- **Rarity:** `LEGENDARY`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Each tier-10 sacrifice adds +5 to multiplier base.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3097` `var empty_pyre_copies: int = int(relic_inventory.get("The Empty Pyre", 0))`
  - `scripts/GameState.gd:3989` `if last_rung_copies > 0:`
  - `scripts/GameState.gd:3993` `last_rung_bonus += 5 * last_rung_copies`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3096` in `_score_selected_internal`

## 114. The Last Sacrifice
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** If pool has under 5 non-SOUL followers, scoring is doubled.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3135` `var hungry_altar_copies: int = int(relic_inventory.get("The Hungry Altar", 0))`
  - `scripts/GameState.gd:4073` `if last_sacrifice_copies > 0:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3134` in `_score_selected_internal`

## 115. The Omen Ledger
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Omen Deck can roll legendary traits on recruits.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Affects recruit shop flow
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:1576` `var bonus_rare: float = 0.10 * float(omen_copies)`
- **Code Touchpoints:**
  - `scripts/GameState.gd:1575` in `generate_shop_recruits`

## 116. The Ossuary Engine
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Clearing a week with 2+ BONE builds permanent BONE additive.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/RunGame.gd:696` `if gs.relic_inventory.get("The Ossuary Engine", 0) > 0 and int(last_result.get("bone_count", 0)) >= 2:`
  - `scripts/RunGame.gd:697` `gs.ossuary_engine_bonus += 2 * int(gs.relic_inventory.get("The Ossuary Engine", 0))`
- **Code Touchpoints:**
  - `scripts/RunGame.gd:696` in `_proceed_after_confirm`
  - `scripts/RunGame.gd:697` in `_proceed_after_confirm`

## 117. The Palimpsest
- **Rarity:** `LEGENDARY`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Once per run: wipe relics and redraw 3 relic offers.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Has purchase-time side effects
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2718` `if name == "The Palimpsest" and not palimpsest_used_run:`
  - `scripts/Shop.gd:154` `if offer_name == "The Palimpsest":`
  - `scripts/Shop.gd:155` `offers = _roll_offers(3, gs.current_week, false)`
- **Code Touchpoints:**
  - `scripts/GameState.gd:873` in `_apply_palimpsest`
  - `scripts/GameState.gd:2718` in `add_relic`
  - `scripts/Shop.gd:154` in `_on_buy_pressed`

## 118. The Pared Offering
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** After 1-sacrifice play, gain random T2 of sacrificed type.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3141` `var sacrificed_info: Array[Dictionary] = []`
  - `scripts/GameState.gd:3228` `pared_offering_copies = 0`
  - `scripts/GameState.gd:4136` `if pared_offering_copies > 0 and indices.size() == 1 and sacrificed_info.size() == 1:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3139` in `_score_selected_internal`
  - `scripts/GameState.gd:3227` in `_score_selected_internal`

## 119. The Peaked Rite
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** If average tier of 3 sacrifices exceeds 7, additive total x1.5.
- **Hook Phase:** `PRE_MULT`
- **Hook Function:** `_hook_pre_mult_peaked_rite`
- **Functionality In Code/In Game:** Scoring hook `PRE_MULT` via `_hook_pre_mult_peaked_rite`
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2972` `var indices: Array = ctx["indices"]`
  - `scripts/GameState.gd:2973` `if indices.size() != 3:`
  - `scripts/GameState.gd:2976` `if sacrificed_info.size() != 3:`
  - `scripts/GameState.gd:2982` `if avg_tier <= 7.0:`
  - `scripts/GameState.gd:2987` `if delta <= 0:`
  - `scripts/GameState.gd:2989` `ctx["additive_total"] = boosted_total`
  - `scripts/GameState.gd:2990` `ctx["relic_additive_total"] = int(ctx.get("relic_additive_total", 0)) + delta`
  - `scripts/GameState.gd:2991` `var relic_lines: Array = ctx["relic_lines"]`
  - `scripts/GameState.gd:2992` `relic_lines.append("The Peaked Rite: +%d (x1.5)" % delta)`
- **Code Touchpoints:**
  - `scripts/GameState.gd:464` in `(top-level)`

## 120. The Primogeniture
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** First nest offspring each run gets stronger trait inheritance.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Applies in nest breeding
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:1777` `var womb_available: bool = int(relic_inventory.get("The Womb of Ages", 0)) > 0 and not womb_of_ages_used_run`
  - `scripts/GameState.gd:1830` `if primogeniture_copies > 0 and not primogeniture_used_run:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:1776` in `resolve_nest_breeding`

## 121. The Pruning Hook
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Once per shop cull and replace with random T3 of same type.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2412` `if trigger_shop_relics and int(relic_inventory.get("The Pruning Hook", 0)) > 0 and not pruning_hook_used_shop:`
  - `scripts/Shop.gd:564` `var cull_ok: bool = (culling_knife_ok or pruning_hook_ok) and selected_pool_id >= 0`
- **Code Touchpoints:**
  - `scripts/GameState.gd:2412` in `cull_follower_by_id`
  - `scripts/Shop.gd:563` in `_update_pool_actions`

## 122. The Purifying Flame
- **Rarity:** `LEGENDARY`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Once per run, transmute 5 followers into stronger rare-trait forms.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Applies on shop entry
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:739` `if int(relic_inventory.get("The Purifying Flame", 0)) > 0 and not purifying_flame_used_run:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:739` in `start_shop_visit`

## 123. The Red Covenant
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Each week target doubled; clear grants Blood and rare shop bonus.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Applies at week start; Affects weekly target calculation
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:1098` `if int(relic_inventory.get("The Red Covenant", 0)) > 0:`
  - `scripts/GameState.gd:1099` `red_covenant_active_week = current_week`
  - `scripts/GameState.gd:2650` `if int(relic_inventory.get("The Red Covenant", 0)) > 0 and red_covenant_active_week == week:`
  - `scripts/GameState.gd:2651` `computed *= 2`
  - `scripts/RunGame.gd:691` `if gs.relic_inventory.get("The Red Covenant", 0) > 0 and gs.red_covenant_active_week == gs.current_week:`
  - `scripts/RunGame.gd:692` `gs.add_blood(30)`
- **Code Touchpoints:**
  - `scripts/GameState.gd:1098` in `start_week`
  - `scripts/GameState.gd:2650` in `get_week_target`
  - `scripts/RunGame.gd:691` in `_proceed_after_confirm`

## 124. The Red Market
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Once per shop can sell a relic for half its cost.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2606` `if int(relic_inventory.get("The Red Market", 0)) <= 0:`
  - `scripts/GameState.gd:2607` `return false`
  - `scripts/GameState.gd:2612` `return int(relic_inventory.get(name, 0)) > 0 and name != "The Red Market"`
- **Code Touchpoints:**
  - `scripts/GameState.gd:2606` in `can_sell_relic`
  - `scripts/GameState.gd:2612` in `can_sell_relic`

## 125. The Red Tithe
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** 3 BLOOD with high total tier gains additive.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3114` `var sanguine_chord_copies: int = int(relic_inventory.get("The Sanguine Chord", 0))`
  - `scripts/GameState.gd:3220` `red_tithe_copies = 0`
  - `scripts/GameState.gd:3468` `if red_tithe_copies > 0 and is_all_blood and indices.size() == 3 and tier_sum >= 18:`
  - `scripts/GameState.gd:3469` `relic_additive_total += 15 * red_tithe_copies`
  - `scripts/GameState.gd:3470` `relic_lines.append("The Red Tithe: +%d" % (15 * red_tithe_copies))`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3113` in `_score_selected_internal`
  - `scripts/GameState.gd:3219` in `_score_selected_internal`

## 126. The Rotary
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Once per shop, swap trait IDs of two pool followers.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Applies on shop entry
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:743` `if int(relic_inventory.get("The Rotary", 0)) > 0 and not rotary_used_shop:`
  - `scripts/GameState.gd:806` `if int(relic_inventory.get("The Rotary", 0)) <= 0 or rotary_used_shop:`
  - `scripts/GameState.gd:807` `return false`
- **Code Touchpoints:**
  - `scripts/GameState.gd:743` in `start_shop_visit`
  - `scripts/GameState.gd:806` in `use_rotary_swap`

## 127. The Running Red
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Cleared 3 BLOOD round adds random T3 BLOOD to pool.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:4131` `if int(relic_inventory.get("The Running Red", 0)) > 0 and play_passed and is_all_blood and indices.size() == 3:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:4131` in `_score_selected_internal`
  - `scripts/GameState.gd:4132` in `_score_selected_internal`

## 128. The Rusted Tithe
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Each play disables one random COMMON relic this round.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3185` `if int(relic_inventory.get("The Rusted Tithe", 0)) > 0 and indices.size() > 0:`
  - `scripts/GameState.gd:3186` `var rusted_candidates: Array[String] = []`
  - `scripts/GameState.gd:3192` `if relic_name == "The Rusted Tithe":`
  - `scripts/GameState.gd:3194` `rusted_candidates.append(relic_name)`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3185` in `_score_selected_internal`
  - `scripts/GameState.gd:3192` in `_score_selected_internal`

## 129. The Sacred Triangle
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Triune play doubles base contribution of top card per type.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3122` `var covenant_of_three_copies: int = int(relic_inventory.get("Covenant of Three", 0))`
  - `scripts/GameState.gd:3488` `if sacred_triangle_copies > 0 and is_triune_play:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3121` in `_score_selected_internal`

## 130. The Sanguine Bank
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Blood carried into week 10 grants final-score bank bonus.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Applies at week start
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:1102` `if int(relic_inventory.get("The Sanguine Bank", 0)) > 0 and current_week == get_max_weeks():`
  - `scripts/GameState.gd:1103` `last_week10_blood_bank_bonus = blood_currency`
  - `scripts/RunGame.gd:706` `if gs.relic_inventory.get("The Sanguine Bank", 0) > 0:`
  - `scripts/RunGame.gd:707` `gs.last_breakdown_text += "\nThe Sanguine Bank: final-week blood banked = %d" % gs.blood_currency`
- **Code Touchpoints:**
  - `scripts/GameState.gd:1102` in `start_week`
  - `scripts/RunGame.gd:706` in `_proceed_after_confirm`

## 131. The Sanguine Chord
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** BLOOD straights gain exponent.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3115` `var bloodfire_compact_copies: int = int(relic_inventory.get("Bloodfire Compact", 0))`
  - `scripts/GameState.gd:4009` `if sanguine_chord_copies > 0 and is_all_blood and blood_straight:`
  - `scripts/GameState.gd:4010` `exponent += sanguine_chord_copies`
  - `scripts/GameState.gd:4011` `relic_multiplier_lines.append("The Sanguine Chord: multiplier exponent +%d" % sanguine_chord_copies)`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3114` in `_score_selected_internal`

## 132. The Sanguine Engine
- **Rarity:** `LEGENDARY`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Highest BLOOD in pool grants BLOOD-play additive.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3118` `var crimson_absolute_copies: int = int(relic_inventory.get("Crimson Absolute", 0))`
  - `scripts/GameState.gd:3471` `if sanguine_engine_copies > 0 and blood_count > 0:`
  - `scripts/GameState.gd:3478` `relic_additive_total += eng_delta * sanguine_engine_copies`
  - `scripts/GameState.gd:3479` `relic_lines.append("The Sanguine Engine: +%d" % (eng_delta * sanguine_engine_copies))`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3117` in `_score_selected_internal`

## 133. The Second Sight
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Shows next week target in shop.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Applies on shop entry
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:747` `if int(relic_inventory.get("The Second Sight", 0)) > 0 and not second_sight_used_run:`
  - `scripts/GameState.gd:748` `var next_w: int = min(get_max_weeks(), current_week + 1)`
- **Code Touchpoints:**
  - `scripts/GameState.gd:747` in `start_shop_visit`

## 134. The Skeleton Archive
- **Rarity:** `LEGENDARY`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Late BONE-focused clears increase permanent BONE bonus.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/RunGame.gd:698` `if gs.relic_inventory.get("The Skeleton Archive", 0) > 0 and not gs.skeleton_archive_awarded_run and gs.current_week >= 5:`
  - `scripts/RunGame.gd:699` `var pool_counts: Dictionary = gs.pool_summary_counts()`
  - `scripts/RunGame.gd:702` `gs.skeleton_archive_bonus += int(gs.relic_inventory.get("The Skeleton Archive", 0))`
  - `scripts/RunGame.gd:703` `gs.skeleton_archive_awarded_run = true`
- **Code Touchpoints:**
  - `scripts/RunGame.gd:698` in `_proceed_after_confirm`
  - `scripts/RunGame.gd:702` in `_proceed_after_confirm`

## 135. The Soul Lantern
- **Rarity:** `LEGENDARY`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Once per run: ascend a pool follower to VOID (tier becomes 0). Drains all blood to 0.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/Shop.gd:572` `pool_apostle.disabled = pack_select_mode or not (gs.relic_inventory["First Apostle"] > 0 and gs.apostle_id == -1 and selected_pool_id >= 0)`
- **Code Touchpoints:**
  - `scripts/Shop.gd:571` in `_update_pool_actions`

## 136. The Summit
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** If highest-tier sacrifice is above last round's highest, +15 additive.
- **Hook Phase:** `PRE_ADD`
- **Hook Function:** `_hook_pre_add_the_summit`
- **Functionality In Code/In Game:** Scoring hook `PRE_ADD` via `_hook_pre_add_the_summit`
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2911` `if summit_last_round_highest_tier < 0:`
  - `scripts/GameState.gd:2913` `if highest_tier_sac <= summit_last_round_highest_tier:`
  - `scripts/GameState.gd:2915` `_hook_additive_delta(ctx, "The Summit: +15", 15)`
- **Code Touchpoints:**
  - `scripts/GameState.gd:457` in `(top-level)`

## 137. The Third Knife
- **Rarity:** `LEGENDARY`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** The first three followers you choose each week count as double tier.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3070` `var bone_copies: int = relic_inventory["Bone Idol"]`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3069` in `_score_selected_internal`

## 138. The Tithe Accelerator
- **Rarity:** `LEGENDARY`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Each relic purchase increases passive interest scaling.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Has purchase-time side effects
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2700` `if int(relic_inventory.get("The Tithe Accelerator", 0)) > 0:`
  - `scripts/GameState.gd:2701` `tithe_accelerator_interest_bonus += int(relic_inventory.get("The Tithe Accelerator", 0))`
  - `scripts/GameState.gd:2702` `if name == "The Tithe Accelerator":`
  - `scripts/GameState.gd:2703` `var gained_copies: int = int(relic_inventory.get("The Tithe Accelerator", 0)) - previous_count`
  - `scripts/GameState.gd:2704` `if gained_copies > 0:`
  - `scripts/GameState.gd:2705` `tithe_accelerator_interest_bonus += gained_copies * purchased_relic_history.size()`
- **Code Touchpoints:**
  - `scripts/GameState.gd:2700` in `add_relic`
  - `scripts/GameState.gd:2701` in `add_relic`
  - `scripts/GameState.gd:2702` in `add_relic`
  - `scripts/GameState.gd:2703` in `add_relic`

## 139. The Triad Compact
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** 3-sacrifice plays build permanent additive.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3913` `if int(relic_inventory.get("The Triad Compact", 0)) > 0 and indices.size() == 3:`
  - `scripts/GameState.gd:3914` `triad_compact_bonus += int(relic_inventory.get("The Triad Compact", 0))`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3913` in `_score_selected_internal`
  - `scripts/GameState.gd:3914` in `_score_selected_internal`

## 140. The Trinity Engine
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Triune Champion/Heir final multipliers always fully apply.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3124` `var absolute_trinity_copies: int = int(relic_inventory.get("The Absolute Trinity", 0))`
  - `scripts/GameState.gd:4084` `if trinity_engine_copies > 0 and is_triune_play:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3123` in `_score_selected_internal`

## 141. The Unbroken Rite
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Triune in both rounds guarantees rare-or-better next shop.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3909` `if int(relic_inventory.get("The Unbroken Rite", 0)) > 0 and week_round == 2 and triune_rounds_this_week == 3:`
  - `scripts/GameState.gd:3910` `guaranteed_rare_next_shop = true`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3909` in `_score_selected_internal`

## 142. The Votive Ledger
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Once per shop, re-fire one purchased relic's on-win effect.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Applies on shop entry
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:745` `if int(relic_inventory.get("The Votive Ledger", 0)) > 0 and not votive_ledger_used_shop:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:745` in `start_shop_visit`

## 143. The Waiting Bell
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Skipping all shop purchases grants +10 Blood.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/Shop.gd:368` `if gs.relic_inventory.get("The Waiting Bell", 0) > 0 and not gs.shop_any_purchase_this_visit:`
  - `scripts/Shop.gd:369` `gs.add_blood(10)`
- **Code Touchpoints:**
  - `scripts/Shop.gd:368` in `_finish_shop`

## 144. The White Wall
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** If 3 BONE and 0 VOID, multiplier base is at least 2.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3109` `var crypt_standard_copies: int = int(relic_inventory.get("Crypt Standard", 0))`
  - `scripts/GameState.gd:4000` `if white_wall_copies > 0 and bone_count == 3 and void_count == 0:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3108` in `_score_selected_internal`

## 145. The Witness
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Reveals all hand trait IDs (information utility).
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** No runtime logic found outside catalog/inventory declarations.
- **Exact Behavior (Code Rules):** None found outside declarations.
- **Code Touchpoints:** None outside catalog/inventory declarations.

## 146. The Womb of Ages
- **Rarity:** `LEGENDARY`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Once per run one nest produces two offspring.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Applies in nest breeding
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:1779` `var entry: Dictionary = nests[n]`
  - `scripts/GameState.gd:1871` `if womb_available:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:1777` in `resolve_nest_breeding`

## 147. Thin Blade
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Sacrifice just 1? Gain a big devotion boost.
- **Hook Phase:** `PRE_ADD`
- **Hook Function:** `_hook_pre_add_thin_blade`
- **Functionality In Code/In Game:** Scoring hook `PRE_ADD` via `_hook_pre_add_thin_blade`; Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2773` `var indices: Array = ctx["indices"]`
  - `scripts/GameState.gd:2774` `if indices.size() != 1:`
  - `scripts/GameState.gd:2777` `_hook_additive_delta(ctx, "Thin Blade (x%d): +%d" % [copies, delta], delta)`
  - `scripts/GameState.gd:3076` `var ossuary_copies: int = relic_inventory["Ossuary Standard"]`
  - `scripts/GameState.gd:3208` `thin_copies = 0`
- **Code Touchpoints:**
  - `scripts/GameState.gd:442` in `(top-level)`
  - `scripts/GameState.gd:3075` in `_score_selected_internal`
  - `scripts/GameState.gd:3207` in `_score_selected_internal`

## 148. Threefold Brand
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** After first triune this run, future triune plays gain additive.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3121` `var sacred_triangle_copies: int = int(relic_inventory.get("The Sacred Triangle", 0))`
  - `scripts/GameState.gd:3484` `if threefold_brand_copies > 0 and triune_play_seen_run and is_triune_play:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3120` in `_score_selected_internal`

## 149. Tithe Discount
- **Rarity:** `UNCOMMON`
- **Category:** `VOUCHER`
- **Stacks:** `No`
- **Description (Catalog):** Relics cost 1 less Blood (min 2).
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2673` `if relic_inventory["Tithe Discount"] > 0:`
  - `scripts/GameState.gd:2674` `discount = 1`
- **Code Touchpoints:**
  - `scripts/GameState.gd:2673` in `get_shop_cost`

## 150. Trine Offering
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Triune play grants free recruit(s) next shop.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3903` `if int(relic_inventory.get("Trine Offering", 0)) > 0:`
  - `scripts/GameState.gd:3904` `trine_offering_free_recruits_pending += int(relic_inventory.get("Trine Offering", 0))`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3903` in `_score_selected_internal`
  - `scripts/GameState.gd:3904` in `_score_selected_internal`

## 151. Triune Reliquary
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** If sacrifices include BLOOD+BONE+VOID, +12 additive per copy.
- **Hook Phase:** `PRE_ADD`
- **Hook Function:** `_hook_pre_add_triune_reliquary`
- **Functionality In Code/In Game:** Scoring hook `PRE_ADD` via `_hook_pre_add_triune_reliquary`; Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2846` `var indices: Array = ctx["indices"]`
  - `scripts/GameState.gd:2847` `if indices.size() != 3:`
  - `scripts/GameState.gd:2849` `if not bool(ctx.get("has_blood", false)) or not bool(ctx.get("has_bone", false)) or not bool(ctx.get("has_void", false)):`
  - `scripts/GameState.gd:2852` `_hook_additive_delta(ctx, "Triune Reliquary (x%d): +%d" % [copies, delta], delta)`
  - `scripts/GameState.gd:3092` `var bloodright_copies: int = relic_inventory["Bloodright Almanac"]`
- **Code Touchpoints:**
  - `scripts/GameState.gd:450` in `(top-level)`
  - `scripts/GameState.gd:3091` in `_score_selected_internal`

## 152. Usurer's Mark
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** Crimson Interest gains extra triggers per shop.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Runtime references exist (see exact code rules below).
- **Exact Behavior (Code Rules):**
  - `scripts/Shop.gd:358` `var interest_gain: int = 0`
- **Code Touchpoints:**
  - `scripts/Shop.gd:357` in `_finish_shop`

## 153. Void Cradle
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** VOID sacrifices return to pool after resolve.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3101` `var hollow_register_copies: int = int(relic_inventory.get("The Hollow Register", 0))`
  - `scripts/GameState.gd:4150` `if void_cradle_copies > 0:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3100` in `_score_selected_internal`

## 154. Void Pilgrim
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Wild VOID-VOID breeding always succeeds.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Applies in wild breeding
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:1985` `if int(relic_inventory.get("Void Pilgrim", 0)) > 0 and str(a.get("trait", "")) == "VOID" and str(b.get("trait", "")) == "VOID":`
  - `scripts/GameState.gd:1986` `chance = 1.0`
- **Code Touchpoints:**
  - `scripts/GameState.gd:1985` in `resolve_wild_breeding`

## 155. Void Prism
- **Rarity:** `LEGENDARY`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** VOID sacrifices count as extra for your multiplier.
- **Hook Phase:** `MULTIPLIER_ADJUST`
- **Hook Function:** `_hook_multiplier_void_prism`
- **Functionality In Code/In Game:** Scoring hook `MULTIPLIER_ADJUST` via `_hook_multiplier_void_prism`; Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3012` `var relic_multiplier_lines: Array = ctx["relic_multiplier_lines"]`
  - `scripts/GameState.gd:3013` `relic_multiplier_lines.append("Void Prism (x%d): effective VOID +%d" % [copies, copies])`
  - `scripts/GameState.gd:3081` `var candle_copies: int = relic_inventory["Black Candle"]`
- **Code Touchpoints:**
  - `scripts/GameState.gd:470` in `(top-level)`
  - `scripts/GameState.gd:3080` in `_score_selected_internal`

## 156. Void Recursion
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Once per week, sacrificing a VOID spawns a copy in pool.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3103` `var null_covenant_copies: int = int(relic_inventory.get("Null Covenant", 0))`
  - `scripts/GameState.gd:4162` `if void_recursion_copies > 0 and void_recursion_used_week != current_week:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3102` in `_score_selected_internal`

## 157. Votive Mirror
- **Rarity:** `COMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** Once per shop, buy one recruit offer twice.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Affects recruit shop flow
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:1597` `if relic_inventory["Votive Mirror"] > 0 and not shop_copy_used:`
  - `scripts/GameState.gd:1598` `is_copy_purchase = true`
  - `scripts/Shop.gd:327` `buy_button.disabled = ((not is_free) and gs.blood_currency < 1) or (gs.shop_recruit_purchased[i] and not can_copy) or gs.is_pool_at_capacity()`
- **Code Touchpoints:**
  - `scripts/GameState.gd:1597` in `buy_shop_recruit`
  - `scripts/Shop.gd:326` in `_setup_recruits`

## 158. Warden of the Fold
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** After each round, lowest non-SOUL in pool gains tier.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Applies during post-play hand/pool resolution
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:1703` `if int(relic_inventory.get("Warden of the Fold", 0)) > 0:`
  - `scripts/GameState.gd:1705` `var low_idx: int = -1`
- **Code Touchpoints:**
  - `scripts/GameState.gd:1703` in `resolve_play_and_update_pool`
  - `scripts/GameState.gd:1704` in `resolve_play_and_update_pool`

## 159. Wax Seal
- **Rarity:** `RARE`
- **Category:** `RELIC`
- **Stacks:** `Yes`
- **Description (Catalog):** If any pair of equal tiers, +8 additive per copy.
- **Hook Phase:** `PRE_ADD`
- **Hook Function:** `_hook_pre_add_wax_seal`
- **Functionality In Code/In Game:** Scoring hook `PRE_ADD` via `_hook_pre_add_wax_seal`; Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:2824` `var tier_counts: Dictionary = ctx["tier_counts"]`
  - `scripts/GameState.gd:2827` `if int(tier_counts[key]) >= 2:`
  - `scripts/GameState.gd:2830` `if not has_pair:`
  - `scripts/GameState.gd:2833` `_hook_additive_delta(ctx, "Wax Seal (x%d): +%d" % [copies, delta], delta)`
  - `scripts/GameState.gd:3088` `var choir_copies: int = relic_inventory["Choir Robes"]`
- **Code Touchpoints:**
  - `scripts/GameState.gd:448` in `(top-level)`
  - `scripts/GameState.gd:3087` in `_score_selected_internal`

## 160. Whetted Bone
- **Rarity:** `UNCOMMON`
- **Category:** `RELIC`
- **Stacks:** `No`
- **Description (Catalog):** BONE sacrifices contribute tier+2 instead of tierx2.
- **Hook Phase:** `-`
- **Hook Function:** `-`
- **Functionality In Code/In Game:** Evaluated inside core scoring pass
- **Exact Behavior (Code Rules):**
  - `scripts/GameState.gd:3095` `var gilded_offering_copies: int = int(relic_inventory.get("The Gilded Offering", 0))`
  - `scripts/GameState.gd:3263` `if whetted_bone_copies > 0:`
  - `scripts/GameState.gd:3285` `if whetted_bone_copies > 0:`
- **Code Touchpoints:**
  - `scripts/GameState.gd:3094` in `_score_selected_internal`
