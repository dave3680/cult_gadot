extends Node

const TRAITS := ["BLOOD", "BONE", "VOID", "SOUL"]
const TRAIT_REGISTRY := {
	"devout": {"name": "Devout", "rarity": "COMMON", "type": "ADDITIVE", "desc": "When sacrificed, +2 additive."},
	"stalwart": {"name": "Stalwart", "rarity": "COMMON", "type": "ADDITIVE", "desc": "If this is BONE, +4 additive."},
	"fervent": {"name": "Fervent", "rarity": "COMMON", "type": "ECONOMY", "desc": "If exactly 3 are sacrificed, +2 Blood."},
	"twinborn": {"name": "Twinborn", "rarity": "COMMON", "type": "ADDITIVE", "desc": "If another sacrifice shares tier, +5 additive."},
	"whispered": {"name": "Whispered", "rarity": "COMMON", "type": "MULTIPLIER", "desc": "If exactly 1 VOID, multiplier base +1."},
	"resilient": {"name": "Resilient", "rarity": "COMMON", "type": "POOL", "desc": "When sacrificed, 35% chance to return to pool."},
	"blood_oathling": {"name": "Blood Oathling", "rarity": "COMMON", "type": "ADDITIVE", "desc": "If this is BLOOD and another BLOOD is sacrificed, +5 additive."},
	"void_spark": {"name": "Void Spark", "rarity": "COMMON", "type": "ECONOMY", "desc": "If this is VOID and exactly 2 VOID are sacrificed, +2 Blood."},
	"high_chanter": {"name": "High Chanter", "rarity": "COMMON", "type": "ADDITIVE", "desc": "If this has highest tier among sacrifices, +5 additive."},
	"low_chanter": {"name": "Low Chanter", "rarity": "COMMON", "type": "ADDITIVE", "desc": "If this has lowest tier among sacrifices, +4 additive."},
	"bloodbrand": {"name": "Bloodbrand", "rarity": "COMMON", "type": "ADDITIVE", "desc": "If this is BLOOD and 2+ BLOOD are sacrificed, +7 additive."},
	"ossuary_laborer": {"name": "Ossuary Laborer", "rarity": "COMMON", "type": "ADDITIVE", "desc": "If this is BONE and 2+ BONE are sacrificed, +7 additive."},
	"void_entrant": {"name": "Void Entrant", "rarity": "COMMON", "type": "HYBRID", "desc": "If this is VOID and exactly 1 VOID is sacrificed, +6 additive and +1 Blood."},
	"triune_acolyte": {"name": "Triune Acolyte", "rarity": "COMMON", "type": "ADDITIVE", "desc": "If BLOOD+BONE+VOID are sacrificed, +10 additive."},
	"zealot_ledger": {"name": "Zealot Ledger", "rarity": "COMMON", "type": "ECONOMY", "desc": "If exactly 3 are sacrificed, +2 Blood."},
	"bone_tithe": {"name": "Bone Tithe", "rarity": "COMMON", "type": "ECONOMY", "desc": "If 2+ BONE are sacrificed, +2 Blood."},
	"pair_hunter": {"name": "Pair Hunter", "rarity": "COMMON", "type": "ADDITIVE", "desc": "If any two sacrifices share tier, +6 additive."},
	"apex_rite": {"name": "Apex Rite", "rarity": "COMMON", "type": "ADDITIVE", "desc": "If this has highest tier among sacrifices, +6 additive."},
	"abyss_rite": {"name": "Abyss Rite", "rarity": "COMMON", "type": "ADDITIVE", "desc": "If this has lowest tier among sacrifices, +5 additive."},
	"rite_channeler": {"name": "Rite Channeler", "rarity": "COMMON", "type": "ADDITIVE", "desc": "If exactly 3 are sacrificed and 0 VOID are sacrificed, +8 additive."},
	"ember_saint": {"name": "Ember Saint", "rarity": "COMMON", "type": "ADDITIVE", "desc": "If this is BLOOD and tier >= 4, +6 additive."},
	"marrow_mason": {"name": "Marrow Mason", "rarity": "COMMON", "type": "ADDITIVE", "desc": "If this is BONE and tier >= 4, +8 additive."},
	"blood_prophet": {"name": "Blood Prophet", "rarity": "RARE", "type": "MULTIPLIER", "desc": "If all 3 are BLOOD, exponent +1."},
	"straight_rite": {"name": "Straight Rite", "rarity": "RARE", "type": "MULTIPLIER", "desc": "If sacrificed tiers are consecutive, multiplier base +2."},
	"ossuary_king": {"name": "Ossuary King", "rarity": "RARE", "type": "ADDITIVE", "desc": "If 2+ BONE, +18 additive."},
	"gravetide": {"name": "Gravetide", "rarity": "RARE", "type": "POOL", "desc": "When sacrificed, add a T1 BONE to pool."},
	"void_herald": {"name": "Void Herald", "rarity": "RARE", "type": "MULTIPLIER", "desc": "If exactly 1 VOID, multiplier base +2."},
	"black_candlebearer": {"name": "Black Candlebearer", "rarity": "RARE", "type": "MULTIPLIER", "desc": "If 0 VOID, multiplier base at least 2."},
	"martyrs_ledger": {"name": "Martyr's Ledger", "rarity": "RARE", "type": "ECONOMY", "desc": "When sacrificed, +3 Blood."},
	"chosen_veil": {"name": "Veiled Bloodline", "rarity": "COMMON", "type": "HYBRID", "desc": "When sacrificed, +4 additive. If parent in nest, offspring rarity is pushed upward (at least RARE for mixed pairs)."},
	"sanguine_conductor": {"name": "Sanguine Conductor", "rarity": "RARE", "type": "ADDITIVE", "desc": "If this is BLOOD and 2+ BLOOD are sacrificed, +16 additive."},
	"ossuary_archon": {"name": "Ossuary Archon", "rarity": "RARE", "type": "ADDITIVE", "desc": "If this is BONE and 2+ BONE are sacrificed, +20 additive."},
	"hush_matron": {"name": "Hush Matron", "rarity": "RARE", "type": "HYBRID", "desc": "If this is VOID and exactly 1 VOID is sacrificed, +12 additive and +2 Blood."},
	"paired_sigil": {"name": "Paired Sigil", "rarity": "RARE", "type": "ADDITIVE", "desc": "If this has a same-tier partner, double this follower's base contribution and +4 additive."},
	"votive_executor": {"name": "Votive Executor", "rarity": "RARE", "type": "HYBRID", "desc": "If highest-tier sacrifice is BONE and this follower is BONE, +14 additive and +2 Blood."},
	"sanguine_overseer": {"name": "Sanguine Overseer", "rarity": "RARE", "type": "ADDITIVE", "desc": "If this is BLOOD and 3+ BLOOD are sacrificed, +24 additive."},
	"ossuary_overseer": {"name": "Ossuary Overseer", "rarity": "RARE", "type": "ADDITIVE", "desc": "If this is BONE and 3+ BONE are sacrificed with 0 VOID, +28 additive."},
	"hush_executor": {"name": "Hush Executor", "rarity": "RARE", "type": "HYBRID", "desc": "If this is VOID and exactly 1 VOID is sacrificed, +14 additive, +2 Blood, and multiplier base +1."},
	"triune_champion": {"name": "Triune Champion", "rarity": "RARE", "type": "MULTIPLIER", "desc": "If BLOOD+BONE+VOID are sacrificed and this follower is present, final devotion x1.25 once per play."},
	"grave_banker": {"name": "Grave Banker", "rarity": "RARE", "type": "POOL", "desc": "When sacrificed, spawn a T1 BONE and gain +3 Blood."},
	"brood_sovereign": {"name": "Brood Sovereign", "rarity": "RARE", "type": "BREEDING", "desc": "When sacrificed, +8 additive and +2 Blood. If parent in nest, newborn gets +1 tier and better rarity odds."},
	"brood_keeper": {"name": "Brood Keeper", "rarity": "COMMON", "type": "BREEDING", "desc": "When sacrificed, +6 additive. If parent in nest, newborn gets +1 tier."},
	"lineage_tutor": {"name": "Lineage Tutor", "rarity": "COMMON", "type": "BREEDING", "desc": "When sacrificed, +4 additive and +2 Blood. If parent in nest, +35% rarity-up chance for offspring traits."},
	"crimson_ascendant": {"name": "Crimson Ascendant", "rarity": "LEGENDARY", "type": "HYBRID", "desc": "If this is BLOOD and all 3 are BLOOD, multiplier base +2 and +3 Blood."},
	"ossuary_oracle": {"name": "Ossuary Oracle", "rarity": "LEGENDARY", "type": "ADDITIVE", "desc": "If this is BONE, with 2+ BONE and 0 VOID, +24 additive."},
	"void_crown": {"name": "Void Crown", "rarity": "LEGENDARY", "type": "HYBRID", "desc": "If this is VOID and exactly 1 VOID is sacrificed, +10 additive and multiplier base +2."},
	"apostolic_womb": {"name": "Apostolic Womb", "rarity": "LEGENDARY", "type": "BREEDING", "desc": "When sacrificed, +12 additive and +2 Blood. If parent in nest, newborn inherits a parent trait and gets +2 tier."},
	"triune_heir": {"name": "Triune Heir", "rarity": "LEGENDARY", "type": "MULTIPLIER", "desc": "If BLOOD+BONE+VOID are sacrificed and this follower is present, final devotion x1.35 once per play."},
	"crimson_revelation": {"name": "Crimson Revelation", "rarity": "LEGENDARY", "type": "HYBRID", "desc": "If this is BLOOD and all 3 are BLOOD, exponent +2 and +4 Blood."},
	"ossuary_titan": {"name": "Ossuary Titan", "rarity": "LEGENDARY", "type": "ADDITIVE", "desc": "If this is BONE and 3+ BONE are sacrificed with 0 VOID, +36 additive."},
}
const COMMON_TRAIT_IDS := ["devout", "stalwart", "fervent", "twinborn", "whispered", "resilient", "blood_oathling", "void_spark", "high_chanter", "low_chanter", "bloodbrand", "ossuary_laborer", "void_entrant", "triune_acolyte", "zealot_ledger", "bone_tithe", "pair_hunter", "apex_rite", "abyss_rite", "rite_channeler", "ember_saint", "marrow_mason", "chosen_veil", "brood_keeper", "lineage_tutor"]
const RARE_TRAIT_IDS := ["blood_prophet", "straight_rite", "ossuary_king", "gravetide", "void_herald", "black_candlebearer", "martyrs_ledger", "sanguine_conductor", "ossuary_archon", "hush_matron", "paired_sigil", "votive_executor", "sanguine_overseer", "ossuary_overseer", "hush_executor", "triune_champion", "grave_banker", "brood_sovereign"]
const LEGENDARY_TRAIT_IDS := ["crimson_ascendant", "ossuary_oracle", "void_crown", "apostolic_womb", "triune_heir", "crimson_revelation", "ossuary_titan"]
const STARTING_COMMON_TRAIT_CHANCE := 0.72
const STARTING_RARE_TRAIT_CHANCE := 0.16
const STARTING_LEGENDARY_TRAIT_CHANCE := 0.02
const SHOP_COMMON_TRAIT_CHANCE := 0.60
const SHOP_RARE_TRAIT_CHANCE := 0.16
const SHOP_LEGENDARY_TRAIT_CHANCE := 0.04
const BREEDING_ANY_TRAIT_CHANCE := 0.80
const BREEDING_COMMON_CHANCE := 0.70
const BREEDING_RARE_CHANCE := 0.22
const BREEDING_PRIMARY_MUTATION_CHANCE := 0.10
const NEST_LEGENDARY_TO_RARE_CHANCE := 0.65
const NEST_SINGLE_RARE_TO_RARE_CHANCE := 0.55
const MULTIPLIER_TRAIT_CAP := 2
const LINEAGE_MULT_PER_POINT := 0.04
const LINEAGE_MULT_CAP := 2.5
const POOL_CAP := 1000
const STARTING_NESTS := 2
const NEST_FOCUS_NONE := "NONE"
const NEST_FOCUS_RARITY := "RARITY"
const NEST_FOCUS_TIER := "TIER"
const NEST_FOCUS_FAMILY := "FAMILY"
const CODEX_SAVE_PATH := "user://codex_data.json"
const CODEX_VERSION := 1
const RUN_CONFIG_DEFAULT := {
	"max_weeks": 10,
	"target_base": 40,
	"target_growth": 1.38,
	"overflow_devotion_per_blood": 1,
	"overflow_blood_per_devotion": 1,
	"overflow_cap_target_mult": 0.5,
	"early_win_bonus": 20,
	"round_devotion_cap_mult": 0.0,
	"week_devotion_cap_mult": 2.0,
	"week_target_overrides": {8: 400, 9: 620, 10: 1000},
}
const MAX_TIER := 10
const SHOP_RARE_BASE := 0.15
const SHOP_RARE_PER_WEEK := 0.02
const SHOP_RARE_MAX := 0.30
const SHOP_LEGENDARY_BASE := 0.02
const SHOP_LEGENDARY_PER_WEEK := 0.01
const SHOP_LEGENDARY_MAX := 0.08
const SHOP_UNCOMMON_CHANCE := 0.35
const TIER_WEIGHTS := {
	1: 1,
	2: 2,
	3: 3,
	4: 4,
	5: 6,
	6: 4,
	7: 3,
	8: 2,
	9: 1,
	10: 1,
}
const RITUAL_CARDS := ["Anoint", "Silence", "Rebirth"]
const RELICS := [
	"Ritual Knife",
	"Bone Idol",
	"Crimson Book",
	"Hollow Chant",
	"Sacrificial Order",
	"Ceremonial Cup",
	"Blood Abacus",
	"Quick Chant",
	"Thin Blade",
	"Tithe Discount",
	"Ossuary Standard",
	"Bone Polisher",
	"Ritual Symmetry",
	"Calcify",
	"Crimson Interest",
	"Void Prism",
	"Black Candle",
	"The Third Knife",
	"Balanced Offering",
	"Blasphemous Geometry",
	"Brass Tithe Bowl",
	"Sharpened Chalk",
	"Prayer Beads",
	"Bone Saw",
	"Red Thread",
	"Cold Incense",
	"Grave Ledger",
	"Culling Knife",
	"Wax Seal",
	"Salt Circle",
	"Spare Chalice",
	"Choir Robes",
	"Blood Market Stall",
	"Ossuary Standards",
	"Hollow Abacus",
	"Debt Scripture",
	"Votive Mirror",
	"Fertility Idol",
	"Selective Breeding Scroll",
	"Triune Reliquary",
	"Bloodright Almanac",
	"Clean Hands",
	"Ectoplasm Jar",
	"Black Contract",
	"Omen Deck",
	"Director's Cut",
	"Scarlet Planetarium",
	"Seal of Inheritance",
	"The Soul Lantern",
	"First Apostle",
	"Iron Reliquary",
	"Ivory Throne",
	"Ascendant Mark",
	"Whetted Bone",
	"The Summit",
	"Bloodline Register",
	"The Peaked Rite",
	"Apex Covenant",
	"The Gilded Offering",
	"Dynasty Seal",
	"Crown of Tiers",
	"The Last Rung",
	"Void Cradle",
	"The Hollow Register",
	"Void Pilgrim",
	"The Empty Pyre",
	"Refinery of Silence",
	"Obsidian Conduit",
	"The Absent Crown",
	"Void Recursion",
	"Null Covenant",
	"The Final Silence",
	"Annihilation Compact",
	"The Deepest Void",
	"Marrow Charter",
	"The Ossuary Engine",
	"Bone Standard",
	"The White Wall",
	"Gravewright",
	"Crypt Standard",
	"The Calcified Gate",
	"Bone Chorus",
	"The Skeleton Archive",
	"Ossuary Absolute",
	"The Red Tithe",
	"Crimson Ledger",
	"The Sanguine Chord",
	"Bloodfire Compact",
	"The Running Red",
	"Crimson Pact",
	"The Arterial Rite",
	"Bloodline Theorem",
	"The Sanguine Engine",
	"Crimson Absolute",
	"The Concordat",
	"Trine Offering",
	"Threefold Brand",
	"The Sacred Triangle",
	"Covenant of Three",
	"The Unbroken Rite",
	"The Trinity Engine",
	"The Absolute Trinity",
	"The Pruning Hook",
	"Grave Compact",
	"The Awakening Bell",
	"The Deep Pool",
	"Warden of the Fold",
	"The Rotary",
	"The Inheritance Forge",
	"Soul Tithe",
	"The Purifying Flame",
	"The Great Cull",
	"The Copper Tithe",
	"Debt Ledger",
	"The Red Market",
	"Crimson Compound",
	"The Iron Tithe",
	"The Debt Engine",
	"Usurer's Mark",
	"The Sanguine Bank",
	"The Tithe Accelerator",
	"The Compound Covenant",
	"Single Rite",
	"The Pared Offering",
	"The Dyad Mark",
	"The Triad Compact",
	"The Foursome",
	"Minimalist Doctrine",
	"Mass Offering",
	"The Expanding Rite",
	"The Count Absolute",
	"The Expanding Contract",
	"The Brood Compact",
	"Nursery Ledger",
	"The Generation Mark",
	"The Breeding Engine",
	"Lineage Harvest",
	"The Primogeniture",
	"The Bloodline Compact",
	"The Dynasty Forge",
	"The Womb of Ages",
	"The Eternal Line",
	"The Bleeding Edge",
	"The Rusted Tithe",
	"The Cursed Offering",
	"The Hollow Pact",
	"The Red Covenant",
	"The Last Sacrifice",
	"The Hungry Altar",
	"The Damnation Seal",
	"The Second Sight",
	"The Waiting Bell",
	"The Faithful Scribe",
	"The Votive Ledger",
	"The Drawn Curtain",
	"The Witness",
	"Director's Addendum",
	"The Omen Ledger",
	"The Palimpsest",
	"The Archive Key",
]

const RELIC_DEFS := {
	"Ritual Knife": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "The first follower you choose each week counts as double tier."},
	"Bone Idol": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "BONE followers are worth more."},
	"Crimson Book": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "Each BLOOD sacrifice adds a small bonus."},
	"Hollow Chant": {"rarity": "RARE", "stacks": true, "category": "RELIC", "desc": "Each copy adds +1 to multiplier exponent (unconditional)."},
	"Sacrificial Order": {"rarity": "LEGENDARY", "stacks": true, "category": "RELIC", "desc": "Exactly 3 sacrifices? Big devotion bonus."},
	"Ceremonial Cup": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "On a win, gain extra Blood before the shop."},
	"Blood Abacus": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "BLOOD sacrifices give extra Blood currency (does not change devotion)."},
	"Quick Chant": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "Any sacrifice grants a small devotion boost."},
	"Thin Blade": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "Sacrifice just 1? Gain a big devotion boost."},
	"Tithe Discount": {"rarity": "UNCOMMON", "stacks": false, "category": "VOUCHER", "desc": "Relics cost 1 less Blood (min 2)."},
	"Ossuary Standard": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "Sacrifice at least 2 BONE to gain bonus devotion."},
	"Bone Polisher": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "Your strongest BONE adds extra devotion."},
	"Ritual Symmetry": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "Even-numbered sacrifices gain bonus devotion."},
	"Calcify": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "Each BONE sacrifice adds extra devotion."},
	"Crimson Interest": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "After the shop, earn bonus Blood based on your stash."},
	"Void Prism": {"rarity": "LEGENDARY", "stacks": true, "category": "RELIC", "desc": "VOID sacrifices count as extra for your multiplier."},
	"Black Candle": {"rarity": "LEGENDARY", "stacks": false, "category": "RELIC", "desc": "Your multiplier never starts below 2."},
	"The Third Knife": {"rarity": "LEGENDARY", "stacks": false, "category": "RELIC", "desc": "The first three followers you choose each week count as double tier."},
	"Balanced Offering": {"rarity": "RARE", "stacks": true, "category": "RELIC", "desc": "If you offer BLOOD, BONE, and VOID, devotion is doubled."},
	"Blasphemous Geometry": {"rarity": "RARE", "stacks": true, "category": "RELIC", "desc": "On a win, gain a large Blood bonus before the shop."},
	"Brass Tithe Bowl": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "On week success, gain +1 Blood per copy."},
	"Sharpened Chalk": {"rarity": "UNCOMMON", "stacks": false, "category": "VOUCHER", "desc": "First relic reroll each shop costs 0."},
	"Prayer Beads": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "If all 3 sacrifices share a main trait, +6 additive per copy."},
	"Bone Saw": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "If 2+ BONE are sacrificed, gain +1 Blood per copy."},
	"Red Thread": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "If 3 BLOOD are sacrificed, random BLOOD in pool +1 tier per copy."},
	"Cold Incense": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "If 0 VOID, multiplier base at least 2 once per week."},
	"Grave Ledger": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "First recruit you buy each shop gets +1 tier per copy (cap 4)."},
	"Culling Knife": {"rarity": "COMMON", "stacks": false, "category": "RELIC", "desc": "Once per shop, cull a follower from the pool for free."},
	"Wax Seal": {"rarity": "RARE", "stacks": true, "category": "RELIC", "desc": "If any pair of equal tiers, +8 additive per copy."},
	"Salt Circle": {"rarity": "COMMON", "stacks": true, "category": "VOUCHER", "desc": "Increase pool cap by +4 per copy."},
	"Spare Chalice": {"rarity": "COMMON", "stacks": false, "category": "RELIC", "desc": "If you enter shop with 0 Blood, gain +2 Blood."},
	"Choir Robes": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "If all 3 sacrifices have different tiers, +5 additive per copy."},
	"Blood Market Stall": {"rarity": "COMMON", "stacks": false, "category": "RELIC", "desc": "Shop recruit offers become 4 instead of 3."},
	"Ossuary Standards": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "Every BONE offered in victory is remembered."},
	"Hollow Abacus": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "If exactly 1 VOID is sacrificed, exponent +1 per copy."},
	"Debt Scripture": {"rarity": "COMMON", "stacks": false, "category": "VOUCHER", "desc": "You may buy relics up to 2 Blood short; debt is repaid from gains."},
	"Votive Mirror": {"rarity": "COMMON", "stacks": false, "category": "RELIC", "desc": "Once per shop, buy one recruit offer twice."},
	"Fertility Idol": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "Wild breeding chance +10% per copy for couples with no VOID."},
	"Selective Breeding Scroll": {"rarity": "COMMON", "stacks": false, "category": "RELIC", "desc": "Nest offspring rarity-up chance +15%."},
	"Triune Reliquary": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "If sacrifices include BLOOD+BONE+VOID, +12 additive per copy."},
	"Bloodright Almanac": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "If Blood Straight triggers, +10 additive and +2 Blood per copy."},
	"Clean Hands": {"rarity": "COMMON", "stacks": false, "category": "RELIC", "desc": "If you clear a week with 0 VOID, gain 1 free relic reroll next shop."},
	"Ectoplasm Jar": {"rarity": "LEGENDARY", "stacks": true, "category": "VOUCHER", "desc": "+1 multiplier exponent per copy; pool cap -6 per copy."},
	"Black Contract": {"rarity": "UNCOMMON", "stacks": false, "category": "RELIC", "desc": "Once per week, you may sacrifice 4 instead of 3."},
	"Omen Deck": {"rarity": "RARE", "stacks": true, "category": "RELIC", "desc": "Recruits have +10% per copy chance to spawn with a RARE trait."},
	"Director's Cut": {"rarity": "RARE", "stacks": false, "category": "VOUCHER", "desc": "Once per week in shop, reroll next week target within +/-15%."},
	"Scarlet Planetarium": {"rarity": "RARE", "stacks": false, "category": "CONSUMABLE", "desc": "Adds a Ritual Card slot; shop offers 1 Ritual Card."},
	"Seal of Inheritance": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "If either parent has a trait, newborn inherits one parent trait (nest and wild)."},
	"The Soul Lantern": {"rarity": "LEGENDARY", "stacks": false, "category": "RELIC", "desc": "Once per run: ascend a pool follower to VOID (tier becomes 0). Drains all blood to 0."},
	"First Apostle": {"rarity": "LEGENDARY", "stacks": false, "category": "RELIC", "desc": "Choose a follower as Apostle; it shapes breeding outcomes."},
	"Iron Reliquary": {"rarity": "COMMON", "stacks": false, "category": "RELIC", "desc": "If highest-tier sacrifice is tier 8+, +20 additive."},
	"Ivory Throne": {"rarity": "COMMON", "stacks": false, "category": "RELIC", "desc": "Each sacrifice above tier 7: +5 additive per tier above 7."},
	"Ascendant Mark": {"rarity": "UNCOMMON", "stacks": false, "category": "RELIC", "desc": "If all 3 sacrifices are same type and all tier 6+, +25 additive."},
	"Whetted Bone": {"rarity": "UNCOMMON", "stacks": false, "category": "RELIC", "desc": "BONE sacrifices contribute tier+2 instead of tierx2."},
	"The Summit": {"rarity": "UNCOMMON", "stacks": false, "category": "RELIC", "desc": "If highest-tier sacrifice is above last round's highest, +15 additive."},
	"Bloodline Register": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "When a pool follower reaches tier 10, gain +1 Blood per copy (one-time per follower)."},
	"The Peaked Rite": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "If average tier of 3 sacrifices exceeds 7, additive total x1.5."},
	"Apex Covenant": {"rarity": "RARE", "stacks": true, "category": "RELIC", "desc": "Highest-tier follower in hand adds floor(tier/2) additive per copy."},
	"The Gilded Offering": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "Tier-10 sacrificed followers return to pool after resolve."},
	"Dynasty Seal": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "Offspring of two tier-8+ parents spawn at tier 6 before other modifiers."},
	"Crown of Tiers": {"rarity": "LEGENDARY", "stacks": false, "category": "RELIC", "desc": "Once per week: promote a pool follower by +3 tier (max 10), costs 5 Blood."},
	"The Last Rung": {"rarity": "LEGENDARY", "stacks": false, "category": "RELIC", "desc": "Each tier-10 sacrifice adds +5 to multiplier base."},
	"Void Cradle": {"rarity": "COMMON", "stacks": false, "category": "RELIC", "desc": "VOID sacrifices return to pool after resolve."},
	"The Hollow Register": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "Once per week, a play with exactly 1 VOID gains stacks; each stack adds +1 exponent permanently."},
	"Void Pilgrim": {"rarity": "COMMON", "stacks": false, "category": "RELIC", "desc": "Wild VOID-VOID breeding always succeeds."},
	"The Empty Pyre": {"rarity": "UNCOMMON", "stacks": false, "category": "RELIC", "desc": "A VOID that has grown beyond nothing gives more than nothing."},
	"Refinery of Silence": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "Refined VOID bonus improves by +0.2 per copy."},
	"Obsidian Conduit": {"rarity": "UNCOMMON", "stacks": false, "category": "RELIC", "desc": "Each sacrificed VOID adds additive equal to VOID count in pool."},
	"The Absent Crown": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "Exactly 2 VOID sacrifices are treated as refined VOID."},
	"Void Recursion": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "Once per week, sacrificing a VOID spawns a copy in pool."},
	"Null Covenant": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "If multiplier base reaches 5+, gain Blood equal to base value."},
	"The Final Silence": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "Exactly 1 VOID grants stronger exponent bonuses."},
	"Annihilation Compact": {"rarity": "LEGENDARY", "stacks": false, "category": "RELIC", "desc": "Designate a Null Sovereign; while in pool, VOID scores as +1 tier."},
	"The Deepest Void": {"rarity": "LEGENDARY", "stacks": true, "category": "RELIC", "desc": "Each sacrificed VOID adds +1 effective VOID per copy."},
	"Marrow Charter": {"rarity": "COMMON", "stacks": false, "category": "RELIC", "desc": "If 3 BONE are sacrificed, gain Blood from their total tier."},
	"The Ossuary Engine": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "Clearing a week with 2+ BONE builds permanent BONE additive."},
	"Bone Standard": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "With 2+ BONE, highest BONE contribution is doubled."},
	"The White Wall": {"rarity": "UNCOMMON", "stacks": false, "category": "RELIC", "desc": "If 3 BONE and 0 VOID, multiplier base is at least 2."},
	"Gravewright": {"rarity": "UNCOMMON", "stacks": false, "category": "RELIC", "desc": "Sacrificed BONE may spawn T2 BONE in pool."},
	"Crypt Standard": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "Exactly 2 BONE and 0 VOID doubles additive total."},
	"The Calcified Gate": {"rarity": "RARE", "stacks": true, "category": "RELIC", "desc": "BONE in pool adds floor(tier/3) additive per copy."},
	"Bone Chorus": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "All-BONE same tier: +30 additive and +3 Blood."},
	"The Skeleton Archive": {"rarity": "LEGENDARY", "stacks": true, "category": "RELIC", "desc": "Late BONE-focused clears increase permanent BONE bonus."},
	"Ossuary Absolute": {"rarity": "LEGENDARY", "stacks": false, "category": "RELIC", "desc": "3 high-tier BONE ignore devotion cap this play."},
	"The Red Tithe": {"rarity": "COMMON", "stacks": false, "category": "RELIC", "desc": "3 BLOOD with high total tier gains additive."},
	"Crimson Ledger": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "3 BLOOD plays build a permanent additive stack."},
	"The Sanguine Chord": {"rarity": "UNCOMMON", "stacks": false, "category": "RELIC", "desc": "Tier straights gain multiplier base."},
	"Bloodfire Compact": {"rarity": "UNCOMMON", "stacks": false, "category": "RELIC", "desc": "3 BLOOD with a multiplier trait bypasses multiplier trait cap."},
	"The Running Red": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "Cleared 3 BLOOD round adds random T3 BLOOD to pool."},
	"Crimson Pact": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "Once per week, consume extra BLOOD from pool for additive and Blood."},
	"The Arterial Rite": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "3 BLOOD with no trait triggers grants big additive."},
	"Bloodline Theorem": {"rarity": "RARE", "stacks": true, "category": "RELIC", "desc": "Returning BLOOD followers gain tier on return."},
	"The Sanguine Engine": {"rarity": "LEGENDARY", "stacks": false, "category": "RELIC", "desc": "Highest BLOOD in pool grants BLOOD-play additive."},
	"Crimson Absolute": {"rarity": "LEGENDARY", "stacks": false, "category": "RELIC", "desc": "High-tier all-BLOOD plays multiply final devotion."},
	"The Concordat": {"rarity": "COMMON", "stacks": false, "category": "RELIC", "desc": "Triune plays gain additive per sacrifice."},
	"Trine Offering": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "Triune play grants free recruit(s) next shop."},
	"Threefold Brand": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "After first triune this run, future triune plays gain additive."},
	"The Sacred Triangle": {"rarity": "UNCOMMON", "stacks": false, "category": "RELIC", "desc": "Triune play doubles base contribution of top card per type."},
	"Covenant of Three": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "High-tier triune gains additive and Blood."},
	"The Unbroken Rite": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "Triune in both rounds guarantees rare-or-better next shop."},
	"The Trinity Engine": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "Triune Champion/Heir final multipliers always fully apply."},
	"The Absolute Trinity": {"rarity": "LEGENDARY", "stacks": false, "category": "RELIC", "desc": "Triune with matching BLOOD and BONE highest tiers doubles final devotion."},
	"The Pruning Hook": {"rarity": "COMMON", "stacks": false, "category": "RELIC", "desc": "Once per shop cull and replace with random T3 of same type."},
	"Grave Compact": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "Culls increase next bred offspring tier bonus."},
	"The Awakening Bell": {"rarity": "UNCOMMON", "stacks": false, "category": "RELIC", "desc": "Once per week before round 2, clear exhausted status."},
	"The Deep Pool": {"rarity": "UNCOMMON", "stacks": true, "category": "VOUCHER", "desc": "Pool cap +6 per copy; 2+ copies unlock third nest."},
	"Warden of the Fold": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "After each round, lowest non-SOUL in pool gains tier."},
	"The Rotary": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "Once per shop, swap trait IDs of two pool followers."},
	"The Inheritance Forge": {"rarity": "RARE", "stacks": true, "category": "RELIC", "desc": "Each nest gets extra breeding attempts per week."},
	"Soul Tithe": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "Each SOUL in pool grants Blood each round."},
	"The Purifying Flame": {"rarity": "LEGENDARY", "stacks": false, "category": "RELIC", "desc": "Once per run, transmute 5 followers into stronger rare-trait forms."},
	"The Great Cull": {"rarity": "LEGENDARY", "stacks": false, "category": "RELIC", "desc": "Once per run, keep only 8 followers; survivors gain +2 tier."},
	"The Copper Tithe": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "Each cleared round grants +copies Blood."},
	"Debt Ledger": {"rarity": "COMMON", "stacks": false, "category": "RELIC", "desc": "Shop entry with 15+ Blood converts 10 Blood into permanent additive."},
	"The Red Market": {"rarity": "UNCOMMON", "stacks": false, "category": "RELIC", "desc": "Once per shop can sell a relic for half its cost."},
	"Crimson Compound": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "Improves Crimson Interest divisor."},
	"The Iron Tithe": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "Start week: gain Blood equal to copies x week."},
	"The Debt Engine": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "Extend debt limit; unpaid debt converts to next-round additive penalty."},
	"Usurer's Mark": {"rarity": "RARE", "stacks": true, "category": "RELIC", "desc": "Crimson Interest gains extra triggers per shop."},
	"The Sanguine Bank": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "Blood carried into week 10 grants final-score bank bonus."},
	"The Tithe Accelerator": {"rarity": "LEGENDARY", "stacks": true, "category": "RELIC", "desc": "Each relic purchase increases passive interest scaling."},
	"The Compound Covenant": {"rarity": "LEGENDARY", "stacks": false, "category": "RELIC", "desc": "Once per run, doubles held Blood (week 5+ shop only)."},
	"Single Rite": {"rarity": "COMMON", "stacks": false, "category": "RELIC", "desc": "A lone sacrifice is returned to you, stronger than before."},
	"The Pared Offering": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "After 1-sacrifice play, gain random T2 of sacrificed type."},
	"The Dyad Mark": {"rarity": "UNCOMMON", "stacks": false, "category": "RELIC", "desc": "Two offered as one - the void between them opens."},
	"The Triad Compact": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "3-sacrifice plays build permanent additive."},
	"The Foursome": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "4-sacrifice plays gain additive per copy."},
	"Minimalist Doctrine": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "1-sacrifice base calculation treats tier as doubled."},
	"Mass Offering": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "4-sacrifice plays return all sacrificed followers to pool."},
	"The Expanding Rite": {"rarity": "RARE", "stacks": true, "category": "RELIC", "desc": "4-sacrifice plays build persistent additive bonus."},
	"The Count Absolute": {"rarity": "LEGENDARY", "stacks": false, "category": "RELIC", "desc": "Single tier-10 sacrifice doubles final devotion."},
	"The Expanding Contract": {"rarity": "LEGENDARY", "stacks": false, "category": "RELIC", "desc": "Once per week, 5-sacrifice play enabled; 5th gives tierx3 and is consumed."},
	"The Brood Compact": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "Wild non-VOID breeding chance +5% per copy."},
	"Nursery Ledger": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "Sacrificing bred offspring grants extra Blood."},
	"The Generation Mark": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "Nest offspring from high-tier parents gain starting tier bonus."},
	"The Breeding Engine": {"rarity": "UNCOMMON", "stacks": false, "category": "RELIC", "desc": "Once per week, run a second wild breeding phase."},
	"Lineage Harvest": {"rarity": "UNCOMMON", "stacks": false, "category": "RELIC", "desc": "Sacrificed bred followers gain additive and return to pool."},
	"The Primogeniture": {"rarity": "RARE", "stacks": true, "category": "RELIC", "desc": "First nest offspring each run gets stronger trait inheritance."},
	"The Bloodline Compact": {"rarity": "RARE", "stacks": true, "category": "RELIC", "desc": "Legendary offspring weeks grant Blood and offspring tier bonus."},
	"The Dynasty Forge": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "Once per run designate a permanent wild breeding pair."},
	"The Womb of Ages": {"rarity": "LEGENDARY", "stacks": false, "category": "RELIC", "desc": "Once per run one nest produces two offspring."},
	"The Eternal Line": {"rarity": "LEGENDARY", "stacks": true, "category": "RELIC", "desc": "Bred offspring do not count toward pool cap."},
	"The Bleeding Edge": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "Big additive each play; failed play loses Blood."},
	"The Rusted Tithe": {"rarity": "UNCOMMON", "stacks": false, "category": "RELIC", "desc": "Each play disables one random COMMON relic this round."},
	"The Cursed Offering": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "Additive boost, but random pool follower loses tier after play."},
	"The Hollow Pact": {"rarity": "RARE", "stacks": true, "category": "RELIC", "desc": "Multiplier exponent bonus; pool cap halved."},
	"The Red Covenant": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "Each week, you may double this week's target. Clearing it grants +30 Blood and a guaranteed Rare offer next shop."},
	"The Last Sacrifice": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "If pool has under 5 non-SOUL followers, scoring is doubled."},
	"The Hungry Altar": {"rarity": "LEGENDARY", "stacks": false, "category": "RELIC", "desc": "Scoring doubles; after play, one random pool follower is consumed."},
	"The Damnation Seal": {"rarity": "LEGENDARY", "stacks": false, "category": "RELIC", "desc": "Week 10 target is doubled."},
	"The Second Sight": {"rarity": "COMMON", "stacks": false, "category": "RELIC", "desc": "Shows next week target in shop."},
	"The Waiting Bell": {"rarity": "COMMON", "stacks": false, "category": "RELIC", "desc": "Skipping all shop purchases grants +10 Blood."},
	"The Faithful Scribe": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "Shop rerolls have elevated minimum rarity."},
	"The Votive Ledger": {"rarity": "UNCOMMON", "stacks": false, "category": "RELIC", "desc": "Once per shop, re-fire one purchased relic's on-win effect."},
	"The Drawn Curtain": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "Doctrine action used this round grants additive."},
	"The Witness": {"rarity": "RARE", "stacks": true, "category": "RELIC", "desc": "Reveals all hand trait IDs (information utility)."},
	"Director's Addendum": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "Director's Cut range widens and gains an extra use."},
	"The Omen Ledger": {"rarity": "RARE", "stacks": true, "category": "RELIC", "desc": "Omen Deck can roll legendary traits on recruits."},
	"The Palimpsest": {"rarity": "LEGENDARY", "stacks": false, "category": "RELIC", "desc": "Once per run: wipe relics and redraw 3 relic offers."},
	"The Archive Key": {"rarity": "LEGENDARY", "stacks": false, "category": "RELIC", "desc": "Codex utility unlock (information only)."},
}

