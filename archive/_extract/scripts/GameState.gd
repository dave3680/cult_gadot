extends Node

const TRAITS := ["BLOOD", "BONE", "VOID"]
const TRAIT_REGISTRY := {
	"devout": {"name": "Devout", "rarity": "COMMON", "type": "ADDITIVE", "desc": "When sacrificed, +1 additive."},
	"stalwart": {"name": "Stalwart", "rarity": "COMMON", "type": "ADDITIVE", "desc": "If this is BONE, +2 additive."},
	"fervent": {"name": "Fervent", "rarity": "COMMON", "type": "ECONOMY", "desc": "If exactly 3 are sacrificed, +1 Blood."},
	"twinborn": {"name": "Twinborn", "rarity": "COMMON", "type": "ADDITIVE", "desc": "If another sacrifice shares tier, +3 additive."},
	"whispered": {"name": "Whispered", "rarity": "COMMON", "type": "MULTIPLIER", "desc": "If exactly 1 VOID, multiplier base +1."},
	"resilient": {"name": "Resilient", "rarity": "COMMON", "type": "POOL", "desc": "When sacrificed, 20% chance to return to pool."},
	"blood_prophet": {"name": "Blood Prophet", "rarity": "RARE", "type": "MULTIPLIER", "desc": "If all 3 are BLOOD, exponent +1."},
	"straight_rite": {"name": "Straight Rite", "rarity": "RARE", "type": "MULTIPLIER", "desc": "If all 3 BLOOD and tiers consecutive, exponent +1."},
	"ossuary_king": {"name": "Ossuary King", "rarity": "RARE", "type": "ADDITIVE", "desc": "If 2+ BONE, +12 additive."},
	"gravetide": {"name": "Gravetide", "rarity": "RARE", "type": "POOL", "desc": "When sacrificed, add a T1 BONE to pool."},
	"void_herald": {"name": "Void Herald", "rarity": "RARE", "type": "MULTIPLIER", "desc": "If exactly 1 VOID, multiplier base +1."},
	"black_candlebearer": {"name": "Black Candlebearer", "rarity": "RARE", "type": "MULTIPLIER", "desc": "If 0 VOID, multiplier base at least 2."},
	"martyrs_ledger": {"name": "Martyr's Ledger", "rarity": "RARE", "type": "ECONOMY", "desc": "When sacrificed, +2 Blood."},
	"chosen_veil": {"name": "Chosen of the Veil", "rarity": "RARE", "type": "BREEDING", "desc": "If parent in breeding, newborn guaranteed a trait."},
}
const COMMON_TRAIT_IDS := ["devout", "stalwart", "fervent", "twinborn", "whispered", "resilient"]
const RARE_TRAIT_IDS := ["blood_prophet", "straight_rite", "ossuary_king", "gravetide", "void_herald", "black_candlebearer", "martyrs_ledger", "chosen_veil"]
const STARTING_TRAIT_CHANCE := 0.45
const SHOP_COMMON_TRAIT_CHANCE := 0.30
const SHOP_RARE_TRAIT_CHANCE := 0.08
const BREEDING_ANY_TRAIT_CHANCE := 0.40
const BREEDING_COMMON_CHANCE := 0.85
const MULTIPLIER_TRAIT_CAP := 1
const POOL_CAP := 1000
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
	"Ritual Knife": {"rarity": "COMMON", "stacks": false, "category": "RELIC", "desc": "The first follower you choose each week counts as double tier."},
	"Bone Idol": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "BONE followers are worth more."},
	"Crimson Book": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "Each BLOOD sacrifice adds a small bonus."},
	"Hollow Chant": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "VOID sacrifices boost your multiplier harder."},
	"Sacrificial Order": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "Exactly 3 sacrifices? Big devotion bonus."},
	"Ceremonial Cup": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "On a win, gain extra Blood before the shop."},
	"Blood Abacus": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "BLOOD sacrifices give extra Blood currency (does not change devotion)."},
	"Quick Chant": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "Any sacrifice grants a small devotion boost."},
	"Thin Blade": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "Sacrifice just 1? Gain a big devotion boost."},
	"Tithe Discount": {"rarity": "COMMON", "stacks": false, "category": "VOUCHER", "desc": "Relics cost 1 less Blood (min 2)."},
	"Ossuary Standard": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "Sacrifice at least 2 BONE to gain bonus devotion."},
	"Bone Polisher": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "Your strongest BONE adds extra devotion."},
	"Ritual Symmetry": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "Even-numbered sacrifices gain bonus devotion."},
	"Calcify": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "Each BONE sacrifice adds extra devotion."},
	"Crimson Interest": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "After the shop, earn bonus Blood based on your stash."},
	"Void Prism": {"rarity": "RARE", "stacks": true, "category": "RELIC", "desc": "VOID sacrifices count as extra for your multiplier."},
	"Black Candle": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "Your multiplier never starts below 2."},
	"The Third Knife": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "The first three followers you choose each week count as double tier."},
	"Balanced Offering": {"rarity": "RARE", "stacks": true, "category": "RELIC", "desc": "If you offer BLOOD, BONE, and VOID, devotion is doubled."},
	"Blasphemous Geometry": {"rarity": "RARE", "stacks": true, "category": "RELIC", "desc": "On a win, gain a large Blood bonus before the shop."},
	"Brass Tithe Bowl": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "On week success, gain +1 Blood per copy."},
	"Sharpened Chalk": {"rarity": "COMMON", "stacks": false, "category": "VOUCHER", "desc": "First relic reroll each shop costs 0."},
	"Prayer Beads": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "If all 3 sacrifices share a main trait, +6 additive per copy."},
	"Bone Saw": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "If 2+ BONE are sacrificed, gain +1 Blood per copy."},
	"Red Thread": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "If 3 BLOOD are sacrificed, random BLOOD in pool +1 tier per copy."},
	"Cold Incense": {"rarity": "COMMON", "stacks": false, "category": "RELIC", "desc": "If 0 VOID, multiplier base at least 2 once per week."},
	"Grave Ledger": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "First recruit you buy each shop gets +1 tier per copy (cap 4)."},
	"Culling Knife": {"rarity": "COMMON", "stacks": false, "category": "RELIC", "desc": "Once per shop, cull a follower from the pool for free."},
	"Wax Seal": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "If any pair of equal tiers, +8 additive per copy."},
	"Salt Circle": {"rarity": "COMMON", "stacks": true, "category": "VOUCHER", "desc": "Increase pool cap by +4 per copy."},
	"Spare Chalice": {"rarity": "COMMON", "stacks": false, "category": "RELIC", "desc": "If you enter shop with 0 Blood, gain +2 Blood."},
	"Choir Robes": {"rarity": "COMMON", "stacks": true, "category": "RELIC", "desc": "If all 3 sacrifices have different tiers, +5 additive per copy."},
	"Blood Market Stall": {"rarity": "UNCOMMON", "stacks": false, "category": "RELIC", "desc": "Shop recruit offers become 4 instead of 3."},
	"Ossuary Standards": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "Increase BONE additive factor by +1 per copy."},
	"Hollow Abacus": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "If exactly 1 VOID is sacrificed, exponent +1 per copy."},
	"Debt Scripture": {"rarity": "UNCOMMON", "stacks": false, "category": "VOUCHER", "desc": "You may buy relics up to 2 Blood short; debt is repaid from gains."},
	"Votive Mirror": {"rarity": "UNCOMMON", "stacks": false, "category": "RELIC", "desc": "Once per shop, buy one recruit offer twice."},
	"Fertility Idol": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "Breeding chance +10% per copy for couples with no VOID."},
	"Selective Breeding Scroll": {"rarity": "UNCOMMON", "stacks": false, "category": "RELIC", "desc": "Select 2 favored breeders to be paired this week."},
	"Triune Reliquary": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "If sacrifices include BLOOD+BONE+VOID, +12 additive per copy."},
	"Bloodright Almanac": {"rarity": "UNCOMMON", "stacks": true, "category": "RELIC", "desc": "If Blood Straight triggers, +10 additive and +2 Blood per copy."},
	"Clean Hands": {"rarity": "UNCOMMON", "stacks": false, "category": "RELIC", "desc": "If you clear a week with 0 VOID, gain 1 free relic reroll next shop."},
	"Ectoplasm Jar": {"rarity": "RARE", "stacks": true, "category": "VOUCHER", "desc": "+1 multiplier exponent per copy; pool cap -6 per copy."},
	"Black Contract": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "Once per week, you may sacrifice 4 instead of 3."},
	"Omen Deck": {"rarity": "RARE", "stacks": true, "category": "RELIC", "desc": "Recruits have +10% per copy chance to spawn with a RARE trait."},
	"Director's Cut": {"rarity": "RARE", "stacks": false, "category": "VOUCHER", "desc": "Once per week in shop, reroll next week target within ±15%."},
	"Scarlet Planetarium": {"rarity": "RARE", "stacks": false, "category": "CONSUMABLE", "desc": "Adds a Ritual Card slot; shop offers 1 Ritual Card."},
	"Seal of Inheritance": {"rarity": "RARE", "stacks": false, "category": "RELIC", "desc": "If either parent has a trait, newborn inherits a parent trait."},
	"The Soul Lantern": {"rarity": "LEGENDARY", "stacks": false, "category": "RELIC", "desc": "Once per run, ascend a follower in the pool."},
	"First Apostle": {"rarity": "LEGENDARY", "stacks": false, "category": "RELIC", "desc": "Choose a follower as Apostle; it shapes breeding outcomes."},
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
var apostle_id: int = -1
var ritual_card_slot: String = ""
var ritual_card_offer: String = ""
var ritual_card_active: String = ""
var ritual_rebirth_pending: bool = false
var suppress_logs: bool = false
var week_overflow_blood_granted: int = 0

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()

