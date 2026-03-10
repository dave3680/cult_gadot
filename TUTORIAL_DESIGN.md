# Cult of Accumulation - Tutorial Design

## Design Principles
1. Teach by doing, not by dumping text.
The player performs each core action (sacrifice, buy, assign nests, set focus) at least once with guided callouts.

2. Explain only what is on screen right now.
The tutorial never explains a system before the player can see and use it in the current scene.

3. Keep outcomes deterministic.
Hands, offers, recruit rolls, breeding results, and scripted prompts are fixed so lesson goals always land.

4. Build from additive to multiplicative to compounding.
Week 1 teaches base/additive and target. Week 2 introduces traits and multiplier logic. Weeks 3-4 teach compounding via relics and lineage.

5. Preserve the real game loop.
The player still plays real rounds and navigates real screens (battle -> shop -> nests -> battle), then exits tutorial after Week 4.

## Systems Introduction Order

| System | Introduced | Active/Passive | Deferred Post-Tutorial |
|---|---:|---|---|
| Core loop (Battle -> Shop -> Nest -> Battle) | Week 1 | Active | No |
| Top bar (week/round, target, blood, menu) | Week 1 | Passive | No |
| Relic drawer (current relics + tooltip) | Week 1 | Passive | No |
| Follower card anatomy (tier/type/trait/lineage badges) | Week 1 | Passive | No |
| Sacrifice interactions (drag/click select, altar, remove) | Week 1 | Active | No |
| Preview panel (base/additive/multiplier/total vs target) | Week 1 | Active | No |
| Confirm + breakdown + round resolution | Week 1 | Active | No |
| Type roles (BLOOD/BONE/VOID/SOUL) | Week 1 | Active | No |
| Doctrine action button (selected doctrine behavior) | Week 2 | Active | No |
| Trait tooltips and rarity tags | Week 2 | Active | No |
| Blood economy (earn/spend) | Week 1 | Active | No |
| Shop relic cards (rarity/category/cost/buy states) | Week 1 | Active | No |
| Recruit purchases | Week 1 | Active | No |
| Reroll button | Week 2 | Active | No |
| Ritual card row (locked/unlocked state) | Week 2 | Passive | No |
| Nest assignment (Parent A/B drag/drop, clear) | Week 1 | Active | No |
| Nest details modal | Week 2 | Active | No |
| Nest focus (Rarity/Tier/Family + blood cost) | Week 2 | Active | No |
| Breeding report screen and reveal sequence | Week 2 | Passive | No |
| Wild breeding results | Week 2 | Passive | No |
| Lineage badges and lineage preview row | Week 2 | Active | No |
| Black Contract / sacrifice count expansion | Week 3 | Active | No |
| Multi-trait followers and xN indicator | Week 3 | Active | No |
| Pool tab management basics (inspect only) | Week 3 | Passive | No |
| Codex progression/unlocks | Week 4 | Passive | Yes |
| Advanced pool actions (cull, favored A/B, ascend, apostle, rotary, relic pack) | Week 4 | Passive | Yes |
| Director's Cut and advanced economy relics | Week 4 | Passive | Yes |
| Rare edge-case relic interactions and cap exploits | Week 4 | Passive | Yes |

## Week-by-Week Script

### Week 1

**Preset pool at start of week:**
- #101 BLOOD T4 - Devout [C] - L0
- #102 BLOOD T5 - Twinborn [C] - L0
- #103 BLOOD T4 - Ember Saint [C] - L0
- #104 BONE T4 - Stalwart [C] - L0
- #105 BONE T5 - Ossuary Laborer [C] - L0
- #106 VOID T0 - Whispered [C] - L0
- #107 BLOOD T6 - High Chanter [C] - L0
- #108 BONE T3 - Pair Hunter [C] - L0
- #109 BLOOD T5 - Bone Tithe [C] - L0
- #110 BONE T4 - Devout [C] - L0
- #111 BLOOD T3 - No Trait - L0
- #112 VOID T0 - No Trait - L0

**Lesson goal:**
Understand core sacrifice flow: choose followers, preview devotion, hit target, and buy your first relic/recruit.