const RELIC_SCORING_HOOKS := {
	"PRE_ADD": {
		"Crimson Book": "_hook_pre_add_crimson_book",
		"Bone Idol": "_hook_pre_add_bone_idol",
		"Calcify": "_hook_pre_add_calcify",
		"Thin Blade": "_hook_pre_add_thin_blade",
		"Quick Chant": "_hook_pre_add_quick_chant",
		"Ossuary Standard": "_hook_pre_add_ossuary_standard",
		"Bone Polisher": "_hook_pre_add_bone_polisher",
		"Ritual Symmetry": "_hook_pre_add_ritual_symmetry",
		"Prayer Beads": "_hook_pre_add_prayer_beads",
		"Wax Seal": "_hook_pre_add_wax_seal",
		"Choir Robes": "_hook_pre_add_choir_robes",
		"Triune Reliquary": "_hook_pre_add_triune_reliquary",
		"Red Thread": "_hook_pre_add_red_thread",
		"Bloodright Almanac": "_hook_pre_add_bloodright_almanac",
		"Bone Saw": "_hook_pre_add_bone_saw",
		"Iron Reliquary": "_hook_pre_add_iron_reliquary",
		"Ivory Throne": "_hook_pre_add_ivory_throne",
		"Ascendant Mark": "_hook_pre_add_ascendant_mark",
		"The Summit": "_hook_pre_add_the_summit",
		"Apex Covenant": "_hook_pre_add_apex_covenant",
		"Obsidian Conduit": "_hook_pre_add_obsidian_conduit",
	},
	"PRE_MULT": {
		"Sacrificial Order": "_hook_pre_mult_sacrificial_order",
		"Balanced Offering": "_hook_pre_mult_balanced_offering",
		"The Peaked Rite": "_hook_pre_mult_peaked_rite",
	},
	"MULTIPLIER_ADJUST": {
		"Hollow Abacus": "_hook_multiplier_hollow_abacus",
		"Ectoplasm Jar": "_hook_multiplier_ectoplasm_jar",
		"Hollow Chant": "_hook_multiplier_hollow_chant",
		"Void Prism": "_hook_multiplier_void_prism",
		"Black Candle": "_hook_multiplier_black_candle",
		"Cold Incense": "_hook_multiplier_cold_incense",
	},
	"POST_RESOLVE": {
		"Red Thread": "_hook_post_resolve_red_thread",
	},
}

const TUTORIAL_MAX_WEEKS := 4
const TUTORIAL_WEEK_TARGETS := {
	1: 40,
	2: 55,
	3: 75,
	4: 105,
}
const TUTORIAL_DATA := {
	1: {
		"required_pool": [
			{"trait": "BLOOD", "tier": 6, "trait_id": "high_chanter", "lineage": 0, "origin_tag": "start"},
			{"trait": "BLOOD", "tier": 5, "trait_id": "twinborn", "lineage": 0, "origin_tag": "start"},
			{"trait": "BLOOD", "tier": 5, "trait_id": "ember_saint", "lineage": 0, "origin_tag": "start"},
			{"trait": "BLOOD", "tier": 4, "trait_id": "devout", "lineage": 0, "origin_tag": "start"},
			{"trait": "BONE", "tier": 5, "trait_id": "ossuary_laborer", "lineage": 0, "origin_tag": "start"},
			{"trait": "BONE", "tier": 4, "trait_id": "stalwart", "lineage": 0, "origin_tag": "start"},
			{"trait": "BONE", "tier": 5, "trait_id": "bone_tithe", "lineage": 0, "origin_tag": "start"},
			{"trait": "VOID", "tier": 0, "trait_id": "whispered", "lineage": 0, "origin_tag": "start"},
			{"trait": "VOID", "tier": 0, "trait_id": "", "lineage": 0, "origin_tag": "start"},
		],
		"round_hands": {
			1: [
				{"trait": "BLOOD", "tier": 6, "trait_id": "high_chanter", "lineage": 0},
				{"trait": "BONE", "tier": 4, "trait_id": "stalwart", "lineage": 0},
				{"trait": "VOID", "tier": 0, "trait_id": "whispered", "lineage": 0},
				{"trait": "BLOOD", "tier": 5, "trait_id": "twinborn", "lineage": 0},
				{"trait": "BONE", "tier": 5, "trait_id": "ossuary_laborer", "lineage": 0},
				{"trait": "BLOOD", "tier": 4, "trait_id": "devout", "lineage": 0},
			],
			2: [
				{"trait": "BLOOD", "tier": 5, "trait_id": "ember_saint", "lineage": 0},
				{"trait": "BLOOD", "tier": 5, "trait_id": "blood_oathling", "lineage": 0},
				{"trait": "BONE", "tier": 5, "trait_id": "bone_tithe", "lineage": 0},
				{"trait": "BLOOD", "tier": 4, "trait_id": "devout", "lineage": 0},
				{"trait": "BONE", "tier": 4, "trait_id": "stalwart", "lineage": 0},
				{"trait": "VOID", "tier": 0, "trait_id": "", "lineage": 0},
			],
		},
		"shop_offers": ["Bone Idol", "Crimson Book", "Tithe Discount"],
		"shop_recruits": [
			{"trait": "BLOOD", "tier": 5, "trait_id": "devout", "lineage": 0},
			{"trait": "BONE", "tier": 4, "trait_id": "stalwart", "lineage": 0},
			{"trait": "VOID", "tier": 0, "trait_id": "whispered", "lineage": 0},
		],
	},
	2: {
		"required_pool": [
			{"trait": "BLOOD", "tier": 5, "trait_id": "bloodbrand", "lineage": 1, "origin_tag": "nest_bred"},
			{"trait": "BONE", "tier": 4, "trait_id": "stalwart", "lineage": 1, "origin_tag": "nest_bred"},
			{"trait": "BLOOD", "tier": 4, "trait_id": "fervent", "lineage": 1, "origin_tag": "wild_bred"},
			{"trait": "BLOOD", "tier": 6, "trait_id": "high_chanter", "lineage": 0, "origin_tag": "start"},
			{"trait": "BONE", "tier": 5, "trait_id": "ossuary_laborer", "lineage": 0, "origin_tag": "start"},
			{"trait": "VOID", "tier": 0, "trait_id": "whispered", "lineage": 0, "origin_tag": "start"},
		],
		"round_hands": {
			1: [
				{"trait": "BLOOD", "tier": 5, "trait_id": "bloodbrand", "lineage": 1},
				{"trait": "BONE", "tier": 4, "trait_id": "stalwart", "lineage": 1},
				{"trait": "BLOOD", "tier": 4, "trait_id": "fervent", "lineage": 1},
				{"trait": "VOID", "tier": 0, "trait_id": "whispered", "lineage": 0},
				{"trait": "BLOOD", "tier": 6, "trait_id": "high_chanter", "lineage": 0},
				{"trait": "BONE", "tier": 5, "trait_id": "ossuary_laborer", "lineage": 0},
			],
			2: [
				{"trait": "BONE", "tier": 5, "trait_id": "ossuary_laborer", "lineage": 0},
				{"trait": "BLOOD", "tier": 5, "trait_id": "bloodbrand", "lineage": 1},
				{"trait": "BLOOD", "tier": 5, "trait_id": "ember_saint", "lineage": 0},
				{"trait": "BLOOD", "tier": 4, "trait_id": "devout", "lineage": 0},
				{"trait": "VOID", "tier": 0, "trait_id": "whispered", "lineage": 0},
				{"trait": "BONE", "tier": 4, "trait_id": "stalwart", "lineage": 1},
			],
		},
		"shop_offers": ["Prayer Beads", "Black Contract", "Selective Breeding Scroll"],
		"shop_recruits": [
			{"trait": "BLOOD", "tier": 6, "trait_id": "straight_rite", "lineage": 0},
			{"trait": "BONE", "tier": 5, "trait_id": "ossuary_king", "lineage": 0},
			{"trait": "VOID", "tier": 0, "trait_id": "void_herald", "lineage": 0},
		],
		"nest_results": [
			{"nest": 1, "success": true, "baby": {"trait": "BLOOD", "tier": 6, "trait_id": "straight_rite", "lineage": 2, "origin_tag": "nest_bred"}},
			{"nest": 2, "success": true, "baby": {"trait": "VOID", "tier": 0, "trait_id": "void_herald", "lineage": 1, "origin_tag": "nest_bred"}},
		],
		"wild_results": [
			{"trait": "BONE", "tier": 5, "trait_id": "pair_hunter", "lineage": 1, "origin_tag": "wild_bred"},
		],
	},
	3: {
		"required_pool": [
			{"trait": "BLOOD", "tier": 6, "trait_id": "straight_rite", "lineage": 2, "origin_tag": "nest_bred"},
			{"trait": "VOID", "tier": 0, "trait_id": "void_herald", "lineage": 1, "origin_tag": "nest_bred"},
			{"trait": "BONE", "tier": 5, "trait_id": "pair_hunter", "lineage": 1, "origin_tag": "wild_bred"},
			{"trait": "BLOOD", "tier": 6, "trait_id": "black_candlebearer", "lineage": 0, "origin_tag": "recruit"},
			{"trait": "BONE", "tier": 6, "trait_id": "ossuary_king", "lineage": 0, "origin_tag": "recruit"},
			{"trait": "BLOOD", "tier": 5, "trait_id": "lineage_tutor", "lineage": 0, "origin_tag": "start"},
		],
		"round_hands": {
			1: [
				{"trait": "BLOOD", "tier": 6, "trait_id": "straight_rite", "lineage": 2},
				{"trait": "VOID", "tier": 0, "trait_id": "void_herald", "lineage": 1},
				{"trait": "BONE", "tier": 5, "trait_id": "pair_hunter", "lineage": 1},
				{"trait": "BLOOD", "tier": 6, "trait_id": "black_candlebearer", "lineage": 0},
				{"trait": "BONE", "tier": 6, "trait_id": "ossuary_king", "lineage": 0},
				{"trait": "BLOOD", "tier": 5, "trait_id": "lineage_tutor", "lineage": 0},
			],
			2: [
				{"trait": "BLOOD", "tier": 6, "trait_id": "blood_prophet", "lineage": 0},
				{"trait": "BLOOD", "tier": 6, "trait_id": "straight_rite", "lineage": 2},
				{"trait": "BLOOD", "tier": 5, "trait_id": "devout", "lineage": 1},
				{"trait": "BONE", "tier": 5, "trait_id": "pair_hunter", "lineage": 1},
				{"trait": "VOID", "tier": 0, "trait_id": "void_herald", "lineage": 1},
				{"trait": "BONE", "tier": 4, "trait_id": "stalwart", "lineage": 0},
			],
		},
		"shop_offers": ["The Sanguine Chord", "Fertility Idol", "Scarlet Planetarium"],
		"shop_recruits": [
			{"trait": "BLOOD", "tier": 6, "trait_id": "blood_prophet", "lineage": 0},
			{"trait": "BONE", "tier": 6, "trait_id": "ossuary_archon", "lineage": 0},
			{"trait": "BLOOD", "tier": 5, "trait_id": "devout", "trait_ids": ["whispered"], "lineage": 0},
		],
		"nest_results": [
			{"nest": 1, "success": true, "baby": {"trait": "BLOOD", "tier": 7, "trait_id": "crimson_ascendant", "lineage": 2, "origin_tag": "nest_bred"}},
			{"nest": 2, "success": true, "baby": {"trait": "BONE", "tier": 6, "trait_id": "ossuary_archon", "lineage": 2, "origin_tag": "nest_bred"}},
		],
		"wild_results": [
			{"trait": "BLOOD", "tier": 5, "trait_id": "devout", "lineage": 1, "origin_tag": "wild_bred"},
			{"trait": "BONE", "tier": 5, "trait_id": "bone_tithe", "lineage": 1, "origin_tag": "wild_bred"},
		],
	},
	4: {
		"required_pool": [
			{"trait": "BLOOD", "tier": 7, "trait_id": "crimson_ascendant", "lineage": 2, "origin_tag": "nest_bred"},
			{"trait": "BONE", "tier": 6, "trait_id": "ossuary_archon", "lineage": 2, "origin_tag": "nest_bred"},
			{"trait": "BLOOD", "tier": 6, "trait_id": "blood_prophet", "lineage": 0, "origin_tag": "recruit"},
			{"trait": "VOID", "tier": 0, "trait_id": "void_herald", "lineage": 1, "origin_tag": "nest_bred"},
		],
		"round_hands": {
			1: [
				{"trait": "BLOOD", "tier": 7, "trait_id": "crimson_ascendant", "lineage": 2},
				{"trait": "BONE", "tier": 6, "trait_id": "ossuary_archon", "lineage": 2},
				{"trait": "BLOOD", "tier": 6, "trait_id": "blood_prophet", "lineage": 0},
				{"trait": "VOID", "tier": 0, "trait_id": "void_herald", "lineage": 1},
				{"trait": "BLOOD", "tier": 6, "trait_id": "straight_rite", "lineage": 2},
				{"trait": "BONE", "tier": 6, "trait_id": "ossuary_king", "lineage": 0},
			],
			2: [
				{"trait": "BLOOD", "tier": 7, "trait_id": "crimson_ascendant", "lineage": 2},
				{"trait": "BLOOD", "tier": 6, "trait_id": "straight_rite", "lineage": 2},
				{"trait": "BLOOD", "tier": 6, "trait_id": "blood_prophet", "lineage": 0},
				{"trait": "BONE", "tier": 6, "trait_id": "ossuary_archon", "lineage": 2},
				{"trait": "BONE", "tier": 6, "trait_id": "ossuary_king", "lineage": 0},
				{"trait": "BLOOD", "tier": 5, "trait_id": "devout", "lineage": 1},
			],
		},
		"nest_results": [
			{"nest": 1, "success": true, "baby": {"trait": "BLOOD", "tier": 8, "trait_id": "crimson_ascendant", "lineage": 3, "origin_tag": "nest_bred"}},
			{"nest": 2, "success": true, "baby": {"trait": "BONE", "tier": 7, "trait_id": "ossuary_oracle", "lineage": 3, "origin_tag": "nest_bred"}},
		],
		"wild_results": [
			{"trait": "BLOOD", "tier": 6, "trait_id": "fervent", "lineage": 2, "origin_tag": "wild_bred"},
		],
	},
}

var current_week: int = 1
var blood_currency: int = 0
var week_round: int = 1
var week_total_devotion: int = 0
var selected_doctrine: String = ""
var doctrine_used_this_play: bool = false
var pool: Array[Dictionary] = []
var next_follower_id: int = 1
var shop_recruit_offers: Array[Dictionary] = []
var shop_recruit_purchased: Array[bool] = []
var shop_recruit_free: Array[bool] = []
var relic_inventory: Dictionary = {
	"Ritual Knife": 0,
	"Bone Idol": 0,
	"Crimson Book": 0,
	"Hollow Chant": 0,
	"Sacrificial Order": 0,
	"Ceremonial Cup": 0,
	"Blood Abacus": 0,
	"Quick Chant": 0,
	"Thin Blade": 0,
	"Tithe Discount": 0,
	"Ossuary Standard": 0,
	"Bone Polisher": 0,
	"Ritual Symmetry": 0,
	"Calcify": 0,
	"Crimson Interest": 0,
	"Void Prism": 0,
	"Black Candle": 0,
	"The Third Knife": 0,
	"Balanced Offering": 0,
	"Blasphemous Geometry": 0,
	"Brass Tithe Bowl": 0,
	"Sharpened Chalk": 0,
	"Prayer Beads": 0,
	"Bone Saw": 0,
	"Red Thread": 0,
	"Cold Incense": 0,
	"Grave Ledger": 0,
	"Culling Knife": 0,
	"Wax Seal": 0,
	"Salt Circle": 0,
	"Spare Chalice": 0,
	"Choir Robes": 0,
	"Blood Market Stall": 0,
	"Ossuary Standards": 0,
	"Hollow Abacus": 0,
	"Debt Scripture": 0,
	"Votive Mirror": 0,
	"Fertility Idol": 0,
	"Selective Breeding Scroll": 0,
	"Triune Reliquary": 0,
	"Bloodright Almanac": 0,
	"Clean Hands": 0,
	"Ectoplasm Jar": 0,
	"Black Contract": 0,
	"Omen Deck": 0,
	"Director's Cut": 0,
	"Scarlet Planetarium": 0,
	"Seal of Inheritance": 0,
	"The Soul Lantern": 0,
	"First Apostle": 0,
	"Iron Reliquary": 0,
	"Ivory Throne": 0,
	"Ascendant Mark": 0,
	"Whetted Bone": 0,
	"The Summit": 0,
	"Bloodline Register": 0,
	"The Peaked Rite": 0,
	"Apex Covenant": 0,
	"The Gilded Offering": 0,
	"Dynasty Seal": 0,
	"Crown of Tiers": 0,
	"The Last Rung": 0,
	"Void Cradle": 0,
	"The Hollow Register": 0,
	"Void Pilgrim": 0,
	"The Empty Pyre": 0,
	"Refinery of Silence": 0,
	"Obsidian Conduit": 0,
	"The Absent Crown": 0,
	"Void Recursion": 0,
}
var current_hand: Array[Dictionary] = []
var last_breakdown_text: String = ""
var last_logs: Array[String] = []
var last_resilient_saved_ids: Dictionary = {}
var blood_debt: int = 0
var shop_rerolls_used: int = 0
var shop_free_reroll_available: bool = false
var free_reroll_next_shop: bool = false
var shop_first_recruit_boost_used: bool = false
var shop_cull_used: bool = false
var shop_copy_used: bool = false
var favored_breeder_ids: Array[int] = []
var next_week_target_overrides: Dictionary = {}
var cold_incense_used_week: int = -1
var contract_used_week: int = -1
var contract_allow_four: bool = false
var soul_lantern_used: bool = false
var legendary_seen_in_shop: bool = false
var apostle_id: int = -1
var ritual_card_slot: String = ""
var ritual_card_offer: String = ""
var ritual_card_active: String = ""
var ritual_rebirth_pending: bool = false
var suppress_logs: bool = false
var week_overflow_blood_granted: int = 0
var last_breeding_summary: String = ""
var nests: Array[Dictionary] = []
var last_nest_results: Array[Dictionary] = []
var pending_sacrifice_indices: Array[int] = []
var pending_confirmed: bool = false
var pending_week: int = 0
var pending_round: int = 0
var pending_pass: bool = false
var pending_target: int = 0
var early_win_bonus_week: int = -1
var run_config: Dictionary = {}
var combo_trait_catalog: Dictionary = {}
var combo_trait_pair_index: Dictionary = {}
var summit_last_round_highest_tier: int = -1
var bloodline_registered_ids: Dictionary = {}
var crown_of_tiers_used_week: int = -1
var hollow_register_stacks: int = 0
var hollow_register_awarded_week: int = -1
var void_recursion_used_week: int = -1
var red_covenant_active_week: int = -1
var red_covenant_reward_pending: bool = false
var crimson_pact_used_week: int = -1
var awakening_bell_used_week: int = -1
var contract_allow_five: bool = false
var contract_five_used_week: int = -1
var trine_offering_free_recruits_pending: int = 0
var triune_play_seen_run: bool = false
var triune_rounds_this_week: int = 0
var guaranteed_rare_next_shop: bool = false
var ossuary_engine_bonus: int = 0
var ossuary_standards_bonus: int = 0
var crimson_ledger_stacks: int = 0
var triad_compact_bonus: int = 0
var expanding_rite_bonus: int = 0
var skeleton_archive_bonus: int = 0
var skeleton_archive_awarded_run: bool = false
var grave_compact_buffer: float = 0.0
var breeding_engine_used_week: int = -1
var womb_of_ages_used_run: bool = false
var primogeniture_used_run: bool = false
var dynasty_forge_pair: Array[int] = [-1, -1]
var dynasty_forge_set_run: bool = false
var annihilation_sovereign_id: int = -1
var annihilation_sovereign_set: bool = false
var permanent_additive_bonus: int = 0
var next_round_additive_penalty: int = 0
var tithe_accelerator_interest_bonus: int = 0
var debt_ledger_applied_shop_week: int = -1
var bloodline_compact_bonus_pending: int = 0
var bloodline_compact_legendary_seen_week: int = -1
var pruning_hook_used_shop: bool = false
var rotary_used_shop: bool = false
var votive_ledger_used_shop: bool = false
var red_market_used_shop: bool = false
var purifying_flame_used_run: bool = false
var great_cull_used_run: bool = false
var compound_covenant_used_run: bool = false
var palimpsest_used_run: bool = false
var shop_any_purchase_this_visit: bool = false
var director_uses_this_shop: int = 0
var purchased_relic_history: Array[String] = []
var tutorial_mode: bool = false
var tutorial_completed: bool = false
var tutorial_seen_callouts: Dictionary = {}
var rusted_disabled_relic: String = ""
var second_sight_used_shop: bool = false
var last_week10_blood_bank_bonus: int = 0
var codex_data: Dictionary = {}
var codex_persistence_enabled: bool = true

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	_ensure_relic_inventory_keys()
	_init_combo_trait_catalog()
	_load_codex_data()

func _codex_default_data() -> Dictionary:
	return {
		"version": CODEX_VERSION,
		"relics_seen": {},
		"relics_purchased": {},
		"relic_purchase_counts": {},
		"traits_seen": {},
		"combo_traits_bred": {},
		"trophies": {},
	}

func _codex_dict(value) -> Dictionary:
	if typeof(value) == TYPE_DICTIONARY:
		return (value as Dictionary).duplicate(true)
	return {}

func _normalize_codex_data(raw: Dictionary) -> Dictionary:
	var data: Dictionary = _codex_default_data()
	data["version"] = int(raw.get("version", CODEX_VERSION))
	data["relics_seen"] = _codex_dict(raw.get("relics_seen", {}))
	data["relics_purchased"] = _codex_dict(raw.get("relics_purchased", {}))
	data["relic_purchase_counts"] = _codex_dict(raw.get("relic_purchase_counts", {}))
	data["traits_seen"] = _codex_dict(raw.get("traits_seen", {}))
	data["combo_traits_bred"] = _codex_dict(raw.get("combo_traits_bred", {}))
	data["trophies"] = _codex_dict(raw.get("trophies", {}))
	return data

func _load_codex_data() -> void:
	if not codex_persistence_enabled:
		codex_data = _codex_default_data()
		return
	var file: FileAccess = FileAccess.open(CODEX_SAVE_PATH, FileAccess.READ)
	if file == null:
		codex_data = _codex_default_data()
		_save_codex_data()
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		codex_data = _codex_default_data()
		_save_codex_data()
		return
	codex_data = _normalize_codex_data(parsed)
	_ensure_codex_integrity()

func _save_codex_data() -> void:
	if codex_data.is_empty():
		codex_data = _codex_default_data()
	if not codex_persistence_enabled:
		return
	var file: FileAccess = FileAccess.open(CODEX_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(codex_data, "\t"))
	file.flush()

func _ensure_codex_integrity() -> void:
	if codex_data.is_empty():
		codex_data = _codex_default_data()
		return
	if not codex_data.has("version"):
		codex_data["version"] = CODEX_VERSION
	if not codex_data.has("relics_seen"):
		codex_data["relics_seen"] = {}
	if not codex_data.has("relics_purchased"):
		codex_data["relics_purchased"] = {}
	if not codex_data.has("relic_purchase_counts"):
		codex_data["relic_purchase_counts"] = {}
	if not codex_data.has("traits_seen"):
		codex_data["traits_seen"] = {}
	if not codex_data.has("combo_traits_bred"):
		codex_data["combo_traits_bred"] = {}
	if not codex_data.has("trophies"):
		codex_data["trophies"] = {}

func _codex_mark(map_key: String, entry_key: String) -> bool:
	if entry_key == "":
		return false
	_ensure_codex_integrity()
	var bucket: Dictionary = codex_data.get(map_key, {})
	if bool(bucket.get(entry_key, false)):
		return false
	bucket[entry_key] = true
	codex_data[map_key] = bucket
	_save_codex_data()
	return true

func codex_mark_relic_seen(name: String) -> void:
	if not RELIC_DEFS.has(name):
		return
	_codex_mark("relics_seen", name)

func codex_mark_relic_purchased(name: String) -> void:
	if not RELIC_DEFS.has(name):
		return
	var changed: bool = false
	changed = _codex_mark("relics_seen", name) or changed
	changed = _codex_mark("relics_purchased", name) or changed
	_ensure_codex_integrity()
	var counts: Dictionary = codex_data.get("relic_purchase_counts", {})
	counts[name] = int(counts.get(name, 0)) + 1
	codex_data["relic_purchase_counts"] = counts
	if changed or int(counts.get(name, 0)) > 0:
		_save_codex_data()

func codex_mark_trait_seen(trait_id: String) -> void:
	if trait_id == "":
		return
	_codex_mark("traits_seen", trait_id)

func codex_mark_combo_trait_bred(trait_id: String) -> void:
	if trait_id == "" or not trait_id.begins_with("combo_"):
		return
	codex_mark_trait_seen(trait_id)
	_codex_mark("combo_traits_bred", trait_id)

func codex_has_relic_seen(name: String) -> bool:
	_ensure_codex_integrity()
	var bucket: Dictionary = codex_data.get("relics_seen", {})
	return bool(bucket.get(name, false))

func codex_is_relic_unlocked(name: String) -> bool:
	_ensure_codex_integrity()
	var bucket: Dictionary = codex_data.get("relics_purchased", {})
	return bool(bucket.get(name, false))

func codex_get_relic_purchase_count(name: String) -> int:
	_ensure_codex_integrity()
	var bucket: Dictionary = codex_data.get("relic_purchase_counts", {})
	return int(bucket.get(name, 0))

func codex_has_trait_seen(trait_id: String) -> bool:
	_ensure_codex_integrity()
	var bucket: Dictionary = codex_data.get("traits_seen", {})
	return bool(bucket.get(trait_id, false))

func codex_has_combo_trait_bred(trait_id: String) -> bool:
	_ensure_codex_integrity()
	var bucket: Dictionary = codex_data.get("combo_traits_bred", {})
	return bool(bucket.get(trait_id, false))

func codex_get_relic_locked_description(name: String) -> String:
	var def: Dictionary = RELIC_DEFS.get(name, {})
	var rarity: String = str(def.get("rarity", "UNKNOWN"))
	var category: String = str(def.get("category", "RELIC"))
	if codex_has_relic_seen(name):
		return "Seen in shop (%s %s). Purchase once to reveal full Codex entry." % [rarity, category]
	return "Undiscovered %s %s relic. Purchase once to reveal full Codex entry." % [rarity, category]

func codex_get_relic_description(name: String) -> String:
	if not RELIC_DEFS.has(name):
		return ""
	if codex_is_relic_unlocked(name):
		return str(RELIC_DEFS[name].get("desc", ""))
	return codex_get_relic_locked_description(name)

func codex_get_trait_description(trait_id: String) -> String:
	if trait_id == "":
		return ""
	if not codex_has_trait_seen(trait_id):
		return "Undiscovered trait. Encounter this follower trait to reveal full Codex entry."
	var info: Dictionary = _trait_info(trait_id)
	if info.is_empty():
		return "No Codex entry available."
	return str(info.get("desc", ""))

func codex_get_counts() -> Dictionary:
	_ensure_codex_integrity()
	var relic_total: int = RELIC_DEFS.size()
	var trait_total: int = TRAIT_REGISTRY.size()
	var combo_total: int = combo_trait_catalog.size()
	var relic_seen: int = 0
	var relic_unlocked: int = 0
	var trait_seen: int = 0
	var combo_seen: int = 0
	var combo_bred: int = 0
	for relic_name in RELIC_DEFS.keys():
		if codex_has_relic_seen(relic_name):
			relic_seen += 1
		if codex_is_relic_unlocked(relic_name):
			relic_unlocked += 1
	for trait_id in TRAIT_REGISTRY.keys():
		if codex_has_trait_seen(str(trait_id)):
			trait_seen += 1
	for combo_id in combo_trait_catalog.keys():
		if codex_has_trait_seen(str(combo_id)):
			combo_seen += 1
		if codex_has_combo_trait_bred(str(combo_id)):
			combo_bred += 1
	return {
		"relic_total": relic_total,
		"relic_seen": relic_seen,
		"relic_unlocked": relic_unlocked,
		"trait_total": trait_total,
		"trait_seen": trait_seen,
		"combo_total": combo_total,
		"combo_seen": combo_seen,
		"combo_bred": combo_bred,
	}