func reset_run() -> void:
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
	apostle_id = -1
	ritual_card_slot = ""
	ritual_card_offer = ""
	ritual_card_active = ""
	ritual_rebirth_pending = false

func draw_new_hand() -> void:
	current_hand.clear()
	for i in range(6):
		current_hand.append(_make_follower())

func _make_follower() -> Dictionary:
	var tier: int = _rng.randi_range(1, 5)
	var roll: float = _rng.randf()
	var trait_name: String = "BLOOD"
	if roll < 0.6:
		trait_name = "BLOOD"
	elif roll < 0.9:
		trait_name = "BONE"
	else:
		trait_name = "VOID"
		tier = 0
	return {
		"id": _next_id(),
		"tier": tier,
		"trait": trait_name,
		"trait_id": "",
		"trait_rarity": "",
		"exhausted": false,
		"origin_tag": "random",
	}

func _next_id() -> int:
	var id: int = next_follower_id
	next_follower_id += 1
	return id

func replace_sacrificed(indices: Array[int]) -> void:
	for idx in indices:
		if idx >= 0 and idx < current_hand.size():
			current_hand[idx] = _make_follower()

func start_week() -> void:
	week_round = 1
	week_total_devotion = 0
	week_overflow_blood_granted = 0
	last_breakdown_text = ""
	doctrine_used_this_play = false
	contract_allow_four = false
	current_hand.clear()

