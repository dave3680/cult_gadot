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
	"straight_rite": {"name": "Straight Rite", "rarity": "RARE", "type": "MULTIPLIER", "desc": "If all 3 BLOOD and tiers consecutive, exponent +2."},
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
	"crimson_ascendant": {"name": "Crimson Ascendant", "rarity": "LEGENDARY", "type": "HYBRID", "desc": "If this is BLOOD and all 3 are BLOOD, exponent +2 and +3 Blood."},
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
const NEST_LEGENDARY_TO_RARE_CHANCE := 0.65
const NEST_SINGLE_RARE_TO_RARE_CHANCE := 0.55
const MULTIPLIER_TRAIT_CAP := 1
const POOL_CAP := 1000
const STARTING_NESTS := 2
const RUN_CONFIG_DEFAULT := {
	"max_weeks": 10,
	"target_base": 40,
	"target_growth": 1.5,
	"overflow_devotion_per_blood": 1,
	"overflow_blood_per_devotion": 1,
	"overflow_weekly_cap": 0,
	"early_win_bonus": 20,
	"round_devotion_cap_mult": 1.25,
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
	"Ossuary Standards": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "+5 additive per BONE sacrificed per copy (flat, not tier-scaled)."},
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
	"The Soul Lantern": {"rarity": "LEGENDARY", "stacks": false, "category": "RELIC", "desc": "Once per run: ascend a pool follower to VOID (+2 tier). Drains all blood to 0."},
	"First Apostle": {"rarity": "LEGENDARY", "stacks": false, "category": "RELIC", "desc": "Choose a follower as Apostle; it shapes breeding outcomes."},
}