func _ensure_relic_inventory_keys() -> void:
	for relic_name in RELIC_DEFS.keys():
		if not relic_inventory.has(relic_name):
			relic_inventory[relic_name] = 0

func set_rng_seed(seed: int) -> void:
	_rng.seed = seed

func _shuffle_array(values: Array) -> void:
	if values.size() < 2:
		return
	for i in range(values.size() - 1, 0, -1):
		var j: int = _rng.randi_range(0, i)
		var tmp = values[i]
		values[i] = values[j]
		values[j] = tmp

func _ensure_annihilation_sovereign() -> void:
	if int(relic_inventory.get("Annihilation Compact", 0)) <= 0:
		annihilation_sovereign_id = -1
		annihilation_sovereign_set = false
		return
	if annihilation_sovereign_id >= 0 and _pool_has_follower_id(annihilation_sovereign_id):
		annihilation_sovereign_set = true
		return
	var best_id: int = -1
	var best_tier: int = -1
	for f in pool:
		if str(f.get("trait", "")) != "VOID":
			continue
		var tier: int = int(f.get("tier", 0))
		if tier > best_tier:
			best_tier = tier
			best_id = int(f.get("id", -1))
	annihilation_sovereign_id = best_id
	annihilation_sovereign_set = best_id >= 0

func _has_active_annihilation_sovereign() -> bool:
	if int(relic_inventory.get("Annihilation Compact", 0)) <= 0:
		return false
	if annihilation_sovereign_id < 0:
		return false
	return _pool_has_follower_id(annihilation_sovereign_id)

func _ensure_dynasty_forge_pair() -> void:
	if int(relic_inventory.get("The Dynasty Forge", 0)) <= 0:
		return
	if dynasty_forge_set_run and _pool_has_follower_id(int(dynasty_forge_pair[0])) and _pool_has_follower_id(int(dynasty_forge_pair[1])):
		return
	var ids: Array[Dictionary] = []
	for f in pool:
		if str(f.get("trait", "")) == "SOUL":
			continue
		ids.append({"id": int(f.get("id", -1)), "tier": int(f.get("tier", 0))})
	if ids.size() < 2:
		return
	ids.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("tier", 0)) > int(b.get("tier", 0))
	)
	dynasty_forge_pair = [int(ids[0].get("id", -1)), int(ids[1].get("id", -1))]
	dynasty_forge_set_run = true

func _consume_grave_compact_bonus() -> int:
	var bonus: int = int(floor(grave_compact_buffer))
	if bonus <= 0:
		return 0
	grave_compact_buffer = max(0.0, grave_compact_buffer - float(bonus))
	return bonus

func start_shop_visit() -> void:
	shop_any_purchase_this_visit = false
	director_uses_this_shop = 0
	pruning_hook_used_shop = false
	rotary_used_shop = false
	votive_ledger_used_shop = false
	red_market_used_shop = false
	second_sight_used_shop = false
	shop_recruit_free.clear()
	if int(relic_inventory.get("Debt Ledger", 0)) > 0 and debt_ledger_applied_shop_week != current_week and blood_currency >= 15:
		blood_currency -= 10
		permanent_additive_bonus += 2
		debt_ledger_applied_shop_week = current_week
	if int(relic_inventory.get("The Purifying Flame", 0)) > 0 and not purifying_flame_used_run:
		_apply_purifying_flame()
	if int(relic_inventory.get("The Great Cull", 0)) > 0 and not great_cull_used_run:
		_apply_great_cull()
	if int(relic_inventory.get("The Votive Ledger", 0)) > 0 and not votive_ledger_used_shop:
		_auto_votive_ledger()
	if int(relic_inventory.get("The Second Sight", 0)) > 0 and not second_sight_used_shop:
		var next_w: int = min(get_max_weeks(), current_week + 1)
		log_message("SECOND SIGHT | Week %d preview target: %d" % [next_w, get_week_target(next_w)])
		second_sight_used_shop = true

func finalize_shop_visit() -> void:
	if int(relic_inventory.get("The Debt Engine", 0)) > 0 and blood_debt > 0:
		next_round_additive_penalty += blood_debt
		blood_debt = 0
	second_sight_used_shop = false

func get_directors_cut_max_uses() -> int:
	return 2 if int(relic_inventory.get("Director's Addendum", 0)) > 0 else 1

func get_directors_cut_range_pct() -> float:
	return 0.25 if int(relic_inventory.get("Director's Addendum", 0)) > 0 else 0.15

func fire_relic_on_win_effect(name: String) -> int:
	var gained: int = 0
	match name:
		"Ceremonial Cup":
			gained = int(relic_inventory.get("Ceremonial Cup", 0))
		"Blasphemous Geometry":
			gained = int(relic_inventory.get("Blasphemous Geometry", 0)) * 3
		"Brass Tithe Bowl":
			gained = int(relic_inventory.get("Brass Tithe Bowl", 0))
		_:
			gained = 0
	if gained > 0:
		add_blood(gained)
	return gained

func _auto_votive_ledger() -> void:
	if purchased_relic_history.is_empty():
		return
	var candidates: Array[String] = []
	for relic_name in purchased_relic_history:
		if candidates.has(relic_name):
			continue
		candidates.append(str(relic_name))
	_shuffle_array(candidates)
	for relic_name in candidates:
		var gained: int = fire_relic_on_win_effect(relic_name)
		if gained > 0:
			votive_ledger_used_shop = true
			log_message("VOTIVE LEDGER | Re-fired %s for +%d Blood" % [relic_name, gained])
			return

func _auto_rotary_swap() -> void:
	var pool_with_traits: Array[int] = []
	for f in pool:
		if str(f.get("trait_id", "")) == "":
			continue
		pool_with_traits.append(int(f.get("id", -1)))
	if pool_with_traits.size() < 2:
		return
	_shuffle_array(pool_with_traits)
	use_rotary_swap(pool_with_traits[0], pool_with_traits[1])

func use_rotary_swap(follower_a_id: int, follower_b_id: int) -> bool:
	if int(relic_inventory.get("The Rotary", 0)) <= 0 or rotary_used_shop:
		return false
	if follower_a_id == follower_b_id:
		return false
	var idx_a: int = -1
	var idx_b: int = -1
	for i in range(pool.size()):
		var fid: int = int(pool[i].get("id", -1))
		if fid == follower_a_id:
			idx_a = i
		elif fid == follower_b_id:
			idx_b = i
	if idx_a < 0 or idx_b < 0:
		return false
	var a_tid: String = str(pool[idx_a].get("trait_id", ""))
	var b_tid: String = str(pool[idx_b].get("trait_id", ""))
	pool[idx_a]["trait_id"] = b_tid
	pool[idx_b]["trait_id"] = a_tid
	rotary_used_shop = true
	return true

func _apply_purifying_flame() -> void:
	var picks: Array[int] = []
	for i in range(pool.size()):
		picks.append(i)
	_shuffle_array(picks)
	var changed: int = 0
	for i in range(min(5, picks.size())):
		var idx: int = int(picks[i])
		if str(pool[idx].get("trait", "")) == "VOID":
			pool[idx]["tier"] = 0
		else:
			pool[idx]["tier"] = min(MAX_TIER, int(pool[idx].get("tier", 0)) + 3)
		pool[idx]["trait_id"] = _random_trait_id("RARE")
		changed += 1
	if changed > 0:
		purifying_flame_used_run = true
		_refresh_bloodline_registers(true)
		log_message("PURIFYING FLAME | Transmuted %d followers" % changed)

func _apply_great_cull() -> void:
	if pool.size() <= 8:
		great_cull_used_run = true
		return
	var sorted_pool: Array[Dictionary] = []
	for f in pool:
		sorted_pool.append(f)
	sorted_pool.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("tier", 0)) > int(b.get("tier", 0))
	)
	var kept: Array[Dictionary] = []
	for i in range(min(8, sorted_pool.size())):
		var copy_f: Dictionary = sorted_pool[i]
		if str(copy_f.get("trait", "")) == "VOID":
			copy_f["tier"] = 0
		else:
			copy_f["tier"] = min(MAX_TIER, int(copy_f.get("tier", 0)) + 2)
		kept.append(copy_f)
	pool = kept
	_sanitize_nests()
	great_cull_used_run = true
	_refresh_bloodline_registers(true)
	log_message("GREAT CULL | Reduced pool to %d followers" % pool.size())

func _apply_palimpsest() -> void:
	if palimpsest_used_run:
		return
	var keep_keys: Array[String] = ["The Palimpsest"]
	for key in relic_inventory.keys():
		if keep_keys.has(str(key)):
			continue
		relic_inventory[key] = 0
	palimpsest_used_run = true

func reset_run() -> void:
	_ensure_run_config()
	current_week = 1
	blood_currency = 5
	week_round = 1
	week_total_devotion = 0
	week_overflow_blood_granted = 0
	selected_doctrine = ""
	doctrine_used_this_play = false
	pool.clear()
	next_follower_id = 1
	shop_recruit_offers.clear()
	shop_recruit_purchased.clear()
	shop_recruit_free.clear()
	_ensure_relic_inventory_keys()
	for k in relic_inventory.keys():
		relic_inventory[k] = 0
	last_breakdown_text = ""
	last_logs.clear()
	current_hand.clear()
	last_resilient_saved_ids.clear()
	blood_debt = 0
	shop_rerolls_used = 0
	shop_free_reroll_available = false
	free_reroll_next_shop = false
	shop_first_recruit_boost_used = false
	shop_cull_used = false
	shop_copy_used = false
	favored_breeder_ids.clear()
	next_week_target_overrides.clear()
	cold_incense_used_week = -1
	contract_used_week = -1
	contract_allow_four = false
	soul_lantern_used = false
	legendary_seen_in_shop = false
	apostle_id = -1
	ritual_card_slot = ""
	ritual_card_offer = ""
	ritual_card_active = ""
	ritual_rebirth_pending = false
	last_breeding_summary = ""
	_init_nests()
	last_nest_results.clear()
	pending_sacrifice_indices.clear()
	pending_confirmed = false
	pending_week = 0
	pending_round = 0
	pending_pass = false
	pending_target = 0
	early_win_bonus_week = -1
	summit_last_round_highest_tier = -1
	bloodline_registered_ids.clear()
	crown_of_tiers_used_week = -1
	hollow_register_stacks = 0
	hollow_register_awarded_week = -1
	void_recursion_used_week = -1
	red_covenant_active_week = -1
	red_covenant_reward_pending = false
	crimson_pact_used_week = -1
	awakening_bell_used_week = -1
	contract_allow_five = false
	contract_five_used_week = -1
	trine_offering_free_recruits_pending = 0
	triune_play_seen_run = false
	triune_rounds_this_week = 0
	guaranteed_rare_next_shop = false
	ossuary_engine_bonus = 0
	ossuary_standards_bonus = 0
	crimson_ledger_stacks = 0
	triad_compact_bonus = 0
	expanding_rite_bonus = 0
	skeleton_archive_bonus = 0
	skeleton_archive_awarded_run = false
	grave_compact_buffer = 0.0
	breeding_engine_used_week = -1
	womb_of_ages_used_run = false
	primogeniture_used_run = false
	dynasty_forge_pair = [-1, -1]
	dynasty_forge_set_run = false
	annihilation_sovereign_id = -1
	annihilation_sovereign_set = false
	permanent_additive_bonus = 0
	next_round_additive_penalty = 0
	tithe_accelerator_interest_bonus = 0
	debt_ledger_applied_shop_week = -1
	bloodline_compact_bonus_pending = 0
	bloodline_compact_legendary_seen_week = -1
	pruning_hook_used_shop = false
	rotary_used_shop = false
	votive_ledger_used_shop = false
	red_market_used_shop = false
	purifying_flame_used_run = false
	great_cull_used_run = false
	compound_covenant_used_run = false
	palimpsest_used_run = false
	shop_any_purchase_this_visit = false
	director_uses_this_shop = 0
	purchased_relic_history.clear()
	rusted_disabled_relic = ""
	second_sight_used_shop = false
	last_week10_blood_bank_bonus = 0
	tutorial_mode = false
	tutorial_completed = false
	tutorial_seen_callouts.clear()
	if combo_trait_catalog.is_empty():
		_init_combo_trait_catalog()

func start_tutorial_run() -> void:
	reset_run()
	tutorial_mode = true
	tutorial_completed = false
	tutorial_seen_callouts.clear()
	selected_doctrine = "FLESH"
	set_rng_seed(424242)
	_tutorial_ensure_week_pool(1)
	_init_nests()
	start_week()

func end_tutorial_run() -> void:
	tutorial_mode = false
	tutorial_completed = true
	tutorial_seen_callouts.clear()

func is_tutorial_active() -> bool:
	return tutorial_mode and current_week <= TUTORIAL_MAX_WEEKS

func tutorial_mark_callout_seen(key: String) -> void:
	if key == "":
		return
	tutorial_seen_callouts[key] = true

func tutorial_has_seen_callout(key: String) -> bool:
	if key == "":
		return false
	return bool(tutorial_seen_callouts.get(key, false))

func tutorial_week_data(week: int) -> Dictionary:
	if TUTORIAL_DATA.has(week):
		return TUTORIAL_DATA[week]
	return {}

func tutorial_shop_offers_for_week(week: int) -> Array[String]:
	var data: Dictionary = tutorial_week_data(week)
	var out: Array[String] = []
	for offer in data.get("shop_offers", []):
		out.append(str(offer))
	return out

func tutorial_recruits_for_week(week: int) -> Array[Dictionary]:
	var data: Dictionary = tutorial_week_data(week)
	var out: Array[Dictionary] = []
	for spec in data.get("shop_recruits", []):
		if spec is Dictionary:
			out.append((spec as Dictionary).duplicate(true))
	return out

func _tutorial_make_follower(spec: Dictionary, default_origin: String) -> Dictionary:
	var trait_name: String = str(spec.get("trait", "BLOOD"))
	var tier: int = int(spec.get("tier", 1))
	var trait_id: String = str(spec.get("trait_id", ""))
	var origin_tag: String = str(spec.get("origin_tag", default_origin))
	var made: Dictionary = _make_specific_follower(trait_name, tier, origin_tag, trait_id)
	made["lineage"] = clamp(int(spec.get("lineage", 0)), 0, 10)
	var extra_traits: Array = spec.get("trait_ids", [])
	var trait_ids: Array[String] = []
	for tid_value in extra_traits:
		var tid: String = str(tid_value)
		if tid != "" and tid != str(made.get("trait_id", "")) and not trait_ids.has(tid):
			trait_ids.append(tid)
	made["trait_ids"] = trait_ids
	return made

func _tutorial_find_pool_match(spec: Dictionary, nested_ids: Dictionary = {}) -> int:
	var target_trait: String = str(spec.get("trait", ""))
	var target_tier: int = int(spec.get("tier", 0))
	var target_trait_id: String = str(spec.get("trait_id", ""))
	var target_lineage: int = clamp(int(spec.get("lineage", 0)), 0, 10)
	for i in range(pool.size()):
		var follower: Dictionary = pool[i]
		if nested_ids.has(int(follower.get("id", -1))):
			continue
		if str(follower.get("trait", "")) != target_trait:
			continue
		if int(follower.get("tier", 0)) != target_tier:
			continue
		if str(follower.get("trait_id", "")) != target_trait_id:
			continue
		if _follower_lineage_value(follower) != target_lineage:
			continue
		return i
	return -1

func _tutorial_take_matching_from_pool(spec: Dictionary) -> Dictionary:
	var nested_ids: Dictionary = _nested_id_set()
	var idx: int = _tutorial_find_pool_match(spec, nested_ids)
	if idx >= 0:
		var taken: Dictionary = pool[idx]
		pool.remove_at(idx)
		return taken
	var created: Dictionary = _tutorial_make_follower(spec, "tutorial")
	return created

func _tutorial_ensure_week_pool(week: int) -> void:
	var data: Dictionary = tutorial_week_data(week)
	if data.is_empty():
		return
	var required_pool: Array = data.get("required_pool", [])
	for raw_spec in required_pool:
		if not (raw_spec is Dictionary):
			continue
		var spec: Dictionary = raw_spec as Dictionary
		if _tutorial_find_pool_match(spec) >= 0:
			continue
		pool.append(_tutorial_make_follower(spec, str(spec.get("origin_tag", "tutorial"))))
	# Also ensure scripted hand cards exist, so deterministic draws work even after player actions.
	var round_hands: Dictionary = data.get("round_hands", {})
	for round_key in round_hands.keys():
		for raw_hand_spec in round_hands[round_key]:
			if not (raw_hand_spec is Dictionary):
				continue
			var hand_spec: Dictionary = raw_hand_spec as Dictionary
			if _tutorial_find_pool_match(hand_spec) >= 0:
				continue
			pool.append(_tutorial_make_follower(hand_spec, "tutorial"))

func _init_combo_trait_catalog() -> void:
	var ComboGenerator = load("res://scripts/ComboTraitGenerator.gd")
	if ComboGenerator == null:
		combo_trait_catalog.clear()
		combo_trait_pair_index.clear()
		return
	combo_trait_catalog = ComboGenerator.generate_catalog(TRAIT_REGISTRY)
	combo_trait_pair_index.clear()
	for combo_id in combo_trait_catalog.keys():
		var info: Dictionary = combo_trait_catalog[combo_id]
		var parents: Array = info.get("parents", [])
		if parents.size() < 2:
			continue
		var key: String = _combo_pair_key(str(parents[0]), str(parents[1]))
		if not combo_trait_pair_index.has(key):
			combo_trait_pair_index[key] = []
		var bucket: Array = combo_trait_pair_index[key]
		bucket.append(str(combo_id))
		combo_trait_pair_index[key] = bucket

func get_combo_trait_catalog() -> Dictionary:
	return combo_trait_catalog

func get_combo_trait(combo_id: String) -> Dictionary:
	if combo_trait_catalog.has(combo_id):
		return combo_trait_catalog[combo_id]
	return {}

func _combo_pair_key(a: String, b: String) -> String:
	if a <= b:
		return a + "|" + b
	return b + "|" + a

func _ensure_run_config() -> void:
	if run_config.is_empty():
		run_config = RUN_CONFIG_DEFAULT.duplicate(true)
	if not run_config.has("overflow_devotion_per_blood"):
		run_config["overflow_devotion_per_blood"] = 1

func set_run_config(config: Dictionary) -> void:
	run_config = config.duplicate(true)
	_ensure_run_config()

func get_run_config() -> Dictionary:
	_ensure_run_config()
	return run_config

func get_overflow_devotion_per_blood() -> int:
	var cfg := get_run_config()
	if cfg.has("overflow_devotion_per_blood"):
		return max(1, int(cfg.get("overflow_devotion_per_blood", 1)))
	var legacy_rate: float = float(cfg.get("overflow_blood_per_devotion", 1.0))
	if legacy_rate > 0.0:
		return max(1, int(round(1.0 / legacy_rate)))
	return 1

func get_overflow_blood_per_devotion() -> int:
	var cfg := get_run_config()
	return int(cfg.get("overflow_blood_per_devotion", 1))

func get_early_win_bonus() -> int:
	var cfg := get_run_config()
	return int(cfg.get("early_win_bonus", 0))

func apply_week_devotion_cap(target: int) -> void:
	var cap_mult: float = float(get_run_config().get("week_devotion_cap_mult", 0.0))
	if cap_mult > 0.0:
		var week_cap: int = int(floor(float(target) * cap_mult))
		if week_cap > 0:
			week_total_devotion = min(week_total_devotion, week_cap)

func apply_overflow_blood_for_target(target: int) -> int:
	if target <= 0:
		return 0
	var devotion_per_blood: int = get_overflow_devotion_per_blood()
	var overflow_now: int = max(0, week_total_devotion - target)
	var overflow_blood_now: int = int(floor(float(overflow_now) / float(devotion_per_blood)))
	var cap_mult: float = float(get_run_config().get("overflow_cap_target_mult", 0.0))
	if cap_mult > 0.0:
		var cap: int = int(floor(float(target) * cap_mult))
		if cap > 0:
			overflow_blood_now = min(overflow_blood_now, cap)
	var overflow_delta: int = overflow_blood_now - week_overflow_blood_granted
	if overflow_delta <= 0:
		return 0
	week_overflow_blood_granted += overflow_delta
	add_blood(overflow_delta)
	return overflow_delta

func _next_id() -> int:
	var id: int = next_follower_id
	next_follower_id += 1
	return id

func start_week() -> void:
	week_round = 1
	week_total_devotion = 0
	week_overflow_blood_granted = 0
	last_breakdown_text = ""
	doctrine_used_this_play = false
	contract_allow_four = false
	contract_allow_five = false
	current_hand.clear()
	pending_sacrifice_indices.clear()
	pending_confirmed = false
	pending_week = 0
	pending_round = 0
	pending_pass = false
	pending_target = 0
	early_win_bonus_week = -1
	triune_rounds_this_week = 0
	rusted_disabled_relic = ""
	awakening_bell_used_week = -1
	if int(relic_inventory.get("The Iron Tithe", 0)) > 0:
		add_blood(int(relic_inventory.get("The Iron Tithe", 0)) * current_week)
	if int(relic_inventory.get("The Red Covenant", 0)) > 0:
		red_covenant_active_week = current_week
	else:
		red_covenant_active_week = -1
	if int(relic_inventory.get("The Sanguine Bank", 0)) > 0 and current_week == get_max_weeks():
		last_week10_blood_bank_bonus = blood_currency
	if is_tutorial_active():
		_tutorial_ensure_week_pool(current_week)
	_ensure_annihilation_sovereign()
	_ensure_dynasty_forge_pair()

func init_starting_pool(doctrine: String) -> void:
	pool.clear()
	next_follower_id = 1
	var entries: Array[Dictionary] = []
	if doctrine == "FLESH":
		entries = [
			{"trait": "BLOOD", "tier": 4}, {"trait": "BLOOD", "tier": 4}, {"trait": "BLOOD", "tier": 5},
			{"trait": "BLOOD", "tier": 5}, {"trait": "BLOOD", "tier": 5}, {"trait": "BLOOD", "tier": 5},
			{"trait": "BLOOD", "tier": 6}, {"trait": "BLOOD", "tier": 6},
			{"trait": "BONE", "tier": 5}, {"trait": "BONE", "tier": 5}, {"trait": "BONE", "tier": 6},
			{"trait": "VOID", "tier": 0},
			{"trait": "BLOOD", "tier": 5}, {"trait": "BLOOD", "tier": 6},
			{"trait": "BONE", "tier": 5},
			{"trait": "VOID", "tier": 0},
		]
	elif doctrine == "RUIN":
		entries = [
			{"trait": "BLOOD", "tier": 4}, {"trait": "BLOOD", "tier": 5},
			{"trait": "BLOOD", "tier": 5}, {"trait": "BLOOD", "tier": 5},
			{"trait": "BLOOD", "tier": 6}, {"trait": "BLOOD", "tier": 6},
			{"trait": "BONE", "tier": 4}, {"trait": "BONE", "tier": 5},
			{"trait": "BONE", "tier": 5}, {"trait": "BONE", "tier": 5},
			{"trait": "BONE", "tier": 6},
			{"trait": "VOID", "tier": 0},
			{"trait": "BONE", "tier": 5}, {"trait": "BONE", "tier": 6},
			{"trait": "BLOOD", "tier": 5},
			{"trait": "VOID", "tier": 0},
		]
	else:
		entries = [
			{"trait": "BLOOD", "tier": 4}, {"trait": "BLOOD", "tier": 4}, {"trait": "BLOOD", "tier": 5},
			{"trait": "BLOOD", "tier": 5}, {"trait": "BLOOD", "tier": 5},
			{"trait": "BLOOD", "tier": 6}, {"trait": "BLOOD", "tier": 6},
			{"trait": "BONE", "tier": 4}, {"trait": "BONE", "tier": 5}, {"trait": "BONE", "tier": 6},
			{"trait": "VOID", "tier": 0},
			{"trait": "VOID", "tier": 0},
			{"trait": "BLOOD", "tier": 5}, {"trait": "BONE", "tier": 5},
			{"trait": "VOID", "tier": 0},
			{"trait": "VOID", "tier": 0},
		]
	for e in entries:
		var trait_roll: float = _rng.randf()
		var tid: String = ""
		if trait_roll < STARTING_LEGENDARY_TRAIT_CHANCE:
			tid = _random_trait_id("LEGENDARY")
		elif trait_roll < (STARTING_LEGENDARY_TRAIT_CHANCE + STARTING_RARE_TRAIT_CHANCE):
			tid = _random_trait_id("RARE")
		elif trait_roll < (STARTING_LEGENDARY_TRAIT_CHANCE + STARTING_RARE_TRAIT_CHANCE + STARTING_COMMON_TRAIT_CHANCE):
			tid = _random_trait_id("COMMON")
		pool.append(_make_specific_follower(e["trait"], int(e["tier"]), "start", tid))
	_sanitize_nests()

func _init_nests() -> void:
	nests.clear()
	for i in range(_get_nest_capacity()):
		nests.append({"a": -1, "b": -1, "focus": NEST_FOCUS_NONE})

func _sanitize_nests() -> void:
	var desired: int = _get_nest_capacity()
	if nests.size() < desired:
		for i in range(nests.size(), desired):
			nests.append({"a": -1, "b": -1, "focus": NEST_FOCUS_NONE})
	elif nests.size() > desired:
		nests.resize(desired)
	var valid_ids: Dictionary = {}
	for f in pool:
		valid_ids[int(f.get("id", -1))] = true
	for i in range(nests.size()):
		var entry: Dictionary = nests[i]
		var a_id: int = int(entry.get("a", -1))
		var b_id: int = int(entry.get("b", -1))
		entry["focus"] = _normalize_nest_focus(str(entry.get("focus", NEST_FOCUS_NONE)))
		if a_id >= 0 and not valid_ids.has(a_id):
			entry["a"] = -1
		if b_id >= 0 and not valid_ids.has(b_id):
			entry["b"] = -1
		nests[i] = entry
	for i in range(favored_breeder_ids.size()):
		var fav_id: int = int(favored_breeder_ids[i])
		if fav_id >= 0 and not valid_ids.has(fav_id):
			favored_breeder_ids[i] = -1

func _get_nest_capacity() -> int:
	var extra: int = 0
	if int(relic_inventory.get("The Deep Pool", 0)) >= 2:
		extra = 1
	return STARTING_NESTS + extra

func _nested_id_set() -> Dictionary:
	var ids: Dictionary = {}
	for entry in nests:
		var a_id: int = int(entry.get("a", -1))
		var b_id: int = int(entry.get("b", -1))
		if a_id >= 0:
			ids[a_id] = true
		if b_id >= 0:
			ids[b_id] = true
	return ids

func _normalize_nest_focus(focus: String) -> String:
	match focus:
		NEST_FOCUS_RARITY, NEST_FOCUS_TIER, NEST_FOCUS_FAMILY:
			return focus
		_:
			return NEST_FOCUS_NONE

func _nest_focus_cost(focus: String) -> int:
	match _normalize_nest_focus(focus):
		NEST_FOCUS_RARITY:
			return 3
		NEST_FOCUS_TIER:
			return 3
		NEST_FOCUS_FAMILY:
			return 2
		_:
			return 0

func get_nest_focus_cost(focus: String) -> int:
	return _nest_focus_cost(focus)

func _nest_entry_focus(entry: Dictionary) -> String:
	return _normalize_nest_focus(str(entry.get("focus", NEST_FOCUS_NONE)))

func get_nest_focus(nest_index: int) -> String:
	_sanitize_nests()
	if nest_index < 0 or nest_index >= nests.size():
		return NEST_FOCUS_NONE
	return _nest_entry_focus(nests[nest_index])

func set_nest_focus(nest_index: int, focus: String) -> Dictionary:
	_sanitize_nests()
	if nest_index < 0 or nest_index >= nests.size():
		return {"ok": false, "reason": "Invalid nest.", "focus": NEST_FOCUS_NONE}
	var desired_focus: String = _normalize_nest_focus(focus)
	var entry: Dictionary = nests[nest_index]
	entry["focus"] = desired_focus
	nests[nest_index] = entry
	return {"ok": true, "reason": "", "focus": desired_focus}

func get_nest_focus_total_cost() -> int:
	_sanitize_nests()
	var total: int = 0
	for entry in nests:
		total += _nest_focus_cost(_nest_entry_focus(entry))
	return total

func get_nest_focus_total_cost_with(nest_index: int, focus: String) -> int:
	_sanitize_nests()
	var desired_focus: String = _normalize_nest_focus(focus)
	var total: int = 0
	for i in range(nests.size()):
		if i == nest_index:
			total += _nest_focus_cost(desired_focus)
		else:
			total += _nest_focus_cost(_nest_entry_focus(nests[i]))
	return total

func commit_nest_focus_costs() -> Dictionary:
	var total_cost: int = get_nest_focus_total_cost()
	if total_cost > blood_currency:
		return {
			"ok": false,
			"reason": "Not enough Blood for selected nest focus (%d needed)." % total_cost,
			"cost": total_cost,
			"blood_remaining": blood_currency,
		}
	blood_currency -= total_cost
	return {"ok": true, "reason": "", "cost": total_cost, "blood_remaining": blood_currency}

func purchase_nest_focus(nest_index: int, focus: String) -> Dictionary:
	_sanitize_nests()
	if nest_index < 0 or nest_index >= nests.size():
		return {"ok": false, "reason": "Invalid nest.", "cost": 0, "focus": NEST_FOCUS_NONE}
	var desired_focus: String = _normalize_nest_focus(focus)
	var entry: Dictionary = nests[nest_index]
	var current_focus: String = _nest_entry_focus(entry)
	if desired_focus == current_focus:
		return {"ok": true, "reason": "", "cost": 0, "focus": current_focus}
	var cost: int = _nest_focus_cost(desired_focus)
	if cost > blood_currency:
		return {"ok": false, "reason": "Not enough Blood (%d needed)." % cost, "cost": cost, "focus": current_focus}
	blood_currency -= cost
	entry["focus"] = desired_focus
	nests[nest_index] = entry
	return {"ok": true, "reason": "", "cost": cost, "focus": desired_focus}

func _pool_has_follower_id(follower_id: int) -> bool:
	for f in pool:
		if int(f.get("id", -1)) == follower_id:
			return true
	return false

func _get_pool_follower_by_id(follower_id: int) -> Dictionary:
	for f in pool:
		if int(f.get("id", -1)) == follower_id:
			return f
	return {}

func is_follower_nested(follower_id: int) -> bool:
	var ids: Dictionary = _nested_id_set()
	return ids.has(follower_id)

func assign_follower_to_nest(nest_index: int, parent_slot: int, follower_id: int) -> bool:
	if nest_index < 0 or nest_index >= nests.size():
		return false
	if parent_slot < 0 or parent_slot > 1:
		return false
	if not _pool_has_follower_id(follower_id):
		return false
	var entry: Dictionary = nests[nest_index]
	var key: String = "a" if parent_slot == 0 else "b"
	var other_key: String = "b" if key == "a" else "a"
	var other_id: int = int(entry.get(other_key, -1))
	if other_id == follower_id:
		return false
	for i in range(nests.size()):
		var e: Dictionary = nests[i]
		if int(e.get("a", -1)) == follower_id:
			e["a"] = -1
		if int(e.get("b", -1)) == follower_id:
			e["b"] = -1
		nests[i] = e
	entry[key] = follower_id
	nests[nest_index] = entry
	return true

func clear_nest_slot(nest_index: int, parent_slot: int) -> void:
	if nest_index < 0 or nest_index >= nests.size():
		return
	if parent_slot < 0 or parent_slot > 1:
		return
	var entry: Dictionary = nests[nest_index]
	entry["a" if parent_slot == 0 else "b"] = -1
	nests[nest_index] = entry