func init_starting_pool(doctrine: String) -> void:
	pool.clear()
	next_follower_id = 1
	var entries: Array[Dictionary] = []
	if doctrine == "FLESH":
		entries = [
			{"trait": "BLOOD", "tier": 1}, {"trait": "BLOOD", "tier": 1}, {"trait": "BLOOD", "tier": 1},
			{"trait": "BLOOD", "tier": 2}, {"trait": "BLOOD", "tier": 2}, {"trait": "BLOOD", "tier": 2},
			{"trait": "BLOOD", "tier": 3}, {"trait": "BLOOD", "tier": 3},
			{"trait": "BONE", "tier": 2}, {"trait": "BONE", "tier": 2}, {"trait": "BONE", "tier": 3},
			{"trait": "VOID", "tier": _rng.randi_range(1, 2)},
			{"trait": "BLOOD", "tier": 2}, {"trait": "BLOOD", "tier": 3},
			{"trait": "BONE", "tier": 2},
			{"trait": "VOID", "tier": _rng.randi_range(1, 2)},
		]
	elif doctrine == "RUIN":
		entries = [
			{"trait": "BLOOD", "tier": 1}, {"trait": "BLOOD", "tier": 1},
			{"trait": "BLOOD", "tier": 2}, {"trait": "BLOOD", "tier": 2},
			{"trait": "BLOOD", "tier": 3}, {"trait": "BLOOD", "tier": 3},
			{"trait": "BONE", "tier": 1}, {"trait": "BONE", "tier": 1},
			{"trait": "BONE", "tier": 2}, {"trait": "BONE", "tier": 2},
			{"trait": "BONE", "tier": 3},
			{"trait": "VOID", "tier": _rng.randi_range(1, 2)},
			{"trait": "BONE", "tier": 2}, {"trait": "BONE", "tier": 3},
			{"trait": "BLOOD", "tier": 2},
			{"trait": "VOID", "tier": _rng.randi_range(1, 2)},
		]
	else:
		entries = [
			{"trait": "BLOOD", "tier": 1}, {"trait": "BLOOD", "tier": 1}, {"trait": "BLOOD", "tier": 1},
			{"trait": "BLOOD", "tier": 2}, {"trait": "BLOOD", "tier": 2},
			{"trait": "BLOOD", "tier": 3}, {"trait": "BLOOD", "tier": 3},
			{"trait": "BONE", "tier": 1}, {"trait": "BONE", "tier": 2}, {"trait": "BONE", "tier": 3},
			{"trait": "VOID", "tier": _rng.randi_range(1, 2)},
			{"trait": "VOID", "tier": _rng.randi_range(1, 2)},
			{"trait": "BLOOD", "tier": 2}, {"trait": "BONE", "tier": 2},
			{"trait": "VOID", "tier": _rng.randi_range(1, 2)},
			{"trait": "VOID", "tier": _rng.randi_range(1, 2)},
		]
	for e in entries:
		var trait_roll: float = _rng.randf()
		var tid: String = ""
		if trait_roll < STARTING_TRAIT_CHANCE:
			tid = _random_trait_id("COMMON")
		pool.append(_make_specific_follower(e["trait"], int(e["tier"]), "start", tid))

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
	var tier: int = _rng.randi_range(1, 5)
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

		var roll_tier: float = _rng.randf()
		var tier: int = 1
		if roll_tier < 0.80:
			tier = _rng.randi_range(1, 3)
		else:
			tier = 4
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
		if roll_trait_bonus < SHOP_RARE_TRAIT_CHANCE:
			trait_id = _random_trait_id("RARE")
		elif roll_trait_bonus < (SHOP_RARE_TRAIT_CHANCE + SHOP_COMMON_TRAIT_CHANCE):
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
		var boosted: int = min(4, int(f["tier"]) + relic_inventory["Grave Ledger"])
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
	if pool.size() >= 6:
		return
	var needed: int = 6 - pool.size()
	for i in range(needed):
		var roll: float = _rng.randf()
		var trait_name: String = "BLOOD"
		if roll < 0.85:
			trait_name = "BLOOD"
		else:
			trait_name = "BONE"
		var tier: int = _rng.randi_range(1, 3)
		pool.append(_make_specific_follower(trait_name, tier, "recruit"))