**Round 1 guided steps:**
1. [HIGHLIGHT: Top Bar / Target] - "This is your target devotion for the week. You need to reach it across this week's rounds."
2. [HIGHLIGHT: Follower Card] - "Each follower has a Type and Tier. Tier drives base value. Type changes how it contributes."
3. [HIGHLIGHT: Type Colors] - "BLOOD (red) adds tier. BONE (off-white) adds double tier. VOID builds multiplier. SOUL gives no devotion."
4. [HIGHLIGHT: Altar] - "Drag followers here to prepare a sacrifice."
5. [ACTION: Drag #107 BLOOD T6 to Altar] - "Start with a strong BLOOD follower."
6. [ACTION: Drag #104 BONE T4 to Altar] - "Add one BONE follower."
7. [ACTION: Drag #106 VOID T0 to Altar] - "Add one VOID to demonstrate multiplier."
8. [HIGHLIGHT: Preview Panel] - "Preview updates live. Base and additive are multiplied before final total."
9. [ACTION: Click Confirm Sacrifice] - "Resolve this play."
10. [RESULT: Breakdown] - "This is the detailed breakdown of where devotion came from."

**Round 2 (if applicable):**
1. [HIGHLIGHT: Week Progress Context] - "You are below this week's target. One more sacrifice should clear it."
2. [ACTION: Select 3 BLOOD-heavy cards] - "Use a simple BLOOD-focused play."
3. [RESULT: Week clears] - "Week success grants access to shop and breeding setup."

**Scripted shop offers:**
- Relics:
1. Bone Idol [UNCOMMON] - 20 Blood
2. Crimson Book [UNCOMMON] - 20 Blood
3. Tithe Discount [UNCOMMON, Voucher] - 20 Blood
- Recruits:
1. BLOOD T5 - Devout [C] - 1 Blood
2. BONE T4 - Stalwart [C] - 1 Blood
3. VOID T0 - Whispered [C] - 1 Blood

Why these offers:
- Bone Idol and Crimson Book teach additive scaling by type.
- Tithe Discount teaches voucher category and long-term economy.
- Recruits mirror the core type triangle so the player can patch weak pools.

**Breeding setup:**
- Nest 1:
Parent A: #101 BLOOD T4 Devout [C]
Parent B: #102 BLOOD T5 Twinborn [C]
Focus: NONE
Scripted offspring: BLOOD T5 Bloodbrand [C], lineage L1
- Nest 2:
Parent A: #104 BONE T4 Stalwart [C]
Parent B: #103 BLOOD T4 Ember Saint [C]
Focus: NONE
Scripted offspring: BONE T4 Stalwart [C], lineage L1
- Wild breeding scripted result:
1 newborn: BLOOD T4 Fervent [C], lineage L1

What this teaches:
- Nests consume parent assignment only for breeding logic, not immediate sacrifice.
- Offspring enters future pool and feeds back into scoring.
- Lineage starts at L1 from L0 parents.

**Week summary tooltip:**
"Week 1 complete: you learned sacrifice flow, target tracking, and first shop decisions. Next week introduces traits and multiplier planning."

### Week 2

**Preset pool at start of week:**
- #201 BLOOD T5 - Devout [C] - L0
- #202 BLOOD T6 - High Chanter [C] - L0
- #203 BONE T5 - Ossuary Laborer [C] - L0
- #204 VOID T0 - Whispered [C] - L0
- #205 BLOOD T5 - Ember Saint [C] - L0
- #206 BONE T4 - Pair Hunter [C] - L0
- #207 BLOOD T5 - Bloodbrand [C] - L1 (nest-born)
- #208 BONE T4 - Stalwart [C] - L1 (nest-born)
- #209 BLOOD T4 - Fervent [C] - L1 (wild-born)
- #210 BLOOD T4 - No Trait - L0
- #211 BONE T5 - No Trait - L0
- #212 VOID T0 - No Trait - L0
- #213 BLOOD T6 - Twinborn [C] - L0
- #214 BONE T3 - Bone Tithe [C] - L0

**Lesson goal:**
Understand trait effects, doctrine action, and lineage as a new multiplier axis.

**Round 1 guided steps:**
1. [HIGHLIGHT: Trait Badges + Tooltip] - "Hover cards to read exact trait effects. Traits can add devotion, blood, or multiplier power."
2. [HIGHLIGHT: Lineage Badge] - "L-values come from breeding. Higher total lineage in the altar gives a lineage multiplier."
3. [ACTION: Add one L1 follower to altar] - "Include a bred follower to activate lineage preview."
4. [HIGHLIGHT: Preview Lineage Row] - "Lineage appears only when total lineage points are above zero."
5. [ACTION: Confirm sacrifice] - "Resolve and review breakdown lines for trait and lineage entries."

**Round 2 (if applicable):**
1. [HIGHLIGHT: Doctrine Action Button] - "Doctrine is a once-per-play action. This tutorial run uses Path of Flesh."
2. [ACTION: Select one non-BLOOD follower, click Doctrine Action] - "Convert to BLOOD before sacrificing."
3. [RESULT: Card updates] - "The card type updates immediately; preview recalculates."
4. [ACTION: Confirm sacrifice] - "Clear Week 2."

**Scripted shop offers:**
- Relics:
1. Prayer Beads [UNCOMMON] - 20 Blood
2. Black Contract [UNCOMMON] - 20 Blood
3. Selective Breeding Scroll [COMMON] - 10 Blood
- Recruits:
1. BLOOD T6 - Straight Rite [R] - 1 Blood
2. BONE T5 - Ossuary King [R] - 1 Blood
3. VOID T0 - Void Herald [R] - 1 Blood

Why these offers:
- Prayer Beads teaches pattern-based additive bonuses.
- Black Contract sets up Week 3's 4-sacrifice lesson.
- Selective Breeding Scroll sets up nest focus value.

**Breeding setup:**
- Nest 1:
Parent A: #207 BLOOD T5 Bloodbrand [C] L1
Parent B: #209 BLOOD T4 Fervent [C] L1
Focus: TIER
Scripted offspring: BLOOD T6 Straight Rite [R], lineage L2
- Nest 2:
Parent A: #208 BONE T4 Stalwart [C] L1
Parent B: #204 VOID T0 Whispered [C] L0
Focus: RARITY
Scripted offspring: VOID T0 Void Herald [R], lineage L1
- Wild breeding scripted result:
1 newborn: BONE T5 Pair Hunter [C], lineage L1

What this teaches:
- Focus selection costs blood and changes expected outcomes.
- Lineage continues to climb through sustained breeding.

**Week summary tooltip:**
"Week 2 complete: traits and doctrine actions now shape each play, and bred lineages are starting to compound."

### Week 3

**Preset pool at start of week:**
- #301 BLOOD T6 - Straight Rite [R] - L2
- #302 VOID T0 - Void Herald [R] - L1
- #303 BONE T5 - Pair Hunter [C] - L1
- #304 BLOOD T6 - Devout [C] - L0
- #305 BLOOD T5 - Twinborn [C] - L0
- #306 BONE T6 - Ossuary King [R] - L0
- #307 BLOOD T5 - Prayer Beads synergy candidate - No Trait - L0
- #308 BONE T4 - No Trait - L0
- #309 VOID T0 - No Trait - L0
- #310 BLOOD T6 - Black Candlebearer [R] - L0
- #311 BLOOD T5 - Lineage Tutor [C] - L0
- #312 BONE T4 - Brood Keeper [C] - L0
- #313 BLOOD T4 - Devout [C] - L1
- #314 BONE T5 - Stalwart [C] - L1
- #315 BLOOD T7 - No Trait - L0

**Lesson goal:**
Use contract-expanded sacrifices and connect relic strategy to breeding outcomes.

**Round 1 guided steps:**
1. [HIGHLIGHT: Contract Toggle] - "Black Contract enables 4 sacrifices once per week."
2. [ACTION: Toggle Contract ON] - "Pit capacity increases from 3 to 4."
3. [ACTION: Add 4 followers] - "Build a larger play and watch counter update (4/4)."
4. [HIGHLIGHT: Preview] - "More sacrifices increase additive and can trigger more trait/relic conditions."
5. [ACTION: Confirm sacrifice] - "Resolve. Contract is now spent for this week."

**Round 2 (if applicable):**
1. [HIGHLIGHT: Relics button] - "Open Relics to review active effects before committing your second play."
2. [ACTION: Use a safer 3-sacrifice line] - "Finish Week 3 with a reliable clear."
3. [RESULT: Week clears] - "You now have enough context to plan compounding lines."

**Scripted shop offers:**
- Relics:
1. The Sanguine Chord [UNCOMMON] - 20 Blood
2. Fertility Idol [COMMON] - 10 Blood
3. Scarlet Planetarium [RARE, Consumable] - 30 Blood
- Recruits:
1. BLOOD T6 - Blood Prophet [R] - 1 Blood
2. BONE T6 - Ossuary Archon [R] - 1 Blood
3. BLOOD T5 - Devout [C] + Whispered [C] (x2 traits) - 1 Blood

Why these offers:
- The Sanguine Chord reinforces tier-straight multiplier-base logic.
- Fertility Idol improves wild breeding consistency.
- Scarlet Planetarium introduces ritual lane visibility for Week 4.
- A multi-trait recruit demonstrates badge slots and tooltip listing.

**Breeding setup:**
- Nest 1:
Parent A: #301 BLOOD T6 Straight Rite [R] L2
Parent B: #313 BLOOD T4 Devout [C] L1
Focus: FAMILY
Scripted offspring: BLOOD T7 Crimson Ascendant [L], lineage L2
- Nest 2:
Parent A: #314 BONE T5 Stalwart [C] L1
Parent B: #303 BONE T5 Pair Hunter [C] L1
Focus: TIER
Scripted offspring: BONE T6 Ossuary Archon [R], lineage L2
- Wild breeding scripted result:
2 newborns:
1. BLOOD T5 Devout [C], lineage L1
2. BONE T5 Bone Tithe [C], lineage L1

What this teaches:
- Focus + relic choices influence long-term pool quality.
- Multi-trait and higher-rarity offspring become realistic by mid-run.

**Week summary tooltip:**
"Week 3 complete: you used expanded sacrifice count and started planning around long-term compounding."

### Week 4

**Preset pool at start of week:**
- #401 BLOOD T7 - Crimson Ascendant [L] - L2
- #402 BONE T6 - Ossuary Archon [R] - L2
- #403 BLOOD T6 - Blood Prophet [R] - L0
- #404 VOID T0 - Void Herald [R] - L1
- #405 BLOOD T6 - Straight Rite [R] - L2
- #406 BONE T6 - Ossuary King [R] - L0
- #407 BLOOD T5 - Devout [C] + Whispered [C] - L0
- #408 BLOOD T5 - Devout [C] - L1
- #409 BONE T5 - Bone Tithe [C] - L1
- #410 BLOOD T6 - Twinborn [C] - L0
- #411 BONE T4 - Stalwart [C] - L0
- #412 VOID T0 - No Trait - L0
- #413 BLOOD T7 - No Trait - L0
- #414 BONE T6 - Pair Hunter [C] - L1
- #415 BLOOD T5 - Ember Saint [C] - L0
- #416 BONE T5 - Devout [C] - L1

**Lesson goal:**
Integrate everything: relic review, breeding-derived lineage, trait synergy, and final week planning.

**Round 1 guided steps:**
1. [HIGHLIGHT: Rituals (if unlocked)] - "Ritual cards are optional tactical boosts."
2. [HIGHLIGHT: Offspring cards in hand] - "These are bred followers from your prior nest decisions."
3. [ACTION: Build a line with at least one L2+ follower and one key trait] - "Use compounding pieces intentionally."
4. [RESULT: Preview and resolve] - "Observe how lineage and trait lines stack with relic lines."

**Round 2 (if applicable):**
1. [ACTION: Final clear play] - "Use your strongest remaining line to secure Week 4."
2. [RESULT: Tutorial completion panel] - "You have seen the full core loop and can start a normal run."

**Scripted shop offers:**
- Not shown.
Tutorial exits immediately after Week 4 clear (before Week 5 shop) to avoid over-teaching.

**Breeding setup:**
- Week 4 nest setup is still playable, but outcomes are informational only in tutorial end state.
- Scripted results (shown in completion summary):
1. Nest newborns: 2
2. Wild newborns: 1
3. Highest lineage reached: L3

What this teaches:
- Breeding decisions in one week directly power later battle scoring.
- Player should now understand compounding loop and where mastery lives.

**Week summary tooltip:**
"Tutorial complete: you learned sacrifice scoring, relic economy, trait and lineage scaling, and breeding loops. Start a full run to apply this."

## Callout and Tooltip Copy

**CALLOUT-001**  
Element: Top bar TARGET value  
Trigger: First load of Week 1 battle  
Text: "This is the week's target devotion. Reach it across this week's rounds."  
Dismiss: Click anywhere

**CALLOUT-002**  
Element: Week/Round label  
Trigger: After CALLOUT-001  
Text: "Week and Round are tracked here. Most weeks can take two rounds."  
Dismiss: Click anywhere

**CALLOUT-003**  
Element: Top-right row (Relics, Blood, Menu)  
Trigger: After CALLOUT-002  
Text: "Blood is your currency. Relics shows your current inventory. Menu pauses and exits."  
Dismiss: Click anywhere

**CALLOUT-004**  
Element: Follower card (any hand card)  
Trigger: After CALLOUT-003  
Text: "Follower anatomy: Tier at top, Type below, lineage and trait badges below. Hover for full trait text."  
Dismiss: Click anywhere

**CALLOUT-005**  
Element: Type label on card  
Trigger: After CALLOUT-004  
Text: "BLOOD adds tier, BONE adds double tier, VOID builds multiplier, SOUL gives no devotion."  
Dismiss: Click anywhere

**CALLOUT-006**  
Element: Altar drop zone  
Trigger: After CALLOUT-005  
Text: "Drag followers into the altar to stage a sacrifice."  
Dismiss: Auto after first successful drag

**CALLOUT-007**  
Element: Altar counter  
Trigger: First follower added to altar  
Text: "This counter shows selected sacrifices vs max allowed for this play."  
Dismiss: Auto after 2 seconds

**CALLOUT-008**  
Element: Preview panel  
Trigger: First follower added to altar  
Text: "Preview updates live. Use this before confirming."  
Dismiss: Click anywhere

**CALLOUT-009**  
Element: Confirm Sacrifice button  
Trigger: Altar contains 3 followers on Week 1 Round 1  
Text: "Confirm resolves this play and opens a full breakdown."  
Dismiss: Click Confirm

**CALLOUT-010**  
Element: Breakdown panel  
Trigger: First sacrifice confirmed  
Text: "Breakdown shows where every point came from: followers, doctrine, relics, traits, multiplier."  
Dismiss: Click Continue

**CALLOUT-011**  
Element: Doctrine Action button  
Trigger: Week 2 Round 2 start  
Text: "Doctrine action is once per play. In this tutorial: Path of Flesh converts one follower to BLOOD."  
Dismiss: Click anywhere

**CALLOUT-012**  
Element: Trait tooltip (hovered card)  
Trigger: First hover on a traited card in Week 2  
Text: "Traits add conditional effects. Read exact trigger text here."  
Dismiss: Auto on mouse exit

**CALLOUT-013**  
Element: Lineage badge on card  
Trigger: First L1+ follower visible in Week 2  
Text: "Lineage comes from breeding. Higher lineage contributes a separate final multiplier."  
Dismiss: Click anywhere

**CALLOUT-014**  
Element: Preview lineage row  
Trigger: Altar contains at least one lineage > 0 follower  
Text: "Lineage multiplier appears only when total lineage points are above zero."  
Dismiss: Auto after 2 seconds

**CALLOUT-015**  
Element: Shop relic row  
Trigger: Enter Week 1 shop  
Text: "These are relic offers. Rarity and category are shown at the top of each card."  
Dismiss: Click anywhere

**CALLOUT-016**  
Element: Relic card cost + buy button  
Trigger: After CALLOUT-015  
Text: "If you can afford it, Buy is enabled. Non-stackable relics become Owned."  
Dismiss: Click anywhere

**CALLOUT-017**  
Element: Recruit row  
Trigger: After CALLOUT-016  
Text: "Recruits are immediate followers added to your pool for future rounds."  
Dismiss: Click anywhere

**CALLOUT-018**  
Element: Reroll button  
Trigger: Week 2 shop  
Text: "Reroll replaces relic offers. Use it when offers do not match your plan."  
Dismiss: Click anywhere

**CALLOUT-019**  
Element: Ritual card panel  
Trigger: Week 2 shop  
Text: "Rituals are optional tactical cards. This panel is locked until Scarlet Planetarium is acquired."  
Dismiss: Click anywhere

**CALLOUT-020**  
Element: Continue to Breeding button (shop bottom)  
Trigger: Before leaving shop for first time  
Text: "Continue moves to nest assignment. Breeding is where long-term scaling comes from."  
Dismiss: Click Continue

**CALLOUT-021**  
Element: Nest panel Parent A slot  
Trigger: First load of Nest Select  
Text: "Drop one parent into Parent A."  
Dismiss: Auto on first assignment

**CALLOUT-022**  
Element: Nest panel Parent B slot  
Trigger: Parent A assigned in same nest  
Text: "Now assign Parent B. Two parents are required for breeding."  
Dismiss: Auto on first assignment

**CALLOUT-023**  
Element: Nest status line  
Trigger: Both parents assigned  
Text: "Status confirms whether this nest can breed this week."  
Dismiss: Auto after 2 seconds

**CALLOUT-024**  
Element: Details button  
Trigger: After first complete nest assignment  
Text: "Open Details to set breeding focus and inspect predicted outcomes."  
Dismiss: Click Details

**CALLOUT-025**  
Element: Focus options (Rarity/Tier/Family)  
Trigger: Details modal open first time  
Text: "Focus changes breeding bias. It costs Blood and is paid when continuing to battle."  
Dismiss: Click anywhere

**CALLOUT-026**  
Element: Predicted Lineage row  
Trigger: Details modal with both parents set  
Text: "Predicted lineage shows expected offspring lineage from current parent pair and focus."  
Dismiss: Click anywhere

**CALLOUT-027**  
Element: Continue to Battle button  
Trigger: Nest Select first completion  
Text: "Continuing commits focus costs and starts the next battle week."  
Dismiss: Click Continue

**CALLOUT-028**  
Element: Breeding Report nest section  
Trigger: First Breeding Report appearance (post Week 2 battle)  
Text: "This report shows each nest's parents and resulting offspring for the week."  
Dismiss: Click anywhere

**CALLOUT-029**  
Element: Offspring card NEW badge  
Trigger: Same as CALLOUT-028  
Text: "NEW marks newborn followers added to your pool."  
Dismiss: Click anywhere

**CALLOUT-030**  
Element: Wild Breeding section  
Trigger: Breeding Report visible  
Text: "Wild breeding runs separately from nests and can add extra newborns."  
Dismiss: Click anywhere

**CALLOUT-031**  
Element: Breeding summary line  
Trigger: Breeding Report visible  
Text: "Summary tracks pool growth and trimmed followers for this week."  
Dismiss: Click anywhere

**CALLOUT-032**  
Element: Contract toggle  
Trigger: Week 3 battle start  
Text: "Black Contract lets you run a 4-sacrifice play once this week."  
Dismiss: Click Toggle

**CALLOUT-033**  
Element: Pit counter after contract toggle  
Trigger: Contract ON  
Text: "Counter now expects 4 max. This changes your play construction."  
Dismiss: Auto after 2 seconds

**CALLOUT-034**  
Element: Relics drawer button  
Trigger: Week 3 Round 2 start  
Text: "Review active relics before committing your line."  
Dismiss: Click anywhere

**CALLOUT-035**  
Element: Multi-trait badge xN  
Trigger: First multi-trait card visible (Week 3 shop/recruits or Week 4 hand)  
Text: "xN means this follower has multiple trait IDs. Hover to inspect all of them."  
Dismiss: Click anywhere

**CALLOUT-036**  
Element: Ritual button in battle context panel  
Trigger: Week 4 battle start with ritual unlocked  
Text: "Rituals are optional one-use tactical effects for the current play."  
Dismiss: Click anywhere

**CALLOUT-037**  
Element: Week 4 completion panel  
Trigger: Week 4 clear  
Text: "Tutorial complete. You now understand the full core loop and compounding systems."  
Dismiss: Click Continue

## Scripted Outcome Table

| Week | Round | Pool preset | Shop offers | Scripted offspring | Target | Expected score |
|---:|---:|---|---|---|---:|---:|
| 1 | 1 | Week 1 preset list (12 followers, all L0) | Week 1 shop set | N/A this round | 40 | 31 |
| 1 | 2 | Post-round-1 pool (deterministic survivors) | Week 1 shop set | N/A this round | 40 | 34 (week total 65) |
| 2 | 1 | Week 2 preset list (includes 3 L1 offspring) | Week 2 shop set | N/A this round | 55 | 46 |
| 2 | 2 | Deterministic hand + doctrine action enabled | Week 2 shop set | N/A this round | 55 | 44 (week total 90) |
| 3 | 1 | Week 3 preset list (includes L2 line) | Week 3 shop set | N/A this round | 75 | 58 |
| 3 | 2 | Contract spent, normal 3-sacrifice round | Week 3 shop set | N/A this round | 75 | 86 (week total 144) |
| 4 | 1 | Week 4 preset list (includes legendary L2 offspring) | Tutorial ends before Week 5 shop | N/A this round | 105 | 74 |
| 4 | 2 | Deterministic final hand | Tutorial ends before Week 5 shop | Week 4 breeding summary scripted in completion panel | 105 | 132 (week total 206) |

Notes:
- Week total cap (`week_devotion_cap_mult`) is 2.0x target in run config; scripted totals stay under cap.
- Breeding outcomes are deterministic and injected at week transitions.

## Implementation Notes

### 1) Add tutorial mode state in GameState
- Add fields:
  - `tutorial_mode: bool = false`
  - `tutorial_step: int = 0`
  - `tutorial_week: int = 1`
  - `tutorial_script: Dictionary` (all fixed hands/offers/recruits/nest outcomes/callouts)
  - `tutorial_completed: bool = false`
- Add helpers:
  - `start_tutorial_run()`
  - `is_tutorial_active()`
  - `tutorial_get_week_script(week: int) -> Dictionary`
  - `tutorial_advance_step(step_id: String)`
  - `end_tutorial_run()`

### 2) Entry point from menu
- Main menu:
  - Add `Tutorial` button in `scenes/MainMenu.tscn`.
  - Wire in `scripts/MainMenu.gd` to call `gs.start_tutorial_run()` then load `RunGame.tscn`.
- Keep current Start Run -> DoctrineSelect unchanged for normal play.

### 3) Override randomness with scripted data
- Battle hand draw:
  - In `GameState.draw_hand_from_pool()`, if tutorial active, pull from tutorial hand list for `(week, round)` instead of shuffling pool.
- Shop relic offers:
  - In `Shop._setup_offers()`, if tutorial active, use scripted relic offer array, do not call `_roll_offers`.
- Shop recruits:
  - In `GameState.generate_shop_recruits()`, if tutorial active, use scripted recruits.
- Breeding outcomes:
  - In `GameState.resolve_nest_breeding()` and `resolve_wild_breeding()`, if tutorial active, return scripted newborn results for current week.
  - Preserve normal path when not tutorial.

### 4) Tutorial callout system
- Add reusable overlay scene:
  - `scenes/TutorialOverlay.tscn`
  - `scripts/TutorialOverlay.gd`
- Behavior:
  - Dim whole screen.
  - Highlight target control by NodePath.
  - Show tooltip box with title/body and optional next-action requirement.
  - Block non-highlight interaction unless step allows free interaction.
- Triggering:
  - Each gameplay scene (`RunGame`, `Shop`, `NestSelect`, `Breeding`) checks tutorial mode on `_ready()`.
  - Scene asks GameState for next tutorial step for its scene.
  - Steps advance on explicit events (button pressed, follower dropped, purchase success, etc.).

### 5) Step completion checks (event-driven)
- RunGame:
  - Altar count changed.
  - Confirm pressed.
  - Doctrine action used.
  - Contract toggled.
- Shop:
  - Relic purchase success.
  - Recruit purchase success.
  - Reroll pressed (if required by week script).
- NestSelect:
  - Slot A/B assigned.
  - Focus set in details modal.
  - Continue to Battle pressed.
- Breeding:
  - Continue pressed after required passive callouts.

### 6) Keep real game logic live
- Do not bypass scoring.
- The tutorial still uses `score_selected` and real resolve paths.
- Only data generation randomness is replaced with deterministic scripted inputs.

### 7) Transition out of tutorial
- After Week 4 clear:
  - Show completion panel with two choices:
1. `Start Real Run` -> `gs.end_tutorial_run(); change_scene(DoctrineSelect.tscn)`
2. `Return to Menu` -> `gs.end_tutorial_run(); change_scene(MainMenu.tscn)`
- Do not transition into Week 5 shop in tutorial mode.

### 8) Save/load behavior
- `tutorial_mode` should not persist into normal save state.
- If saving during tutorial is supported, store tutorial step and deterministic state snapshot.
- On tutorial abort (main menu), clear tutorial state.

## What the Tutorial Does NOT Teach
- Full relic catalog mastery.
Reason: too many relic-specific edge cases; teach reading card text and planning instead.

- Codex completion and unlock tracking.
Reason: meta-progression, not required for first successful run.

- Advanced pool actions (Rotary swap, relic pack draft, apostle micromanagement, Great Cull, Palimpsest).
Reason: high-complexity optional systems better learned after core loop is internalized.

- Rare cap-exception interactions and degenerate builds.
Reason: these are expert-level optimization layers.

- Doctrine-specific deep optimization across all 3 doctrines.
Reason: tutorial run is fixed and deterministic; players should choose a doctrine in live play to explore depth.