func _nest_parent_flags(parent_a: Dictionary, parent_b: Dictionary) -> Dictionary:
	var parent_a_tid: String = str(parent_a.get("trait_id", ""))
	var parent_b_tid: String = str(parent_b.get("trait_id", ""))
	var parent_a_template: String = _combo_template_id(parent_a_tid)
	var parent_b_template: String = _combo_template_id(parent_b_tid)
	var parent_a_id: int = int(parent_a.get("id", -1))
	var parent_b_id: int = int(parent_b.get("id", -1))
	var has_nest_dynasty: bool = parent_a_template == "nest_dynasty" or parent_b_template == "nest_dynasty"
	var has_legendary_nest_dynasty: bool = (
		(parent_a_template == "nest_dynasty" and _trait_rarity(parent_a_tid) == "LEGENDARY")
		or (parent_b_template == "nest_dynasty" and _trait_rarity(parent_b_tid) == "LEGENDARY")
	)
	var has_brood_sovereign: bool = parent_a_tid == "brood_sovereign" or parent_b_tid == "brood_sovereign"
	var has_brood_keeper: bool = parent_a_tid == "brood_keeper" or parent_b_tid == "brood_keeper" or has_nest_dynasty
	var has_lineage_tutor: bool = parent_a_tid == "lineage_tutor" or parent_b_tid == "lineage_tutor" or has_nest_dynasty
	var has_apostolic_womb: bool = parent_a_tid == "apostolic_womb" or parent_b_tid == "apostolic_womb"
	var has_chosen_veil: bool = parent_a_tid == "chosen_veil" or parent_b_tid == "chosen_veil"
	var has_selective_scroll: bool = relic_inventory["Selective Breeding Scroll"] > 0
	var has_favored_parent: bool = _is_favored_breeder(parent_a_id) or _is_favored_breeder(parent_b_id)
	var apostle_parent: bool = (apostle_id >= 0) and (parent_a_id == apostle_id or parent_b_id == apostle_id)
	return {
		"parent_a_tid": parent_a_tid,
		"parent_b_tid": parent_b_tid,
		"parent_a_id": parent_a_id,
		"parent_b_id": parent_b_id,
		"has_nest_dynasty": has_nest_dynasty,
		"has_legendary_nest_dynasty": has_legendary_nest_dynasty,
		"has_brood_sovereign": has_brood_sovereign,
		"has_brood_keeper": has_brood_keeper,
		"has_lineage_tutor": has_lineage_tutor,
		"has_apostolic_womb": has_apostolic_womb,
		"has_chosen_veil": has_chosen_veil,
		"has_selective_scroll": has_selective_scroll,
		"has_favored_parent": has_favored_parent,
		"apostle_parent": apostle_parent,
	}

func _baby_trait_probabilities(parent_a_trait: String, parent_b_trait: String) -> Dictionary:
	var probs: Dictionary = {}
	if parent_a_trait == parent_b_trait:
		probs[parent_a_trait] = 1.0
		return probs
	if parent_a_trait == "VOID" or parent_b_trait == "VOID":
		var non_void_trait: String = parent_b_trait if parent_a_trait == "VOID" else parent_a_trait
		probs["VOID"] = 0.15
		probs[non_void_trait] = 0.85
		return probs
	probs[parent_a_trait] = 0.5
	probs[parent_b_trait] = 0.5
	return probs

func _apply_nest_tier_bonuses(base_tier: int, flags: Dictionary, nest_focus: String) -> int:
	var tier: int = base_tier
	if tier > 0 and bool(flags.get("has_brood_keeper", false)):
		tier = min(MAX_TIER, tier + 1)
	if tier > 0 and bool(flags.get("has_brood_sovereign", false)):
		tier = min(MAX_TIER, tier + 1)
	if tier > 0 and bool(flags.get("has_legendary_nest_dynasty", false)):
		tier = min(MAX_TIER, tier + 1)
	if bool(flags.get("has_apostolic_womb", false)) and tier > 0:
		tier = min(MAX_TIER, tier + 2)
	if bool(flags.get("apostle_parent", false)) and tier > 0:
		tier = min(MAX_TIER, tier + 1)
	if _normalize_nest_focus(nest_focus) == NEST_FOCUS_TIER and tier > 0:
		tier = min(MAX_TIER, tier + 1)
	return tier

func _base_tier_from_parents_for_offspring_trait(parent_a: Dictionary, parent_b: Dictionary, offspring_trait: String) -> int:
	var baby_trait: String = offspring_trait.strip_edges().to_upper()
	if baby_trait == "VOID":
		return 0
	var parent_a_trait: String = str(parent_a.get("trait", "")).strip_edges().to_upper()
	var parent_b_trait: String = str(parent_b.get("trait", "")).strip_edges().to_upper()
	var parent_a_tier: int = int(parent_a.get("tier", 1))
	var parent_b_tier: int = int(parent_b.get("tier", 1))
	var parent_a_is_void: bool = parent_a_trait == "VOID"
	var parent_b_is_void: bool = parent_b_trait == "VOID"
	if parent_a_is_void != parent_b_is_void:
		var inherited_tier: int = parent_b_tier if parent_a_is_void else parent_a_tier
		return clamp(inherited_tier, 1, MAX_TIER)
	return clamp(int(floor((parent_a_tier + parent_b_tier) / 2.0)), 1, MAX_TIER)

func _follower_lineage_value(follower: Dictionary) -> int:
	return clamp(int(follower.get("lineage", 0)), 0, 10)

func _inherited_lineage_value(parent_a: Dictionary, parent_b: Dictionary) -> int:
	var lineage_a: int = _follower_lineage_value(parent_a)
	var lineage_b: int = _follower_lineage_value(parent_b)
	var highest_parent_lineage: int = max(lineage_a, lineage_b)
	# Offspring lineage always advances one step from the highest parent lineage.
	return clamp(highest_parent_lineage + 1, 0, 10)

func _compute_wild_offspring_lineage(parent_a: Dictionary, parent_b: Dictionary) -> int:
	return _inherited_lineage_value(parent_a, parent_b)

func _compute_nest_lineage_components(parent_a: Dictionary, parent_b: Dictionary, _focus_mode: String, _offspring_trait_id: String) -> Dictionary:
	var a_lineage: int = _follower_lineage_value(parent_a)
	var b_lineage: int = _follower_lineage_value(parent_b)
	var base: int = max(a_lineage, b_lineage)
	var generation_bonus: int = 1
	var focus_bonus: int = 0
	var trait_bonus: int = 0
	var total: int = clamp(base + generation_bonus + focus_bonus + trait_bonus, 0, 10)
	return {
		"base": base,
		"generation_bonus": generation_bonus,
		"focus_bonus": focus_bonus,
		"trait_bonus": trait_bonus,
		"total": total,
	}

func _compute_nest_offspring_lineage(parent_a: Dictionary, parent_b: Dictionary, focus_mode: String, offspring_trait_id: String) -> int:
	var parts: Dictionary = _compute_nest_lineage_components(parent_a, parent_b, focus_mode, offspring_trait_id)
	return int(parts.get("total", 0))

func _compute_nest_lineage_preview(parent_a: Dictionary, parent_b: Dictionary, focus_mode: String) -> Dictionary:
	var predicted_trait_id: String = ""
	if _normalize_nest_focus(focus_mode) == NEST_FOCUS_RARITY:
		var odds: Dictionary = _compute_nest_rarity_probabilities(parent_a, parent_b, focus_mode)
		var rare_plus: float = float(odds.get("rare", 0.0)) + float(odds.get("legendary", 0.0))
		if rare_plus >= 0.5:
			# Synthetic rare marker for deterministic preview focus bonus.
			predicted_trait_id = "straight_rite"
	var parts: Dictionary = _compute_nest_lineage_components(parent_a, parent_b, focus_mode, predicted_trait_id)
	parts["predicted_trait_id"] = predicted_trait_id
	return parts

func _estimate_nest_expected_tier(parent_a: Dictionary, parent_b: Dictionary, nest_focus: String) -> float:
	var focus_mode: String = _normalize_nest_focus(nest_focus)
	var parent_a_trait: String = str(parent_a.get("trait", ""))
	var parent_b_trait: String = str(parent_b.get("trait", ""))
	var flags: Dictionary = _nest_parent_flags(parent_a, parent_b)
	var trait_probs: Dictionary = _baby_trait_probabilities(parent_a_trait, parent_b_trait)
	var expected: float = 0.0
	var deltas: Array = [
		{"delta": 1, "chance": 0.20},
		{"delta": 0, "chance": 0.70},
		{"delta": -1, "chance": 0.10},
	]
	for trait_key in trait_probs.keys():
		var baby_trait: String = str(trait_key)
		var trait_chance: float = float(trait_probs[trait_key])
		var base_mid: int = _base_tier_from_parents_for_offspring_trait(parent_a, parent_b, baby_trait)
		for bucket in deltas:
			var roll_delta: int = int(bucket["delta"])
			var roll_chance: float = float(bucket["chance"])
			var tier: int = 0
			if baby_trait == "VOID":
				tier = 0
			else:
				tier = clamp(base_mid + roll_delta, 1, MAX_TIER)
			tier = _apply_nest_tier_bonuses(tier, flags, focus_mode)
			expected += trait_chance * roll_chance * float(tier)
	return expected

func get_nest_preview(nest_index: int) -> Dictionary:
	_sanitize_nests()
	var preview: Dictionary = {
		"nest": nest_index + 1,
		"focus": NEST_FOCUS_NONE,
		"focus_cost_none": _nest_focus_cost(NEST_FOCUS_NONE),
		"focus_cost_rarity": _nest_focus_cost(NEST_FOCUS_RARITY),
		"focus_cost_tier": _nest_focus_cost(NEST_FOCUS_TIER),
		"focus_cost_family": _nest_focus_cost(NEST_FOCUS_FAMILY),
		"a_id": -1,
		"b_id": -1,
		"blocked_reason": "",
		"can_breed": false,
		"expected_newborns": 0.0,
		"expected_tier": 0.0,
		"combo_eligible": false,
		"combo_count": 0,
		"combo_names": [],
		"rarity_odds": {"common": 0.0, "rare": 0.0, "legendary": 0.0},
		"lineage_base": 0,
		"lineage_generation_bonus": 0,
		"lineage_focus_bonus": 0,
		"lineage_trait_bonus": 0,
		"lineage_total": -1,
	}
	if nest_index < 0 or nest_index >= nests.size():
		preview["blocked_reason"] = "Invalid nest."
		return preview
	var entry: Dictionary = nests[nest_index]
	var focus_mode: String = _nest_entry_focus(entry)
	var a_id: int = int(entry.get("a", -1))
	var b_id: int = int(entry.get("b", -1))
	preview["focus"] = focus_mode
	preview["a_id"] = a_id
	preview["b_id"] = b_id
	if a_id < 0 or b_id < 0:
		preview["blocked_reason"] = "Missing parent."
		return preview
	var parent_a: Dictionary = _get_pool_follower_by_id(a_id)
	var parent_b: Dictionary = _get_pool_follower_by_id(b_id)
	if parent_a.is_empty() or parent_b.is_empty():
		preview["blocked_reason"] = "Parent missing from pool."
		return preview
	if str(parent_a.get("trait", "")) == "SOUL" or str(parent_b.get("trait", "")) == "SOUL":
		preview["blocked_reason"] = "SOUL cannot breed."
		return preview
	if is_pool_at_capacity():
		preview["blocked_reason"] = "Pool full."
		return preview
	var parent_a_traits: Array[String] = _trait_ids_for_follower(parent_a)
	var parent_b_traits: Array[String] = _trait_ids_for_follower(parent_b)
	var combo_candidates: Array[String] = _combo_candidates_for_parent_trait_lists(parent_a_traits, parent_b_traits)
	preview["combo_eligible"] = not combo_candidates.is_empty()
	preview["combo_count"] = combo_candidates.size()
	var combo_names: Array[String] = []
	for combo_id in combo_candidates:
		var combo_info: Dictionary = get_combo_trait(combo_id)
		var cname: String = str(combo_info.get("name", combo_id))
		var rarity: String = str(combo_info.get("rarity", ""))
		combo_names.append("%s (%s)" % [cname, rarity])
	preview["combo_names"] = combo_names
	preview["rarity_odds"] = _compute_nest_rarity_probabilities(parent_a, parent_b, focus_mode)
	preview["expected_tier"] = _estimate_nest_expected_tier(parent_a, parent_b, focus_mode)
	var lineage_parts: Dictionary = _compute_nest_lineage_preview(parent_a, parent_b, focus_mode)
	preview["lineage_base"] = int(lineage_parts.get("base", 0))
	preview["lineage_generation_bonus"] = int(lineage_parts.get("generation_bonus", 0))
	preview["lineage_focus_bonus"] = int(lineage_parts.get("focus_bonus", 0))
	preview["lineage_trait_bonus"] = int(lineage_parts.get("trait_bonus", 0))
	preview["lineage_total"] = int(lineage_parts.get("total", 0))
	preview["expected_newborns"] = 1.0
	preview["can_breed"] = true
	return preview

func _make_specific_follower(trait_name: String, tier: int, origin: String, trait_id: String = "", trait_rarity: String = "") -> Dictionary:
	var t: int = tier
	var tr: String = trait_name
	if tr == "VOID":
		t = 0
	var tid: String = trait_id
	var trarity: String = trait_rarity
	if tid != "" and trarity == "":
		trarity = _trait_rarity(tid)
	if tid != "":
		codex_mark_trait_seen(tid)
		if (origin == "nest_bred" or origin == "wild_bred") and tid.begins_with("combo_"):
			codex_mark_combo_trait_bred(tid)
	return {
		"id": _next_id(),
		"tier": t,
		"trait": tr,
		"trait_id": tid,
		"trait_ids": [],
		"trait_rarity": trarity,
		"lineage": 0,
		"exhausted": false,
		"origin_tag": origin,
	}

func make_random_follower(origin: String) -> Dictionary:
	var tier: int = _roll_tier_weighted()
	var roll: float = _rng.randf()
	var trait_name: String = "BLOOD"
	if roll < 0.6:
		trait_name = "BLOOD"
	elif roll < 0.9:
		trait_name = "BONE"
	else:
		trait_name = "VOID"
	if trait_name == "VOID":
		tier = 0
	return {
		"id": _next_id(),
		"tier": tier,
		"trait": trait_name,
		"trait_id": "",
		"trait_ids": [],
		"trait_rarity": "",
		"lineage": 0,
		"exhausted": false,
		"origin_tag": origin,
	}

func generate_shop_recruits() -> void:
	shop_recruit_offers.clear()
	shop_recruit_purchased.clear()
	shop_recruit_free.clear()
	shop_copy_used = false
	shop_first_recruit_boost_used = false
	if is_tutorial_active():
		var scripted_recruits: Array[Dictionary] = tutorial_recruits_for_week(current_week)
		if not scripted_recruits.is_empty():
			for spec in scripted_recruits:
				shop_recruit_offers.append(_tutorial_make_follower(spec, "recruit_shop"))
				shop_recruit_purchased.append(false)
				shop_recruit_free.append(false)
			return
	var tries: int = 0
	var desired: int = 4 if relic_inventory["Blood Market Stall"] > 0 else 3
	var free_slots: int = max(0, trine_offering_free_recruits_pending)
	desired = min(4, desired + free_slots)
	while shop_recruit_offers.size() < desired and tries < 100:
		tries += 1
		var roll_trait: float = _rng.randf()
		var trait_name: String = "BLOOD"
		if roll_trait < 0.70:
			trait_name = "BLOOD"
		elif roll_trait < 0.95:
			trait_name = "BONE"
		else:
			trait_name = "VOID"

		var tier: int = _roll_tier_weighted()
		if trait_name == "VOID":
			tier = 0

		var dup: bool = false
		for f in shop_recruit_offers:
			if f["trait"] == trait_name and int(f["tier"]) == tier:
				dup = true
				break
		if dup:
			continue
		var trait_id: String = ""
		var roll_trait_bonus: float = _rng.randf()
		var omen_copies: int = int(relic_inventory.get("Omen Deck", 0))
		var omen_ledger_copies: int = int(relic_inventory.get("The Omen Ledger", 0))
		var bonus_rare: float = 0.10 * float(omen_copies)
		var bonus_legendary: float = (0.03 * float(omen_ledger_copies)) if omen_copies > 0 else 0.0
		var legendary_cut: float = min(0.95, SHOP_LEGENDARY_TRAIT_CHANCE + bonus_legendary)
		var rare_cut: float = min(0.98, legendary_cut + SHOP_RARE_TRAIT_CHANCE + bonus_rare)
		var common_cut: float = min(1.0, rare_cut + SHOP_COMMON_TRAIT_CHANCE)
		if roll_trait_bonus < legendary_cut:
			trait_id = _random_trait_id("LEGENDARY")
		elif roll_trait_bonus < rare_cut:
			trait_id = _random_trait_id("RARE")
		elif roll_trait_bonus < common_cut:
			trait_id = _random_trait_id("COMMON")
		shop_recruit_offers.append(_make_specific_follower(trait_name, tier, "recruit_shop", trait_id))
		shop_recruit_purchased.append(false)
		shop_recruit_free.append(shop_recruit_offers.size() <= free_slots)
	trine_offering_free_recruits_pending = 0

func buy_shop_recruit(index: int) -> Dictionary:
	if index < 0 or index >= shop_recruit_offers.size():
		return {"ok": false, "reason": "invalid"}
	var is_copy_purchase: bool = false
	if shop_recruit_purchased[index]:
		if relic_inventory["Votive Mirror"] > 0 and not shop_copy_used:
			is_copy_purchase = true
		else:
			return {"ok": false, "reason": "purchased"}
	var is_free: bool = index < shop_recruit_free.size() and bool(shop_recruit_free[index])
	if not is_free and blood_currency < 1:
		return {"ok": false, "reason": "blood"}
	if is_pool_at_capacity():
		return {"ok": false, "reason": "full"}
	if not is_free:
		blood_currency -= 1
	var f: Dictionary = shop_recruit_offers[index].duplicate()
	if relic_inventory["Grave Ledger"] > 0 and not shop_first_recruit_boost_used and f["trait"] != "VOID":
		var boosted: int = min(MAX_TIER, int(f["tier"]) + relic_inventory["Grave Ledger"])
		f["tier"] = boosted
		shop_first_recruit_boost_used = true
	shop_recruit_purchased[index] = true
	if index < shop_recruit_free.size():
		shop_recruit_free[index] = false
	shop_any_purchase_this_visit = true
	if is_copy_purchase:
		shop_copy_used = true
	log_message("Shop recruit purchased: %s tier %d (id %d), blood now %d, pool size %d" % [
		f["trait"], int(f["tier"]), int(f["id"]), blood_currency, pool.size()
	])
	pool.append(f)
	_refresh_bloodline_registers(true)
	return {"ok": true}

func ensure_pool_minimum_for_draw() -> void:
	var available: int = 0
	var nested_ids: Dictionary = _nested_id_set()
	for f in pool:
		if not nested_ids.has(int(f.get("id", -1))):
			available += 1
	if available >= 6:
		return
	var needed: int = 6 - available
	for i in range(needed):
		pool.append(_make_specific_follower("SOUL", 1, "soul"))

func draw_hand_from_pool() -> void:
	if is_tutorial_active():
		current_hand.clear()
		var week_data: Dictionary = tutorial_week_data(current_week)
		var round_hands: Dictionary = week_data.get("round_hands", {})
		var scripted_specs: Array = round_hands.get(week_round, [])
		if not scripted_specs.is_empty():
			for raw_spec in scripted_specs:
				if not (raw_spec is Dictionary):
					continue
				var spec: Dictionary = raw_spec as Dictionary
				current_hand.append(_tutorial_take_matching_from_pool(spec))
		ensure_pool_minimum_for_draw()
		var nested_ids_scripted: Dictionary = _nested_id_set()
		var fallback_candidates: Array[Dictionary] = []
		for f in pool:
			if not nested_ids_scripted.has(int(f.get("id", -1))):
				fallback_candidates.append(f)
		_shuffle_array(fallback_candidates)
		var needed: int = max(0, 6 - current_hand.size())
		for i in range(min(needed, fallback_candidates.size())):
			var fallback_id: int = int(fallback_candidates[i].get("id", -1))
			for p in range(pool.size()):
				if int(pool[p].get("id", -1)) == fallback_id:
					current_hand.append(pool[p])
					pool.remove_at(p)
					break
		return
	ensure_pool_minimum_for_draw()
	current_hand.clear()
	var nested_ids: Dictionary = _nested_id_set()
	var candidates: Array[Dictionary] = []
	for f in pool:
		if not nested_ids.has(int(f.get("id", -1))):
			candidates.append(f)
	_shuffle_array(candidates)
	var draw_count: int = min(6, candidates.size())
	var drawn_ids: Array[int] = []
	for i in range(draw_count):
		drawn_ids.append(int(candidates[i].get("id", -1)))
	for drawn_id in drawn_ids:
		for p in range(pool.size()):
			if int(pool[p].get("id", -1)) == drawn_id:
				current_hand.append(pool[p])
				pool.remove_at(p)
				break

func resolve_play_and_update_pool(selected_indices: Array[int]) -> void:
	var selected_set: Dictionary = {}
	for idx in selected_indices:
		selected_set[idx] = true
	var mass_offering_active: bool = int(relic_inventory.get("Mass Offering", 0)) > 0 and selected_indices.size() == 4
	var lineage_harvest_active: bool = int(relic_inventory.get("Lineage Harvest", 0)) > 0
	var single_rite_return_active: bool = int(relic_inventory.get("Single Rite", 0)) > 0 and selected_indices.size() == 1
	var theorem_copies: int = int(relic_inventory.get("Bloodline Theorem", 0))
	var consume_fifth_idx: int = -1
	if int(relic_inventory.get("The Expanding Contract", 0)) > 0 and selected_indices.size() >= 5:
		consume_fifth_idx = int(selected_indices[selected_indices.size() - 1])
	var rebirth_idx: int = -1
	if ritual_rebirth_pending and not selected_indices.is_empty():
		var picks: Array[int] = selected_indices.duplicate()
		_shuffle_array(picks)
		rebirth_idx = picks[0]
	var survivors: Array[Dictionary] = []
	for i in range(current_hand.size()):
		var f: Dictionary = current_hand[i]
		if selected_set.has(i):
			var should_return: bool = false
			var single_rite_return: bool = false
			if i == rebirth_idx:
				should_return = true
			if last_resilient_saved_ids.has(int(f["id"])):
				should_return = true
			if mass_offering_active:
				should_return = true
			if lineage_harvest_active:
				var origin_tag: String = str(f.get("origin_tag", ""))
				if origin_tag == "nest_bred" or origin_tag == "wild_bred":
					should_return = true
			if single_rite_return_active:
				should_return = true
				single_rite_return = true
			if i == consume_fifth_idx:
				should_return = false
				single_rite_return = false
			if should_return:
				if theorem_copies > 0 and str(f.get("trait", "")) == "BLOOD":
					f["tier"] = min(MAX_TIER, int(f.get("tier", 0)) + theorem_copies)
				if single_rite_return:
					f["tier"] = min(MAX_TIER, int(f.get("tier", 0)) + 1)
				f["exhausted"] = false
				pool.append(f)
		else:
			survivors.append(f)
	for s in survivors:
		s["exhausted"] = false
		pool.append(s)
	current_hand.clear()
	last_resilient_saved_ids.clear()
	ritual_rebirth_pending = false
	if int(relic_inventory.get("Warden of the Fold", 0)) > 0:
		for c in range(int(relic_inventory.get("Warden of the Fold", 0))):
			var low_idx: int = -1
			var low_tier: int = 9999
			for i in range(pool.size()):
				var tr: String = str(pool[i].get("trait", ""))
				if tr == "SOUL" or tr == "VOID":
					continue
				var tier: int = int(pool[i].get("tier", 0))
				if tier < low_tier:
					low_tier = tier
					low_idx = i
			if low_idx >= 0:
				pool[low_idx]["tier"] = min(MAX_TIER, int(pool[low_idx].get("tier", 0)) + 1)
	if int(relic_inventory.get("The Hungry Altar", 0)) > 0:
		var non_nested: Array[int] = []
		var nested_ids: Dictionary = _nested_id_set()
		for f in pool:
			var fid: int = int(f.get("id", -1))
			if fid < 0 or nested_ids.has(fid):
				continue
			if str(f.get("trait", "")) == "SOUL":
				continue
			non_nested.append(fid)
		if not non_nested.is_empty():
			_shuffle_array(non_nested)
			cull_follower_by_id(int(non_nested[0]), false)
	_refresh_bloodline_registers(true)

func perform_weekly_breeding(week_cleared: int) -> void:
	if is_tutorial_active():
		var tutorial_nest_summary: Dictionary = resolve_nest_breeding(week_cleared)
		var tutorial_wild_summary: Dictionary = resolve_wild_breeding(week_cleared)
		favored_breeder_ids.clear()
		for i in range(nests.size()):
			var tutorial_entry: Dictionary = nests[i]
			tutorial_entry["focus"] = NEST_FOCUS_NONE
			nests[i] = tutorial_entry
		last_breeding_summary = "Breeding Update (Week %d)\nNest newborns: %d\nWild newborns: %d\nPool: %d -> %d\nBlood: %d  Bone: %d  Void: %d  Soul: %d\nTrimmed: %d" % [
			week_cleared,
			int(tutorial_nest_summary.get("newborns", 0)),
			int(tutorial_wild_summary.get("newborns", 0)),
			int(tutorial_nest_summary.get("before", pool.size())),
			int(tutorial_wild_summary.get("after", pool.size())),
			int(tutorial_wild_summary.get("blood", 0)),
			int(tutorial_wild_summary.get("bone", 0)),
			int(tutorial_wild_summary.get("void", 0)),
			int(tutorial_wild_summary.get("soul", 0)),
			int(tutorial_nest_summary.get("trimmed", 0)) + int(tutorial_wild_summary.get("trimmed", 0)),
		]
		return
	var nest_summary: Dictionary = resolve_nest_breeding(week_cleared)
	var wild_summary: Dictionary = resolve_wild_breeding(week_cleared)
	if int(relic_inventory.get("The Breeding Engine", 0)) > 0 and breeding_engine_used_week != week_cleared:
		var wild_extra: Dictionary = resolve_wild_breeding(week_cleared)
		wild_summary["newborns"] = int(wild_summary.get("newborns", 0)) + int(wild_extra.get("newborns", 0))
		wild_summary["trimmed"] = int(wild_summary.get("trimmed", 0)) + int(wild_extra.get("trimmed", 0))
		wild_summary["after"] = int(wild_extra.get("after", wild_summary.get("after", pool.size())))
		wild_summary["blood"] = int(wild_extra.get("blood", wild_summary.get("blood", 0)))
		wild_summary["bone"] = int(wild_extra.get("bone", wild_summary.get("bone", 0)))
		wild_summary["void"] = int(wild_extra.get("void", wild_summary.get("void", 0)))
		wild_summary["soul"] = int(wild_extra.get("soul", wild_summary.get("soul", 0)))
		breeding_engine_used_week = week_cleared
	if bloodline_compact_legendary_seen_week == week_cleared and int(relic_inventory.get("The Bloodline Compact", 0)) > 0:
		var compact_gain: int = 3 * int(relic_inventory.get("The Bloodline Compact", 0))
		add_blood(compact_gain)
		bloodline_compact_bonus_pending += compact_gain
	favored_breeder_ids.clear()
	for i in range(nests.size()):
		var entry: Dictionary = nests[i]
		entry["focus"] = NEST_FOCUS_NONE
		nests[i] = entry
	last_breeding_summary = "Breeding Update (Week %d)\nNest newborns: %d\nWild newborns: %d\nPool: %d -> %d\nBlood: %d  Bone: %d  Void: %d  Soul: %d\nTrimmed: %d" % [
		week_cleared,
		int(nest_summary.get("newborns", 0)),
		int(wild_summary.get("newborns", 0)),
		int(nest_summary.get("before", pool.size())),
		int(wild_summary.get("after", pool.size())),
		int(wild_summary.get("blood", 0)),
		int(wild_summary.get("bone", 0)),
		int(wild_summary.get("void", 0)),
		int(wild_summary.get("soul", 0)),
		int(nest_summary.get("trimmed", 0)) + int(wild_summary.get("trimmed", 0)),
	]

func resolve_nest_breeding(week_cleared: int) -> Dictionary:
	if is_tutorial_active():
		return _tutorial_resolve_nest_breeding(week_cleared)
	_sanitize_nests()
	last_nest_results.clear()
	var before: int = pool.size()
	var newborns: int = 0
	var trimmed: int = 0
	var forge_copies: int = int(relic_inventory.get("The Inheritance Forge", 0))
	var generation_mark_copies: int = int(relic_inventory.get("The Generation Mark", 0))
	var bloodline_compact_copies: int = int(relic_inventory.get("The Bloodline Compact", 0))
	var primogeniture_copies: int = int(relic_inventory.get("The Primogeniture", 0))
	var womb_available: bool = int(relic_inventory.get("The Womb of Ages", 0)) > 0 and not womb_of_ages_used_run
	for n in range(nests.size()):
		var entry: Dictionary = nests[n]
		var a_id: int = int(entry.get("a", -1))
		var b_id: int = int(entry.get("b", -1))
		var focus_mode: String = _nest_entry_focus(entry)
		var result: Dictionary = {
			"nest": n + 1,
			"a_id": a_id,
			"b_id": b_id,
			"focus": focus_mode,
			"success": false,
			"reason": "",
			"baby": {},
		}
		if a_id < 0 or b_id < 0:
			result["reason"] = "missing parent"
			last_nest_results.append(result)
			continue
		var a: Dictionary = _get_pool_follower_by_id(a_id)
		var b: Dictionary = _get_pool_follower_by_id(b_id)
		if a.is_empty() or b.is_empty():
			result["reason"] = "parent missing from pool"
			last_nest_results.append(result)
			continue
		if str(a.get("trait", "")) == "SOUL" or str(b.get("trait", "")) == "SOUL":
			result["reason"] = "SOUL cannot breed"
			last_nest_results.append(result)
			continue
		var baby_trait: String = _inherit_trait_breeding(str(a.get("trait", "")), str(b.get("trait", "")))
		var base_tier: int = _base_tier_from_parents_for_offspring_trait(a, b, baby_trait)
		if base_tier > 0:
			var roll: float = _rng.randf()
			if roll < 0.2:
				base_tier += 1
			elif roll < 0.3:
				base_tier -= 1
			base_tier = clamp(base_tier, 1, MAX_TIER)
		if generation_mark_copies > 0 and int(a.get("tier", 0)) >= 5 and int(b.get("tier", 0)) >= 5:
			base_tier = min(MAX_TIER, base_tier + generation_mark_copies)
		base_tier = min(MAX_TIER, base_tier + _consume_grave_compact_bonus())
		if baby_trait == "VOID":
			base_tier = 0
		var dynasty_seal_copies: int = int(relic_inventory.get("Dynasty Seal", 0))
		if dynasty_seal_copies > 0 and int(a.get("tier", 0)) >= 8 and int(b.get("tier", 0)) >= 8:
			base_tier = 0 if baby_trait == "VOID" else 6
		var flags: Dictionary = _nest_parent_flags(a, b)
		var parent_a_tid: String = str(flags.get("parent_a_tid", ""))
		var parent_b_tid: String = str(flags.get("parent_b_tid", ""))
		var parent_a_traits: Array[String] = _trait_ids_for_follower(a)
		var parent_b_traits: Array[String] = _trait_ids_for_follower(b)
		var has_lineage_tutor: bool = bool(flags.get("has_lineage_tutor", false))
		var has_apostolic_womb: bool = bool(flags.get("has_apostolic_womb", false))
		var has_legendary_nest_dynasty: bool = bool(flags.get("has_legendary_nest_dynasty", false))
		base_tier = _apply_nest_tier_bonuses(base_tier, flags, focus_mode)
		var trait_id: String = _resolve_nest_trait_id(a, b, focus_mode)
		if primogeniture_copies > 0 and not primogeniture_used_run:
			var combo_pick: String = _pick_any_combo_trait_for_parent_trait_lists(parent_a_traits, parent_b_traits)
			var inherit_roll: float = _rng.randf()
			var inherit_chance: float = min(1.0, 0.50 + (0.25 * float(primogeniture_copies)))
			if combo_pick != "" and inherit_roll < inherit_chance:
				trait_id = combo_pick
			elif parent_a_tid != "" and parent_b_tid != "":
				trait_id = parent_a_tid if _rng.randf() < 0.5 else parent_b_tid
			primogeniture_used_run = true
		if has_apostolic_womb:
			var parent_traits: Array[String] = []
			if parent_a_tid != "":
				parent_traits.append(parent_a_tid)
			if parent_b_tid != "":
				parent_traits.append(parent_b_tid)
			if not parent_traits.is_empty():
				trait_id = parent_traits[_rng.randi_range(0, parent_traits.size() - 1)]
		elif has_lineage_tutor and trait_id == "":
			var tutor_chance: float = 0.55 if has_legendary_nest_dynasty else 0.35
			if _rng.randf() < tutor_chance:
				trait_id = _random_trait_id("COMMON")
		if bool(flags.get("has_brood_sovereign", false)) and trait_id == "" and _rng.randf() < 0.40:
			trait_id = _random_trait_id("RARE")
		var apostle_parent: bool = bool(flags.get("apostle_parent", false))
		var apostle_parent_tid: String = ""
		if apostle_parent:
			apostle_parent_tid = str(a.get("trait_id", "")) if int(a.get("id", -1)) == apostle_id else str(b.get("trait_id", ""))
			trait_id = apostle_parent_tid
		if is_pool_at_capacity():
			result["reason"] = "pool full"
			trimmed += 1
			last_nest_results.append(result)
			continue
		var baby: Dictionary = _make_specific_follower(baby_trait, base_tier, "nest_bred", trait_id)
		baby["lineage"] = _compute_nest_offspring_lineage(a, b, focus_mode, trait_id)
		var extra_slot_count: int = _roll_offspring_trait_count(a, b) - 1
		if extra_slot_count > 0:
			baby["trait_ids"] = _roll_additional_trait_ids(a, b, str(baby.get("trait_id", "")), extra_slot_count)
		else:
			baby["trait_ids"] = []
		pool.append(baby)
		newborns += 1
		if bloodline_compact_copies > 0 and str(baby.get("trait", "")) != "VOID" and _trait_rarity(str(baby.get("trait_id", ""))) == "LEGENDARY":
			baby["tier"] = min(MAX_TIER, int(baby.get("tier", 0)) + 1)
			bloodline_compact_legendary_seen_week = week_cleared
			pool[pool.size() - 1] = baby
		result["success"] = true
		result["baby"] = baby
		var extra_births: int = forge_copies
		if womb_available:
			extra_births += 1
			womb_available = false
			womb_of_ages_used_run = true
		for e in range(extra_births):
			if is_pool_at_capacity():
				trimmed += 1
				break
			var extra_trait_id: String = _resolve_nest_trait_id(a, b, focus_mode)
			if apostle_parent:
				extra_trait_id = apostle_parent_tid
			var extra_tier: int = min(MAX_TIER, base_tier + _consume_grave_compact_bonus())
			var extra_baby: Dictionary = _make_specific_follower(baby_trait, extra_tier, "nest_bred", extra_trait_id)
			extra_baby["lineage"] = _compute_nest_offspring_lineage(a, b, focus_mode, extra_trait_id)
			var extra_slots: int = _roll_offspring_trait_count(a, b) - 1
			if extra_slots > 0:
				extra_baby["trait_ids"] = _roll_additional_trait_ids(a, b, str(extra_baby.get("trait_id", "")), extra_slots)
			else:
				extra_baby["trait_ids"] = []
			if bloodline_compact_copies > 0 and str(extra_baby.get("trait", "")) != "VOID" and _trait_rarity(str(extra_baby.get("trait_id", ""))) == "LEGENDARY":
				extra_baby["tier"] = min(MAX_TIER, int(extra_baby.get("tier", 0)) + 1)
				bloodline_compact_legendary_seen_week = week_cleared
			pool.append(extra_baby)
			newborns += 1
		last_nest_results.append(result)

	var summary: Dictionary = pool_summary_counts()
	log_message("NEST BREEDING | Week %d | Pool %d->%d | Nests %d | Newborns %d | Trimmed %d" % [
		week_cleared,
		before,
		pool.size(),
		nests.size(),
		newborns,
		trimmed,
	])
	last_breeding_summary = "Nest Update (Week %d)\nPool: %d -> %d\nNests: %d\nNewborns: %d\nBlood: %d  Bone: %d  Void: %d  Soul: %d\nTrimmed: %d" % [
		week_cleared,
		before,
		pool.size(),
		nests.size(),
		newborns,
		summary["blood"],
		summary["bone"],
		summary["void"],
		summary["soul"],
		trimmed,
	]
	_refresh_bloodline_registers(true)
	return {
		"before": before,
		"after": pool.size(),
		"newborns": newborns,
		"trimmed": trimmed,
		"blood": int(summary.get("blood", 0)),
		"bone": int(summary.get("bone", 0)),
		"void": int(summary.get("void", 0)),
		"soul": int(summary.get("soul", 0)),
	}