func draw_hand_from_pool() -> void:
	ensure_pool_minimum_for_draw()
	current_hand.clear()
	pool.shuffle()
	for i in range(6):
		current_hand.append(pool.pop_back())

func resolve_play_and_update_pool(selected_indices: Array[int]) -> void:
	var selected_set: Dictionary = {}
	for idx in selected_indices:
		selected_set[idx] = true
	var rebirth_idx: int = -1
	if ritual_rebirth_pending and not selected_indices.is_empty():
		var picks: Array[int] = selected_indices.duplicate()
		picks.shuffle()
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
	var before: int = pool.size()
	var shuffled: Array = pool.duplicate()
	shuffled.shuffle()
	if favored_breeder_ids.size() == 2:
		var a_idx: int = -1
		var b_idx: int = -1
		for i in range(shuffled.size()):
			var fid: int = int(shuffled[i].get("id", -1))
			if fid == favored_breeder_ids[0]:
				a_idx = i
			elif fid == favored_breeder_ids[1]:
				b_idx = i
		if a_idx >= 0 and b_idx >= 0:
			var a: Dictionary = shuffled[a_idx]
			var b: Dictionary = shuffled[b_idx]
			shuffled.remove_at(max(a_idx, b_idx))
			shuffled.remove_at(min(a_idx, b_idx))
			shuffled.insert(0, b)
			shuffled.insert(0, a)
	var newborns: Array[Dictionary] = []
	var couples: int = int(floor(shuffled.size() / 2.0))
	var idx: int = 0
	for i in range(couples):
		var a: Dictionary = shuffled[idx]
		var b: Dictionary = shuffled[idx + 1]
		idx += 2
		var chance: float = _breeding_chance(a["trait"], b["trait"])
		if _rng.randf() > chance:
			continue
		var baby_trait: String = _inherit_trait_breeding(a["trait"], b["trait"])
		var base_tier: int = int(floor((int(a["tier"]) + int(b["tier"])) / 2.0))
		var roll: float = _rng.randf()
		if roll < 0.2:
			base_tier += 1
		elif roll < 0.3:
			base_tier -= 1
		base_tier = clamp(base_tier, 1, 6)
		if baby_trait == "VOID":
			base_tier = 0
		var trait_id: String = _roll_breeding_trait(a, b)
		var apostle_parent: bool = (apostle_id >= 0) and (int(a.get("id", -1)) == apostle_id or int(b.get("id", -1)) == apostle_id)
		if apostle_parent:
			trait_id = str(a.get("trait_id", "")) if int(a.get("id", -1)) == apostle_id else str(b.get("trait_id", ""))
			base_tier = min(6, base_tier + 1)
		newborns.append(_make_specific_follower(baby_trait, base_tier, "bred", trait_id))

	var trimmed: int = 0
	var cap: int = get_pool_cap()
	if pool.size() + newborns.size() > cap:
		trimmed = (pool.size() + newborns.size()) - cap
		newborns = newborns.slice(0, newborns.size() - trimmed)

	for nb in newborns:
		pool.append(nb)

	var summary: Dictionary = pool_summary_counts()
	log_message("BREEDING | Week %d | Pool %d->%d | Couples %d | Newborns %d | B:%d Bo:%d V:%d | Trimmed %d" % [
		week_cleared,
		before,
		pool.size(),
		couples,
		newborns.size(),
		summary["blood"],
		summary["bone"],
		summary["void"],
		trimmed,
	])
	favored_breeder_ids.clear()

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
		pool[i]["tier"] = min(6, int(pool[i]["tier"]) + 1)