const RELIC_SCORING_HOOKS := {
	"PRE_ADD": {
		"Crimson Book": "_hook_pre_add_crimson_book",
		"Bone Idol": "_hook_pre_add_bone_idol",
		"Ossuary Standards": "_hook_pre_add_ossuary_standards",
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
	},
	"PRE_MULT": {
		"Sacrificial Order": "_hook_pre_mult_sacrificial_order",
		"Balanced Offering": "_hook_pre_mult_balanced_offering",
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

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	_init_combo_trait_catalog()

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

func reset_run() -> void:
	_ensure_run_config()
	current_week = 1
	blood_currency = 0
	week_round = 1
	week_total_devotion = 0
	week_overflow_blood_granted = 0
	selected_doctrine = ""
	doctrine_used_this_play = false
	pool.clear()
	next_follower_id = 1
	shop_recruit_offers.clear()
	shop_recruit_purchased.clear()
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
	if combo_trait_catalog.is_empty():
		_init_combo_trait_catalog()

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

func get_overflow_weekly_cap() -> int:
	var cfg := get_run_config()
	return int(cfg.get("overflow_weekly_cap", 0))

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

func apply_overflow_blood_for_target(target: int) -> int:
	if target <= 0:
		return 0
	var devotion_per_blood: int = get_overflow_devotion_per_blood()
	var overflow_now: int = max(0, week_total_devotion - target)
	var overflow_blood_now: int = int(floor(float(overflow_now) / float(devotion_per_blood)))
	var cap: int = get_overflow_weekly_cap()
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
	current_hand.clear()
	pending_sacrifice_indices.clear()
	pending_confirmed = false
	pending_week = 0
	pending_round = 0
	pending_pass = false
	pending_target = 0
	early_win_bonus_week = -1

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
			{"trait": "VOID", "tier": _rng.randi_range(1, 2)},
			{"trait": "BLOOD", "tier": 5}, {"trait": "BLOOD", "tier": 6},
			{"trait": "BONE", "tier": 5},
			{"trait": "VOID", "tier": _rng.randi_range(1, 2)},
		]
	elif doctrine == "RUIN":
		entries = [
			{"trait": "BLOOD", "tier": 4}, {"trait": "BLOOD", "tier": 5},
			{"trait": "BLOOD", "tier": 5}, {"trait": "BLOOD", "tier": 5},
			{"trait": "BLOOD", "tier": 6}, {"trait": "BLOOD", "tier": 6},
			{"trait": "BONE", "tier": 4}, {"trait": "BONE", "tier": 5},
			{"trait": "BONE", "tier": 5}, {"trait": "BONE", "tier": 5},
			{"trait": "BONE", "tier": 6},
			{"trait": "VOID", "tier": _rng.randi_range(1, 2)},
			{"trait": "BONE", "tier": 5}, {"trait": "BONE", "tier": 6},
			{"trait": "BLOOD", "tier": 5},
			{"trait": "VOID", "tier": _rng.randi_range(1, 2)},
		]
	else:
		entries = [
			{"trait": "BLOOD", "tier": 4}, {"trait": "BLOOD", "tier": 4}, {"trait": "BLOOD", "tier": 5},
			{"trait": "BLOOD", "tier": 5}, {"trait": "BLOOD", "tier": 5},
			{"trait": "BLOOD", "tier": 6}, {"trait": "BLOOD", "tier": 6},
			{"trait": "BONE", "tier": 4}, {"trait": "BONE", "tier": 5}, {"trait": "BONE", "tier": 6},
			{"trait": "VOID", "tier": _rng.randi_range(1, 2)},
			{"trait": "VOID", "tier": _rng.randi_range(1, 2)},
			{"trait": "BLOOD", "tier": 5}, {"trait": "BONE", "tier": 5},
			{"trait": "VOID", "tier": _rng.randi_range(1, 2)},
			{"trait": "VOID", "tier": _rng.randi_range(1, 2)},
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
	for i in range(STARTING_NESTS):
		nests.append({"a": -1, "b": -1})

func _sanitize_nests() -> void:
	if nests.size() != STARTING_NESTS:
		_init_nests()
	var valid_ids: Dictionary = {}
	for f in pool:
		valid_ids[int(f.get("id", -1))] = true
	for i in range(nests.size()):
		var entry: Dictionary = nests[i]
		var a_id: int = int(entry.get("a", -1))
		var b_id: int = int(entry.get("b", -1))
		if a_id >= 0 and not valid_ids.has(a_id):
			entry["a"] = -1
		if b_id >= 0 and not valid_ids.has(b_id):
			entry["b"] = -1
		nests[i] = entry
	for i in range(favored_breeder_ids.size()):
		var fav_id: int = int(favored_breeder_ids[i])
		if fav_id >= 0 and not valid_ids.has(fav_id):
			favored_breeder_ids[i] = -1

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

func _make_specific_follower(trait_name: String, tier: int, origin: String, trait_id: String = "", trait_rarity: String = "") -> Dictionary:
	var t: int = tier
	var tr: String = trait_name
	if tr == "VOID":
		t = 0
	var tid: String = trait_id
	var trarity: String = trait_rarity
	if tid != "" and trarity == "":
		trarity = _trait_rarity(tid)
	return {
		"id": _next_id(),
		"tier": t,
		"trait": tr,
		"trait_id": tid,
		"trait_rarity": trarity,
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
		"trait_rarity": "",
		"exhausted": false,
		"origin_tag": origin,
	}

func generate_shop_recruits() -> void:
	shop_recruit_offers.clear()
	shop_recruit_purchased.clear()
	shop_copy_used = false
	shop_first_recruit_boost_used = false
	var tries: int = 0
	var desired: int = 4 if relic_inventory["Blood Market Stall"] > 0 else 3
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
		if roll_trait_bonus < SHOP_LEGENDARY_TRAIT_CHANCE:
			trait_id = _random_trait_id("LEGENDARY")
		elif roll_trait_bonus < (SHOP_LEGENDARY_TRAIT_CHANCE + SHOP_RARE_TRAIT_CHANCE):
			trait_id = _random_trait_id("RARE")
		elif roll_trait_bonus < (SHOP_LEGENDARY_TRAIT_CHANCE + SHOP_RARE_TRAIT_CHANCE + SHOP_COMMON_TRAIT_CHANCE):
			trait_id = _random_trait_id("COMMON")
		shop_recruit_offers.append(_make_specific_follower(trait_name, tier, "recruit_shop", trait_id))
		shop_recruit_purchased.append(false)

func buy_shop_recruit(index: int) -> Dictionary:
	if index < 0 or index >= shop_recruit_offers.size():
		return {"ok": false, "reason": "invalid"}
	var is_copy_purchase: bool = false
	if shop_recruit_purchased[index]:
		if relic_inventory["Votive Mirror"] > 0 and not shop_copy_used:
			is_copy_purchase = true
		else:
			return {"ok": false, "reason": "purchased"}
	if blood_currency < 1:
		return {"ok": false, "reason": "blood"}
	if pool.size() >= get_pool_cap():
		return {"ok": false, "reason": "full"}
	blood_currency -= 1
	var f: Dictionary = shop_recruit_offers[index].duplicate()
	if relic_inventory["Grave Ledger"] > 0 and not shop_first_recruit_boost_used and f["trait"] != "VOID":
		var boosted: int = min(MAX_TIER, int(f["tier"]) + relic_inventory["Grave Ledger"])
		f["tier"] = boosted
		shop_first_recruit_boost_used = true
	if relic_inventory["Omen Deck"] > 0:
		var omen_roll: float = _rng.randf()
		var omen_chance: float = 0.10 * float(relic_inventory["Omen Deck"])
		if omen_roll < omen_chance:
			f["trait_id"] = _random_trait_id("RARE")
			f["trait_rarity"] = "RARE"
	shop_recruit_purchased[index] = true
	if is_copy_purchase:
		shop_copy_used = true
	log_message("Shop recruit purchased: %s tier %d (id %d), blood now %d, pool size %d" % [
		f["trait"], int(f["tier"]), int(f["id"]), blood_currency, pool.size()
	])
	pool.append(f)
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
	var rebirth_idx: int = -1
	if ritual_rebirth_pending and not selected_indices.is_empty():
		var picks: Array[int] = selected_indices.duplicate()
		_shuffle_array(picks)
		rebirth_idx = picks[0]
	var survivors: Array[Dictionary] = []
	for i in range(current_hand.size()):
		var f: Dictionary = current_hand[i]
		if selected_set.has(i):
			if i == rebirth_idx:
				f["exhausted"] = false
				pool.append(f)
				continue
			if last_resilient_saved_ids.has(int(f["id"])):
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

func perform_weekly_breeding(week_cleared: int) -> void:
	var nest_summary: Dictionary = resolve_nest_breeding(week_cleared)
	var wild_summary: Dictionary = resolve_wild_breeding(week_cleared)
	favored_breeder_ids.clear()
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
	_sanitize_nests()
	last_nest_results.clear()
	var before: int = pool.size()
	var newborns: int = 0
	var trimmed: int = 0
	for n in range(nests.size()):
		var entry: Dictionary = nests[n]
		var a_id: int = int(entry.get("a", -1))
		var b_id: int = int(entry.get("b", -1))
		var result: Dictionary = {
			"nest": n + 1,
			"a_id": a_id,
			"b_id": b_id,
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
		var base_tier: int = int(floor((int(a.get("tier", 1)) + int(b.get("tier", 1))) / 2.0))
		var roll: float = _rng.randf()
		if roll < 0.2:
			base_tier += 1
		elif roll < 0.3:
			base_tier -= 1
		base_tier = clamp(base_tier, 1, MAX_TIER)
		if baby_trait == "VOID":
			base_tier = 0
		var parent_a_tid: String = str(a.get("trait_id", ""))
		var parent_b_tid: String = str(b.get("trait_id", ""))
		var parent_a_template: String = _combo_template_id(parent_a_tid)
		var parent_b_template: String = _combo_template_id(parent_b_tid)
		var has_nest_dynasty: bool = parent_a_template == "nest_dynasty" or parent_b_template == "nest_dynasty"
		var has_legendary_nest_dynasty: bool = (
			(parent_a_template == "nest_dynasty" and _trait_rarity(parent_a_tid) == "LEGENDARY")
			or (parent_b_template == "nest_dynasty" and _trait_rarity(parent_b_tid) == "LEGENDARY")
		)
		var has_brood_sovereign: bool = parent_a_tid == "brood_sovereign" or parent_b_tid == "brood_sovereign"
		var has_brood_keeper: bool = parent_a_tid == "brood_keeper" or parent_b_tid == "brood_keeper" or has_nest_dynasty
		var has_lineage_tutor: bool = parent_a_tid == "lineage_tutor" or parent_b_tid == "lineage_tutor" or has_nest_dynasty
		var has_apostolic_womb: bool = parent_a_tid == "apostolic_womb" or parent_b_tid == "apostolic_womb"
		if base_tier > 0 and has_brood_keeper:
			base_tier = min(MAX_TIER, base_tier + 1)
		if base_tier > 0 and has_brood_sovereign:
			base_tier = min(MAX_TIER, base_tier + 1)
		if base_tier > 0 and has_legendary_nest_dynasty:
			base_tier = min(MAX_TIER, base_tier + 1)
		var trait_id: String = _resolve_nest_trait_id(a, b)
		if has_apostolic_womb:
			var parent_traits: Array[String] = []
			if parent_a_tid != "":
				parent_traits.append(parent_a_tid)
			if parent_b_tid != "":
				parent_traits.append(parent_b_tid)
			if not parent_traits.is_empty():
				trait_id = parent_traits[_rng.randi_range(0, parent_traits.size() - 1)]
			if base_tier > 0:
				base_tier = min(MAX_TIER, base_tier + 2)
		elif has_lineage_tutor and trait_id == "":
			var tutor_chance: float = 0.55 if has_legendary_nest_dynasty else 0.35
			if _rng.randf() < tutor_chance:
				trait_id = _random_trait_id("COMMON")
		if has_brood_sovereign and trait_id == "" and _rng.randf() < 0.40:
			trait_id = _random_trait_id("RARE")
		var apostle_parent: bool = (apostle_id >= 0) and (int(a.get("id", -1)) == apostle_id or int(b.get("id", -1)) == apostle_id)
		if apostle_parent:
			trait_id = str(a.get("trait_id", "")) if int(a.get("id", -1)) == apostle_id else str(b.get("trait_id", ""))
			base_tier = min(MAX_TIER, base_tier + 1)
		if pool.size() >= get_pool_cap():
			result["reason"] = "pool full"
			trimmed += 1
			last_nest_results.append(result)
			continue
		var baby: Dictionary = _make_specific_follower(baby_trait, base_tier, "nest_bred", trait_id)
		pool.append(baby)
		newborns += 1
		result["success"] = true
		result["baby"] = baby
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
	_sanitize_nests()
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
		if is_favored_pair:
			favored_pair_attempted += 1
			chance = min(0.95, chance + 0.20)
		if _rng.randf() > chance:
			continue
		var baby_trait: String = _inherit_trait_breeding(str(a.get("trait", "")), str(b.get("trait", "")))
		var base_tier: int = int(floor((int(a.get("tier", 1)) + int(b.get("tier", 1))) / 2.0))
		var roll: float = _rng.randf()
		if roll < 0.2:
			base_tier += 1
		elif roll < 0.3:
			base_tier -= 1
		base_tier = clamp(base_tier, 1, MAX_TIER)
		if baby_trait == "VOID":
			base_tier = 0
		var trait_id: String = _roll_wild_breeding_trait(a, b)
		if pool.size() >= get_pool_cap():
			trimmed += 1
			continue
		pool.append(_make_specific_follower(baby_trait, base_tier, "wild_bred", trait_id))
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
	if fertility_copies > 0:
		base += 0.10 * float(fertility_copies)
	return min(0.95, base)

func boost_pool_tiers_weekly() -> void:
	for i in range(pool.size()):
		if pool[i]["trait"] == "VOID":
			continue
		pool[i]["tier"] = min(MAX_TIER, int(pool[i]["tier"]) + 1)

func _inherit_trait_breeding(a: String, b: String) -> String:
	if a == b:
		return a
	var pick: String = a if _rng.randf() < 0.5 else b
	if (a == "VOID" or b == "VOID") and pick == "VOID":
		return "VOID" if _rng.randf() < 0.30 else (b if a == "VOID" else a)
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

func _resolve_nest_target_rarity(parent_a: Dictionary, parent_b: Dictionary) -> String:
	var rarity_a: String = _trait_rarity(str(parent_a.get("trait_id", "")))
	var rarity_b: String = _trait_rarity(str(parent_b.get("trait_id", "")))
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
	var has_lineage_tutor: bool = parent_a_tid == "lineage_tutor" or parent_b_tid == "lineage_tutor" or has_nest_dynasty
	var has_chosen_veil: bool = parent_a_tid == "chosen_veil" or parent_b_tid == "chosen_veil"
	var has_selective_scroll: bool = relic_inventory["Selective Breeding Scroll"] > 0
	var has_favored_parent: bool = _is_favored_breeder(parent_a_id) or _is_favored_breeder(parent_b_id)
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
	single_rare_chance = clamp(single_rare_chance, 0.25, 0.95)
	rare_from_legendary_chance = clamp(rare_from_legendary_chance, 0.05, 0.95)
	common_to_rare_chance = clamp(common_to_rare_chance, 0.0, 0.80)
	if a_legendary and b_legendary:
		return "LEGENDARY"
	if a_rare and b_rare:
		return "RARE"
	if a_legendary or b_legendary:
		return "RARE" if _rng.randf() < rare_from_legendary_chance else "LEGENDARY"
	if a_rare or b_rare:
		return "RARE" if _rng.randf() < single_rare_chance else "COMMON"
	if common_to_rare_chance > 0.0 and _rng.randf() < common_to_rare_chance:
		return "RARE"
	return "COMMON"

func _pick_combo_trait_for_parents(parent_a_trait_id: String, parent_b_trait_id: String, target_rarity: String) -> String:
	if parent_a_trait_id == "" or parent_b_trait_id == "":
		return ""
	var key: String = _combo_pair_key(parent_a_trait_id, parent_b_trait_id)
	if not combo_trait_pair_index.has(key):
		return ""
	var bucket: Array = combo_trait_pair_index[key]
	var candidates: Array[String] = []
	for combo_id in bucket:
		var combo: Dictionary = get_combo_trait(str(combo_id))
		var rarity: String = str(combo.get("rarity", ""))
		if rarity == target_rarity:
			candidates.append(str(combo_id))
	if candidates.is_empty():
		return ""
	return candidates[_rng.randi_range(0, candidates.size() - 1)]

func _resolve_nest_trait_id(parent_a: Dictionary, parent_b: Dictionary) -> String:
	var parent_a_tid: String = str(parent_a.get("trait_id", ""))
	var parent_b_tid: String = str(parent_b.get("trait_id", ""))
	if relic_inventory["Seal of Inheritance"] > 0:
		var inherited: String = _pick_parent_trait_id(parent_a_tid, parent_b_tid)
		if inherited != "":
			return inherited
	var target_rarity: String = _resolve_nest_target_rarity(parent_a, parent_b)
	var combo_trait_id: String = _pick_combo_trait_for_parents(parent_a_tid, parent_b_tid, target_rarity)
	if combo_trait_id != "":
		return combo_trait_id
	if parent_a_tid != "" and parent_b_tid != "" and parent_a_tid == parent_b_tid and _trait_rarity(parent_a_tid) == target_rarity:
		return parent_a_tid
	var parent_matches: Array[String] = []
	if parent_a_tid != "" and _trait_rarity(parent_a_tid) == target_rarity:
		parent_matches.append(parent_a_tid)
	if parent_b_tid != "" and _trait_rarity(parent_b_tid) == target_rarity:
		parent_matches.append(parent_b_tid)
	if not parent_matches.is_empty():
		return parent_matches[_rng.randi_range(0, parent_matches.size() - 1)]
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

func _roll_breeding_trait(parent_a: Dictionary, parent_b: Dictionary) -> String:
	var roll_any: float = _rng.randf()
	var trait_id: String = ""
	var guaranteed: bool = (str(parent_a.get("trait_id", "")) == "chosen_veil") or (str(parent_b.get("trait_id", "")) == "chosen_veil")
	var parent_a_trait: String = str(parent_a.get("trait_id", ""))
	var parent_b_trait: String = str(parent_b.get("trait_id", ""))
	if relic_inventory["Seal of Inheritance"] > 0:
		var inherited: String = _pick_parent_trait_id(parent_a_trait, parent_b_trait)
		if inherited != "":
			return inherited
	if parent_a_trait != "" or parent_b_trait != "":
		if parent_a_trait != "" and parent_b_trait != "":
			trait_id = parent_a_trait if _rng.randf() < 0.5 else parent_b_trait
		else:
			trait_id = parent_a_trait if parent_a_trait != "" else parent_b_trait
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
	var parent_a_tid: String = str(parent_a.get("trait_id", ""))
	var parent_b_tid: String = str(parent_b.get("trait_id", ""))
	var brood_sovereign_parent: bool = parent_a_tid == "brood_sovereign" or parent_b_tid == "brood_sovereign"
	if relic_inventory["Seal of Inheritance"] > 0:
		var inherited: String = _pick_parent_trait_id(parent_a_tid, parent_b_tid)
		if inherited != "":
			return inherited
	var guaranteed: bool = (parent_a_tid == "chosen_veil") or (parent_b_tid == "chosen_veil") or brood_sovereign_parent
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
	var inherited_bias: float = 0.60 if brood_sovereign_parent else 0.35
	var parent_ids: Array[String] = []
	if parent_a_tid != "":
		parent_ids.append(parent_a_tid)
	if parent_b_tid != "":
		parent_ids.append(parent_b_tid)
	if not parent_ids.is_empty() and _rng.randf() < inherited_bias:
		return parent_ids[_rng.randi_range(0, parent_ids.size() - 1)]
	return _random_trait_id(rarity)

func _pick_parent_trait_id(parent_a_tid: String, parent_b_tid: String) -> String:
	var parent_ids: Array[String] = []
	if parent_a_tid != "":
		parent_ids.append(parent_a_tid)
	if parent_b_tid != "":
		parent_ids.append(parent_b_tid)
	if parent_ids.is_empty():
		return ""
	return parent_ids[_rng.randi_range(0, parent_ids.size() - 1)]

func cull_follower_by_id(follower_id: int) -> bool:
	if apostle_id == follower_id:
		return false
	for i in range(pool.size()):
		if int(pool[i]["id"]) == follower_id:
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
			return true
	return false

func ascend_follower_by_id(follower_id: int) -> bool:
	if soul_lantern_used:
		return false
	for i in range(pool.size()):
		if int(pool[i]["id"]) == follower_id:
			pool[i]["trait"] = "VOID"
			pool[i]["tier"] = min(MAX_TIER, int(pool[i]["tier"]) + 2)
			blood_currency = 0
			soul_lantern_used = true
			return true
	return false

func set_apostle(follower_id: int) -> bool:
	if apostle_id != -1:
		return false
	for i in range(pool.size()):
		if int(pool[i]["id"]) == follower_id:
			apostle_id = follower_id
			return true
	return false

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
	cap += (4 * salt_copies)
	cap -= (6 * ecto_copies)
	return max(10, cap)

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
	if relic_inventory["Debt Scripture"] > 0:
		return (blood_currency + 2) >= cost
	return false

func spend_blood_for_relic(cost: int) -> void:
	var available: int = blood_currency
	if available >= cost:
		blood_currency -= cost
		return
	if relic_inventory["Debt Scripture"] > 0:
		var shortfall: int = cost - available
		blood_currency = 0
		blood_debt = min(2, blood_debt + shortfall)

func can_offer_relic(name: String) -> bool:
	if not relic_inventory.has(name):
		return false
	if RELIC_DEFS.has(name) and not bool(RELIC_DEFS[name]["stacks"]):
		return relic_inventory[name] == 0
	return true

func get_week_target(week: int) -> int:
	if next_week_target_overrides.has(week):
		return int(next_week_target_overrides[week])
	var cfg := get_run_config()
	var base_target: float = float(cfg.get("target_base", 18.0))
	var growth: float = float(cfg.get("target_growth", 1.45))
	var w: int = max(1, week)
	var raw_target: float = base_target * pow(growth, float(w - 1))
	var rounded: int = int(round(raw_target))
	return int(round(float(rounded) / 5.0)) * 5

func get_max_weeks() -> int:
	var cfg := get_run_config()
	return int(cfg.get("max_weeks", 10))

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
	if not relic_inventory.has(name):
		return
	if RELIC_DEFS.has(name) and not bool(RELIC_DEFS[name]["stacks"]):
		relic_inventory[name] = 1
	else:
		relic_inventory[name] += 1

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

func _hook_pre_add_ossuary_standards(ctx: Dictionary, copies: int) -> void:
	var bone_count: int = int(ctx.get("bone_count", 0))
	if bone_count <= 0:
		return
	var delta: int = 5 * bone_count * copies
	_hook_additive_delta(ctx, "Ossuary Standards (x%d): +%d" % [copies, delta], delta)

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
	if indices.size() != 3 or not bool(ctx.get("blood_straight", false)):
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
	var ossuary_standards: int = relic_inventory["Ossuary Standards"]
	var hollow_abacus_copies: int = relic_inventory["Hollow Abacus"]
	var triune_copies: int = relic_inventory["Triune Reliquary"]
	var bloodright_copies: int = relic_inventory["Bloodright Almanac"]
	var ectoplasm_copies: int = relic_inventory["Ectoplasm Jar"]

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
	var trait_multiplier_applied: bool = false
	var trait_multiplier_skipped: Array[String] = []
	var trait_resilient_saved: Dictionary = {}
	var gravetide_spawns: int = 0
	var trait_base_bonus: int = 0
	var trait_exponent_bonus: int = 0
	var trait_force_base_min2: bool = false
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
			base_contrib = tier * 2
			var bone_term: int = effective_tier * (2 + bone_copies) + 5 * ossuary_standards
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
				# Includes ritual scaling plus Bone Idol interaction on the doubled tier.
				ritual_delta_total += (tier * 2) + (tier * (bone_copies + ossuary_standards))

		sacrificed_info.append({
			"index": idx,
			"id": follower_id,
			"trait": trait_name,
			"tier": tier,
			"base_contrib": base_contrib,
			"effective_tier": effective_tier,
			"ritual_applied": ritual_applied,
			"trait_id": trait_id,
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
	var blood_straight: bool = false
	if blood_count == 3:
		var blood_tiers: Array[int] = []
		for info in sacrificed_info:
			if info["trait"] == "BLOOD":
				blood_tiers.append(int(info["tier"]))
		blood_tiers.sort()
		if blood_tiers.size() == 3:
			blood_straight = (blood_tiers[0] + 1 == blood_tiers[1]) and (blood_tiers[1] + 1 == blood_tiers[2])
	var has_pair_tier: bool = false
	for tier_key in tier_counts.keys():
		if int(tier_counts[tier_key]) >= 2:
			has_pair_tier = true
			break

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
		"blood_straight": blood_straight,
		"relic_lines": relic_lines,
		"relic_additive_total": relic_additive_total,
		"relic_blood_bonus": relic_blood_bonus,
		"polisher_total": polisher_total,
	}
	_apply_relic_scoring_hooks("PRE_ADD", pre_add_ctx)
	relic_additive_total = int(pre_add_ctx.get("relic_additive_total", 0))
	relic_blood_bonus = int(pre_add_ctx.get("relic_blood_bonus", 0))
	polisher_total = int(pre_add_ctx.get("polisher_total", 0))

	if ritual_card_active == "Anoint":
		ritual_additive_bonus = 15
		relic_lines.append("Ritual Card (Anoint): +15")
		relic_additive_total += ritual_additive_bonus
	elif ritual_card_active == "Silence":
		ritual_void_bonus = 1
		relic_multiplier_lines.append("Ritual Card (Silence): effective VOID +1")
	elif ritual_card_active == "Rebirth":
		relic_lines.append("Ritual Card (Rebirth): return 1 sacrifice")

	for info in sacrificed_info:
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
				"blood_straight_exalt":
					if blood_count == 3:
						trait_blood_bonus += 3 if combo_is_legendary else 2
						if not trait_multiplier_applied:
							trait_multiplier_applied = true
							trait_exponent_bonus += 2 if combo_is_legendary else 1
							trait_multiplier_lines.append("#%d %s: multiplier exponent +%d, +%d Blood" % [
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
						if not trait_multiplier_applied:
							trait_multiplier_applied = true
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
				if info["trait"] == "BONE" and highest_tier_is_bone_only and int(info.get("tier", 0)) == highest_tier_sac:
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
					if not trait_multiplier_applied:
						trait_multiplier_applied = true
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
					if not trait_multiplier_applied:
						trait_multiplier_applied = true
						trait_base_bonus += 1
						trait_multiplier_lines.append("#%d %s: multiplier base +1" % [fid, fname])
					else:
						trait_multiplier_skipped.append("#%d %s: (no effect: multiplier trait cap)" % [fid, fname])
			"blood_prophet":
				if blood_count == 3:
					if not trait_multiplier_applied:
						trait_multiplier_applied = true
						trait_exponent_bonus += 1
						trait_multiplier_lines.append("#%d %s: multiplier exponent +1" % [fid, fname])
					else:
						trait_multiplier_skipped.append("#%d %s: (no effect: multiplier trait cap)" % [fid, fname])
			"straight_rite":
				if blood_count == 3:
					var tiers: Array[int] = []
					for si in sacrificed_info:
						tiers.append(int(si["tier"]))
					tiers.sort()
					var consecutive: bool = (tiers[0] + 1 == tiers[1]) and (tiers[1] + 1 == tiers[2])
					if consecutive:
						if not trait_multiplier_applied:
							trait_multiplier_applied = true
							trait_exponent_bonus += 2
							trait_multiplier_lines.append("#%d %s: multiplier exponent +2" % [fid, fname])
						else:
							trait_multiplier_skipped.append("#%d %s: (no effect: multiplier trait cap)" % [fid, fname])
			"void_herald":
				if void_count == 1:
					if not trait_multiplier_applied:
						trait_multiplier_applied = true
						trait_base_bonus += 2
						trait_multiplier_lines.append("#%d %s: multiplier base +2" % [fid, fname])
					else:
						trait_multiplier_skipped.append("#%d %s: (no effect: multiplier trait cap)" % [fid, fname])
			"black_candlebearer":
				if void_count == 0:
					if not trait_multiplier_applied:
						trait_multiplier_applied = true
						trait_force_base_min2 = true
						trait_multiplier_lines.append("#%d %s: multiplier base at least 2" % [fid, fname])
					else:
						trait_multiplier_skipped.append("#%d %s: (no effect: multiplier trait cap)" % [fid, fname])
			"crimson_ascendant":
				if info["trait"] == "BLOOD" and blood_count == 3 and indices.size() == 3:
					trait_blood_bonus += 3
					if not trait_multiplier_applied:
						trait_multiplier_applied = true
						trait_exponent_bonus += 2
						trait_multiplier_lines.append("#%d %s: multiplier exponent +2, +3 Blood" % [fid, fname])
					else:
						trait_multiplier_skipped.append("#%d %s: +3 Blood (multiplier trait cap)" % [fid, fname])
			"ossuary_oracle":
				if info["trait"] == "BONE" and bone_count >= 2 and void_count == 0:
					trait_additive_total += 24
					trait_lines.append("#%d %s: +24 additive" % [fid, fname])
			"void_crown":
				if info["trait"] == "VOID" and void_count == 1:
					trait_additive_total += 10
					if not trait_multiplier_applied:
						trait_multiplier_applied = true
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
					if not trait_multiplier_applied:
						trait_multiplier_applied = true
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

	# Doctrine additive modifiers (after trait + additive relics, before multiplicative modifiers)
	if selected_doctrine == "FLESH":
		if blood_count >= 3:
			doctrine_additive += 6
			doctrine_lines.append("Path of Flesh: +6 (3+ BLOOD)")
		elif blood_count == 0:
			doctrine_additive -= 6
			doctrine_lines.append("Path of Flesh: -6 (no BLOOD)")
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
				doctrine_additive += 8
				doctrine_lines.append("Path of Ruin: +8 (highest-tier was BONE)")
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
		"additive_total": additive_total,
		"relic_additive_total": relic_additive_total,
		"relic_lines": relic_lines,
	}
	_apply_relic_scoring_hooks("PRE_MULT", pre_mult_ctx)
	additive_total = int(pre_mult_ctx.get("additive_total", 0))
	relic_additive_total = int(pre_mult_ctx.get("relic_additive_total", 0))

	var effective_void: int = void_count + prism_copies + ritual_void_bonus
	var base_before_candle: int = 1 + effective_void + trait_base_bonus
	var base: int = base_before_candle
	if candle_copies > 0:
		base = max(2, base)
	if trait_force_base_min2:
		base = max(2, base)
	var exponent: int = 1 if hollow_copies == 0 else (hollow_copies + 1)
	if selected_doctrine == "SILENCE" and void_count == 1:
		exponent += 1
		doctrine_exponent_bonus = 1
		doctrine_multiplier_lines.append("Path of Silence: multiplier exponent +1")
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
	if trait_exponent_bonus > 0:
		exponent += trait_exponent_bonus
	var multiplier: int = int(pow(float(base), float(exponent)))
	var multiplier_bonus_factor: float = 1.0
	if refined_void_count > 0:
		multiplier_bonus_factor = 1.0 + (0.5 * float(refined_void_count))
	var final_devotion: int = int(float(additive_total * multiplier) * multiplier_bonus_factor)
	if trait_final_mult_factor > 1.0:
		final_devotion = int(floor(float(final_devotion) * trait_final_mult_factor))
	var target: int = get_week_target(current_week)
	var cap_mult: float = float(get_run_config().get("round_devotion_cap_mult", 0.0))
	if cap_mult > 0.0:
		var round_cap: int = int(floor(float(target) * cap_mult))
		if round_cap > 0:
			final_devotion = min(final_devotion, round_cap)

	var per_blood: int = 2 + relic_inventory["Blood Abacus"]
	blood_gain = (blood_count * per_blood) + trait_blood_bonus + relic_blood_bonus
	if apply_currency:
		add_blood(blood_gain)
		if cold_incense_applied:
			cold_incense_used_week = current_week
		if ritual_card_active == "Rebirth":
			ritual_rebirth_pending = true
		ritual_card_active = ""
		last_resilient_saved_ids = trait_resilient_saved
		if gravetide_spawns > 0:
			for i in range(gravetide_spawns):
				if pool.size() >= get_pool_cap():
					break
				pool.append(_make_specific_follower("BONE", 1, "grave_spawn"))
		var post_resolve_ctx: Dictionary = {
			"apply_currency": apply_currency,
			"indices": indices,
			"blood_count": blood_count,
		}
		_apply_relic_scoring_hooks("POST_RESOLVE", post_resolve_ctx)

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