func resolve_wild_breeding(week_cleared: int) -> Dictionary:
	if is_tutorial_active():
		return _tutorial_resolve_wild_breeding(week_cleared)
	_sanitize_nests()
	_ensure_dynasty_forge_pair()
	var before: int = pool.size()
	var trimmed: int = 0
	var newborns: int = 0
	var attempted_pairs: int = 0
	var successful_pairs: int = 0
	var favored_pair_attempted: int = 0
	var favored_pair_success: int = 0
	var nested_ids: Dictionary = _nested_id_set()
	var candidates: Array[Dictionary] = []
	for follower in pool:
		var fid: int = int(follower.get("id", -1))
		if nested_ids.has(fid):
			continue
		if str(follower.get("trait", "")) == "SOUL":
			continue
		candidates.append(follower)
	var favored_a_id: int = -1
	var favored_b_id: int = -1
	if favored_breeder_ids.size() >= 2:
		favored_a_id = int(favored_breeder_ids[0])
		favored_b_id = int(favored_breeder_ids[1])
	if int(relic_inventory.get("The Dynasty Forge", 0)) > 0 and dynasty_forge_set_run:
		favored_a_id = int(dynasty_forge_pair[0])
		favored_b_id = int(dynasty_forge_pair[1])
	_shuffle_array(candidates)
	if favored_a_id >= 0 and favored_b_id >= 0 and favored_a_id != favored_b_id:
		var idx_a: int = -1
		var idx_b: int = -1
		for i in range(candidates.size()):
			var fid: int = int(candidates[i].get("id", -1))
			if fid == favored_a_id:
				idx_a = i
			elif fid == favored_b_id:
				idx_b = i
		if idx_a >= 0 and idx_b >= 0:
			if idx_a != 0:
				var tmp_a = candidates[0]
				candidates[0] = candidates[idx_a]
				candidates[idx_a] = tmp_a
			if idx_b == 0:
				idx_b = idx_a
			if idx_b != 1:
				var tmp_b = candidates[1]
				candidates[1] = candidates[idx_b]
				candidates[idx_b] = tmp_b
	var pair_count: int = int(candidates.size() / 2)
	for i in range(pair_count):
		var a: Dictionary = candidates[i * 2]
		var b: Dictionary = candidates[(i * 2) + 1]
		attempted_pairs += 1
		var is_favored_pair: bool = (
			favored_a_id >= 0
			and favored_b_id >= 0
			and int(a.get("id", -1)) != int(b.get("id", -1))
			and (
				(int(a.get("id", -1)) == favored_a_id and int(b.get("id", -1)) == favored_b_id)
				or (int(a.get("id", -1)) == favored_b_id and int(b.get("id", -1)) == favored_a_id)
			)
		)
		var chance: float = _breeding_chance(str(a.get("trait", "")), str(b.get("trait", "")))
		if int(relic_inventory.get("Void Pilgrim", 0)) > 0 and str(a.get("trait", "")) == "VOID" and str(b.get("trait", "")) == "VOID":
			chance = 1.0
		if is_favored_pair:
			favored_pair_attempted += 1
			chance = min(0.95, chance + 0.20)
		if _rng.randf() > chance:
			continue
		var baby_trait: String = _inherit_trait_breeding(str(a.get("trait", "")), str(b.get("trait", "")))
		var base_tier: int = _base_tier_from_parents_for_offspring_trait(a, b, baby_trait)
		if base_tier > 0:
			var roll: float = _rng.randf()
			if roll < 0.2:
				base_tier += 1
			elif roll < 0.3:
				base_tier -= 1
			base_tier = clamp(base_tier, 1, MAX_TIER)
		base_tier = min(MAX_TIER, base_tier + _consume_grave_compact_bonus())
		if baby_trait == "VOID":
			base_tier = 0
		var dynasty_seal_copies: int = int(relic_inventory.get("Dynasty Seal", 0))
		if dynasty_seal_copies > 0 and int(a.get("tier", 0)) >= 8 and int(b.get("tier", 0)) >= 8:
			base_tier = 0 if baby_trait == "VOID" else 6
		var apostle_parent: bool = apostle_id >= 0 and (int(a.get("id", -1)) == apostle_id or int(b.get("id", -1)) == apostle_id)
		if apostle_parent and base_tier > 0:
			base_tier = min(MAX_TIER, base_tier + 1)
		var trait_id: String = _roll_wild_breeding_trait(a, b)
		if apostle_parent:
			trait_id = str(a.get("trait_id", "")) if int(a.get("id", -1)) == apostle_id else str(b.get("trait_id", ""))
		if is_pool_at_capacity():
			trimmed += 1
			continue
		var baby: Dictionary = _make_specific_follower(baby_trait, base_tier, "wild_bred", trait_id)
		baby["lineage"] = _compute_wild_offspring_lineage(a, b)
		var extra_slot_count: int = _roll_offspring_trait_count(a, b) - 1
		if extra_slot_count > 0:
			baby["trait_ids"] = _roll_additional_trait_ids(a, b, str(baby.get("trait_id", "")), extra_slot_count)
		else:
			baby["trait_ids"] = []
		if int(relic_inventory.get("The Bloodline Compact", 0)) > 0 and str(baby.get("trait", "")) != "VOID" and _trait_rarity(str(baby.get("trait_id", ""))) == "LEGENDARY":
			baby["tier"] = min(MAX_TIER, int(baby.get("tier", 0)) + 1)
			bloodline_compact_legendary_seen_week = week_cleared
		pool.append(baby)
		newborns += 1
		successful_pairs += 1
		if is_favored_pair:
			favored_pair_success += 1
	var summary: Dictionary = pool_summary_counts()
	log_message("WILD BREEDING | Week %d | Pairs %d/%d | Favored %d/%d | Pool %d->%d | Newborns %d | Trimmed %d" % [
		week_cleared,
		successful_pairs,
		attempted_pairs,
		favored_pair_success,
		favored_pair_attempted,
		before,
		pool.size(),
		newborns,
		trimmed,
	])
	_refresh_bloodline_registers(true)
	return {
		"before": before,
		"after": pool.size(),
		"newborns": newborns,
		"trimmed": trimmed,
		"blood": int(summary.get("blood", 0)),
		"bone": int(summary.get("bone", 0)),
		"void": int(summary.get("void", 0)),
		"soul": int(summary.get("soul", 0)),
	}

func _tutorial_resolve_nest_breeding(week_cleared: int) -> Dictionary:
	_sanitize_nests()
	last_nest_results.clear()
	var before: int = pool.size()
	var newborns: int = 0
	var trimmed: int = 0
	var week_data: Dictionary = tutorial_week_data(week_cleared)
	var scripted: Array = week_data.get("nest_results", [])
	var scripted_by_nest: Dictionary = {}
	for item in scripted:
		if item is Dictionary:
			var row: Dictionary = item as Dictionary
			scripted_by_nest[int(row.get("nest", 0))] = row
	for n in range(nests.size()):
		var entry: Dictionary = nests[n]
		var a_id: int = int(entry.get("a", -1))
		var b_id: int = int(entry.get("b", -1))
		var focus_mode: String = _nest_entry_focus(entry)
		var result: Dictionary = {
			"nest": n + 1,
			"a_id": a_id,
			"b_id": b_id,
			"focus": focus_mode,
			"success": false,
			"reason": "",
			"baby": {},
		}
		if a_id < 0 or b_id < 0:
			result["reason"] = "missing parent"
			last_nest_results.append(result)
			continue
		if not scripted_by_nest.has(n + 1):
			result["reason"] = "no scripted outcome"
			last_nest_results.append(result)
			continue
		var scripted_row: Dictionary = scripted_by_nest[n + 1]
		var scripted_success: bool = bool(scripted_row.get("success", false))
		if not scripted_success:
			result["reason"] = str(scripted_row.get("reason", "no offspring"))
			last_nest_results.append(result)
			continue
		if is_pool_at_capacity():
			result["reason"] = "pool full"
			trimmed += 1
			last_nest_results.append(result)
			continue
		var baby_spec: Dictionary = scripted_row.get("baby", {})
		if baby_spec.is_empty():
			result["reason"] = "no offspring"
			last_nest_results.append(result)
			continue
		var baby: Dictionary = _tutorial_make_follower(baby_spec, "nest_bred")
		pool.append(baby)
		newborns += 1
		result["success"] = true
		result["baby"] = baby
		last_nest_results.append(result)
	var summary: Dictionary = pool_summary_counts()
	_refresh_bloodline_registers(true)
	return {
		"before": before,
		"after": pool.size(),
		"newborns": newborns,
		"trimmed": trimmed,
		"blood": int(summary.get("blood", 0)),
		"bone": int(summary.get("bone", 0)),
		"void": int(summary.get("void", 0)),
		"soul": int(summary.get("soul", 0)),
	}

func _tutorial_resolve_wild_breeding(week_cleared: int) -> Dictionary:
	var before: int = pool.size()
	var newborns: int = 0
	var trimmed: int = 0
	var week_data: Dictionary = tutorial_week_data(week_cleared)
	var scripted: Array = week_data.get("wild_results", [])
	for item in scripted:
		if not (item is Dictionary):
			continue
		if is_pool_at_capacity():
			trimmed += 1
			continue
		var baby_spec: Dictionary = item as Dictionary
		var baby: Dictionary = _tutorial_make_follower(baby_spec, "wild_bred")
		pool.append(baby)
		newborns += 1
	var summary: Dictionary = pool_summary_counts()
	_refresh_bloodline_registers(true)
	return {
		"before": before,
		"after": pool.size(),
		"newborns": newborns,
		"trimmed": trimmed,
		"blood": int(summary.get("blood", 0)),
		"bone": int(summary.get("bone", 0)),
		"void": int(summary.get("void", 0)),
		"soul": int(summary.get("soul", 0)),
	}

func _breeding_chance(a: String, b: String) -> float:
	if a == "VOID" and b == "VOID":
		return 0.30
	if a == "VOID" or b == "VOID":
		return 0.20
	var base: float = 0.45
	var fertility_copies: int = relic_inventory["Fertility Idol"]
	var brood_copies: int = int(relic_inventory.get("The Brood Compact", 0))
	if fertility_copies > 0:
		base += 0.10 * float(fertility_copies)
	if brood_copies > 0:
		base += 0.05 * float(brood_copies)
	return min(0.95, base)

func boost_pool_tiers_weekly() -> void:
	for i in range(pool.size()):
		if pool[i]["trait"] == "VOID":
			continue
		pool[i]["tier"] = min(MAX_TIER, int(pool[i]["tier"]) + 1)
	_refresh_bloodline_registers(true)

func _inherit_trait_breeding(a: String, b: String) -> String:
	var type_a: String = a.strip_edges().to_upper()
	var type_b: String = b.strip_edges().to_upper()
	if type_a != "" and type_a == type_b:
		# Hard guarantee: two parents of the same type always produce that type.
		return type_a
	var pick: String = type_a if _rng.randf() < 0.5 else type_b
	if (type_a == "VOID" or type_b == "VOID") and pick == "VOID":
		return "VOID" if _rng.randf() < 0.30 else (type_b if type_a == "VOID" else type_a)
	return pick

func _trait_info(trait_id: String) -> Dictionary:
	if trait_id == "":
		return {}
	if TRAIT_REGISTRY.has(trait_id):
		return TRAIT_REGISTRY[trait_id]
	var combo_info: Dictionary = get_combo_trait(trait_id)
	if not combo_info.is_empty():
		return combo_info
	return {}

func _combo_template_id(trait_id: String) -> String:
	if trait_id == "":
		return ""
	var combo_info: Dictionary = get_combo_trait(trait_id)
	if combo_info.is_empty():
		return ""
	return str(combo_info.get("template", ""))

func _rarity_rank(rarity: String) -> int:
	match rarity:
		"COMMON":
			return 1
		"RARE":
			return 2
		"LEGENDARY":
			return 3
		_:
			return 0

func _compute_nest_rarity_probabilities(parent_a: Dictionary, parent_b: Dictionary, nest_focus: String = NEST_FOCUS_NONE) -> Dictionary:
	var focus_mode: String = _normalize_nest_focus(nest_focus)
	var rarity_a: String = _trait_rarity(str(parent_a.get("trait_id", "")))
	var rarity_b: String = _trait_rarity(str(parent_b.get("trait_id", "")))
	var flags: Dictionary = _nest_parent_flags(parent_a, parent_b)
	var parent_a_tid: String = str(flags.get("parent_a_tid", ""))
	var parent_b_tid: String = str(flags.get("parent_b_tid", ""))
	var has_nest_dynasty: bool = bool(flags.get("has_nest_dynasty", false))
	var has_legendary_nest_dynasty: bool = bool(flags.get("has_legendary_nest_dynasty", false))
	var has_brood_sovereign: bool = bool(flags.get("has_brood_sovereign", false))
	var has_lineage_tutor: bool = bool(flags.get("has_lineage_tutor", false))
	var has_chosen_veil: bool = bool(flags.get("has_chosen_veil", false))
	var has_selective_scroll: bool = bool(flags.get("has_selective_scroll", false))
	var has_favored_parent: bool = bool(flags.get("has_favored_parent", false))
	if relic_inventory["Seal of Inheritance"] > 0:
		var inherited_probs := {"common": 0.0, "rare": 0.0, "legendary": 0.0}
		if parent_a_tid != "" and parent_b_tid != "":
			var rarity_a_key: String = _trait_rarity(parent_a_tid).to_lower()
			var rarity_b_key: String = _trait_rarity(parent_b_tid).to_lower()
			if inherited_probs.has(rarity_a_key):
				inherited_probs[rarity_a_key] = float(inherited_probs[rarity_a_key]) + 0.5
			if inherited_probs.has(rarity_b_key):
				inherited_probs[rarity_b_key] = float(inherited_probs[rarity_b_key]) + 0.5
			return inherited_probs
		if parent_a_tid != "" or parent_b_tid != "":
			var only_tid: String = parent_a_tid if parent_a_tid != "" else parent_b_tid
			var only_key: String = _trait_rarity(only_tid).to_lower()
			if inherited_probs.has(only_key):
				inherited_probs[only_key] = 1.0
				return inherited_probs

	var a_legendary: bool = rarity_a == "LEGENDARY"
	var b_legendary: bool = rarity_b == "LEGENDARY"
	var a_rare: bool = rarity_a == "RARE"
	var b_rare: bool = rarity_b == "RARE"
	var single_rare_chance: float = NEST_SINGLE_RARE_TO_RARE_CHANCE
	var rare_from_legendary_chance: float = NEST_LEGENDARY_TO_RARE_CHANCE
	var common_to_rare_chance: float = 0.0
	if has_lineage_tutor:
		single_rare_chance += 0.35
		rare_from_legendary_chance -= 0.10
		common_to_rare_chance += 0.35
	if has_nest_dynasty:
		single_rare_chance += 0.15
		rare_from_legendary_chance -= 0.10
		common_to_rare_chance += 0.20
	if has_legendary_nest_dynasty:
		single_rare_chance += 0.10
		rare_from_legendary_chance -= 0.05
		common_to_rare_chance += 0.10
	if has_brood_sovereign:
		single_rare_chance += 0.20
		rare_from_legendary_chance -= 0.10
		common_to_rare_chance += 0.20
	if has_chosen_veil:
		single_rare_chance = max(single_rare_chance, 0.75)
		rare_from_legendary_chance -= 0.15
		common_to_rare_chance = max(common_to_rare_chance, 0.35)
	if has_selective_scroll:
		single_rare_chance += 0.15
		rare_from_legendary_chance -= 0.10
		common_to_rare_chance += 0.15
	if has_favored_parent:
		single_rare_chance += 0.10
		rare_from_legendary_chance -= 0.05
		common_to_rare_chance += 0.10
	if focus_mode == NEST_FOCUS_RARITY:
		single_rare_chance += 0.20
		rare_from_legendary_chance -= 0.10
		common_to_rare_chance += 0.20
	single_rare_chance = clamp(single_rare_chance, 0.25, 0.95)
	rare_from_legendary_chance = clamp(rare_from_legendary_chance, 0.05, 0.95)
	common_to_rare_chance = clamp(common_to_rare_chance, 0.0, 0.80)
	var probs := {"common": 0.0, "rare": 0.0, "legendary": 0.0}
	if a_legendary and b_legendary:
		probs["legendary"] = 1.0
		return probs
	if a_rare and b_rare:
		probs["rare"] = 1.0
		return probs
	if a_legendary or b_legendary:
		probs["rare"] = rare_from_legendary_chance
		probs["legendary"] = 1.0 - rare_from_legendary_chance
		return probs
	if a_rare or b_rare:
		probs["rare"] = single_rare_chance
		probs["common"] = 1.0 - single_rare_chance
		return probs
	probs["rare"] = common_to_rare_chance
	probs["common"] = 1.0 - common_to_rare_chance
	return probs

func _resolve_nest_target_rarity(parent_a: Dictionary, parent_b: Dictionary, nest_focus: String = NEST_FOCUS_NONE) -> String:
	var probs: Dictionary = _compute_nest_rarity_probabilities(parent_a, parent_b, nest_focus)
	var roll: float = _rng.randf()
	var common_chance: float = float(probs.get("common", 0.0))
	var rare_chance: float = float(probs.get("rare", 0.0))
	var legendary_chance: float = float(probs.get("legendary", 0.0))
	if roll < common_chance:
		return "COMMON"
	if roll < (common_chance + rare_chance):
		return "RARE"
	if legendary_chance > 0.0:
		return "LEGENDARY"
	return "COMMON"

func _combo_candidates_for_parent_trait_lists(parent_a_traits: Array[String], parent_b_traits: Array[String]) -> Array[String]:
	var out: Array[String] = []
	var seen: Dictionary = {}
	for a_tid in parent_a_traits:
		for b_tid in parent_b_traits:
			if a_tid == "" or b_tid == "":
				continue
			var key: String = _combo_pair_key(a_tid, b_tid)
			if not combo_trait_pair_index.has(key):
				continue
			var bucket: Array = combo_trait_pair_index[key]
			for combo_id in bucket:
				var cid: String = str(combo_id)
				if seen.has(cid):
					continue
				seen[cid] = true
				out.append(cid)
	return out

func _pick_combo_trait_for_parent_trait_lists(parent_a_traits: Array[String], parent_b_traits: Array[String], target_rarity: String) -> String:
	var combos: Array[String] = _combo_candidates_for_parent_trait_lists(parent_a_traits, parent_b_traits)
	if combos.is_empty():
		return ""
	var candidates: Array[String] = []
	for combo_id in combos:
		var combo: Dictionary = get_combo_trait(combo_id)
		var rarity: String = str(combo.get("rarity", ""))
		if rarity == target_rarity:
			candidates.append(combo_id)
	if candidates.is_empty():
		return ""
	return candidates[_rng.randi_range(0, candidates.size() - 1)]

func _pick_any_combo_trait_for_parent_trait_lists(parent_a_traits: Array[String], parent_b_traits: Array[String]) -> String:
	var combos: Array[String] = _combo_candidates_for_parent_trait_lists(parent_a_traits, parent_b_traits)
	if combos.is_empty():
		return ""
	return combos[_rng.randi_range(0, combos.size() - 1)]

func _combo_candidates_for_parents(parent_a_trait_id: String, parent_b_trait_id: String) -> Array[String]:
	var parent_a_traits: Array[String] = []
	var parent_b_traits: Array[String] = []
	if parent_a_trait_id != "":
		parent_a_traits.append(parent_a_trait_id)
	if parent_b_trait_id != "":
		parent_b_traits.append(parent_b_trait_id)
	return _combo_candidates_for_parent_trait_lists(parent_a_traits, parent_b_traits)

func _pick_combo_trait_for_parents(parent_a_trait_id: String, parent_b_trait_id: String, target_rarity: String) -> String:
	var parent_a_traits: Array[String] = []
	var parent_b_traits: Array[String] = []
	if parent_a_trait_id != "":
		parent_a_traits.append(parent_a_trait_id)
	if parent_b_trait_id != "":
		parent_b_traits.append(parent_b_trait_id)
	return _pick_combo_trait_for_parent_trait_lists(parent_a_traits, parent_b_traits, target_rarity)

func _pick_any_combo_trait_for_parents(parent_a_trait_id: String, parent_b_trait_id: String) -> String:
	var parent_a_traits: Array[String] = []
	var parent_b_traits: Array[String] = []
	if parent_a_trait_id != "":
		parent_a_traits.append(parent_a_trait_id)
	if parent_b_trait_id != "":
		parent_b_traits.append(parent_b_trait_id)
	return _pick_any_combo_trait_for_parent_trait_lists(parent_a_traits, parent_b_traits)

func _shared_parent_trait_from_lists(parent_a_traits: Array[String], parent_b_traits: Array[String]) -> String:
	var shared: Array[String] = []
	for tid in parent_a_traits:
		if tid == "":
			continue
		if parent_b_traits.has(tid) and not shared.has(tid):
			shared.append(tid)
	if shared.is_empty():
		return ""
	if shared.size() == 1:
		return shared[0]
	var best_rank: int = -1
	var best: Array[String] = []
	for tid in shared:
		var rank: int = _rarity_rank(_trait_rarity(tid))
		if rank > best_rank:
			best_rank = rank
			best = [tid]
		elif rank == best_rank:
			best.append(tid)
	return best[_rng.randi_range(0, best.size() - 1)]

func _maybe_roll_primary_trait_mutation() -> String:
	if _rng.randf() >= BREEDING_PRIMARY_MUTATION_CHANCE:
		return ""
	return _roll_random_trait_id()

func _resolve_nest_trait_id(parent_a: Dictionary, parent_b: Dictionary, nest_focus: String = NEST_FOCUS_NONE) -> String:
	var focus_mode: String = _normalize_nest_focus(nest_focus)
	var parent_a_tid: String = str(parent_a.get("trait_id", ""))
	var parent_b_tid: String = str(parent_b.get("trait_id", ""))
	var parent_a_all_traits: Array[String] = _trait_ids_for_follower(parent_a)
	var parent_b_all_traits: Array[String] = _trait_ids_for_follower(parent_b)
	var shared_trait: String = _shared_parent_trait_from_lists(parent_a_all_traits, parent_b_all_traits)
	if shared_trait != "":
		# Hard guarantee: same trait on both parents must be inherited.
		return shared_trait
	var mutation_trait: String = _maybe_roll_primary_trait_mutation()
	if mutation_trait != "":
		return mutation_trait
	if relic_inventory["Seal of Inheritance"] > 0:
		var inherited: String = _pick_parent_trait_from_lists(parent_a_all_traits, parent_b_all_traits)
		if inherited != "":
			return inherited
	if focus_mode == NEST_FOCUS_FAMILY:
		if parent_a_tid != "" and parent_a_tid == parent_b_tid:
			return parent_a_tid
		if _rng.randf() < 0.65:
			var family_inherited: String = _pick_parent_trait_from_lists(parent_a_all_traits, parent_b_all_traits)
			if family_inherited != "":
				return family_inherited
	var target_rarity: String = _resolve_nest_target_rarity(parent_a, parent_b, focus_mode)
	var combo_trait_id: String = _pick_combo_trait_for_parent_trait_lists(parent_a_all_traits, parent_b_all_traits, target_rarity)
	if combo_trait_id != "":
		return combo_trait_id
	if focus_mode == NEST_FOCUS_FAMILY and _rng.randf() < 0.40:
		var any_combo: String = _pick_any_combo_trait_for_parent_trait_lists(parent_a_all_traits, parent_b_all_traits)
		if any_combo != "":
			return any_combo
	if parent_a_tid != "" and parent_b_tid != "" and parent_a_tid == parent_b_tid and _trait_rarity(parent_a_tid) == target_rarity:
		return parent_a_tid
	var parent_matches: Array[String] = []
	for tid in parent_a_all_traits:
		if tid != "" and _trait_rarity(tid) == target_rarity and not parent_matches.has(tid):
			parent_matches.append(tid)
	for tid in parent_b_all_traits:
		if tid != "" and _trait_rarity(tid) == target_rarity and not parent_matches.has(tid):
			parent_matches.append(tid)
	if not parent_matches.is_empty():
		return parent_matches[_rng.randi_range(0, parent_matches.size() - 1)]
	if focus_mode == NEST_FOCUS_FAMILY:
		var fallback_parent: String = _pick_parent_trait_from_lists(parent_a_all_traits, parent_b_all_traits)
		if fallback_parent != "":
			return fallback_parent
	return _random_trait_id(target_rarity)

func _trait_rarity(trait_id: String) -> String:
	if trait_id == "":
		return ""
	var info: Dictionary = _trait_info(trait_id)
	if info.is_empty():
		return ""
	return str(info.get("rarity", ""))

func _trait_name(trait_id: String) -> String:
	if trait_id == "":
		return "None"
	var info: Dictionary = _trait_info(trait_id)
	if info.is_empty():
		return trait_id
	return str(info.get("name", trait_id))

func _random_trait_id(rarity: String) -> String:
	var pool: Array = []
	if rarity == "COMMON":
		pool = COMMON_TRAIT_IDS
	elif rarity == "RARE":
		pool = RARE_TRAIT_IDS
	elif rarity == "LEGENDARY":
		pool = LEGENDARY_TRAIT_IDS
	else:
		pool = COMMON_TRAIT_IDS
	if pool.is_empty():
		return ""
	return pool[_rng.randi_range(0, pool.size() - 1)]

func _roll_tier_weighted() -> int:
	var total: int = 0
	for k in TIER_WEIGHTS.keys():
		total += int(TIER_WEIGHTS[k])
	var roll: int = _rng.randi_range(1, total)
	var running: int = 0
	for k in TIER_WEIGHTS.keys():
		running += int(TIER_WEIGHTS[k])
		if roll <= running:
			return int(k)
	return 5

func _trait_ids_for_follower(f: Dictionary) -> Array[String]:
	var out: Array[String] = []
	var primary: String = str(f.get("trait_id", ""))
	if primary != "":
		out.append(primary)
	for extra in f.get("trait_ids", []):
		var tid: String = str(extra)
		if tid != "" and not out.has(tid):
			out.append(tid)
	return out

func _total_trait_count(f: Dictionary) -> int:
	var base: int = 1 if str(f.get("trait_id", "")) != "" else 0
	return base + int(f.get("trait_ids", []).size())

func _roll_offspring_trait_count(parent_a: Dictionary, parent_b: Dictionary) -> int:
	var combined: int = _total_trait_count(parent_a) + _total_trait_count(parent_b)
	var cap: int = get_max_trait_slots()
	if cap <= 1:
		return 1

	var roll: float = _rng.randf()
	var result: int = 1

	if combined <= 1:
		result = 1
	elif combined == 2:
		result = 2 if roll < 0.15 else 1
	elif combined == 3:
		if roll < 0.05:
			result = 3
		elif roll < 0.40:
			result = 2
		else:
			result = 1
	elif combined == 4:
		if roll < 0.15:
			result = 3
		elif roll < 0.60:
			result = 2
		else:
			result = 1
	elif combined == 5:
		if roll < 0.05:
			result = 4
		elif roll < 0.35:
			result = 3
		elif roll < 0.80:
			result = 2
		else:
			result = 1
	else:
		if roll < 0.15:
			result = 4
		elif roll < 0.55:
			result = 3
		elif roll < 0.90:
			result = 2
		else:
			result = 1

	return min(result, cap)

func _roll_random_trait_id() -> String:
	var roll_rarity: float = _rng.randf()
	var rarity: String = "COMMON"
	if roll_rarity < BREEDING_COMMON_CHANCE:
		rarity = "COMMON"
	elif roll_rarity < (BREEDING_COMMON_CHANCE + BREEDING_RARE_CHANCE):
		rarity = "RARE"
	else:
		rarity = "LEGENDARY"
	return _random_trait_id(rarity)

func _roll_additional_trait_ids(parent_a: Dictionary, parent_b: Dictionary, existing_trait_id: String, count: int) -> Array:
	if count <= 0:
		return []

	var parent_pool: Array[String] = []
	for tid in _trait_ids_for_follower(parent_a):
		parent_pool.append(tid)
	for tid in _trait_ids_for_follower(parent_b):
		parent_pool.append(tid)

	var result: Array[String] = []
	var used: Array[String] = []
	if existing_trait_id != "":
		used.append(existing_trait_id)

	for _i in range(count):
		var trait_id: String = ""

		if _rng.randf() < 0.10 or parent_pool.is_empty():
			trait_id = _roll_random_trait_id()
		else:
			var candidates: Array[String] = []
			for pid in parent_pool:
				if not used.has(pid):
					candidates.append(pid)
			if candidates.is_empty():
				trait_id = _roll_random_trait_id()
			else:
				trait_id = candidates[_rng.randi() % candidates.size()]
				if used.has(trait_id):
					candidates.clear()
					for pid in parent_pool:
						if not used.has(pid):
							candidates.append(pid)
					if candidates.is_empty():
						continue
					trait_id = candidates[_rng.randi() % candidates.size()]

		if trait_id != "" and not used.has(trait_id):
			result.append(trait_id)
			used.append(trait_id)

	return result

func _roll_breeding_trait(parent_a: Dictionary, parent_b: Dictionary) -> String:
	var roll_any: float = _rng.randf()
	var trait_id: String = ""
	var parent_a_traits: Array[String] = _trait_ids_for_follower(parent_a)
	var parent_b_traits: Array[String] = _trait_ids_for_follower(parent_b)
	var shared_trait: String = _shared_parent_trait_from_lists(parent_a_traits, parent_b_traits)
	if shared_trait != "":
		return shared_trait
	var mutation_trait: String = _maybe_roll_primary_trait_mutation()
	if mutation_trait != "":
		return mutation_trait
	var guaranteed: bool = parent_a_traits.has("chosen_veil") or parent_b_traits.has("chosen_veil")
	if relic_inventory["Seal of Inheritance"] > 0:
		var inherited: String = _pick_parent_trait_from_lists(parent_a_traits, parent_b_traits)
		if inherited != "":
			return inherited
	if not parent_a_traits.is_empty() or not parent_b_traits.is_empty():
		trait_id = _pick_parent_trait_from_lists(parent_a_traits, parent_b_traits)
		return trait_id

	if not guaranteed and roll_any > BREEDING_ANY_TRAIT_CHANCE:
		return ""
	var roll_rarity: float = _rng.randf()
	var rarity: String = "COMMON"
	if roll_rarity < BREEDING_COMMON_CHANCE:
		rarity = "COMMON"
	elif roll_rarity < (BREEDING_COMMON_CHANCE + BREEDING_RARE_CHANCE):
		rarity = "RARE"
	else:
		rarity = "LEGENDARY"
	trait_id = _random_trait_id(rarity)
	return trait_id