func _inherit_trait_breeding(a: String, b: String) -> String:
	if a == b:
		return a
	var pick: String = a if _rng.randf() < 0.5 else b
	if (a == "VOID" or b == "VOID") and pick == "VOID":
		return "VOID" if _rng.randf() < 0.30 else (b if a == "VOID" else a)
	return pick

func _trait_rarity(trait_id: String) -> String:
	if trait_id == "":
		return ""
	if not TRAIT_REGISTRY.has(trait_id):
		return ""
	return str(TRAIT_REGISTRY[trait_id]["rarity"])

func _trait_name(trait_id: String) -> String:
	if trait_id == "":
		return "None"
	if not TRAIT_REGISTRY.has(trait_id):
		return trait_id
	return str(TRAIT_REGISTRY[trait_id]["name"])

func _random_trait_id(rarity: String) -> String:
	var pool: Array = COMMON_TRAIT_IDS if rarity == "COMMON" else RARE_TRAIT_IDS
	if pool.is_empty():
		return ""
	return pool[_rng.randi_range(0, pool.size() - 1)]

func _roll_breeding_trait(parent_a: Dictionary, parent_b: Dictionary) -> String:
	var roll_any: float = _rng.randf()
	var trait_id: String = ""
	var guaranteed: bool = (str(parent_a.get("trait_id", "")) == "chosen_veil") or (str(parent_b.get("trait_id", "")) == "chosen_veil")
	var parent_a_trait: String = str(parent_a.get("trait_id", ""))
	var parent_b_trait: String = str(parent_b.get("trait_id", ""))
	if parent_a_trait != "" or parent_b_trait != "":
		if parent_a_trait != "" and parent_b_trait != "":
			trait_id = parent_a_trait if _rng.randf() < 0.5 else parent_b_trait
		else:
			trait_id = parent_a_trait if parent_a_trait != "" else parent_b_trait
		return trait_id

	if not guaranteed and roll_any > BREEDING_ANY_TRAIT_CHANCE:
		return ""
	var roll_rarity: float = _rng.randf()
	var rarity: String = "COMMON" if roll_rarity < BREEDING_COMMON_CHANCE else "RARE"
	trait_id = _random_trait_id(rarity)
	return trait_id

func cull_follower_by_id(follower_id: int) -> bool:
	if apostle_id == follower_id:
		return false
	for i in range(pool.size()):
		if int(pool[i]["id"]) == follower_id:
			pool.remove_at(i)
			return true
	return false

func ascend_follower_by_id(follower_id: int) -> bool:
	if soul_lantern_used:
		return false
	for i in range(pool.size()):
		if int(pool[i]["id"]) == follower_id:
			pool[i]["trait"] = "VOID"
			pool[i]["tier"] = min(6, int(pool[i]["tier"]) + 2)
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

func set_favored_breeder(follower_id: int, slot: int) -> void:
	if favored_breeder_ids.size() < 2:
		favored_breeder_ids.resize(2)
	if slot < 0 or slot > 1:
		return
	favored_breeder_ids[slot] = follower_id

