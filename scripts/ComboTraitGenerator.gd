extends RefCounted

const COMBO_SEEDS: Array[Dictionary] = [
	{"id":"combo_001","name":"Red Catechism","rarity":"RARE","parents":["blood_prophet","straight_rite"],"template":"tier_straight_exalt","trigger":"Sacrificed tiers form a straight."},
	{"id":"combo_002","name":"Sanguine Thesis","rarity":"RARE","parents":["blood_prophet","sanguine_conductor"],"template":"blood_economy_forge","trigger":"2+ BLOOD are sacrificed."},
	{"id":"combo_003","name":"Martyr's Communion","rarity":"RARE","parents":["blood_prophet","martyrs_ledger"],"template":"blood_economy_forge","trigger":"2+ BLOOD are sacrificed."},
	{"id":"combo_004","name":"Severed Sequence","rarity":"RARE","parents":["straight_rite","paired_sigil"],"template":"pair_execution","trigger":"Any two sacrifices share tier."},
	{"id":"combo_005","name":"Ivory Dominion","rarity":"RARE","parents":["ossuary_king","ossuary_archon"],"template":"bone_citadel","trigger":"2+ BONE and 0 VOID are sacrificed."},
	{"id":"combo_006","name":"Execution Gallery","rarity":"RARE","parents":["ossuary_king","votive_executor"],"template":"bone_citadel","trigger":"2+ BONE and 0 VOID are sacrificed."},
	{"id":"combo_007","name":"Nursery of Dust","rarity":"RARE","parents":["gravetide","brood_keeper"],"template":"grave_engine","trigger":"This follower is sacrificed."},
	{"id":"combo_008","name":"Lineage Catacomb","rarity":"RARE","parents":["gravetide","lineage_tutor"],"template":"nest_dynasty","trigger":"This follower is a nest parent."},
	{"id":"combo_009","name":"Hushed Aperture","rarity":"RARE","parents":["void_herald","hush_matron"],"template":"void_edge","trigger":"Exactly 1 VOID is sacrificed."},
	{"id":"combo_010","name":"Candle Fracture","rarity":"RARE","parents":["void_herald","black_candlebearer"],"template":"void_edge","trigger":"Exactly 1 VOID is sacrificed."},
	{"id":"combo_011","name":"Black Matins","rarity":"RARE","parents":["black_candlebearer","hush_matron"],"template":"void_edge","trigger":"Exactly 1 VOID is sacrificed."},
	{"id":"combo_012","name":"Tithe Execution","rarity":"RARE","parents":["martyrs_ledger","votive_executor"],"template":"blood_economy_forge","trigger":"Any BONE or BLOOD is sacrificed."},
	{"id":"combo_013","name":"Veiled Tutorium","rarity":"RARE","parents":["chosen_veil","lineage_tutor"],"template":"nest_dynasty","trigger":"This follower is a nest parent."},
	{"id":"combo_014","name":"Veil of Broods","rarity":"RARE","parents":["chosen_veil","brood_keeper"],"template":"nest_dynasty","trigger":"This follower is a nest parent."},
	{"id":"combo_015","name":"Conductor's Knot","rarity":"RARE","parents":["sanguine_conductor","paired_sigil"],"template":"pair_execution","trigger":"Any two sacrifices share tier."},
	{"id":"combo_016","name":"Archon's Knot","rarity":"RARE","parents":["ossuary_archon","paired_sigil"],"template":"pair_execution","trigger":"Any two sacrifices share tier."},
	{"id":"combo_017","name":"Silent Knot","rarity":"RARE","parents":["hush_matron","paired_sigil"],"template":"pair_execution","trigger":"Any two sacrifices share tier."},
	{"id":"combo_018","name":"Executor's Knot","rarity":"RARE","parents":["votive_executor","paired_sigil"],"template":"pair_execution","trigger":"Any two sacrifices share tier."},
	{"id":"combo_019","name":"Dynasty Scroll","rarity":"RARE","parents":["brood_keeper","lineage_tutor"],"template":"nest_dynasty","trigger":"This follower is a nest parent."},
	{"id":"combo_020","name":"Ledger of Graves","rarity":"RARE","parents":["martyrs_ledger","gravetide"],"template":"grave_engine","trigger":"This follower is sacrificed."},
	{"id":"combo_021","name":"Archon's Writ","rarity":"RARE","parents":["ossuary_archon","votive_executor"],"template":"bone_citadel","trigger":"2+ BONE and 0 VOID are sacrificed."},
	{"id":"combo_022","name":"Conductor's Writ","rarity":"RARE","parents":["sanguine_conductor","martyrs_ledger"],"template":"blood_economy_forge","trigger":"2+ BLOOD are sacrificed."},
	{"id":"combo_023","name":"Rite Ledger","rarity":"RARE","parents":["straight_rite","martyrs_ledger"],"template":"tier_straight_exalt","trigger":"Sacrificed tiers form a straight."},
	{"id":"combo_024","name":"Prophet's Veil","rarity":"RARE","parents":["blood_prophet","chosen_veil"],"template":"tier_straight_exalt","trigger":"Sacrificed tiers form a straight."},
	{"id":"combo_025","name":"Kingmaker Nursery","rarity":"RARE","parents":["ossuary_king","brood_keeper"],"template":"nest_dynasty","trigger":"This follower is a nest parent."},
	{"id":"combo_026","name":"Void Pedagogy","rarity":"RARE","parents":["void_herald","lineage_tutor"],"template":"nest_dynasty","trigger":"This follower is a nest parent."},
	{"id":"combo_027","name":"Executor's Candle","rarity":"RARE","parents":["black_candlebearer","votive_executor"],"template":"bone_citadel","trigger":"2+ BONE and 0 VOID are sacrificed."},
	{"id":"combo_028","name":"Hushed Veil","rarity":"RARE","parents":["chosen_veil","hush_matron"],"template":"void_edge","trigger":"Exactly 1 VOID is sacrificed."},
	{"id":"combo_029","name":"Bonefall Charter","rarity":"RARE","parents":["gravetide","ossuary_archon"],"template":"grave_engine","trigger":"This follower is sacrificed."},
	{"id":"combo_030","name":"Crimson Aperture","rarity":"RARE","parents":["sanguine_conductor","void_herald"],"template":"void_edge","trigger":"Exactly 1 VOID is sacrificed."},
	{"id":"combo_031","name":"Ascendant Prophet","rarity":"LEGENDARY","parents":["crimson_ascendant","blood_prophet"],"template":"tier_straight_exalt","trigger":"Sacrificed tiers form a straight."},
	{"id":"combo_032","name":"Ascendant Rite","rarity":"LEGENDARY","parents":["crimson_ascendant","straight_rite"],"template":"tier_straight_exalt","trigger":"Sacrificed tiers form a straight."},
	{"id":"combo_033","name":"Ascendant Conductor","rarity":"LEGENDARY","parents":["crimson_ascendant","sanguine_conductor"],"template":"blood_economy_forge","trigger":"2+ BLOOD are sacrificed."},
	{"id":"combo_034","name":"Oracle King","rarity":"LEGENDARY","parents":["ossuary_oracle","ossuary_king"],"template":"bone_citadel","trigger":"2+ BONE and 0 VOID are sacrificed."},
	{"id":"combo_035","name":"Oracle Archon","rarity":"LEGENDARY","parents":["ossuary_oracle","ossuary_archon"],"template":"bone_citadel","trigger":"2+ BONE and 0 VOID are sacrificed."},
	{"id":"combo_036","name":"Crowned Herald","rarity":"LEGENDARY","parents":["void_crown","void_herald"],"template":"void_edge","trigger":"Exactly 1 VOID is sacrificed."},
	{"id":"combo_037","name":"Crowned Hush","rarity":"LEGENDARY","parents":["void_crown","hush_matron"],"template":"void_edge","trigger":"Exactly 1 VOID is sacrificed."},
	{"id":"combo_038","name":"Apostolic Veil","rarity":"LEGENDARY","parents":["apostolic_womb","chosen_veil"],"template":"nest_dynasty","trigger":"This follower is a nest parent."},
	{"id":"combo_039","name":"Apostolic Brood","rarity":"LEGENDARY","parents":["apostolic_womb","brood_keeper"],"template":"nest_dynasty","trigger":"This follower is a nest parent."},
	{"id":"combo_040","name":"Apostolic Tutor","rarity":"LEGENDARY","parents":["apostolic_womb","lineage_tutor"],"template":"nest_dynasty","trigger":"This follower is a nest parent."},
	{"id":"combo_041","name":"Triune Herald","rarity":"LEGENDARY","parents":["triune_heir","void_herald"],"template":"triune_cataclysm","trigger":"BLOOD+BONE+VOID are sacrificed."},
	{"id":"combo_042","name":"Triune Conductor","rarity":"LEGENDARY","parents":["triune_heir","sanguine_conductor"],"template":"triune_cataclysm","trigger":"BLOOD+BONE+VOID are sacrificed."},
	{"id":"combo_043","name":"Triune Archon","rarity":"LEGENDARY","parents":["triune_heir","ossuary_archon"],"template":"triune_cataclysm","trigger":"BLOOD+BONE+VOID are sacrificed."},
	{"id":"combo_044","name":"Triune Sigil","rarity":"LEGENDARY","parents":["triune_heir","paired_sigil"],"template":"triune_cataclysm","trigger":"BLOOD+BONE+VOID are sacrificed."},
	{"id":"combo_045","name":"Ascendant Heir","rarity":"LEGENDARY","parents":["crimson_ascendant","triune_heir"],"template":"triune_cataclysm","trigger":"BLOOD+BONE+VOID are sacrificed."},
	{"id":"combo_046","name":"Oracle Heir","rarity":"LEGENDARY","parents":["ossuary_oracle","triune_heir"],"template":"triune_cataclysm","trigger":"BLOOD+BONE+VOID are sacrificed."},
	{"id":"combo_047","name":"Crowned Heir","rarity":"LEGENDARY","parents":["void_crown","triune_heir"],"template":"triune_cataclysm","trigger":"BLOOD+BONE+VOID are sacrificed."},
	{"id":"combo_048","name":"Apostolic Heir","rarity":"LEGENDARY","parents":["apostolic_womb","triune_heir"],"template":"triune_cataclysm","trigger":"BLOOD+BONE+VOID are sacrificed."},
	{"id":"combo_049","name":"Crimson Crown","rarity":"LEGENDARY","parents":["crimson_ascendant","void_crown"],"template":"void_edge","trigger":"Exactly 1 VOID is sacrificed."},
	{"id":"combo_050","name":"Apostolic Oracle","rarity":"LEGENDARY","parents":["ossuary_oracle","apostolic_womb"],"template":"nest_dynasty","trigger":"This follower is a nest parent."},
]