func _roll_wild_breeding_trait(parent_a: Dictionary, parent_b: Dictionary) -> String:
	var parent_a_all_traits: Array[String] = _trait_ids_for_follower(parent_a)
	var parent_b_all_traits: Array[String] = _trait_ids_for_follower(parent_b)
	var shared_trait: String = _shared_parent_trait_from_lists(parent_a_all_traits, parent_b_all_traits)
	if shared_trait != "":
		# Hard guarantee: same trait on both parents must be inherited.
		return shared_trait
	var mutation_trait: String = _maybe_roll_primary_trait_mutation()
	if mutation_trait != "":
		return mutation_trait
	var brood_sovereign_parent: bool = parent_a_all_traits.has("brood_sovereign") or parent_b_all_traits.has("brood_sovereign")
	if relic_inventory["Seal of Inheritance"] > 0:
		var inherited: String = _pick_parent_trait_from_lists(parent_a_all_traits, parent_b_all_traits)
		if inherited != "":
			return inherited
	var guaranteed: bool = parent_a_all_traits.has("chosen_veil") or parent_b_all_traits.has("chosen_veil") or brood_sovereign_parent
	if not guaranteed and _rng.randf() > BREEDING_ANY_TRAIT_CHANCE:
		return ""
	var rarity_roll: float = _rng.randf()
	var rarity: String = "COMMON"
	if rarity_roll < BREEDING_COMMON_CHANCE:
		rarity = "COMMON"
	elif rarity_roll < (BREEDING_COMMON_CHANCE + BREEDING_RARE_CHANCE):
		rarity = "RARE"
	else:
		rarity = "LEGENDARY"
	if brood_sovereign_parent and rarity == "COMMON":
		rarity = "RARE"
	var combo_trait_id: String = _pick_combo_trait_for_parent_trait_lists(parent_a_all_traits, parent_b_all_traits, rarity)
	if combo_trait_id != "":
		return combo_trait_id
	var inherited_bias: float = 0.60 if brood_sovereign_parent else 0.35
	var parent_ids: Array[String] = []
	for tid in parent_a_all_traits:
		if tid != "":
			parent_ids.append(tid)
	for tid in parent_b_all_traits:
		if tid != "":
			parent_ids.append(tid)
	if not parent_ids.is_empty() and _rng.randf() < inherited_bias:
		return parent_ids[_rng.randi_range(0, parent_ids.size() - 1)]
	return _random_trait_id(rarity)

func _pick_parent_trait_from_lists(parent_a_traits: Array[String], parent_b_traits: Array[String]) -> String:
	var parent_ids: Array[String] = []
	for tid in parent_a_traits:
		if tid != "":
			parent_ids.append(tid)
	for tid in parent_b_traits:
		if tid != "":
			parent_ids.append(tid)
	if parent_ids.is_empty():
		return ""
	return parent_ids[_rng.randi_range(0, parent_ids.size() - 1)]

func _pick_parent_trait_id(parent_a_tid: String, parent_b_tid: String) -> String:
	var parent_a_traits: Array[String] = []
	var parent_b_traits: Array[String] = []
	if parent_a_tid != "":
		parent_a_traits.append(parent_a_tid)
	if parent_b_tid != "":
		parent_b_traits.append(parent_b_tid)
	return _pick_parent_trait_from_lists(parent_a_traits, parent_b_traits)

func cull_follower_by_id(follower_id: int, trigger_shop_relics: bool = true) -> bool:
	if apostle_id == follower_id:
		return false
	for i in range(pool.size()):
		if int(pool[i]["id"]) == follower_id:
			var culled_trait: String = str(pool[i].get("trait", "SOUL"))
			pool.remove_at(i)
			for n in range(nests.size()):
				var entry: Dictionary = nests[n]
				if int(entry.get("a", -1)) == follower_id:
					entry["a"] = -1
				if int(entry.get("b", -1)) == follower_id:
					entry["b"] = -1
				nests[n] = entry
			for fi in range(favored_breeder_ids.size()):
				if int(favored_breeder_ids[fi]) == follower_id:
					favored_breeder_ids[fi] = -1
			if int(relic_inventory.get("Grave Compact", 0)) > 0:
				grave_compact_buffer += 0.5 * float(int(relic_inventory.get("Grave Compact", 0)))
			if trigger_shop_relics and int(relic_inventory.get("The Pruning Hook", 0)) > 0 and not pruning_hook_used_shop:
				if not is_pool_at_capacity():
					var spawn_trait: String = culled_trait
					if spawn_trait == "SOUL":
						spawn_trait = "BLOOD"
					var newborn: Dictionary = _make_specific_follower(spawn_trait, 3, "pruning_hook")
					pool.append(newborn)
					_refresh_bloodline_registers(true)
				pruning_hook_used_shop = true
			return true
	return false

func ascend_follower_by_id(follower_id: int) -> bool:
	if soul_lantern_used:
		return false
	for i in range(pool.size()):
		if int(pool[i]["id"]) == follower_id:
			pool[i]["trait"] = "VOID"
			pool[i]["tier"] = 0
			blood_currency = 0
			soul_lantern_used = true
			return true
	return false

func use_crown_of_tiers(follower_id: int) -> Dictionary:
	if relic_inventory.get("Crown of Tiers", 0) <= 0:
		return {"ok": false, "reason": "Crown of Tiers not owned."}
	if crown_of_tiers_used_week == current_week:
		return {"ok": false, "reason": "Crown of Tiers already used this week."}
	if blood_currency < 5:
		return {"ok": false, "reason": "Not enough Blood (5 needed)."}
	for i in range(pool.size()):
		if int(pool[i].get("id", -1)) == follower_id:
			var before_tier: int = int(pool[i].get("tier", 0))
			var after_tier: int = 0 if str(pool[i].get("trait", "")) == "VOID" else min(MAX_TIER, before_tier + 3)
			pool[i]["tier"] = after_tier
			blood_currency -= 5
			crown_of_tiers_used_week = current_week
			_refresh_bloodline_registers(true)
			return {
				"ok": true,
				"reason": "",
				"id": follower_id,
				"before_tier": before_tier,
				"after_tier": after_tier,
				"blood_remaining": blood_currency,
			}
	return {"ok": false, "reason": "Follower not found in pool."}

func set_apostle(follower_id: int) -> bool:
	if apostle_id != -1:
		return false
	for i in range(pool.size()):
		if int(pool[i]["id"]) == follower_id:
			apostle_id = follower_id
			return true
	return false

func _refresh_bloodline_registers(grant_blood: bool) -> int:
	var copies: int = int(relic_inventory.get("Bloodline Register", 0))
	if copies <= 0:
		return 0
	var gained: int = 0
	for f in pool:
		var fid: int = int(f.get("id", -1))
		if fid < 0:
			continue
		if int(f.get("tier", 0)) < 10:
			continue
		if bloodline_registered_ids.has(fid):
			continue
		bloodline_registered_ids[fid] = true
		if grant_blood:
			gained += copies
	if grant_blood and gained > 0:
		add_blood(gained)
	return gained

func _is_favored_breeder(follower_id: int) -> bool:
	if follower_id < 0:
		return false
	return favored_breeder_ids.has(follower_id)

func set_favored_breeder(follower_id: int, slot: int) -> void:
	if not _pool_has_follower_id(follower_id):
		return
	if favored_breeder_ids.size() < 2:
		favored_breeder_ids = [-1, -1]
	if slot < 0 or slot > 1:
		return
	favored_breeder_ids[slot] = follower_id
	var other_slot: int = 1 if slot == 0 else 0
	if int(favored_breeder_ids[other_slot]) == follower_id:
		favored_breeder_ids[other_slot] = -1

func pool_summary_counts() -> Dictionary:
	var blood: int = 0
	var bone: int = 0
	var voids: int = 0
	var souls: int = 0
	var total_tier: int = 0
	for f in pool:
		var tr: String = f["trait"]
		if tr == "BLOOD":
			blood += 1
		elif tr == "BONE":
			bone += 1
		elif tr == "VOID":
			voids += 1
		else:
			souls += 1
		total_tier += int(f["tier"])
	var avg: float = 0.0
	if pool.size() > 0:
		avg = float(total_tier) / float(pool.size())
	return {"total": pool.size(), "blood": blood, "bone": bone, "void": voids, "soul": souls, "avg_tier": avg}

func reset_doctrine_for_play() -> void:
	doctrine_used_this_play = false
	clear_exhausted()

func clear_exhausted() -> void:
	for i in range(current_hand.size()):
		current_hand[i]["exhausted"] = false

func get_pool_cap() -> int:
	var cap: int = POOL_CAP
	var salt_copies: int = relic_inventory["Salt Circle"]
	var ecto_copies: int = relic_inventory["Ectoplasm Jar"]
	var deep_pool_copies: int = int(relic_inventory.get("The Deep Pool", 0))
	var hollow_pact_copies: int = int(relic_inventory.get("The Hollow Pact", 0))
	cap += (4 * salt_copies)
	cap += (6 * deep_pool_copies)
	cap -= (6 * ecto_copies)
	if hollow_pact_copies > 0:
		cap = int(ceil(float(cap) / 2.0))
	return max(10, cap)

func _counts_toward_pool_cap(follower: Dictionary) -> bool:
	if int(relic_inventory.get("The Eternal Line", 0)) <= 0:
		return true
	var origin: String = str(follower.get("origin_tag", ""))
	if origin == "nest_bred" or origin == "wild_bred":
		return false
	return true

func get_pool_load_for_cap() -> int:
	var load: int = 0
	for f in pool:
		if _counts_toward_pool_cap(f):
			load += 1
	return load

func is_pool_at_capacity() -> bool:
	return get_pool_load_for_cap() >= get_pool_cap()

func add_blood(amount: int) -> void:
	if amount <= 0:
		return
	if blood_debt > 0:
		var pay: int = min(blood_debt, amount)
		blood_debt -= pay
		amount -= pay
	if amount > 0:
		blood_currency += amount

func can_afford_relic(cost: int) -> bool:
	if blood_currency >= cost:
		return true
	var debt_limit: int = 0
	if int(relic_inventory.get("Debt Scripture", 0)) > 0:
		debt_limit = 2
	if int(relic_inventory.get("The Debt Engine", 0)) > 0:
		debt_limit = 6
	if debt_limit > 0:
		return (blood_currency + debt_limit) >= cost
	return false

func spend_blood_for_relic(cost: int) -> void:
	var available: int = blood_currency
	if available >= cost:
		blood_currency -= cost
		return
	var debt_limit: int = 0
	if int(relic_inventory.get("Debt Scripture", 0)) > 0:
		debt_limit = 2
	if int(relic_inventory.get("The Debt Engine", 0)) > 0:
		debt_limit = 6
	if debt_limit > 0:
		var shortfall: int = cost - available
		blood_currency = 0
		blood_debt = min(debt_limit, blood_debt + shortfall)

func can_sell_relic(name: String) -> bool:
	if int(relic_inventory.get("The Red Market", 0)) <= 0:
		return false
	if red_market_used_shop:
		return false
	if not relic_inventory.has(name):
		return false
	return int(relic_inventory.get(name, 0)) > 0 and name != "The Red Market"

func sell_relic(name: String) -> Dictionary:
	if not can_sell_relic(name):
		return {"ok": false, "reason": "unavailable"}
	var rarity: String = str(RELIC_DEFS.get(name, {}).get("rarity", "COMMON"))
	var cost: int = get_shop_cost(current_week, rarity)
	var gain: int = int(ceil(float(cost) / 2.0))
	relic_inventory[name] = max(0, int(relic_inventory.get(name, 0)) - 1)
	add_blood(gain)
	red_market_used_shop = true
	return {"ok": true, "blood_gain": gain, "name": name}

func can_offer_relic(name: String) -> bool:
	if not relic_inventory.has(name):
		return false
	if name == "The Witness" or name == "The Archive Key":
		# TODO: not yet implemented - re-enable when logic is added.
		return false
	if name == "Ossuary Standard":
		# Retired - overlaps with Bone Standard and reworked Ossuary Standards.
		return false
	if name == "The Compound Covenant" and current_week < 5:
		return false
	if RELIC_DEFS.has(name) and not bool(RELIC_DEFS[name]["stacks"]):
		return relic_inventory[name] == 0
	return true

func get_week_target(week: int) -> int:
	if tutorial_mode and TUTORIAL_WEEK_TARGETS.has(week):
		return int(TUTORIAL_WEEK_TARGETS[week])
	var computed: int = 0
	if next_week_target_overrides.has(week):
		computed = int(next_week_target_overrides[week])
	else:
		var cfg := get_run_config()
		var static_overrides: Dictionary = cfg.get("week_target_overrides", {})
		if static_overrides.has(week):
			computed = int(static_overrides[week])
		else:
			var base_target: float = float(cfg.get("target_base", 18.0))
			var growth: float = float(cfg.get("target_growth", 1.45))
			var w: int = max(1, week)
			var raw_target: float = base_target * pow(growth, float(w - 1))
			var rounded: int = int(round(raw_target))
			computed = int(round(float(rounded) / 5.0)) * 5
	if int(relic_inventory.get("The Red Covenant", 0)) > 0 and red_covenant_active_week == week:
		computed *= 2
	if int(relic_inventory.get("The Damnation Seal", 0)) > 0 and week == get_max_weeks():
		computed *= 2
	return computed

func get_max_weeks() -> int:
	if tutorial_mode:
		return TUTORIAL_MAX_WEEKS
	var cfg := get_run_config()
	return int(cfg.get("max_weeks", 10))

func get_max_trait_slots() -> int:
	var max_w: int = get_max_weeks()
	var divisor: float = floor(float(max_w) / 5.0)
	if divisor <= 0.0:
		divisor = 1.0
	return min(6, 1 + int(floor(float(current_week) / divisor)))

func get_shop_cost(week: int, rarity: String = "COMMON") -> int:
	var rarity_step: int = 0
	match rarity:
		"UNCOMMON":
			rarity_step = 1
		"RARE":
			rarity_step = 2
		"LEGENDARY":
			rarity_step = 3
		_:
			rarity_step = 0
	var base_cost: int = 10 + (10 * rarity_step)
	var discount: int = 0
	if relic_inventory["Tithe Discount"] > 0:
		discount = 1
	return max(2, base_cost - discount)

func roll_shop_rarity(week: int, rng: RandomNumberGenerator, rare_bonus: float = 0.0, legendary_bonus: float = 0.0, guarantee_rare: bool = false) -> String:
	var rare_chance: float = min(SHOP_RARE_MAX, SHOP_RARE_BASE + (SHOP_RARE_PER_WEEK * float(week - 1)) + rare_bonus)
	var legendary_chance: float = min(SHOP_LEGENDARY_MAX, SHOP_LEGENDARY_BASE + (SHOP_LEGENDARY_PER_WEEK * float(week - 1)) + legendary_bonus)
	var roll: float = rng.randf()
	if roll < legendary_chance:
		return "LEGENDARY"
	if roll < (legendary_chance + rare_chance):
		return "RARE"
	if guarantee_rare:
		return "RARE"
	return "UNCOMMON" if rng.randf() < SHOP_UNCOMMON_CHANCE else "COMMON"

func add_relic(name: String) -> void:
	_ensure_relic_inventory_keys()
	if not relic_inventory.has(name):
		return
	codex_mark_relic_purchased(name)
	var previous_count: int = int(relic_inventory.get(name, 0))
	if RELIC_DEFS.has(name) and not bool(RELIC_DEFS[name]["stacks"]):
		relic_inventory[name] = 1
	else:
		relic_inventory[name] += 1
	purchased_relic_history.append(name)
	shop_any_purchase_this_visit = true
	if int(relic_inventory.get("The Tithe Accelerator", 0)) > 0:
		tithe_accelerator_interest_bonus += int(relic_inventory.get("The Tithe Accelerator", 0))
	if name == "The Tithe Accelerator":
		var gained_copies: int = int(relic_inventory.get("The Tithe Accelerator", 0)) - previous_count
		if gained_copies > 0:
			tithe_accelerator_interest_bonus += gained_copies * purchased_relic_history.size()
	if name == "Bloodline Register" and previous_count == 0:
		# Existing tier-10 followers should not pay out retroactively.
		for f in pool:
			if int(f.get("tier", 0)) >= 10:
				var fid: int = int(f.get("id", -1))
				if fid >= 0:
					bloodline_registered_ids[fid] = true
	if name == "Annihilation Compact":
		_ensure_annihilation_sovereign()
	if name == "The Compound Covenant" and not compound_covenant_used_run and current_week >= 5:
		blood_currency *= 2
		compound_covenant_used_run = true
	if name == "The Palimpsest" and not palimpsest_used_run:
		_apply_palimpsest()

func _apply_relic_scoring_hooks(phase: String, ctx: Dictionary) -> void:
	if not RELIC_SCORING_HOOKS.has(phase):
		return
	var phase_hooks: Dictionary = RELIC_SCORING_HOOKS[phase]
	for relic_name in phase_hooks.keys():
		var copies: int = int(relic_inventory.get(relic_name, 0))
		if copies <= 0:
			continue
		var method_name: String = str(phase_hooks[relic_name])
		if has_method(method_name):
			call(method_name, ctx, copies)

func _hook_additive_delta(ctx: Dictionary, line: String, delta: int) -> void:
	if delta <= 0:
		return
	var relic_lines: Array = ctx["relic_lines"]
	relic_lines.append(line)
	ctx["relic_additive_total"] = int(ctx.get("relic_additive_total", 0)) + delta

func _hook_pre_add_crimson_book(ctx: Dictionary, copies: int) -> void:
	var blood_count: int = int(ctx.get("blood_count", 0))
	if blood_count <= 0:
		return
	var delta: int = copies * blood_count
	_hook_additive_delta(ctx, "Crimson Book (x%d): +%d" % [copies, delta], delta)

func _hook_pre_add_bone_idol(ctx: Dictionary, copies: int) -> void:
	var bone_count: int = int(ctx.get("bone_count", 0))
	if bone_count <= 0:
		return
	var sacrificed_info: Array = ctx["sacrificed_info"]
	var delta: int = 0
	for info in sacrificed_info:
		if str(info.get("trait", "")) == "BONE":
			delta += int(info.get("tier", 0)) * copies
	_hook_additive_delta(ctx, "Bone Idol (x%d): +%d" % [copies, delta], delta)

func _hook_pre_add_calcify(ctx: Dictionary, copies: int) -> void:
	var bone_count: int = int(ctx.get("bone_count", 0))
	if bone_count <= 0:
		return
	var delta: int = 2 * copies * bone_count
	_hook_additive_delta(ctx, "Calcify (x%d): +%d" % [copies, delta], delta)

func _hook_pre_add_thin_blade(ctx: Dictionary, copies: int) -> void:
	var indices: Array = ctx["indices"]
	if indices.size() != 1:
		return
	var delta: int = 8 * copies
	_hook_additive_delta(ctx, "Thin Blade (x%d): +%d" % [copies, delta], delta)

func _hook_pre_add_quick_chant(ctx: Dictionary, copies: int) -> void:
	var indices: Array = ctx["indices"]
	if indices.is_empty():
		return
	var delta: int = 3 * copies
	_hook_additive_delta(ctx, "Quick Chant (x%d): +%d" % [copies, delta], delta)

func _hook_pre_add_ossuary_standard(ctx: Dictionary, copies: int) -> void:
	var bone_count: int = int(ctx.get("bone_count", 0))
	if bone_count < 2:
		return
	var delta: int = 10 * copies
	_hook_additive_delta(ctx, "Ossuary Standard (x%d): +%d" % [copies, delta], delta)

func _hook_pre_add_bone_polisher(ctx: Dictionary, copies: int) -> void:
	var bone_count: int = int(ctx.get("bone_count", 0))
	if bone_count <= 0:
		return
	var highest_bone: int = 0
	var sacrificed_info: Array = ctx["sacrificed_info"]
	for info in sacrificed_info:
		if str(info.get("trait", "")) == "BONE":
			highest_bone = max(highest_bone, int(info.get("tier", 0)))
	var delta: int = highest_bone * copies
	ctx["polisher_total"] = delta
	_hook_additive_delta(ctx, "Bone Polisher (x%d): +%d" % [copies, delta], delta)

func _hook_pre_add_ritual_symmetry(ctx: Dictionary, copies: int) -> void:
	var indices: Array = ctx["indices"]
	if indices.size() <= 0 or indices.size() % 2 != 0:
		return
	var delta: int = 12 * copies
	_hook_additive_delta(ctx, "Ritual Symmetry (x%d): +%d" % [copies, delta], delta)

func _hook_pre_add_prayer_beads(ctx: Dictionary, copies: int) -> void:
	var indices: Array = ctx["indices"]
	if indices.size() != 3:
		return
	var same_trait: bool = bool(ctx.get("same_trait", false))
	if not same_trait:
		return
	var delta: int = 6 * copies
	_hook_additive_delta(ctx, "Prayer Beads (x%d): +%d" % [copies, delta], delta)

func _hook_pre_add_wax_seal(ctx: Dictionary, copies: int) -> void:
	var tier_counts: Dictionary = ctx["tier_counts"]
	var has_pair: bool = false
	for key in tier_counts.keys():
		if int(tier_counts[key]) >= 2:
			has_pair = true
			break
	if not has_pair:
		return
	var delta: int = 8 * copies
	_hook_additive_delta(ctx, "Wax Seal (x%d): +%d" % [copies, delta], delta)

func _hook_pre_add_choir_robes(ctx: Dictionary, copies: int) -> void:
	var indices: Array = ctx["indices"]
	if indices.size() != 3:
		return
	var tier_counts: Dictionary = ctx["tier_counts"]
	if tier_counts.keys().size() != 3:
		return
	var delta: int = 5 * copies
	_hook_additive_delta(ctx, "Choir Robes (x%d): +%d" % [copies, delta], delta)

func _hook_pre_add_triune_reliquary(ctx: Dictionary, copies: int) -> void:
	var indices: Array = ctx["indices"]
	if indices.size() != 3:
		return
	if not bool(ctx.get("has_blood", false)) or not bool(ctx.get("has_bone", false)) or not bool(ctx.get("has_void", false)):
		return
	var delta: int = 12 * copies
	_hook_additive_delta(ctx, "Triune Reliquary (x%d): +%d" % [copies, delta], delta)

func _hook_pre_add_red_thread(ctx: Dictionary, copies: int) -> void:
	var indices: Array = ctx["indices"]
	var blood_count: int = int(ctx.get("blood_count", 0))
	if blood_count == 3 and indices.size() == 3:
		var relic_lines: Array = ctx["relic_lines"]
		relic_lines.append("Red Thread (x%d): +1 tier to random BLOOD" % copies)

func _hook_pre_add_bloodright_almanac(ctx: Dictionary, copies: int) -> void:
	var indices: Array = ctx["indices"]
	if indices.size() != 3 or not bool(ctx.get("tier_straight", false)):
		return
	var add_delta: int = 10 * copies
	_hook_additive_delta(ctx, "Bloodright Almanac (x%d): +%d" % [copies, add_delta], add_delta)
	var blood_delta: int = 2 * copies
	ctx["relic_blood_bonus"] = int(ctx.get("relic_blood_bonus", 0)) + blood_delta
	var relic_lines: Array = ctx["relic_lines"]
	relic_lines.append("Bloodright Almanac (x%d): +%d Blood" % [copies, blood_delta])

func _hook_pre_add_bone_saw(ctx: Dictionary, copies: int) -> void:
	var bone_count: int = int(ctx.get("bone_count", 0))
	if bone_count < 2:
		return
	ctx["relic_blood_bonus"] = int(ctx.get("relic_blood_bonus", 0)) + copies
	var relic_lines: Array = ctx["relic_lines"]
	relic_lines.append("Bone Saw (x%d): +%d Blood" % [copies, copies])

func _hook_pre_add_iron_reliquary(ctx: Dictionary, _copies: int) -> void:
	var highest_tier_sac: int = int(ctx.get("highest_tier_sac", -1))
	if highest_tier_sac < 8:
		return
	_hook_additive_delta(ctx, "Iron Reliquary: +20", 20)

func _hook_pre_add_ivory_throne(ctx: Dictionary, _copies: int) -> void:
	var sacrificed_info: Array = ctx["sacrificed_info"]
	var delta: int = 0
	for info in sacrificed_info:
		var tier: int = int(info.get("tier", 0))
		if tier > 7:
			delta += (tier - 7) * 5
	if delta <= 0:
		return
	_hook_additive_delta(ctx, "Ivory Throne: +%d" % delta, delta)

func _hook_pre_add_ascendant_mark(ctx: Dictionary, _copies: int) -> void:
	var indices: Array = ctx["indices"]
	if indices.size() != 3:
		return
	if not bool(ctx.get("same_trait", false)):
		return
	var sacrificed_info: Array = ctx["sacrificed_info"]
	for info in sacrificed_info:
		if int(info.get("tier", 0)) < 6:
			return
	_hook_additive_delta(ctx, "Ascendant Mark: +25", 25)

func _hook_pre_add_the_summit(ctx: Dictionary, _copies: int) -> void:
	var highest_tier_sac: int = int(ctx.get("highest_tier_sac", -1))
	if summit_last_round_highest_tier < 0:
		return
	if highest_tier_sac <= summit_last_round_highest_tier:
		return
	_hook_additive_delta(ctx, "The Summit: +15", 15)

func _hook_pre_add_apex_covenant(ctx: Dictionary, copies: int) -> void:
	if current_hand.is_empty():
		return
	var highest_tier: int = 0
	for f in current_hand:
		highest_tier = max(highest_tier, int(f.get("tier", 0)))
	if highest_tier <= 0:
		return
	var delta: int = int(floor(float(highest_tier) / 2.0)) * copies
	if delta <= 0:
		return
	_hook_additive_delta(ctx, "Apex Covenant (x%d): +%d" % [copies, delta], delta)

func _hook_pre_add_obsidian_conduit(ctx: Dictionary, copies: int) -> void:
	var sacrificed_info: Array = ctx["sacrificed_info"]
	var pool_void_count: int = 0
	for f in pool:
		if str(f.get("trait", "")) == "VOID":
			pool_void_count += 1
	if pool_void_count <= 0:
		return
	var sacrificed_void_count: int = 0
	for info in sacrificed_info:
		if str(info.get("trait", "")) != "VOID":
			continue
		sacrificed_void_count += 1
	var delta: int = sacrificed_void_count * pool_void_count * copies
	if delta <= 0:
		return
	_hook_additive_delta(ctx, "Obsidian Conduit: +%d" % delta, delta)

func _hook_pre_mult_sacrificial_order(ctx: Dictionary, copies: int) -> void:
	var indices: Array = ctx["indices"]
	if indices.size() != 3:
		return
	var additive_total: int = int(ctx.get("additive_total", 0))
	var mult: int = int(pow(2.0, float(copies)))
	var delta: int = additive_total * (mult - 1)
	ctx["additive_total"] = additive_total * mult
	ctx["relic_additive_total"] = int(ctx.get("relic_additive_total", 0)) + delta
	var relic_lines: Array = ctx["relic_lines"]
	relic_lines.append("Sacrificial Order (x%d): +%d" % [mult, delta])

func _hook_pre_mult_balanced_offering(ctx: Dictionary, copies: int) -> void:
	if not bool(ctx.get("has_blood", false)) or not bool(ctx.get("has_bone", false)) or not bool(ctx.get("has_void", false)):
		return
	var additive_total: int = int(ctx.get("additive_total", 0))
	var mult: int = int(pow(2.0, float(copies)))
	var delta: int = additive_total * (mult - 1)
	ctx["additive_total"] = additive_total * mult
	ctx["relic_additive_total"] = int(ctx.get("relic_additive_total", 0)) + delta
	var relic_lines: Array = ctx["relic_lines"]
	relic_lines.append("Balanced Offering (x%d): +%d" % [mult, delta])

func _hook_pre_mult_peaked_rite(ctx: Dictionary, _copies: int) -> void:
	var indices: Array = ctx["indices"]
	if indices.size() != 3:
		return
	var sacrificed_info: Array = ctx.get("sacrificed_info", [])
	if sacrificed_info.size() != 3:
		return
	var total_tier: int = 0
	for info in sacrificed_info:
		total_tier += int(info.get("tier", 0))
	var avg_tier: float = float(total_tier) / 3.0
	if avg_tier <= 7.0:
		return
	var additive_total: int = int(ctx.get("additive_total", 0))
	var boosted_total: int = int(floor(float(additive_total) * 1.5))
	var delta: int = boosted_total - additive_total
	if delta <= 0:
		return
	ctx["additive_total"] = boosted_total
	ctx["relic_additive_total"] = int(ctx.get("relic_additive_total", 0)) + delta
	var relic_lines: Array = ctx["relic_lines"]
	relic_lines.append("The Peaked Rite: +%d (x1.5)" % delta)

func _hook_multiplier_hollow_abacus(ctx: Dictionary, copies: int) -> void:
	var void_count: int = int(ctx.get("void_count", 0))
	if void_count != 1:
		return
	ctx["exponent"] = int(ctx.get("exponent", 1)) + copies
	var relic_multiplier_lines: Array = ctx["relic_multiplier_lines"]
	relic_multiplier_lines.append("Hollow Abacus (x%d): multiplier exponent +%d" % [copies, copies])

func _hook_multiplier_ectoplasm_jar(ctx: Dictionary, copies: int) -> void:
	ctx["exponent"] = int(ctx.get("exponent", 1)) + copies
	var relic_multiplier_lines: Array = ctx["relic_multiplier_lines"]
	relic_multiplier_lines.append("Ectoplasm Jar (x%d): multiplier exponent +%d" % [copies, copies])

func _hook_multiplier_hollow_chant(ctx: Dictionary, copies: int) -> void:
	var relic_multiplier_lines: Array = ctx["relic_multiplier_lines"]
	relic_multiplier_lines.append("Hollow Chant (x%d): multiplier exponent +%d" % [copies, copies])

func _hook_multiplier_void_prism(ctx: Dictionary, copies: int) -> void:
	var relic_multiplier_lines: Array = ctx["relic_multiplier_lines"]
	relic_multiplier_lines.append("Void Prism (x%d): effective VOID +%d" % [copies, copies])

func _hook_multiplier_black_candle(ctx: Dictionary, _copies: int) -> void:
	var base_before_candle: int = int(ctx.get("base_before_candle", 1))
	if base_before_candle < 2:
		var relic_multiplier_lines: Array = ctx["relic_multiplier_lines"]
		relic_multiplier_lines.append("Black Candle: multiplier base at least 2")

func _hook_multiplier_cold_incense(ctx: Dictionary, _copies: int) -> void:
	var void_count: int = int(ctx.get("void_count", 0))
	var current_w: int = int(ctx.get("current_week", 0))
	var used_week: int = int(ctx.get("cold_incense_used_week", -1))
	if void_count == 0 and used_week != current_w:
		ctx["base"] = max(2, int(ctx.get("base", 1)))
		ctx["cold_incense_applied"] = true
		var relic_multiplier_lines: Array = ctx["relic_multiplier_lines"]
		relic_multiplier_lines.append("Cold Incense: multiplier base at least 2 (weekly)")

func _hook_post_resolve_red_thread(ctx: Dictionary, copies: int) -> void:
	var apply_currency: bool = bool(ctx.get("apply_currency", false))
	var indices: Array = ctx["indices"]
	var blood_count: int = int(ctx.get("blood_count", 0))
	if not apply_currency or blood_count != 3 or indices.size() != 3:
		return
	for i in range(copies):
		var blood_ids: Array[int] = []
		for f in pool:
			if str(f.get("trait", "")) == "BLOOD":
				blood_ids.append(int(f.get("id", -1)))
		if blood_ids.is_empty():
			break
		_shuffle_array(blood_ids)
		var pick_id: int = blood_ids[0]
		for p in range(pool.size()):
			if int(pool[p].get("id", -1)) == pick_id:
				pool[p]["tier"] = min(MAX_TIER, int(pool[p].get("tier", 1)) + 1)
				break

func score_selected(selected_indices: Array) -> Dictionary:
	return _score_selected_internal(selected_indices, true, true, true)

func preview_selected(selected_indices: Array) -> Dictionary:
	return _score_selected_internal(selected_indices, false, false, false)