func pool_summary_counts() -> Dictionary:
	var blood: int = 0
	var bone: int = 0
	var voids: int = 0
	var total_tier: int = 0
	for f in pool:
		var tr: String = f["trait"]
		if tr == "BLOOD":
			blood += 1
		elif tr == "BONE":
			bone += 1
		else:
			voids += 1
		total_tier += int(f["tier"])
	var avg: float = 0.0
	if pool.size() > 0:
		avg = float(total_tier) / float(pool.size())
	return {"total": pool.size(), "blood": blood, "bone": bone, "void": voids, "avg_tier": avg}

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
	var base_target: float = 20.0
	var growth: float = 1.9
	var w: int = max(1, week)
	return int(round(base_target * pow(growth, float(w - 1))))

func get_shop_cost(week: int) -> int:
	var base_cost: int = 10
	var discount: int = 0
	if relic_inventory["Tithe Discount"] > 0:
		discount = 1
	return max(2, base_cost - discount)

func get_shop_rarity_slots(week_cleared: int) -> Array[String]:
	if week_cleared <= 2:
		return ["COMMON", "COMMON", "UNCOMMON"]
	return ["COMMON", "UNCOMMON", "RARE"]

func add_relic(name: String) -> void:
	if not relic_inventory.has(name):
		return
	if RELIC_DEFS.has(name) and not bool(RELIC_DEFS[name]["stacks"]):
		relic_inventory[name] = 1
	else:
		relic_inventory[name] += 1

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
			var bone_term: int = effective_tier * (2 + bone_copies + ossuary_standards)
			bone_terms.append(str(bone_term))
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

	if crimson_copies > 0 and blood_count > 0:
		var crimson_delta: int = crimson_copies * blood_count
		relic_lines.append("Crimson Book (x%d): +%d" % [crimson_copies, crimson_delta])
		relic_additive_total += crimson_delta

	if bone_copies > 0 and bone_count > 0:
		var bone_idol_delta: int = 0
		for info in sacrificed_info:
			if info["trait"] == "BONE":
				bone_idol_delta += int(info["tier"]) * bone_copies
		relic_lines.append("Bone Idol (x%d): +%d" % [bone_copies, bone_idol_delta])
		relic_additive_total += bone_idol_delta
	if ossuary_standards > 0 and bone_count > 0:
		var ossuary_std_delta: int = 0
		for info in sacrificed_info:
			if info["trait"] == "BONE":
				ossuary_std_delta += int(info["tier"]) * ossuary_standards
		relic_lines.append("Ossuary Standards (x%d): +%d" % [ossuary_standards, ossuary_std_delta])
		relic_additive_total += ossuary_std_delta

	if calcify_copies > 0 and bone_count > 0:
		var calcify_delta: int = 2 * calcify_copies * bone_count
		relic_lines.append("Calcify (x%d): +%d" % [calcify_copies, calcify_delta])
		relic_additive_total += calcify_delta

	if indices.size() == 1 and thin_copies > 0:
		var thin_delta: int = 8 * thin_copies
		relic_lines.append("Thin Blade (x%d): +%d" % [thin_copies, thin_delta])
		relic_additive_total += thin_delta

	if indices.size() > 0 and quick_copies > 0:
		var quick_delta: int = 3 * quick_copies
		relic_lines.append("Quick Chant (x%d): +%d" % [quick_copies, quick_delta])
		relic_additive_total += quick_delta

	if bone_count >= 2 and ossuary_copies > 0:
		var ossuary_delta: int = 10 * ossuary_copies
		relic_lines.append("Ossuary Standard (x%d): +%d" % [ossuary_copies, ossuary_delta])
		relic_additive_total += ossuary_delta

	if polisher_copies > 0 and bone_count > 0:
		var highest_bone: int = 0
		for info in sacrificed_info:
			if info["trait"] == "BONE":
				highest_bone = max(highest_bone, int(info["tier"]))
		polisher_total = highest_bone * polisher_copies
		relic_lines.append("Bone Polisher (x%d): +%d" % [polisher_copies, polisher_total])
		relic_additive_total += polisher_total
	if indices.size() % 2 == 0 and indices.size() > 0 and symmetry_copies > 0:
		var symmetry_delta: int = 12 * symmetry_copies
		relic_lines.append("Ritual Symmetry (x%d): +%d" % [symmetry_copies, symmetry_delta])
		relic_additive_total += symmetry_delta

	var tier_counts: Dictionary = {}
	for info in sacrificed_info:
		var t: int = int(info["tier"])
		tier_counts[t] = int(tier_counts.get(t, 0)) + 1

	var same_trait: bool = has_blood and not has_bone and not has_void
	same_trait = same_trait or (has_bone and not has_blood and not has_void)
	same_trait = same_trait or (has_void and not has_blood and not has_bone)
	if prayer_copies > 0 and same_trait and indices.size() == 3:
		var prayer_delta: int = 6 * prayer_copies
		relic_lines.append("Prayer Beads (x%d): +%d" % [prayer_copies, prayer_delta])
		relic_additive_total += prayer_delta
	if wax_seal_copies > 0:
		var has_pair: bool = false
		for key in tier_counts.keys():
			if int(tier_counts[key]) >= 2:
				has_pair = true
				break
		if has_pair:
			var wax_delta: int = 8 * wax_seal_copies
			relic_lines.append("Wax Seal (x%d): +%d" % [wax_seal_copies, wax_delta])
			relic_additive_total += wax_delta
	if choir_copies > 0 and tier_counts.keys().size() == 3 and indices.size() == 3:
		var choir_delta: int = 5 * choir_copies
		relic_lines.append("Choir Robes (x%d): +%d" % [choir_copies, choir_delta])
		relic_additive_total += choir_delta
	if triune_copies > 0 and has_blood and has_bone and has_void and indices.size() == 3:
		var triune_delta: int = 12 * triune_copies
		relic_lines.append("Triune Reliquary (x%d): +%d" % [triune_copies, triune_delta])
		relic_additive_total += triune_delta
	if red_thread_copies > 0 and blood_count == 3 and indices.size() == 3:
		relic_lines.append("Red Thread (x%d): +1 tier to random BLOOD" % red_thread_copies)

	var blood_straight: bool = false
	if blood_count == 3:
		var blood_tiers: Array[int] = []
		for info in sacrificed_info:
			if info["trait"] == "BLOOD":
				blood_tiers.append(int(info["tier"]))
		blood_tiers.sort()
		if blood_tiers.size() == 3:
			blood_straight = (blood_tiers[0] + 1 == blood_tiers[1]) and (blood_tiers[1] + 1 == blood_tiers[2])
	if bloodright_copies > 0 and blood_straight and indices.size() == 3:
		var bloodright_add: int = 10 * bloodright_copies
		relic_lines.append("Bloodright Almanac (x%d): +%d" % [bloodright_copies, bloodright_add])
		relic_additive_total += bloodright_add
		relic_blood_bonus += 2 * bloodright_copies
		relic_lines.append("Bloodright Almanac (x%d): +%d Blood" % [bloodright_copies, 2 * bloodright_copies])

	if bone_saw_copies > 0 and bone_count >= 2:
		relic_blood_bonus += bone_saw_copies
		relic_lines.append("Bone Saw (x%d): +%d Blood" % [bone_saw_copies, bone_saw_copies])

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
		match tid:
			"devout":
				trait_additive_total += 1
				trait_lines.append("#%d %s: +1 additive" % [fid, fname])
			"stalwart":
				if info["trait"] == "BONE":
					trait_additive_total += 2
					trait_lines.append("#%d %s: +2 additive" % [fid, fname])
			"fervent":
				if indices.size() == 3:
					trait_blood_bonus += 1
					trait_lines.append("#%d %s: +1 Blood" % [fid, fname])
			"twinborn":
				if int(tier_counts.get(int(info["tier"]), 0)) >= 2:
					trait_additive_total += 3
					trait_lines.append("#%d %s: +3 additive" % [fid, fname])
			"resilient":
				if apply_currency:
					if _rng.randf() < 0.20:
						trait_resilient_saved[fid] = true
						trait_lines.append("#%d %s: returned to pool" % [fid, fname])
					else:
						trait_lines.append("#%d %s: no effect" % [fid, fname])
				else:
					trait_lines.append("#%d %s: 20%% chance to return" % [fid, fname])
			"ossuary_king":
				if bone_count >= 2:
					trait_additive_total += 12
					trait_lines.append("#%d %s: +12 additive" % [fid, fname])
			"gravetide":
				if apply_currency:
					gravetide_spawns += 1
					trait_lines.append("#%d %s: spawn T1 BONE" % [fid, fname])
				else:
					trait_lines.append("#%d %s: spawn T1 BONE" % [fid, fname])
			"martyrs_ledger":
				trait_blood_bonus += 2
				trait_lines.append("#%d %s: +2 Blood" % [fid, fname])
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
							trait_exponent_bonus += 1
							trait_multiplier_lines.append("#%d %s: multiplier exponent +1" % [fid, fname])
						else:
							trait_multiplier_skipped.append("#%d %s: (no effect: multiplier trait cap)" % [fid, fname])
			"void_herald":
				if void_count == 1:
					if not trait_multiplier_applied:
						trait_multiplier_applied = true
						trait_base_bonus += 1
						trait_multiplier_lines.append("#%d %s: multiplier base +1" % [fid, fname])
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

	if indices.size() == 3 and order_copies > 0:
		var order_mult: int = int(pow(2.0, float(order_copies)))
		var order_delta: int = additive_total * (order_mult - 1)
		additive_total *= order_mult
		relic_lines.append("Sacrificial Order (x%d): +%d" % [order_mult, order_delta])
		relic_additive_total += order_delta
	if balanced_copies > 0 and has_blood and has_bone and has_void:
		var balanced_mult: int = int(pow(2.0, float(balanced_copies)))
		var balanced_delta: int = additive_total * (balanced_mult - 1)
		additive_total *= balanced_mult
		relic_lines.append("Balanced Offering (x%d): +%d" % [balanced_mult, balanced_delta])
		relic_additive_total += balanced_delta

	var effective_void: int = void_count + prism_copies + ritual_void_bonus
	var base_before_candle: int = 1 + effective_void + trait_base_bonus
	var base: int = base_before_candle
	if candle_copies > 0:
		base = max(2, base)
	if trait_force_base_min2:
		base = max(2, base)
	if cold_incense_copies > 0 and void_count == 0 and cold_incense_used_week != current_week:
		base = max(2, base)
		cold_incense_applied = true
	var exponent: int = 1 if hollow_copies == 0 else (hollow_copies + 1)
	if selected_doctrine == "SILENCE" and void_count == 1:
		exponent += 1
		doctrine_exponent_bonus = 1
		doctrine_multiplier_lines.append("Path of Silence: multiplier exponent +1")
	if hollow_abacus_copies > 0 and void_count == 1:
		exponent += hollow_abacus_copies
		relic_multiplier_lines.append("Hollow Abacus (x%d): multiplier exponent +%d" % [hollow_abacus_copies, hollow_abacus_copies])
	if ectoplasm_copies > 0:
		exponent += ectoplasm_copies
		relic_multiplier_lines.append("Ectoplasm Jar (x%d): multiplier exponent +%d" % [ectoplasm_copies, ectoplasm_copies])
	if trait_exponent_bonus > 0:
		exponent += trait_exponent_bonus
	var multiplier: int = int(pow(float(base), float(exponent)))
	var multiplier_bonus_factor: float = 1.0
	if refined_void_count > 0:
		multiplier_bonus_factor = 1.0 + (0.5 * float(refined_void_count))
	if hollow_copies > 0:
		relic_multiplier_lines.append("Hollow Chant (x%d): multiplier exponent +%d" % [hollow_copies, hollow_copies])
	if prism_copies > 0:
		relic_multiplier_lines.append("Void Prism (x%d): effective VOID +%d" % [prism_copies, prism_copies])
	if candle_copies > 0 and base_before_candle < 2:
		relic_multiplier_lines.append("Black Candle: multiplier base at least 2")
	if cold_incense_applied:
		relic_multiplier_lines.append("Cold Incense: multiplier base at least 2 (weekly)")
	var final_devotion: int = int(float(additive_total * multiplier) * multiplier_bonus_factor)
	var target: int = get_week_target(current_week)

	var per_blood: int = 1 + relic_inventory["Blood Abacus"]
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
		if red_thread_copies > 0 and blood_count == 3 and indices.size() == 3:
			for i in range(red_thread_copies):
				var blood_ids: Array[int] = []
				for f in pool:
					if f["trait"] == "BLOOD":
						blood_ids.append(int(f["id"]))
				if blood_ids.is_empty():
					break
				blood_ids.shuffle()
				var pick_id: int = blood_ids[0]
				for p in range(pool.size()):
					if int(pool[p]["id"]) == pick_id:
						pool[p]["tier"] = min(6, int(pool[p]["tier"]) + 1)
						break

	var summary_parts: Array[String] = []
	for info in sacrificed_info:
		var tags: String = ""
		var tid: String = str(info.get("trait_id", ""))
		if tid != "":
			var rarity_mark: String = "[C]" if _trait_rarity(tid) == "COMMON" else "[R]"
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
	var per_blood: int = 1 + relic_inventory["Blood Abacus"]
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