static func generate_catalog(trait_registry: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for seed in COMBO_SEEDS:
		var combo: Dictionary = _build_combo(seed, trait_registry)
		out[str(seed.get("id", ""))] = combo
	return out

static func _build_combo(seed: Dictionary, trait_registry: Dictionary) -> Dictionary:
	var parent_ids: Array = seed.get("parents", [])
	var p0: String = str(parent_ids[0]) if parent_ids.size() > 0 else ""
	var p1: String = str(parent_ids[1]) if parent_ids.size() > 1 else ""
	var parent_names: Array[String] = []
	for pid in [p0, p1]:
		if trait_registry.has(pid):
			parent_names.append(str(trait_registry[pid].get("name", pid)))
		else:
			parent_names.append(pid)
	var effect: String = _template_effect(str(seed.get("template", "")), str(seed.get("rarity", "RARE")))
	return {
		"id": str(seed.get("id", "")),
		"name": str(seed.get("name", "")),
		"rarity": str(seed.get("rarity", "RARE")),
		"parents": [p0, p1],
		"parent_names": parent_names,
		"trigger": str(seed.get("trigger", "")),
		"template": str(seed.get("template", "")),
		"effect": effect,
		"desc": "%s Effect: %s" % [str(seed.get("trigger", "")), effect],
	}

static func _template_effect(template_id: String, rarity: String) -> String:
	var is_legendary: bool = rarity == "LEGENDARY"
	match template_id:
		"tier_straight_exalt":
			return "Multiplier base +%d and +%d Blood." % [2 if is_legendary else 1, 3 if is_legendary else 2]
		"blood_economy_forge":
			return "+%d additive and +%d Blood." % [18 if is_legendary else 12, 3 if is_legendary else 2]
		"bone_citadel":
			return "+%d additive." % [30 if is_legendary else 20]
		"void_edge":
			return "Multiplier base +%d and +%d additive." % [2 if is_legendary else 1, 14 if is_legendary else 10]
		"pair_execution":
			return "Double this follower's base contribution and +%d additive." % [10 if is_legendary else 6]
		"nest_dynasty":
			return "As nest parent, newborn +%d tier and strong rarity-up pressure." % [2 if is_legendary else 1]
		"triune_cataclysm":
			return "Final devotion x%.2f." % [1.35 if is_legendary else 1.25]
		"grave_engine":
			return "When sacrificed: +%d additive, +%d Blood, and spawn a T1 BONE." % [12 if is_legendary else 8, 3 if is_legendary else 2]
		_:
			return "+8 additive."