func _score_selected_internal(selected_indices: Array, apply_currency: bool, write_breakdown: bool, write_log: bool) -> Dictionary:
	if apply_currency:
		last_resilient_saved_ids.clear()
	var indices: Array[int] = []
	var seen: Dictionary = {}
	for idx in selected_indices:
		if not seen.has(idx):
			seen[idx] = true
			indices.append(idx)
	indices.sort()

	var ritual_copies: int = relic_inventory["Ritual Knife"]
	var third_knife: int = relic_inventory["The Third Knife"]
	var bone_copies: int = relic_inventory["Bone Idol"]
	var crimson_copies: int = relic_inventory["Crimson Book"]
	var hollow_copies: int = relic_inventory["Hollow Chant"]
	var order_copies: int = relic_inventory["Sacrificial Order"]
	var quick_copies: int = relic_inventory["Quick Chant"]
	var thin_copies: int = relic_inventory["Thin Blade"]
	var ossuary_copies: int = relic_inventory["Ossuary Standard"]
	var polisher_copies: int = relic_inventory["Bone Polisher"]
	var symmetry_copies: int = relic_inventory["Ritual Symmetry"]
	var calcify_copies: int = relic_inventory["Calcify"]
	var prism_copies: int = relic_inventory["Void Prism"]
	var candle_copies: int = relic_inventory["Black Candle"]
	var balanced_copies: int = relic_inventory["Balanced Offering"]
	var prayer_copies: int = relic_inventory["Prayer Beads"]
	var bone_saw_copies: int = relic_inventory["Bone Saw"]
	var red_thread_copies: int = relic_inventory["Red Thread"]
	var cold_incense_copies: int = relic_inventory["Cold Incense"]
	var wax_seal_copies: int = relic_inventory["Wax Seal"]
	var choir_copies: int = relic_inventory["Choir Robes"]
	var hollow_abacus_copies: int = relic_inventory["Hollow Abacus"]
	var triune_copies: int = relic_inventory["Triune Reliquary"]
	var bloodright_copies: int = relic_inventory["Bloodright Almanac"]
	var ectoplasm_copies: int = relic_inventory["Ectoplasm Jar"]
	var whetted_bone_copies: int = int(relic_inventory.get("Whetted Bone", 0))
	var gilded_offering_copies: int = int(relic_inventory.get("The Gilded Offering", 0))
	var last_rung_copies: int = int(relic_inventory.get("The Last Rung", 0))
	var empty_pyre_copies: int = int(relic_inventory.get("The Empty Pyre", 0))
	var absent_crown_copies: int = int(relic_inventory.get("The Absent Crown", 0))
	var refinery_copies: int = int(relic_inventory.get("Refinery of Silence", 0))
	var void_cradle_copies: int = int(relic_inventory.get("Void Cradle", 0))
	var hollow_register_copies: int = int(relic_inventory.get("The Hollow Register", 0))
	var void_recursion_copies: int = int(relic_inventory.get("Void Recursion", 0))
	var null_covenant_copies: int = int(relic_inventory.get("Null Covenant", 0))
	var final_silence_copies: int = int(relic_inventory.get("The Final Silence", 0))
	var deepest_void_copies: int = int(relic_inventory.get("The Deepest Void", 0))
	var marrow_charter_copies: int = int(relic_inventory.get("Marrow Charter", 0))
	var bone_standard_copies: int = int(relic_inventory.get("Bone Standard", 0))
	var white_wall_copies: int = int(relic_inventory.get("The White Wall", 0))
	var crypt_standard_copies: int = int(relic_inventory.get("Crypt Standard", 0))
	var calcified_gate_copies: int = int(relic_inventory.get("The Calcified Gate", 0))
	var bone_chorus_copies: int = int(relic_inventory.get("Bone Chorus", 0))
	var ossuary_absolute_copies: int = int(relic_inventory.get("Ossuary Absolute", 0))
	var red_tithe_copies: int = int(relic_inventory.get("The Red Tithe", 0))
	var sanguine_chord_copies: int = int(relic_inventory.get("The Sanguine Chord", 0))
	var bloodfire_compact_copies: int = int(relic_inventory.get("Bloodfire Compact", 0))
	var arterial_rite_copies: int = int(relic_inventory.get("The Arterial Rite", 0))
	var sanguine_engine_copies: int = int(relic_inventory.get("The Sanguine Engine", 0))
	var crimson_absolute_copies: int = int(relic_inventory.get("Crimson Absolute", 0))
	var concordat_copies: int = int(relic_inventory.get("The Concordat", 0))
	var threefold_brand_copies: int = int(relic_inventory.get("Threefold Brand", 0))
	var sacred_triangle_copies: int = int(relic_inventory.get("The Sacred Triangle", 0))
	var covenant_of_three_copies: int = int(relic_inventory.get("Covenant of Three", 0))
	var trinity_engine_copies: int = int(relic_inventory.get("The Trinity Engine", 0))
	var absolute_trinity_copies: int = int(relic_inventory.get("The Absolute Trinity", 0))
	var copper_tithe_copies: int = int(relic_inventory.get("The Copper Tithe", 0))
	var dyad_mark_copies: int = int(relic_inventory.get("The Dyad Mark", 0))
	var foursome_copies: int = int(relic_inventory.get("The Foursome", 0))
	var minimalist_doctrine_copies: int = int(relic_inventory.get("Minimalist Doctrine", 0))
	var count_absolute_copies: int = int(relic_inventory.get("The Count Absolute", 0))
	var bleeding_edge_copies: int = int(relic_inventory.get("The Bleeding Edge", 0))
	var cursed_offering_copies: int = int(relic_inventory.get("The Cursed Offering", 0))
	var hollow_pact_copies: int = int(relic_inventory.get("The Hollow Pact", 0))
	var last_sacrifice_copies: int = int(relic_inventory.get("The Last Sacrifice", 0))
	var hungry_altar_copies: int = int(relic_inventory.get("The Hungry Altar", 0))
	var drawn_curtain_copies: int = int(relic_inventory.get("The Drawn Curtain", 0))
	var nursery_ledger_copies: int = int(relic_inventory.get("Nursery Ledger", 0))
	var lineage_harvest_copies: int = int(relic_inventory.get("Lineage Harvest", 0))
	var pared_offering_copies: int = int(relic_inventory.get("The Pared Offering", 0))

	var sacrificed_info: Array[Dictionary] = []
	var additive_total: int = 0
	var blood_gain: int = 0
	var void_count: int = 0
	var bone_count: int = 0
	var blood_count: int = 0
	var has_blood: bool = false
	var has_bone: bool = false
	var has_void: bool = false
	var doctrine_lines: Array[String] = []
	var doctrine_additive: int = 0
	var doctrine_exponent_bonus: int = 0
	var relic_lines: Array[String] = []
	var blood_terms: Array[String] = []
	var bone_terms: Array[String] = []
	var polisher_total: int = 0
	var refined_void_count: int = 0
	var trait_lines: Array[String] = []
	var trait_additive_total: int = 0
	var trait_blood_bonus: int = 0
	var relic_blood_bonus: int = 0
	var trait_multiplier_lines: Array[String] = []
	var trait_multiplier_applied_count: int = 0
	var multiplier_trait_cap: int = MULTIPLIER_TRAIT_CAP
	var trait_multiplier_skipped: Array[String] = []
	var trait_resilient_saved: Dictionary = {}
	var gravetide_spawns: int = 0
	var trait_base_bonus: int = 0
	var trait_exponent_bonus: int = 0
	var trait_black_candlebearer_count: int = 0
	var trait_final_mult_factor: float = 1.0
	var followers_lines: Array[String] = []
	var followers_subtotal: int = 0
	var relic_additive_total: int = 0
	var doctrine_multiplier_lines: Array[String] = []
	var relic_multiplier_lines: Array[String] = []
	var ritual_delta_total: int = 0
	var ritual_additive_bonus: int = 0
	var ritual_void_bonus: int = 0
	var cold_incense_applied: bool = false
	var rusted_disabled_this_play: String = ""
	var minimal_double_base_bonus: int = 0
	var should_ignore_round_cap: bool = false

	if int(relic_inventory.get("The Rusted Tithe", 0)) > 0 and indices.size() > 0:
		var rusted_candidates: Array[String] = []
		for relic_name in RELIC_DEFS.keys():
			if str(RELIC_DEFS[relic_name].get("rarity", "")) != "COMMON":
				continue
			if int(relic_inventory.get(relic_name, 0)) <= 0:
				continue
			if relic_name == "The Rusted Tithe":
				continue
			rusted_candidates.append(relic_name)
		if not rusted_candidates.is_empty():
			_shuffle_array(rusted_candidates)
			rusted_disabled_this_play = rusted_candidates[0]
			relic_lines.append("The Rusted Tithe: disabled %s this round" % rusted_disabled_this_play)

	match rusted_disabled_this_play:
		"Crimson Book":
			crimson_copies = 0
		"Bone Idol":
			bone_copies = 0
		"Quick Chant":
			quick_copies = 0
		"Thin Blade":
			thin_copies = 0
		"Ritual Symmetry":
			symmetry_copies = 0
		"Calcify":
			calcify_copies = 0
		"Bloodright Almanac":
			bloodright_copies = 0
		"Marrow Charter":
			marrow_charter_copies = 0
		"The Red Tithe":
			red_tithe_copies = 0
		"The Concordat":
			concordat_copies = 0
		"The Copper Tithe":
			copper_tithe_copies = 0
		"The Pared Offering":
			pared_offering_copies = 0
		_:
			pass

	var ritual_indices: Array[int] = []
	var ritual_count: int = 0
	if third_knife > 0:
		ritual_count = min(3, indices.size())
	elif ritual_copies > 0:
		ritual_count = min(1, indices.size())
	for i in range(ritual_count):
		ritual_indices.append(indices[i])

	for idx in indices:
		var follower: Dictionary = current_hand[idx]
		var follower_id: int = int(follower["id"])
		var tier: int = follower["tier"]
		var trait_name: String = follower["trait"]
		var trait_id: String = str(follower.get("trait_id", ""))
		var trait_ids: Array[String] = []
		for extra_tid in follower.get("trait_ids", []):
			var normalized_tid: String = str(extra_tid)
			if normalized_tid != "" and normalized_tid != trait_id and not trait_ids.has(normalized_tid):
				trait_ids.append(normalized_tid)
		var effective_tier: int = tier
		var ritual_applied: bool = false
		if ritual_indices.has(idx):
			effective_tier = tier * 2
			ritual_applied = true

		var base_contrib: int = 0
		if trait_name == "BLOOD":
			blood_count += 1
			has_blood = true
			base_contrib = tier
			var blood_term: int = effective_tier + crimson_copies
			blood_terms.append(str(blood_term))
		elif trait_name == "BONE":
			bone_count += 1
			has_bone = true
			if whetted_bone_copies > 0:
				base_contrib = tier + 2
			else:
				base_contrib = tier * 2
			var bone_term: int = effective_tier * (2 + bone_copies)
			bone_terms.append(str(bone_term))
		elif trait_name == "SOUL":
			base_contrib = 0
		else:
			has_void = true
			void_count += 1
			if int(tier) > 0:
				refined_void_count += 1

		followers_subtotal += base_contrib
		followers_lines.append("- #%d %s t%d: +%d" % [follower_id, trait_name, tier, base_contrib])

		if ritual_applied:
			if trait_name == "BLOOD":
				ritual_delta_total += tier
			elif trait_name == "BONE":
				# Includes ritual scaling plus Bone Idol interaction on doubled tier.
				if whetted_bone_copies > 0:
					ritual_delta_total += (tier + 2) + (tier * bone_copies)
				else:
					ritual_delta_total += (tier * 2) + (tier * bone_copies)

		sacrificed_info.append({
			"index": idx,
			"id": follower_id,
			"trait": trait_name,
			"tier": tier,
			"base_contrib": base_contrib,
			"effective_tier": effective_tier,
			"ritual_applied": ritual_applied,
			"trait_id": trait_id,
			"trait_ids": trait_ids,
			"origin_tag": str(follower.get("origin_tag", "")),
			"lineage": _follower_lineage_value(follower),
		})

	if ritual_delta_total > 0:
		if third_knife > 0 and ritual_indices.size() > 0:
			relic_lines.append("The Third Knife: +%d" % ritual_delta_total)
		elif ritual_copies > 0 and ritual_indices.size() > 0:
			relic_lines.append("Ritual Knife: +%d" % ritual_delta_total)
		relic_additive_total += ritual_delta_total

	var tier_counts: Dictionary = {}
	for info in sacrificed_info:
		var t: int = int(info["tier"])
		tier_counts[t] = int(tier_counts.get(t, 0)) + 1

	var same_trait: bool = has_blood and not has_bone and not has_void
	same_trait = same_trait or (has_bone and not has_blood and not has_void)
	same_trait = same_trait or (has_void and not has_blood and not has_bone)
	var highest_tier_sac: int = -1
	var lowest_tier_sac: int = 9999
	for info in sacrificed_info:
		var st: int = int(info.get("tier", 0))
		highest_tier_sac = max(highest_tier_sac, st)
		lowest_tier_sac = min(lowest_tier_sac, st)
	var highest_tier_is_bone_only: bool = true
	for info in sacrificed_info:
		if int(info.get("tier", 0)) == highest_tier_sac and str(info.get("trait", "")) != "BONE":
			highest_tier_is_bone_only = false
			break
	var tier_straight: bool = false
	if indices.size() >= 3:
		var sorted_tiers: Array[int] = []
		for info in sacrificed_info:
			sorted_tiers.append(int(info["tier"]))
		sorted_tiers.sort()
		tier_straight = true
		for ti in range(1, sorted_tiers.size()):
			if sorted_tiers[ti - 1] + 1 != sorted_tiers[ti]:
				tier_straight = false
				break
	var has_pair_tier: bool = false
	for tier_key in tier_counts.keys():
		if int(tier_counts[tier_key]) >= 2:
			has_pair_tier = true
			break
	if bloodfire_compact_copies > 0 and blood_count == indices.size() and indices.size() == 3:
		var has_multiplier_trait: bool = false
		for info in sacrificed_info:
			for tid in _trait_ids_for_follower(info):
				var info_dict: Dictionary = _trait_info(tid)
				var ttype: String = str(info_dict.get("type", ""))
				if ttype == "MULTIPLIER":
					has_multiplier_trait = true
					break
			if has_multiplier_trait:
				break
		if has_multiplier_trait:
			multiplier_trait_cap = 999
			relic_lines.append("Bloodfire Compact: multiplier trait cap disabled this round")

	var pre_add_ctx: Dictionary = {
		"indices": indices,
		"sacrificed_info": sacrificed_info,
		"blood_count": blood_count,
		"bone_count": bone_count,
		"has_blood": has_blood,
		"has_bone": has_bone,
		"has_void": has_void,
		"same_trait": same_trait,
		"tier_counts": tier_counts,
		"tier_straight": tier_straight,
		"highest_tier_sac": highest_tier_sac,
		"relic_lines": relic_lines,
		"relic_additive_total": relic_additive_total,
		"relic_blood_bonus": relic_blood_bonus,
		"polisher_total": polisher_total,
	}
	_apply_relic_scoring_hooks("PRE_ADD", pre_add_ctx)
	relic_additive_total = int(pre_add_ctx.get("relic_additive_total", 0))
	relic_blood_bonus = int(pre_add_ctx.get("relic_blood_bonus", 0))
	polisher_total = int(pre_add_ctx.get("polisher_total", 0))
	var tier_sum: int = 0
	for info in sacrificed_info:
		tier_sum += int(info.get("tier", 0))
	var is_triune_play: bool = has_blood and has_bone and has_void
	var is_all_bone: bool = bone_count == indices.size() and indices.size() > 0
	var is_all_blood: bool = blood_count == indices.size() and indices.size() > 0
	if permanent_additive_bonus > 0:
		relic_additive_total += permanent_additive_bonus
		relic_lines.append("Permanent Additive (Debt Ledger/etc): +%d" % permanent_additive_bonus)
	if next_round_additive_penalty > 0:
		relic_additive_total -= next_round_additive_penalty
		relic_lines.append("Debt Engine Penalty: -%d" % next_round_additive_penalty)
	if bleeding_edge_copies > 0:
		var edge_delta: int = 15 * bleeding_edge_copies
		relic_additive_total += edge_delta
		relic_lines.append("The Bleeding Edge: +%d" % edge_delta)
	if cursed_offering_copies > 0:
		var curse_delta: int = 20 * cursed_offering_copies
		relic_additive_total += curse_delta
		relic_lines.append("The Cursed Offering: +%d" % curse_delta)
	if drawn_curtain_copies > 0 and doctrine_used_this_play:
		var curtain_delta: int = 5 * drawn_curtain_copies
		relic_additive_total += curtain_delta
		relic_lines.append("The Drawn Curtain: +%d" % curtain_delta)
	if crimson_ledger_stacks > 0 and blood_count > 0:
		relic_additive_total += crimson_ledger_stacks
		relic_lines.append("Crimson Ledger: +%d" % crimson_ledger_stacks)
	if triad_compact_bonus > 0:
		relic_additive_total += triad_compact_bonus
		relic_lines.append("The Triad Compact: +%d" % triad_compact_bonus)
	if expanding_rite_bonus > 0:
		relic_additive_total += expanding_rite_bonus
		relic_lines.append("The Expanding Rite: +%d" % expanding_rite_bonus)
	if is_all_bone and ossuary_engine_bonus > 0:
		relic_additive_total += ossuary_engine_bonus
		relic_lines.append("The Ossuary Engine: +%d" % ossuary_engine_bonus)
	if skeleton_archive_bonus > 0 and bone_count > 0:
		relic_additive_total += skeleton_archive_bonus
		relic_lines.append("The Skeleton Archive: +%d" % skeleton_archive_bonus)
	if ossuary_standards_bonus > 0 and bone_count > 0:
		var standards_delta: int = bone_count * ossuary_standards_bonus
		relic_additive_total += standards_delta
		relic_lines.append("Ossuary Standards: +%d" % standards_delta)
	if calcified_gate_copies > 0:
		var sacrificed_ids: Dictionary = {}
		for info in sacrificed_info:
			sacrificed_ids[int(info.get("id", -1))] = true
		var gate_delta: int = 0
		for f in pool:
			if str(f.get("trait", "")) != "BONE":
				continue
			var fid: int = int(f.get("id", -1))
			if sacrificed_ids.has(fid):
				continue
			gate_delta += int(floor(float(int(f.get("tier", 0))) / 3.0)) * calcified_gate_copies
		if gate_delta > 0:
			relic_additive_total += gate_delta
			relic_lines.append("The Calcified Gate: +%d" % gate_delta)
	if foursome_copies > 0 and indices.size() == 4:
		relic_additive_total += 10 * foursome_copies
		relic_lines.append("The Foursome: +%d" % (10 * foursome_copies))
	if int(relic_inventory.get("The Expanding Contract", 0)) > 0 and indices.size() >= 5 and sacrificed_info.size() >= 5:
		var fifth_info: Dictionary = sacrificed_info[sacrificed_info.size() - 1]
		var fifth_delta: int = int(fifth_info.get("tier", 0)) * 3
		relic_additive_total += fifth_delta
		relic_lines.append("The Expanding Contract: +%d (fifth sacrifice)" % fifth_delta)
	if minimalist_doctrine_copies > 0 and indices.size() == 1 and sacrificed_info.size() == 1:
		minimal_double_base_bonus = int(sacrificed_info[0].get("base_contrib", 0))
		relic_additive_total += minimal_double_base_bonus
		relic_lines.append("Minimalist Doctrine: +%d" % minimal_double_base_bonus)
	if marrow_charter_copies > 0 and is_all_bone and indices.size() == 3:
		var marrow_blood: int = tier_sum * marrow_charter_copies
		relic_blood_bonus += marrow_blood
		relic_lines.append("Marrow Charter: +%d Blood" % marrow_blood)
	if bone_standard_copies > 0 and bone_count >= 2:
		var highest_bone_contrib: int = 0
		for info in sacrificed_info:
			if str(info.get("trait", "")) == "BONE":
				highest_bone_contrib = max(highest_bone_contrib, int(info.get("base_contrib", 0)))
		if highest_bone_contrib > 0:
			var bone_std_delta: int = highest_bone_contrib * bone_standard_copies
			relic_additive_total += bone_std_delta
			relic_lines.append("Bone Standard: +%d" % bone_std_delta)
	if bone_chorus_copies > 0 and is_all_bone and tier_counts.keys().size() == 1:
		relic_additive_total += 30 * bone_chorus_copies
		relic_blood_bonus += 3 * bone_chorus_copies
		relic_lines.append("Bone Chorus: +%d and +%d Blood" % [30 * bone_chorus_copies, 3 * bone_chorus_copies])
	if red_tithe_copies > 0 and is_all_blood and indices.size() == 3 and tier_sum >= 18:
		relic_additive_total += 15 * red_tithe_copies
		relic_lines.append("The Red Tithe: +%d" % (15 * red_tithe_copies))
	if sanguine_engine_copies > 0 and blood_count > 0:
		var highest_pool_blood: int = 0
		for f in pool:
			if str(f.get("trait", "")) == "BLOOD":
				highest_pool_blood = max(highest_pool_blood, int(f.get("tier", 0)))
		var eng_delta: int = int(floor(float(highest_pool_blood) / 2.0))
		if eng_delta > 0:
			relic_additive_total += eng_delta * sanguine_engine_copies
			relic_lines.append("The Sanguine Engine: +%d" % (eng_delta * sanguine_engine_copies))
	if concordat_copies > 0 and is_triune_play:
		var con_delta: int = 3 * indices.size() * concordat_copies
		relic_additive_total += con_delta
		relic_lines.append("The Concordat: +%d" % con_delta)
	if threefold_brand_copies > 0 and triune_play_seen_run and is_triune_play:
		var brand_delta: int = threefold_brand_copies * 5
		relic_additive_total += brand_delta
		relic_lines.append("Threefold Brand: +%d" % brand_delta)
	if sacred_triangle_copies > 0 and is_triune_play:
		var add_types: Array[String] = ["BLOOD", "BONE", "VOID"]
		var tri_delta: int = 0
		for tname in add_types:
			var best: int = 0
			for info in sacrificed_info:
				if str(info.get("trait", "")) == tname:
					best = max(best, int(info.get("base_contrib", 0)))
			tri_delta += best
		if tri_delta > 0:
			relic_additive_total += tri_delta
			relic_lines.append("The Sacred Triangle: +%d" % tri_delta)
	if covenant_of_three_copies > 0 and is_triune_play and tier_sum >= 15:
		var cov_delta: int = 12 * covenant_of_three_copies
		relic_additive_total += cov_delta
		relic_blood_bonus += 2 * covenant_of_three_copies
		relic_lines.append("Covenant of Three: +%d and +%d Blood" % [cov_delta, 2 * covenant_of_three_copies])
	if lineage_harvest_copies > 0:
		var line_count: int = 0
		for info in sacrificed_info:
			var origin_tag: String = str(info.get("origin_tag", ""))
			if origin_tag == "nest_bred" or origin_tag == "wild_bred":
				line_count += 1
		if line_count > 0:
			var line_delta: int = line_count * 5 * lineage_harvest_copies
			relic_additive_total += line_delta
			relic_lines.append("Lineage Harvest: +%d" % line_delta)
	if nursery_ledger_copies > 0:
		var bred_count: int = 0
		for info in sacrificed_info:
			var origin_tag: String = str(info.get("origin_tag", ""))
			if origin_tag == "nest_bred" or origin_tag == "wild_bred":
				bred_count += 1
		if bred_count > 0:
			var nursery_blood: int = bred_count * nursery_ledger_copies
			relic_blood_bonus += nursery_blood
			relic_lines.append("Nursery Ledger: +%d Blood" % nursery_blood)
	if crimson_pact_used_week != current_week and int(relic_inventory.get("Crimson Pact", 0)) > 0:
		var blood_pool_candidates: Array[Dictionary] = []
		for f in pool:
			if str(f.get("trait", "")) == "BLOOD":
				blood_pool_candidates.append(f)
		if not blood_pool_candidates.is_empty():
			blood_pool_candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
				return int(a.get("tier", 0)) > int(b.get("tier", 0))
			)
			var pact_tier: int = int(blood_pool_candidates[0].get("tier", 0))
			var pact_id: int = int(blood_pool_candidates[0].get("id", -1))
			relic_additive_total += pact_tier
			relic_blood_bonus += 1
			if apply_currency:
				crimson_pact_used_week = current_week
				if pact_id >= 0:
					cull_follower_by_id(pact_id, false)
			relic_lines.append("Crimson Pact: +%d and +1 Blood" % pact_tier)

	if ritual_card_active == "Anoint":
		ritual_additive_bonus = 15
		relic_lines.append("Ritual Card (Anoint): +15")
		relic_additive_total += ritual_additive_bonus
	elif ritual_card_active == "Silence":
		ritual_void_bonus = 1
		relic_multiplier_lines.append("Ritual Card (Silence): effective VOID +1")
	elif ritual_card_active == "Rebirth":
		relic_lines.append("Ritual Card (Rebirth): return 1 sacrifice")

	var trait_eval_info: Array[Dictionary] = []
	for info in sacrificed_info:
		var all_trait_ids: Array[String] = _trait_ids_for_follower(info)
		for tid_eval in all_trait_ids:
			var eval_info: Dictionary = info.duplicate(true)
			eval_info["trait_id"] = tid_eval
			trait_eval_info.append(eval_info)

	for info in trait_eval_info:
		var tid: String = str(info.get("trait_id", ""))
		if tid == "":
			continue
		var fname: String = _trait_name(tid)
		var fid: int = int(info.get("id", 0))
		if tid.begins_with("combo_"):
			var combo_info: Dictionary = get_combo_trait(tid)
			var template_id: String = str(combo_info.get("template", ""))
			var combo_is_legendary: bool = str(combo_info.get("rarity", "RARE")) == "LEGENDARY"
			match template_id:
				"tier_straight_exalt":
					if tier_straight:
						trait_blood_bonus += 3 if combo_is_legendary else 2
						if trait_multiplier_applied_count < multiplier_trait_cap:
							trait_multiplier_applied_count += 1
							trait_base_bonus += 2 if combo_is_legendary else 1
							trait_multiplier_lines.append("#%d %s: multiplier base +%d, +%d Blood" % [
								fid,
								fname,
								2 if combo_is_legendary else 1,
								3 if combo_is_legendary else 2,
							])
						else:
							trait_multiplier_skipped.append("#%d %s: +%d Blood (multiplier trait cap)" % [
								fid,
								fname,
								3 if combo_is_legendary else 2,
							])
				"blood_economy_forge":
					if blood_count >= 2:
						var forge_add: int = 18 if combo_is_legendary else 12
						var forge_blood: int = 3 if combo_is_legendary else 2
						trait_additive_total += forge_add
						trait_blood_bonus += forge_blood
						trait_lines.append("#%d %s: +%d additive, +%d Blood" % [fid, fname, forge_add, forge_blood])
				"bone_citadel":
					if bone_count >= 2 and void_count == 0:
						var citadel_add: int = 30 if combo_is_legendary else 20
						trait_additive_total += citadel_add
						trait_lines.append("#%d %s: +%d additive" % [fid, fname, citadel_add])
				"void_edge":
					if void_count == 1:
						var edge_add: int = 14 if combo_is_legendary else 10
						trait_additive_total += edge_add
						if trait_multiplier_applied_count < multiplier_trait_cap:
							trait_multiplier_applied_count += 1
							trait_base_bonus += 2 if combo_is_legendary else 1
							trait_multiplier_lines.append("#%d %s: +%d additive, multiplier base +%d" % [
								fid,
								fname,
								edge_add,
								2 if combo_is_legendary else 1,
							])
						else:
							trait_multiplier_skipped.append("#%d %s: +%d additive (multiplier trait cap)" % [fid, fname, edge_add])
				"pair_execution":
					if has_pair_tier:
						var pair_bonus: int = 10 if combo_is_legendary else 6
						var pair_delta: int = int(info.get("base_contrib", 0))
						trait_additive_total += pair_delta + pair_bonus
						trait_lines.append("#%d %s: +%d additive (paired base doubled + bonus)" % [fid, fname, pair_delta + pair_bonus])
				"nest_dynasty":
					trait_lines.append("#%d %s: nest breeding bonus (applies as parent)" % [fid, fname])
				"triune_cataclysm":
					if has_blood and has_bone and has_void:
						var combo_mult: float = 1.35 if combo_is_legendary else 1.25
						trait_final_mult_factor = max(trait_final_mult_factor, combo_mult)
						trait_multiplier_lines.append("#%d %s: final devotion x%.2f" % [fid, fname, combo_mult])
				"grave_engine":
					var grave_add: int = 12 if combo_is_legendary else 8
					var grave_blood: int = 3 if combo_is_legendary else 2
					trait_additive_total += grave_add
					trait_blood_bonus += grave_blood
					if apply_currency:
						gravetide_spawns += 1
					trait_lines.append("#%d %s: +%d additive, +%d Blood, spawn T1 BONE" % [fid, fname, grave_add, grave_blood])
				_:
					pass
			continue
		match tid:
			"devout":
				trait_additive_total += 2
				trait_lines.append("#%d %s: +2 additive" % [fid, fname])
			"stalwart":
				if info["trait"] == "BONE":
					trait_additive_total += 4
					trait_lines.append("#%d %s: +4 additive" % [fid, fname])
			"fervent":
				if indices.size() == 3:
					trait_blood_bonus += 2
					trait_lines.append("#%d %s: +2 Blood" % [fid, fname])
			"twinborn":
				if int(tier_counts.get(int(info["tier"]), 0)) >= 2:
					trait_additive_total += 5
					trait_lines.append("#%d %s: +5 additive" % [fid, fname])
			"blood_oathling":
				if info["trait"] == "BLOOD" and blood_count >= 2:
					trait_additive_total += 5
					trait_lines.append("#%d %s: +5 additive" % [fid, fname])
			"void_spark":
				if info["trait"] == "VOID" and void_count == 2:
					trait_blood_bonus += 2
					trait_lines.append("#%d %s: +2 Blood" % [fid, fname])
			"high_chanter":
				if int(info.get("tier", 0)) == highest_tier_sac:
					trait_additive_total += 5
					trait_lines.append("#%d %s: +5 additive" % [fid, fname])
			"low_chanter":
				if int(info.get("tier", 0)) == lowest_tier_sac:
					trait_additive_total += 4
					trait_lines.append("#%d %s: +4 additive" % [fid, fname])
			"bloodbrand":
				if info["trait"] == "BLOOD" and blood_count >= 2:
					trait_additive_total += 7
					trait_lines.append("#%d %s: +7 additive" % [fid, fname])
			"ossuary_laborer":
				if info["trait"] == "BONE" and bone_count >= 2:
					trait_additive_total += 7
					trait_lines.append("#%d %s: +7 additive" % [fid, fname])
			"void_entrant":
				if info["trait"] == "VOID" and void_count == 1:
					trait_additive_total += 6
					trait_blood_bonus += 1
					trait_lines.append("#%d %s: +6 additive, +1 Blood" % [fid, fname])
			"triune_acolyte":
				if has_blood and has_bone and has_void:
					trait_additive_total += 10
					trait_lines.append("#%d %s: +10 additive" % [fid, fname])
			"zealot_ledger":
				if indices.size() == 3:
					trait_blood_bonus += 2
					trait_lines.append("#%d %s: +2 Blood" % [fid, fname])
			"bone_tithe":
				if bone_count >= 2:
					trait_blood_bonus += 2
					trait_lines.append("#%d %s: +2 Blood" % [fid, fname])
			"pair_hunter":
				if has_pair_tier:
					trait_additive_total += 6
					trait_lines.append("#%d %s: +6 additive" % [fid, fname])
			"apex_rite":
				if int(info.get("tier", 0)) == highest_tier_sac:
					trait_additive_total += 6
					trait_lines.append("#%d %s: +6 additive" % [fid, fname])
			"abyss_rite":
				if int(info.get("tier", 0)) == lowest_tier_sac:
					trait_additive_total += 5
					trait_lines.append("#%d %s: +5 additive" % [fid, fname])
			"rite_channeler":
				if indices.size() == 3 and void_count == 0:
					trait_additive_total += 8
					trait_lines.append("#%d %s: +8 additive" % [fid, fname])
			"ember_saint":
				if info["trait"] == "BLOOD" and int(info.get("tier", 0)) >= 4:
					trait_additive_total += 6
					trait_lines.append("#%d %s: +6 additive" % [fid, fname])
			"marrow_mason":
				if info["trait"] == "BONE" and int(info.get("tier", 0)) >= 4:
					trait_additive_total += 8
					trait_lines.append("#%d %s: +8 additive" % [fid, fname])
			"resilient":
				if apply_currency:
					if _rng.randf() < 0.35:
						trait_resilient_saved[fid] = true
						trait_lines.append("#%d %s: returned to pool" % [fid, fname])
					else:
						trait_lines.append("#%d %s: no effect" % [fid, fname])
				else:
					trait_lines.append("#%d %s: 35%% chance to return" % [fid, fname])
			"ossuary_king":
				if bone_count >= 2:
					trait_additive_total += 18
					trait_lines.append("#%d %s: +18 additive" % [fid, fname])
			"gravetide":
				if apply_currency:
					gravetide_spawns += 1
					trait_lines.append("#%d %s: spawn T1 BONE" % [fid, fname])
				else:
					trait_lines.append("#%d %s: spawn T1 BONE" % [fid, fname])
			"martyrs_ledger":
				trait_blood_bonus += 3
				trait_lines.append("#%d %s: +3 Blood" % [fid, fname])
			"chosen_veil":
				trait_additive_total += 4
				trait_lines.append("#%d %s: +4 additive" % [fid, fname])
			"sanguine_conductor":
				if info["trait"] == "BLOOD" and blood_count >= 2:
					trait_additive_total += 16
					trait_lines.append("#%d %s: +16 additive" % [fid, fname])
			"ossuary_archon":
				if info["trait"] == "BONE" and bone_count >= 2:
					trait_additive_total += 20
					trait_lines.append("#%d %s: +20 additive" % [fid, fname])
			"hush_matron":
				if info["trait"] == "VOID" and void_count == 1:
					trait_additive_total += 12
					trait_blood_bonus += 2
					trait_lines.append("#%d %s: +12 additive, +2 Blood" % [fid, fname])
			"paired_sigil":
				if int(tier_counts.get(int(info.get("tier", 0)), 0)) >= 2:
					var sigil_delta: int = int(info.get("base_contrib", 0)) + 4
					trait_additive_total += sigil_delta
					trait_lines.append("#%d %s: +%d additive (paired base doubled + bonus)" % [fid, fname, sigil_delta])
			"votive_executor":
				if info["trait"] == "BONE" and highest_tier_is_bone_only:
					trait_additive_total += 14
					trait_blood_bonus += 2
					trait_lines.append("#%d %s: +14 additive, +2 Blood" % [fid, fname])
			"sanguine_overseer":
				if info["trait"] == "BLOOD" and blood_count >= 3:
					trait_additive_total += 24
					trait_lines.append("#%d %s: +24 additive" % [fid, fname])
			"ossuary_overseer":
				if info["trait"] == "BONE" and bone_count >= 3 and void_count == 0:
					trait_additive_total += 28
					trait_lines.append("#%d %s: +28 additive" % [fid, fname])
			"hush_executor":
				if info["trait"] == "VOID" and void_count == 1:
					trait_additive_total += 14
					trait_blood_bonus += 2
					if trait_multiplier_applied_count < multiplier_trait_cap:
						trait_multiplier_applied_count += 1
						trait_base_bonus += 1
						trait_multiplier_lines.append("#%d %s: +14 additive, +2 Blood, multiplier base +1" % [fid, fname])
					else:
						trait_lines.append("#%d %s: +14 additive, +2 Blood" % [fid, fname])
						trait_multiplier_skipped.append("#%d %s: multiplier base +1 (multiplier trait cap)" % [fid, fname])
			"triune_champion":
				if has_blood and has_bone and has_void:
					trait_final_mult_factor = max(trait_final_mult_factor, 1.25)
					trait_multiplier_lines.append("#%d %s: final devotion x1.25" % [fid, fname])
			"grave_banker":
				trait_blood_bonus += 3
				if apply_currency:
					gravetide_spawns += 1
				trait_lines.append("#%d %s: +3 Blood, spawn T1 BONE" % [fid, fname])
			"brood_sovereign":
				trait_additive_total += 8
				trait_blood_bonus += 2
				trait_lines.append("#%d %s: +8 additive, +2 Blood" % [fid, fname])
			"brood_keeper":
				trait_additive_total += 6
				trait_lines.append("#%d %s: +6 additive" % [fid, fname])
			"lineage_tutor":
				trait_additive_total += 4
				trait_blood_bonus += 2
				trait_lines.append("#%d %s: +4 additive, +2 Blood" % [fid, fname])
			"whispered":
				if void_count == 1:
					if trait_multiplier_applied_count < multiplier_trait_cap:
						trait_multiplier_applied_count += 1
						trait_base_bonus += 1
						trait_multiplier_lines.append("#%d %s: multiplier base +1" % [fid, fname])
					else:
						trait_multiplier_skipped.append("#%d %s: (no effect: multiplier trait cap)" % [fid, fname])
			"blood_prophet":
				if blood_count == 3:
					if trait_multiplier_applied_count < multiplier_trait_cap:
						trait_multiplier_applied_count += 1
						trait_exponent_bonus += 1
						trait_multiplier_lines.append("#%d %s: multiplier exponent +1" % [fid, fname])
					else:
						trait_multiplier_skipped.append("#%d %s: (no effect: multiplier trait cap)" % [fid, fname])
			"straight_rite":
				if tier_straight:
					if trait_multiplier_applied_count < multiplier_trait_cap:
						trait_multiplier_applied_count += 1
						trait_base_bonus += 2
						trait_multiplier_lines.append("#%d %s: multiplier base +2" % [fid, fname])
					else:
						trait_multiplier_skipped.append("#%d %s: (no effect: multiplier trait cap)" % [fid, fname])
			"void_herald":
				if void_count == 1:
					if trait_multiplier_applied_count < multiplier_trait_cap:
						trait_multiplier_applied_count += 1
						trait_base_bonus += 2
						trait_multiplier_lines.append("#%d %s: multiplier base +2" % [fid, fname])
					else:
						trait_multiplier_skipped.append("#%d %s: (no effect: multiplier trait cap)" % [fid, fname])
			"black_candlebearer":
				if void_count == 0:
					if trait_multiplier_applied_count < multiplier_trait_cap:
						trait_multiplier_applied_count += 1
						trait_black_candlebearer_count += 1
						var floor_value: int = 1 + trait_black_candlebearer_count
						trait_multiplier_lines.append("#%d %s: multiplier base at least %d" % [fid, fname, floor_value])
					else:
						trait_multiplier_skipped.append("#%d %s: (no effect: multiplier trait cap)" % [fid, fname])
			"crimson_ascendant":
				if info["trait"] == "BLOOD" and blood_count == 3 and indices.size() == 3:
					trait_blood_bonus += 3
					if trait_multiplier_applied_count < multiplier_trait_cap:
						trait_multiplier_applied_count += 1
						trait_base_bonus += 2
						trait_multiplier_lines.append("#%d %s: multiplier base +2, +3 Blood" % [fid, fname])
					else:
						trait_multiplier_skipped.append("#%d %s: +3 Blood (multiplier trait cap)" % [fid, fname])
			"ossuary_oracle":
				if info["trait"] == "BONE" and bone_count >= 2 and void_count == 0:
					trait_additive_total += 24
					trait_lines.append("#%d %s: +24 additive" % [fid, fname])
			"void_crown":
				if info["trait"] == "VOID" and void_count == 1:
					trait_additive_total += 10
					if trait_multiplier_applied_count < multiplier_trait_cap:
						trait_multiplier_applied_count += 1
						trait_base_bonus += 2
						trait_multiplier_lines.append("#%d %s: +10 additive, multiplier base +2" % [fid, fname])
					else:
						trait_multiplier_skipped.append("#%d %s: +10 additive (multiplier trait cap)" % [fid, fname])
			"triune_heir":
				if has_blood and has_bone and has_void:
					trait_final_mult_factor = max(trait_final_mult_factor, 1.35)
					trait_multiplier_lines.append("#%d %s: final devotion x1.35" % [fid, fname])
			"apostolic_womb":
				trait_additive_total += 12
				trait_blood_bonus += 2
				trait_lines.append("#%d %s: +12 additive, +2 Blood" % [fid, fname])
			"crimson_revelation":
				if info["trait"] == "BLOOD" and blood_count == 3 and indices.size() == 3:
					trait_blood_bonus += 4
					if trait_multiplier_applied_count < multiplier_trait_cap:
						trait_multiplier_applied_count += 1
						trait_exponent_bonus += 2
						trait_multiplier_lines.append("#%d %s: multiplier exponent +2, +4 Blood" % [fid, fname])
					else:
						trait_multiplier_skipped.append("#%d %s: +4 Blood (multiplier trait cap)" % [fid, fname])
			"ossuary_titan":
				if info["trait"] == "BONE" and bone_count >= 3 and void_count == 0:
					trait_additive_total += 36
					trait_lines.append("#%d %s: +36 additive" % [fid, fname])
			_:
				pass

	if arterial_rite_copies > 0 and is_all_blood and indices.size() == 3:
		var total_trait_events: int = trait_lines.size() + trait_multiplier_lines.size() + trait_multiplier_skipped.size()
		if total_trait_events == 0:
			var arterial_delta: int = 40 * arterial_rite_copies
			relic_additive_total += arterial_delta
			relic_lines.append("The Arterial Rite: +%d" % arterial_delta)
	if apply_currency:
		if is_triune_play:
			triune_play_seen_run = true
			if int(relic_inventory.get("Trine Offering", 0)) > 0:
				trine_offering_free_recruits_pending += int(relic_inventory.get("Trine Offering", 0))
			if week_round == 1:
				triune_rounds_this_week = triune_rounds_this_week | 1
			elif week_round == 2:
				triune_rounds_this_week = triune_rounds_this_week | 2
		if int(relic_inventory.get("The Unbroken Rite", 0)) > 0 and week_round == 2 and triune_rounds_this_week == 3:
			guaranteed_rare_next_shop = true
		if int(relic_inventory.get("Crimson Ledger", 0)) > 0 and is_all_blood and indices.size() == 3:
			crimson_ledger_stacks += int(relic_inventory.get("Crimson Ledger", 0))
		if int(relic_inventory.get("The Triad Compact", 0)) > 0 and indices.size() == 3:
			triad_compact_bonus += int(relic_inventory.get("The Triad Compact", 0))
		if int(relic_inventory.get("The Expanding Rite", 0)) > 0 and indices.size() == 4:
			expanding_rite_bonus += 2 * int(relic_inventory.get("The Expanding Rite", 0))

	# Doctrine additive modifiers (after trait + additive relics, before multiplicative modifiers)
	var target: int = get_week_target(current_week)
	if selected_doctrine == "FLESH":
		if blood_count >= 3:
			var bonus: int = int(floor(float(target) * 0.08))
			doctrine_additive += bonus
			doctrine_lines.append("Path of Flesh: +%d (3+ BLOOD, 8%% of target %d)" % [bonus, target])
		elif blood_count == 0:
			var penalty: int = int(floor(float(target) * 0.04))
			doctrine_additive -= penalty
			doctrine_lines.append("Path of Flesh: -%d (no BLOOD, 4%% of target %d)" % [penalty, target])
		else:
			doctrine_lines.append("Path of Flesh: +0")
	elif selected_doctrine == "RUIN":
		if bone_count > 0:
			var highest_tier: int = 0
			var highest_trait: String = ""
			for info in sacrificed_info:
				var t: int = int(info["tier"])
				if t > highest_tier:
					highest_tier = t
					highest_trait = info["trait"]
			if highest_trait == "BONE":
				var bonus: int = int(floor(float(target) * 0.10)) + (highest_tier * 2)
				doctrine_additive += bonus
				doctrine_lines.append("Path of Ruin: +%d (10%% of target %d + tier %d×2)" % [bonus, target, highest_tier])
			else:
				doctrine_lines.append("Path of Ruin: +0")
		else:
			doctrine_lines.append("Path of Ruin: +0")
	elif selected_doctrine == "SILENCE":
		doctrine_lines.append("Path of Silence: +0")

	var relic_additive_pre_mult: int = relic_additive_total
	additive_total = followers_subtotal + doctrine_additive + relic_additive_pre_mult + trait_additive_total
	if additive_total < 0:
		additive_total = 0
	var pre_mult_ctx: Dictionary = {
		"indices": indices,
		"has_blood": has_blood,
		"has_bone": has_bone,
		"has_void": has_void,
		"sacrificed_info": sacrificed_info,
		"additive_total": additive_total,
		"relic_additive_total": relic_additive_total,
		"relic_lines": relic_lines,
	}
	_apply_relic_scoring_hooks("PRE_MULT", pre_mult_ctx)
	additive_total = int(pre_mult_ctx.get("additive_total", 0))
	relic_additive_total = int(pre_mult_ctx.get("relic_additive_total", 0))
	if crypt_standard_copies > 0 and bone_count == 2 and void_count == 0:
		var crypt_delta: int = additive_total
		additive_total *= 2
		relic_additive_total += crypt_delta
		relic_lines.append("Crypt Standard: +%d (x2)" % crypt_delta)

	var effective_void: int = void_count + prism_copies + ritual_void_bonus
	var sovereign_bonus: int = 1 if _has_active_annihilation_sovereign() else 0
	if sovereign_bonus > 0 and void_count > 0:
		var sovereign_delta: int = void_count * sovereign_bonus
		effective_void += sovereign_delta
		relic_multiplier_lines.append("Annihilation Compact: effective VOID +%d" % sovereign_delta)
	if deepest_void_copies > 0 and void_count > 0:
		var deepest_bonus: int = void_count * deepest_void_copies
		effective_void += deepest_bonus
		relic_multiplier_lines.append("The Deepest Void: effective VOID +%d" % deepest_bonus)
	var empty_pyre_base_bonus: int = 0
	if empty_pyre_copies > 0 and void_count > 0:
		for info in sacrificed_info:
			if str(info.get("trait", "")) != "VOID":
				continue
			var void_tier: int = int(info.get("tier", 0))
			if void_tier > 0:
				# Tiered VOID replaces its normal +1 base step with +tier.
				empty_pyre_base_bonus += max(0, void_tier - 1)
		if empty_pyre_base_bonus > 0:
			relic_multiplier_lines.append("The Empty Pyre: multiplier base +%d" % empty_pyre_base_bonus)
	var base_before_candle: int = 1 + effective_void + trait_base_bonus + empty_pyre_base_bonus
	if dyad_mark_copies > 0 and indices.size() == 2:
		base_before_candle += dyad_mark_copies
		relic_multiplier_lines.append("The Dyad Mark: multiplier base +%d" % dyad_mark_copies)
	if last_rung_copies > 0:
		var last_rung_bonus: int = 0
		for info in sacrificed_info:
			if int(info.get("tier", 0)) >= 10:
				last_rung_bonus += 5 * last_rung_copies
		if last_rung_bonus > 0:
			base_before_candle += last_rung_bonus
			relic_multiplier_lines.append("The Last Rung: multiplier base +%d" % last_rung_bonus)
	var base: int = base_before_candle
	if candle_copies > 0:
		base = max(2, base)
	if white_wall_copies > 0 and bone_count == 3 and void_count == 0:
		base = max(2, base)
		relic_multiplier_lines.append("The White Wall: multiplier base at least 2")
	if trait_black_candlebearer_count > 0:
		base = max(1 + trait_black_candlebearer_count, base)
	if sanguine_chord_copies > 0 and tier_straight:
		base += sanguine_chord_copies
		relic_multiplier_lines.append("The Sanguine Chord: multiplier base +%d (tier straight)" % sanguine_chord_copies)
	var exponent: int = 1 if hollow_copies == 0 else (hollow_copies + 1)
	if hollow_pact_copies > 0:
		exponent += hollow_pact_copies
		relic_multiplier_lines.append("The Hollow Pact: multiplier exponent +%d" % hollow_pact_copies)
	if final_silence_copies > 0 and void_count == 1:
		exponent += 2 * final_silence_copies
		relic_multiplier_lines.append("The Final Silence: multiplier exponent +%d" % (2 * final_silence_copies))
	if selected_doctrine == "SILENCE" and void_count == 1:
		var silence_bonus: int = 2 if final_silence_copies > 0 else 1
		exponent += silence_bonus
		doctrine_exponent_bonus = silence_bonus
		doctrine_multiplier_lines.append("Path of Silence: multiplier exponent +%d" % silence_bonus)
	var multiplier_ctx: Dictionary = {
		"void_count": void_count,
		"current_week": current_week,
		"cold_incense_used_week": cold_incense_used_week,
		"base_before_candle": base_before_candle,
		"base": base,
		"exponent": exponent,
		"cold_incense_applied": cold_incense_applied,
		"relic_multiplier_lines": relic_multiplier_lines,
	}
	_apply_relic_scoring_hooks("MULTIPLIER_ADJUST", multiplier_ctx)
	base = int(multiplier_ctx.get("base", base))
	exponent = int(multiplier_ctx.get("exponent", exponent))
	cold_incense_applied = bool(multiplier_ctx.get("cold_incense_applied", false))
	if hollow_register_stacks > 0:
		exponent += hollow_register_stacks
		relic_multiplier_lines.append("The Hollow Register: multiplier exponent +%d" % hollow_register_stacks)
	if trait_exponent_bonus > 0:
		exponent += trait_exponent_bonus
	if null_covenant_copies > 0 and base >= 5:
		relic_blood_bonus += base * null_covenant_copies
		relic_multiplier_lines.append("Null Covenant: +%d Blood" % (base * null_covenant_copies))
	var multiplier: int = int(pow(float(base), float(exponent)))
	var multiplier_bonus_factor: float = 1.0
	if absent_crown_copies > 0 and void_count == 2 and indices.size() > 0:
		refined_void_count = max(refined_void_count, 2)
		relic_multiplier_lines.append("The Absent Crown: both VOID treated as refined")
	if refinery_copies > 0 and void_count > 0 and refined_void_count == 0:
		refined_void_count = 1
		relic_multiplier_lines.append("Refinery of Silence: one VOID treated as refined")
	if refined_void_count > 0:
		var refined_step: float = 0.5 + (0.2 * float(refinery_copies))
		multiplier_bonus_factor = 1.0 + (refined_step * float(refined_void_count))
	var void_resonance_factor: float = 1.0
	if void_count >= 2:
		void_resonance_factor += 0.25 * float(void_count - 1)
		relic_multiplier_lines.append("Void Resonance: final devotion x%.2f" % void_resonance_factor)
	var final_devotion: int = int(float(additive_total * multiplier) * multiplier_bonus_factor * void_resonance_factor)
	var lineage_values: Array[int] = []
	var lineage_score: int = 0
	for info in sacrificed_info:
		var lineage_value: int = clamp(int(info.get("lineage", 0)), 0, 10)
		lineage_values.append(lineage_value)
		lineage_score += lineage_value
	if lineage_score > 0:
		var lineage_mult: float = 1.0 + (float(lineage_score) * LINEAGE_MULT_PER_POINT)
		lineage_mult = min(lineage_mult, LINEAGE_MULT_CAP)
		final_devotion = int(floor(float(final_devotion) * lineage_mult))
		var lineage_terms: Array[String] = []
		for lineage_value in lineage_values:
			lineage_terms.append("L%d" % lineage_value)
		relic_multiplier_lines.append("Lineage x%.2f (%s = %dpts)" % [lineage_mult, " + ".join(lineage_terms), lineage_score])
	if count_absolute_copies > 0 and indices.size() == 1 and highest_tier_sac >= 10:
		final_devotion = int(floor(float(final_devotion) * 2.0))
		relic_multiplier_lines.append("The Count Absolute: final devotion x2")
	if crimson_absolute_copies > 0 and is_all_blood and tier_sum >= 24:
		final_devotion = int(floor(float(final_devotion) * 1.5))
		relic_multiplier_lines.append("Crimson Absolute: final devotion x1.5")
	if absolute_trinity_copies > 0 and is_triune_play:
		var type_tiers: Dictionary = {"BLOOD": -1, "BONE": -1}
		for info in sacrificed_info:
			var trn: String = str(info.get("trait", ""))
			if type_tiers.has(trn):
				type_tiers[trn] = max(int(type_tiers[trn]), int(info.get("tier", -1)))
		if int(type_tiers["BLOOD"]) >= 0 and int(type_tiers["BLOOD"]) == int(type_tiers["BONE"]):
			final_devotion = int(floor(float(final_devotion) * 2.0))
			relic_multiplier_lines.append("The Absolute Trinity: final devotion x2")
	if last_sacrifice_copies > 0:
		var non_soul: int = 0
		for f in pool:
			if str(f.get("trait", "")) != "SOUL":
				non_soul += 1
		if non_soul < 5:
			final_devotion *= 2
			relic_multiplier_lines.append("The Last Sacrifice: final devotion x2")
	if hungry_altar_copies > 0:
		final_devotion *= 2
		relic_multiplier_lines.append("The Hungry Altar: final devotion x2")
	if trinity_engine_copies > 0 and is_triune_play:
		var champ_seen: bool = false
		var heir_seen: bool = false
		for info in sacrificed_info:
			for tid in _trait_ids_for_follower(info):
				if tid == "triune_champion":
					champ_seen = true
				elif tid == "triune_heir":
					heir_seen = true
		if champ_seen:
			final_devotion = int(floor(float(final_devotion) * 1.25))
		if heir_seen:
			final_devotion = int(floor(float(final_devotion) * 1.35))
		if champ_seen or heir_seen:
			relic_multiplier_lines.append("The Trinity Engine: triune trait multipliers fully applied")
	if trait_final_mult_factor > 1.0:
		final_devotion = int(floor(float(final_devotion) * trait_final_mult_factor))
	var cap_mult: float = float(get_run_config().get("round_devotion_cap_mult", 0.0))
	if ossuary_absolute_copies > 0 and bone_count == 3 and void_count == 0:
		var all_bone_high: bool = true
		for info in sacrificed_info:
			if str(info.get("trait", "")) != "BONE" or int(info.get("tier", 0)) < 7:
				all_bone_high = false
				break
		should_ignore_round_cap = all_bone_high
	if cap_mult > 0.0:
		var round_cap: int = int(floor(float(target) * cap_mult))
		if round_cap > 0 and not should_ignore_round_cap:
			final_devotion = min(final_devotion, round_cap)

	var soul_tithe_copies: int = int(relic_inventory.get("Soul Tithe", 0))
	if soul_tithe_copies > 0:
		var soul_count_pool: int = 0
		for pf in pool:
			if str(pf.get("trait", "")) == "SOUL":
				soul_count_pool += 1
		if soul_count_pool > 0:
			relic_blood_bonus += soul_count_pool * soul_tithe_copies
			relic_lines.append("Soul Tithe: +%d Blood" % (soul_count_pool * soul_tithe_copies))
	var per_blood: int = 2 + relic_inventory["Blood Abacus"]
	blood_gain = (blood_count * per_blood) + trait_blood_bonus + relic_blood_bonus
	if apply_currency:
		add_blood(blood_gain)
		var play_passed: bool = final_devotion >= target
		if copper_tithe_copies > 0 and play_passed:
			add_blood(copper_tithe_copies)
			relic_lines.append("The Copper Tithe: +%d Blood" % copper_tithe_copies)
		if int(relic_inventory.get("The Running Red", 0)) > 0 and play_passed and is_all_blood and indices.size() == 3:
			for i in range(int(relic_inventory.get("The Running Red", 0))):
				if is_pool_at_capacity():
					break
				pool.append(_make_specific_follower("BLOOD", 3, "running_red"))
		if pared_offering_copies > 0 and indices.size() == 1 and sacrificed_info.size() == 1:
			var single_trait: String = str(sacrificed_info[0].get("trait", "BLOOD"))
			for i in range(pared_offering_copies):
				if is_pool_at_capacity():
					break
				var spawn_trait: String = single_trait if single_trait != "SOUL" else "BLOOD"
				pool.append(_make_specific_follower(spawn_trait, 2, "pared_offering"))
		var forced_return_ids: Dictionary = {}
		if gilded_offering_copies > 0:
			for info in sacrificed_info:
				if int(info.get("tier", 0)) >= 10:
					forced_return_ids[int(info.get("id", -1))] = true
			if forced_return_ids.size() > 0:
				relic_lines.append("The Gilded Offering: tier-10 sacrifices return to pool")
		if void_cradle_copies > 0:
			for info in sacrificed_info:
				if str(info.get("trait", "")) != "VOID":
					continue
				forced_return_ids[int(info.get("id", -1))] = true
			if void_count > 0:
				relic_lines.append("Void Cradle: sacrificed VOID returned")
		for fid_key in forced_return_ids.keys():
			trait_resilient_saved[int(fid_key)] = true
		if hollow_register_copies > 0 and void_count == 1 and hollow_register_awarded_week != current_week:
			hollow_register_stacks += max(1, hollow_register_copies)
			hollow_register_awarded_week = current_week
		if void_recursion_copies > 0 and void_recursion_used_week != current_week:
			var picked_void: Dictionary = {}
			for info in sacrificed_info:
				if str(info.get("trait", "")) != "VOID":
					continue
				if picked_void.is_empty() or int(info.get("tier", 0)) > int(picked_void.get("tier", 0)):
					picked_void = info
			if not picked_void.is_empty() and not is_pool_at_capacity():
				var copied_tier: int = 0
				var copied_tid: String = str(picked_void.get("trait_id", ""))
				var copied_rarity: String = _trait_rarity(copied_tid)
				var baby_copy: Dictionary = _make_specific_follower("VOID", copied_tier, "void_recursion", copied_tid, copied_rarity)
				baby_copy["tier"] = copied_tier
				pool.append(baby_copy)
				void_recursion_used_week = current_week
		if int(relic_inventory.get("Gravewright", 0)) > 0:
			for info in sacrificed_info:
				if str(info.get("trait", "")) != "BONE":
					continue
				if is_pool_at_capacity():
					break
				if _rng.randf() < 0.25:
					pool.append(_make_specific_follower("BONE", 2, "gravewright"))
		if cursed_offering_copies > 0 and not pool.is_empty():
			var pick_idx: int = _rng.randi_range(0, pool.size() - 1)
			pool[pick_idx]["tier"] = max(0, int(pool[pick_idx].get("tier", 0)) - 1)
		if cold_incense_applied:
			cold_incense_used_week = current_week
		if ritual_card_active == "Rebirth":
			ritual_rebirth_pending = true
		ritual_card_active = ""
		last_resilient_saved_ids = trait_resilient_saved
		if gravetide_spawns > 0:
			for i in range(gravetide_spawns):
				if is_pool_at_capacity():
					break
				pool.append(_make_specific_follower("BONE", 1, "grave_spawn"))
		var post_resolve_ctx: Dictionary = {
			"apply_currency": apply_currency,
			"indices": indices,
			"blood_count": blood_count,
		}
		_apply_relic_scoring_hooks("POST_RESOLVE", post_resolve_ctx)
		summit_last_round_highest_tier = highest_tier_sac
		if next_round_additive_penalty > 0:
			next_round_additive_penalty = 0

	var summary_parts: Array[String] = []
	for info in sacrificed_info:
		var tags: String = ""
		var tid: String = str(info.get("trait_id", ""))
		if tid != "":
			var tr: String = _trait_rarity(tid)
			var rarity_mark: String = "[C]"
			if tr == "RARE":
				rarity_mark = "[R]"
			elif tr == "LEGENDARY":
				rarity_mark = "[L]"
			tags = " (%s %s)" % [rarity_mark, _trait_name(tid)]
		summary_parts.append("#%d %s t%d%s" % [
			int(info.get("id", 0)),
			info["trait"],
			int(info["tier"]),
			tags,
		])

	var doctrine_name: String = "None"
	if selected_doctrine == "FLESH":
		doctrine_name = "Path of Flesh"
	elif selected_doctrine == "RUIN":
		doctrine_name = "Path of Ruin"
	elif selected_doctrine == "SILENCE":
		doctrine_name = "Path of Silence"

	# Sanity scenarios for breakdown output:
	# - No relics, no doctrine bonus, with 1 VOID
	# - Multiple additive relics (Crimson Book, Bone Idol, Calcify)
	# - Hollow Chant exponent modification
	# - Path of Silence exponent bonus
	# - Common trait additive trigger (Fickle, Zealous)
	var lines: Array[String] = []
	lines.append("--------------------------------")
	lines.append("SACRIFICE SUMMARY")
	lines.append("Sacrificed: " + (", ".join(summary_parts) if summary_parts.size() > 0 else "(none)"))
	var pass_fail: String = "PASS" if final_devotion >= target else "FAIL"
	lines.append("Target: %d   Final Devotion: %d   Result: %s" % [target, final_devotion, pass_fail])
	lines.append("--------------------------------")
	lines.append("")
	lines.append("1) FOLLOWERS (Base)")
	if followers_lines.size() == 0:
		lines.append("- (none): +0")
	else:
		for fl in followers_lines:
			lines.append(fl)
	lines.append("Subtotal (Followers): +%d" % followers_subtotal)
	lines.append("")
	lines.append("2) DOCTRINE (%s)" % doctrine_name)
	if doctrine_lines.size() == 0:
		lines.append("- (none): +0")
	else:
		for dl in doctrine_lines:
			lines.append("- " + dl)
	for dm in doctrine_multiplier_lines:
		lines.append("- " + dm)
	lines.append("Subtotal (Doctrine): %+d" % doctrine_additive)
	lines.append("")
	lines.append("3) RELICS")
	if relic_lines.size() == 0 and relic_multiplier_lines.size() == 0:
		lines.append("- (none): +0")
	else:
		for rl in relic_lines:
			lines.append("- " + rl)
		for rm in relic_multiplier_lines:
			lines.append("- " + rm)
	lines.append("Subtotal (Relics): +%d" % relic_additive_total)
	lines.append("")
	lines.append("4) TRAITS / BELIEFS")
	if trait_lines.size() == 0 and trait_multiplier_lines.size() == 0 and trait_multiplier_skipped.size() == 0:
		lines.append("- (none): +0")
	else:
		for tl in trait_lines:
			lines.append("- " + tl)
		for tm in trait_multiplier_lines:
			lines.append("- " + tm)
		for ts in trait_multiplier_skipped:
			lines.append("- " + ts)
	lines.append("Subtotal (Traits/Beliefs): +%d" % trait_additive_total)
	lines.append("")
	lines.append("MULTIPLIER SUMMARY")
	lines.append("- Void count (effective): %d" % effective_void)
	lines.append("- Multiplier base: %d" % base)
	lines.append("- Multiplier exponent: %d" % exponent)
	lines.append("- Multiplier = %d^%d = %d" % [base, exponent, multiplier])
	if multiplier_bonus_factor != 1.0:
		lines.append("- Bonus factor (refined VOID): x%.2f" % multiplier_bonus_factor)
	var final_line: String = "Final Devotion = (Followers + Doctrine + Relics + Traits/Beliefs) * %d" % multiplier
	if multiplier_bonus_factor != 1.0:
		final_line += " * %.2f" % multiplier_bonus_factor
	lines.append(final_line)
	lines.append("--------------------------------")
	lines.append("Blood gained: +%d" % blood_gain)

	var breakdown: String = "\n".join(lines)
	if write_breakdown:
		last_breakdown_text = breakdown
	if write_log:
		_write_debug_log(indices, sacrificed_info, additive_total, base, exponent, multiplier, final_devotion, blood_gain, target)

	return {
		"final_devotion": final_devotion,
		"breakdown": breakdown,
		"blood_gain": blood_gain,
		"void_count": void_count,
		"blood_count": blood_count,
		"bone_count": bone_count,
		"per_blood": per_blood,
		"base": base,
		"exponent": exponent,
		"multiplier": multiplier,
		"additive_total": additive_total,
		"relic_lines": relic_lines,
		"doctrine_lines": doctrine_lines,
		"blood_terms": blood_terms,
		"bone_terms": bone_terms,
		"refined_void_count": refined_void_count,
		"calcify_total": (bone_count * 2 * calcify_copies),
		"quick_total": (3 * quick_copies if indices.size() > 0 else 0),
		"thin_total": (8 * thin_copies if indices.size() == 1 else 0),
		"ossuary_total": (10 * ossuary_copies if bone_count >= 2 else 0),
		"polisher_total": polisher_total,
		"symmetry_total": (12 * symmetry_copies if indices.size() % 2 == 0 and indices.size() > 0 else 0),
		"order_mult": (int(pow(2.0, float(order_copies))) if indices.size() == 3 and order_copies > 0 else 1),
		"balanced_mult": (int(pow(2.0, float(balanced_copies))) if balanced_copies > 0 and has_blood and has_bone and has_void else 1),
		"doctrine_additive": doctrine_additive,
		"trait_lines": trait_lines,
		"trait_multiplier_lines": trait_multiplier_lines,
		"trait_multiplier_skipped": trait_multiplier_skipped,
		"trait_additive_total": trait_additive_total,
		"trait_blood_bonus": trait_blood_bonus,
		"trait_trigger_count": trait_lines.size() + trait_multiplier_lines.size() + trait_multiplier_skipped.size(),
		"target": target,
		"pass": final_devotion >= target,
	}

func _write_debug_log(indices: Array[int], sacrificed_info: Array[Dictionary], additive_total: int, base: int, exponent: int, multiplier: int, final_devotion: int, blood_gain: int, target: int) -> void:
	var lines: Array[String] = []
	lines.append("=== Round Log ===")
	lines.append("Week: %d  Round: %d" % [current_week, week_round])
	lines.append("Target: %d" % target)
	lines.append("Doctrine: %s" % (selected_doctrine if selected_doctrine != "" else "none"))
	lines.append("Relics: %s" % _relic_summary())
	lines.append("Selected order (indices): %s" % [str(indices)])
	lines.append("Sacrificed details:")
	for info in sacrificed_info:
		var line: String = "#%d %s(%d) trait=%s effective=%d ritual=%s" % [
			info["index"] + 1,
			info["trait"],
			info["tier"],
			_trait_name(str(info.get("trait_id", ""))),
			info["effective_tier"],
			str(info["ritual_applied"]),
		]
		lines.append(line)
	lines.append("Additive total: %d" % additive_total)
	lines.append("Void base: %d  exponent: %d  multiplier: %d" % [base, exponent, multiplier])
	lines.append("Final devotion: %d" % final_devotion)
	var per_blood: int = 2 + relic_inventory["Blood Abacus"]
	lines.append("Blood gain: %d (per %d)  Blood total: %d" % [blood_gain, per_blood, blood_currency])
	lines.append("")
	_append_log(lines)

func _append_log(lines: Array[String]) -> void:
	var path: String = "user://debug_log.txt"
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE_READ)
	if file == null:
		return
	file.seek_end()
	for line in lines:
		file.store_line(line)
	file.flush()

func log_message(msg: String) -> void:
	if suppress_logs:
		return
	print(msg)
	last_logs.append(msg)
	while last_logs.size() > 10:
		last_logs.pop_front()

func _relic_summary() -> String:
	var parts: Array[String] = []
	for name in RELICS:
		var count: int = relic_inventory.get(name, 0)
		if count > 0:
			parts.append("%s=%d" % [name, count])
	if parts.is_empty():
		return "none"
	return ", ".join(parts)
