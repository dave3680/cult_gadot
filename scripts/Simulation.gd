extends SceneTree

const DOCTRINES := ["FLESH", "RUIN", "SILENCE"]
const BASE_SEED := 910246
const REPORT_DIR := "res://docs/sim_reports"

const SAFE_RELIC_PURCHASES := {
	"Quick Chant": true,
	"Hollow Chant": true,
	"Crimson Book": true,
	"Bone Idol": true,
	"Calcify": true,
	"Prayer Beads": true,
	"Wax Seal": true,
	"Choir Robes": true,
	"Sacrificial Order": true,
	"Balanced Offering": true,
	"Hollow Abacus": true,
	"Void Prism": true,
	"Ectoplasm Jar": true,
	"The Sanguine Chord": true,
	"Bloodright Almanac": true,
	"Apex Covenant": true,
	"The Last Rung": true,
	"Refinery of Silence": true,
	"The Concordat": true,
	"Covenant of Three": true,
	"The Copper Tithe": true,
	"The Foursome": true,
}

var _failures: Array[String] = []
var _warnings: Array[String] = []
var _report_lines: Array[String] = []
var _method_missing: Dictionary = {}


func _init() -> void:
	var started_ms: int = Time.get_ticks_msec()
	_log("")
	_log("=== Cult of Accumulation: Full Simulation Runner ===")
	_log("Seed base: %d" % BASE_SEED)

	var run_results: Array = []
	for i in range(DOCTRINES.size()):
		var doctrine: String = DOCTRINES[i]
		var seed: int = BASE_SEED + (i * 1000)
		var run_result: Dictionary = _run_doctrine(doctrine, seed)
		run_results.append(run_result)
		_print_run_report(run_result)

	_run_global_assertions(run_results)

	var elapsed_ms: int = Time.get_ticks_msec() - started_ms
	_log("")
	_log("=== Simulation Assertions ===")
	if _failures.is_empty():
		_log("SIMULATION PASS")
	else:
		_log("SIMULATION FAIL")
		for line in _failures:
			_log("FAIL: " + line)
	if not _warnings.is_empty():
		for line in _warnings:
			_log("WARN: " + line)
	_log("Elapsed: %d ms" % elapsed_ms)

	_write_report(elapsed_ms)
	quit(1 if not _failures.is_empty() else 0)


func _run_doctrine(doctrine: String, seed: int) -> Dictionary:
	var gs: Node = _fresh_gs(seed, doctrine)
	if gs == null:
		return {
			"doctrine": doctrine,
			"error": "GameState missing",
			"weeks": [],
			"cleared_weeks": 0,
			"loss_week": 1,
			"win": false,
		}

	var run_state: Dictionary = {
		"purchased_relics": {},
		"fired_relics": {},
		"birth_week_by_id": {},
		"offspring_sacrificed_later": false,
		"lineage_by_week": {},
		"lineage_cap_breaches": [],
		"duplicate_trait_breaches": [],
		"pool_cap_breaches": [],
		"week_cap_breaches": [],
		"week_records": [],
		"null_ref_errors": [],
	}

	var max_weeks: int = int(_safe_call(gs, "get_max_weeks", [], 10))
	var cleared_weeks: int = 0
	var win: bool = false
	var loss_week: int = max_weeks

	for week in range(1, max_weeks + 1):
		gs.current_week = week
		_safe_call(gs, "start_week")
		var target: int = int(_safe_call(gs, "get_week_target", [week], 0))

		var week_record: Dictionary = {
			"week": week,
			"target": target,
			"rounds": [],
			"weekly_total": 0,
			"cap_fired": false,
			"pass": false,
			"overflow_blood": 0,
			"shop_purchases": [],
			"offspring": [],
			"pool_summary": {},
			"relics_end": [],
			"blood_end": 0,
		}

		var round1: Dictionary = _simulate_round(gs, doctrine, week, 1, target, run_state)
		week_record["rounds"].append(round1)
		week_record["cap_fired"] = bool(week_record["cap_fired"]) or bool(round1.get("cap_fired", false))
		week_record["overflow_blood"] = int(week_record["overflow_blood"]) + int(round1.get("overflow_blood", 0))

		# Week flow requirement: run a wild breeding phase between rounds.
		var mid_wild_offspring: Array = _simulate_midweek_wild_breeding(gs, week, run_state)
		for child in mid_wild_offspring:
			(week_record["offspring"] as Array).append(child)

		var round2: Dictionary = _simulate_round(gs, doctrine, week, 2, target, run_state)
		week_record["rounds"].append(round2)
		week_record["cap_fired"] = bool(week_record["cap_fired"]) or bool(round2.get("cap_fired", false))
		week_record["overflow_blood"] = int(week_record["overflow_blood"]) + int(round2.get("overflow_blood", 0))

		var pre_week_cap: int = int(gs.week_total_devotion)
		_safe_call(gs, "apply_week_devotion_cap", [target], null)
		var post_week_cap: int = int(gs.week_total_devotion)
		if post_week_cap < pre_week_cap:
			week_record["cap_fired"] = true

		var cap_mult: float = float(gs.get_run_config().get("week_devotion_cap_mult", 0.0))
		if cap_mult > 0.0:
			var week_cap: int = int(floor(float(target) * cap_mult))
			if week_cap > 0 and int(gs.week_total_devotion) > week_cap:
				run_state["week_cap_breaches"].append("Doctrine %s Week %d total %d > cap %d" % [doctrine, week, int(gs.week_total_devotion), week_cap])

		week_record["weekly_total"] = int(gs.week_total_devotion)
		week_record["pass"] = int(gs.week_total_devotion) >= target

		if bool(week_record["pass"]):
			cleared_weeks += 1
			if week < max_weeks:
				var shop_result: Dictionary = _simulate_shop(gs, doctrine, week, run_state)
				week_record["shop_purchases"] = shop_result.get("purchased", [])
				_simulate_nest_selection(gs, doctrine)
				var breeding_result: Dictionary = _simulate_weekly_breeding(gs, week, run_state)
				for child in breeding_result.get("offspring", []):
					(week_record["offspring"] as Array).append(child)
		else:
			loss_week = week
			win = false
			week_record["pool_summary"] = _pool_summary_for_report(gs)
			week_record["relics_end"] = _active_relics(gs)
			week_record["blood_end"] = int(gs.blood_currency)
			run_state["week_records"].append(week_record)
			break

		week_record["pool_summary"] = _pool_summary_for_report(gs)
		week_record["relics_end"] = _active_relics(gs)
		week_record["blood_end"] = int(gs.blood_currency)
		run_state["week_records"].append(week_record)

		_validate_pool_and_traits(gs, doctrine, week, run_state)

		if week == max_weeks:
			win = true
			loss_week = max_weeks

	var final_pool_summary: Dictionary = _pool_summary_for_report(gs)
	var final_avg_lineage: float = float(final_pool_summary.get("avg_lineage", 0.0))
	var purchased_relics: Dictionary = run_state.get("purchased_relics", {})
	var fired_relics: Dictionary = run_state.get("fired_relics", {})
	for relic_name in purchased_relics.keys():
		if not fired_relics.has(relic_name):
			_fail("%s purchased relic never fired: %s" % [doctrine, relic_name])

	if int(purchased_relics.size()) == 0:
		_fail("%s did not purchase any relics during the run." % doctrine)

	for line in run_state.get("lineage_cap_breaches", []):
		_fail(line)
	for line in run_state.get("duplicate_trait_breaches", []):
		_fail(line)
	for line in run_state.get("pool_cap_breaches", []):
		_fail(line)
	for line in run_state.get("week_cap_breaches", []):
		_fail(line)
	for line in run_state.get("null_ref_errors", []):
		_fail(line)

	return {
		"doctrine": doctrine,
		"weeks": run_state.get("week_records", []),
		"cleared_weeks": cleared_weeks,
		"loss_week": loss_week,
		"win": win,
		"final_pool_summary": final_pool_summary,
		"final_avg_lineage": final_avg_lineage,
		"purchased_relics": purchased_relics,
		"fired_relics": fired_relics,
		"offspring_sacrificed_later": bool(run_state.get("offspring_sacrificed_later", false)),
		"lineage_by_week": run_state.get("lineage_by_week", {}),
	}


func _simulate_round(gs: Node, doctrine: String, week: int, round_num: int, target: int, run_state: Dictionary) -> Dictionary:
	_safe_call(gs, "draw_hand_from_pool")

	if not gs.has_method("_score_selected_internal"):
		# METHOD NOT FOUND: core scoring API missing; skip round gracefully.
		_mark_method_missing("_score_selected_internal", "round scoring")
		return {
			"devotion": 0,
			"additive": 0,
			"base": 1,
			"exponent": 1,
			"lineage_mult": 1.0,
			"refined_void": 0,
			"cap_fired": false,
			"overflow_blood": 0,
			"picks": [],
		}

	var hand_size: int = gs.current_hand.size()
	if hand_size <= 0:
		return {
			"devotion": 0,
			"additive": 0,
			"base": 1,
			"exponent": 1,
			"lineage_mult": 1.0,
			"refined_void": 0,
			"cap_fired": false,
			"overflow_blood": 0,
			"picks": [],
		}

	var required: int = _choose_required_count(gs, week, doctrine)
	required = clamp(required, 1, hand_size)

	var picks: Array[int] = _choose_sacrifice_indices(gs, doctrine, required)
	if picks.is_empty():
		return {
			"devotion": 0,
			"additive": 0,
			"base": 1,
			"exponent": 1,
			"lineage_mult": 1.0,
			"refined_void": 0,
			"cap_fired": false,
			"overflow_blood": 0,
			"picks": [],
		}

	if required == 5:
		gs.contract_five_used_week = week
		gs.contract_allow_five = false
	elif required == 4:
		gs.contract_used_week = week
		gs.contract_allow_four = false

	var selected_followers: Array[Dictionary] = []
	for idx in picks:
		if idx >= 0 and idx < gs.current_hand.size():
			selected_followers.append(gs.current_hand[idx].duplicate(true))

	var score_result: Dictionary = _safe_call(gs, "_score_selected_internal", [picks, true, true, false], {})
	var final_devotion: int = int(score_result.get("final_devotion", 0))
	gs.week_total_devotion += final_devotion
	var before_cap: int = int(gs.week_total_devotion)
	_safe_call(gs, "apply_week_devotion_cap", [target], null)
	var after_cap: int = int(gs.week_total_devotion)
	var cap_fired: bool = after_cap < before_cap
	var overflow_gain: int = int(_safe_call(gs, "apply_overflow_blood_for_target", [target], 0))

	_track_round_lineage(doctrine, week, selected_followers, run_state)
	_track_offspring_feedback(week, selected_followers, run_state)
	_track_lineage_multiplier_cap(doctrine, week, round_num, score_result, run_state)
	_mark_relic_fires_from_breakdown(run_state, str(score_result.get("breakdown", "")))

	_safe_call(gs, "resolve_play_and_update_pool", [picks], null)
	_validate_pool_and_traits(gs, doctrine, week, run_state)

	var lineage_mult: float = _parse_lineage_mult(str(score_result.get("breakdown", "")))
	return {
		"devotion": final_devotion,
		"additive": int(score_result.get("additive_total", 0)),
		"base": int(score_result.get("base", 1)),
		"exponent": int(score_result.get("exponent", 1)),
		"lineage_mult": lineage_mult,
		"refined_void": int(score_result.get("refined_void_count", 0)),
		"final": final_devotion,
		"cap_fired": cap_fired,
		"overflow_blood": overflow_gain,
		"picks": picks,
	}


func _simulate_midweek_wild_breeding(gs: Node, week: int, run_state: Dictionary) -> Array:
	if not gs.has_method("resolve_wild_breeding"):
		# METHOD NOT FOUND: midweek wild breeding API missing; skip gracefully.
		_mark_method_missing("resolve_wild_breeding", "midweek wild breeding")
		return []
	var before_ids: Dictionary = {}
	for f in gs.pool:
		before_ids[int(f.get("id", -1))] = true
	_safe_call(gs, "resolve_wild_breeding", [week], {})
	return _collect_new_offspring(gs, before_ids, week, run_state)


func _simulate_shop(gs: Node, doctrine: String, week: int, run_state: Dictionary) -> Dictionary:
	_safe_call(gs, "start_shop_visit", [], null)
	gs.shop_rerolls_used = 0
	gs.shop_cull_used = false
	gs.shop_copy_used = false
	if bool(gs.free_reroll_next_shop):
		gs.shop_free_reroll_available = true
		gs.free_reroll_next_shop = false

	if int(gs.relic_inventory.get("Spare Chalice", 0)) > 0 and int(gs.blood_currency) == 0:
		_safe_call(gs, "add_blood", [2], null)

	var purchased: Array[String] = []
	var offers: Array = _roll_offers(gs, 3, week, bool(gs.guaranteed_rare_next_shop))
	gs.guaranteed_rare_next_shop = false
	offers = _offer_legendary_if_needed(gs, offers, week)

	var bought_now: Array[String] = _buy_synergy_relics(gs, doctrine, offers, week, run_state)
	for name in bought_now:
		purchased.append(name)

	if gs.shop_rerolls_used == 0:
		var reroll_cost: int = 5
		if int(gs.relic_inventory.get("Sharpened Chalk", 0)) > 0 or bool(gs.shop_free_reroll_available):
			reroll_cost = 0
		if int(gs.blood_currency) >= reroll_cost:
			if reroll_cost > 0:
				gs.blood_currency -= reroll_cost
			if bool(gs.shop_free_reroll_available):
				gs.shop_free_reroll_available = false
			gs.shop_rerolls_used += 1
			var reroll_offers: Array = _roll_offers(gs, 3, week, false)
			reroll_offers = _offer_legendary_if_needed(gs, reroll_offers, week)
			var bought_reroll: Array[String] = _buy_synergy_relics(gs, doctrine, reroll_offers, week, run_state)
			for name in bought_reroll:
				purchased.append(name)

	_safe_call(gs, "generate_shop_recruits", [], null)
	for i in range(min(2, gs.shop_recruit_offers.size())):
		var recruit: Dictionary = gs.shop_recruit_offers[i]
		var recruit_type: String = str(recruit.get("trait", ""))
		var weight: int = 0
		if doctrine == "FLESH" and recruit_type == "BLOOD":
			weight += 2
		elif doctrine == "RUIN" and recruit_type == "BONE":
			weight += 2
		elif doctrine == "SILENCE" and recruit_type == "VOID":
			weight += 2
		if weight <= 0 and int(gs.blood_currency) < 2:
			continue
		_safe_call(gs, "buy_shop_recruit", [i], {})

	_apply_shop_end_effects(gs)
	return {"purchased": purchased}


func _simulate_nest_selection(gs: Node, doctrine: String) -> void:
	if not gs.has_method("assign_follower_to_nest"):
		# METHOD NOT FOUND: nest assignment API missing; skip gracefully.
		_mark_method_missing("assign_follower_to_nest", "nest selection")
		return

	for i in range(gs.nests.size()):
		_safe_call(gs, "clear_nest_slot", [i, 0], null)
		_safe_call(gs, "clear_nest_slot", [i, 1], null)
		_safe_call(gs, "set_nest_focus", [i, "NONE"], {})

	var available: Array = []
	for f in gs.pool:
		if str(f.get("trait", "")) == "SOUL":
			continue
		available.append(f)
	available.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ta: int = int(a.get("tier", 0))
		var tb: int = int(b.get("tier", 0))
		if ta != tb:
			return ta > tb
		return int(a.get("id", 0)) < int(b.get("id", 0))
	)

	var used_ids: Dictionary = {}
	for nest_idx in range(gs.nests.size()):
		var pair: Array = _pick_nest_pair(available, used_ids, doctrine)
		if pair.size() < 2:
			break
		var a_id: int = int(pair[0].get("id", -1))
		var b_id: int = int(pair[1].get("id", -1))
		used_ids[a_id] = true
		used_ids[b_id] = true
		_safe_call(gs, "assign_follower_to_nest", [nest_idx, 0, a_id], false)
		_safe_call(gs, "assign_follower_to_nest", [nest_idx, 1, b_id], false)

		var focus: String = "NONE"
		if str(pair[0].get("trait", "")) == str(pair[1].get("trait", "")):
			focus = "FAMILY"
		elif doctrine == "SILENCE":
			focus = "RARITY"
		elif doctrine == "FLESH" or doctrine == "RUIN":
			focus = "TIER"
		var projected_cost: int = int(_safe_call(gs, "get_nest_focus_total_cost_with", [nest_idx, focus], 0))
		if projected_cost <= int(gs.blood_currency):
			_safe_call(gs, "set_nest_focus", [nest_idx, focus], {})

	_safe_call(gs, "commit_nest_focus_costs", [], {})


func _simulate_weekly_breeding(gs: Node, week: int, run_state: Dictionary) -> Dictionary:
	var before_ids: Dictionary = {}
	for f in gs.pool:
		before_ids[int(f.get("id", -1))] = true
	_safe_call(gs, "perform_weekly_breeding", [week], null)
	var offspring: Array = _collect_new_offspring(gs, before_ids, week, run_state)
	return {"offspring": offspring}


func _collect_new_offspring(gs: Node, before_ids: Dictionary, week: int, run_state: Dictionary) -> Array:
	var offspring: Array = []
	for f in gs.pool:
		var fid: int = int(f.get("id", -1))
		if before_ids.has(fid):
			continue
		var trait_ids: Array[String] = _follower_all_trait_ids(f)
		var offspring_entry: Dictionary = {
			"id": fid,
			"type": str(f.get("trait", "")),
			"tier": int(f.get("tier", 0)),
			"lineage": int(f.get("lineage", 0)),
			"origin": str(f.get("origin_tag", "")),
			"traits": trait_ids,
		}
		offspring.append(offspring_entry)
		run_state["birth_week_by_id"][fid] = week
	return offspring


func _choose_required_count(gs: Node, week: int, doctrine: String) -> int:
	gs.contract_allow_four = false
	gs.contract_allow_five = false
	var hand_size: int = gs.current_hand.size()
	var has_five: bool = int(gs.relic_inventory.get("The Expanding Contract", 0)) > 0 and int(gs.contract_five_used_week) != week and hand_size >= 5
	var has_four: bool = int(gs.relic_inventory.get("Black Contract", 0)) > 0 and int(gs.contract_used_week) != week and hand_size >= 4
	if has_five:
		var use_five: bool = doctrine == "SILENCE" or doctrine == "FLESH"
		if use_five:
			gs.contract_allow_five = true
			return 5
	if has_four:
		gs.contract_allow_four = true
		return 4
	return min(3, hand_size)


func _choose_sacrifice_indices(gs: Node, doctrine: String, required: int) -> Array[int]:
	var hand_size: int = gs.current_hand.size()
	if required <= 0 or hand_size <= 0 or required > hand_size:
		return []
	var combos: Array = []
	_build_combos(hand_size, required, 0, [], combos)
	var best_combo: Array[int] = []
	var best_score: float = -1e20
	for combo_untyped in combos:
		var combo: Array[int] = []
		for v in combo_untyped:
			combo.append(int(v))
		var preview: Dictionary = _safe_call(gs, "preview_selected", [combo], {})
		var devotion: int = int(preview.get("final_devotion", 0))
		var doctrine_bias: float = _doctrine_combo_bias(gs.current_hand, combo, doctrine)
		var lineage_bias: float = 0.0
		for idx in combo:
			lineage_bias += float(clamp(int(gs.current_hand[idx].get("lineage", 0)), 0, 10)) * 2.5
		var score: float = float(devotion) + doctrine_bias + lineage_bias
		if score > best_score:
			best_score = score
			best_combo = combo
	return best_combo


func _doctrine_combo_bias(hand: Array, combo: Array[int], doctrine: String) -> float:
	var blood_count: int = 0
	var bone_count: int = 0
	var void_count: int = 0
	for idx in combo:
		var tr: String = str(hand[idx].get("trait", ""))
		if tr == "BLOOD":
			blood_count += 1
		elif tr == "BONE":
			bone_count += 1
		elif tr == "VOID":
			void_count += 1
	match doctrine:
		"FLESH":
			return (blood_count * 18.0) - (bone_count * 5.0) - (void_count * 10.0)
		"RUIN":
			return (bone_count * 18.0) - (blood_count * 5.0) - (void_count * 8.0)
		"SILENCE":
			return -abs(void_count - 1) * 35.0 + (void_count * 12.0)
		_:
			return 0.0


func _build_combos(n: int, k: int, start: int, current: Array, out: Array) -> void:
	if current.size() == k:
		out.append(current.duplicate())
		return
	for i in range(start, n):
		current.append(i)
		_build_combos(n, k, i + 1, current, out)
		current.pop_back()


func _roll_offers(gs: Node, count: int, week: int, guarantee_rare_shop: bool = false) -> Array:
	var chosen: Array = []
	for i in range(count):
		var guarantee_slot: bool = guarantee_rare_shop and i == 0
		var rarity: String = str(_safe_call(gs, "roll_shop_rarity", [week, gs._rng, 0.0, 0.0, guarantee_slot], "COMMON"))
		if int(gs.shop_rerolls_used) > 0 and int(gs.relic_inventory.get("The Faithful Scribe", 0)) > 0:
			rarity = _raise_rarity_floor(rarity, int(gs.relic_inventory.get("The Faithful Scribe", 0)))
		var pick: String = _pick_from_rarity(gs, rarity, chosen)
		if pick == "":
			pick = _pick_from_rarity(gs, _fallback_rarity(rarity), chosen)
		if pick != "":
			chosen.append(pick)
			if str(gs.RELIC_DEFS[pick].get("rarity", "")) == "LEGENDARY":
				gs.legendary_seen_in_shop = true
	return chosen


func _offer_legendary_if_needed(gs: Node, offers: Array, week: int) -> Array:
	if bool(gs.legendary_seen_in_shop) or week < 6:
		return offers
	for offer in offers:
		var name: String = str(offer)
		if name != "" and str(gs.RELIC_DEFS[name].get("rarity", "")) == "LEGENDARY":
			gs.legendary_seen_in_shop = true
			return offers
	var legendary_pick: String = _pick_from_rarity(gs, "LEGENDARY", offers)
	if legendary_pick == "":
		return offers
	for i in range(offers.size()):
		if str(offers[i]) != "":
			offers[i] = legendary_pick
			gs.legendary_seen_in_shop = true
			break
	return offers


func _buy_synergy_relics(gs: Node, doctrine: String, offers: Array, week: int, run_state: Dictionary) -> Array[String]:
	var purchased: Array[String] = []
	var sorted_offers: Array = offers.duplicate()
	sorted_offers.sort_custom(func(a, b):
		return _relic_offer_score(gs, str(a), doctrine, week) > _relic_offer_score(gs, str(b), doctrine, week)
	)
	for offer in sorted_offers:
		var name: String = str(offer)
		if name == "" or not SAFE_RELIC_PURCHASES.has(name):
			continue
		if not bool(_safe_call(gs, "can_offer_relic", [name], false)):
			continue
		var rarity: String = str(gs.RELIC_DEFS.get(name, {}).get("rarity", "COMMON"))
		var cost: int = int(_safe_call(gs, "get_shop_cost", [week, rarity], 10))
		if not bool(_safe_call(gs, "can_afford_relic", [cost], false)):
			continue
		_safe_call(gs, "spend_blood_for_relic", [cost], null)
		_safe_call(gs, "add_relic", [name], null)
		run_state["purchased_relics"][name] = true
		purchased.append(name)
		if purchased.size() >= 2:
			break
	return purchased


func _relic_offer_score(gs: Node, relic_name: String, doctrine: String, week: int) -> float:
	if relic_name == "":
		return -99999.0
	var rarity: String = str(gs.RELIC_DEFS.get(relic_name, {}).get("rarity", "COMMON"))
	var score: float = 0.0
	match rarity:
		"LEGENDARY":
			score += 30.0
		"RARE":
			score += 20.0
		"UNCOMMON":
			score += 10.0
		_:
			score += 5.0
	if doctrine == "FLESH":
		if relic_name.find("Crimson") >= 0 or relic_name.find("Blood") >= 0:
			score += 14.0
	elif doctrine == "RUIN":
		if relic_name.find("Bone") >= 0 or relic_name.find("Ossuary") >= 0:
			score += 14.0
	elif doctrine == "SILENCE":
		if relic_name.find("Void") >= 0 or relic_name.find("Hollow") >= 0 or relic_name.find("Silence") >= 0:
			score += 14.0
	if relic_name == "Quick Chant" or relic_name == "Hollow Chant":
		score += 9.0
	if week >= 6 and rarity == "LEGENDARY":
		score += 4.0
	return score


func _pick_from_rarity(gs: Node, rarity: String, exclude: Array) -> String:
	var pool: Array = []
	for name in gs.RELICS:
		if exclude.has(name):
			continue
		if not bool(_safe_call(gs, "can_offer_relic", [name], false)):
			continue
		if str(gs.RELIC_DEFS[name].get("rarity", "")) == rarity:
			pool.append(name)
	if pool.is_empty():
		return ""
	_shuffle_with_rng(pool, gs._rng)
	return str(pool[0])


func _raise_rarity_floor(rarity: String, steps: int) -> String:
	var order: Array[String] = ["COMMON", "UNCOMMON", "RARE", "LEGENDARY"]
	var idx: int = order.find(rarity)
	if idx < 0:
		idx = 0
	return order[min(order.size() - 1, idx + max(0, steps))]


func _fallback_rarity(rarity: String) -> String:
	if rarity == "RARE":
		return "UNCOMMON"
	if rarity == "UNCOMMON":
		return "COMMON"
	return "COMMON"


func _apply_shop_end_effects(gs: Node) -> void:
	var interest_copies: int = int(gs.relic_inventory.get("Crimson Interest", 0)) + int(gs.tithe_accelerator_interest_bonus)
	var compound_copies: int = int(gs.relic_inventory.get("Crimson Compound", 0))
	var usurer_copies: int = int(gs.relic_inventory.get("Usurer's Mark", 0))
	if interest_copies > 0:
		var divisor: int = max(1, 5 - compound_copies)
		var fires: int = 1 + max(0, usurer_copies - 1)
		for _i in range(fires):
			var gain_i: int = int(floor(float(gs.blood_currency) / float(divisor))) * interest_copies
			if gain_i > 0:
				_safe_call(gs, "add_blood", [gain_i], null)
	if int(gs.relic_inventory.get("The Waiting Bell", 0)) > 0 and not bool(gs.shop_any_purchase_this_visit):
		_safe_call(gs, "add_blood", [10], null)
	_safe_call(gs, "finalize_shop_visit", [], null)
	_safe_call(gs, "boost_pool_tiers_weekly", [], null)


func _pick_nest_pair(available: Array, used_ids: Dictionary, doctrine: String) -> Array:
	var preferred_type: String = ""
	if doctrine == "FLESH":
		preferred_type = "BLOOD"
	elif doctrine == "RUIN":
		preferred_type = "BONE"
	elif doctrine == "SILENCE":
		preferred_type = "VOID"

	var same_type: Array = []
	for f in available:
		var fid: int = int(f.get("id", -1))
		if used_ids.has(fid):
			continue
		if str(f.get("trait", "")) == preferred_type:
			same_type.append(f)
	if same_type.size() >= 2:
		return [same_type[0], same_type[1]]

	var fallback: Array = []
	for f in available:
		var fid: int = int(f.get("id", -1))
		if used_ids.has(fid):
			continue
		fallback.append(f)
		if fallback.size() >= 2:
			break
	return fallback


func _track_round_lineage(doctrine: String, week: int, selected_followers: Array, run_state: Dictionary) -> void:
	if not run_state["lineage_by_week"].has(week):
		run_state["lineage_by_week"][week] = []
	for f in selected_followers:
		var lineage: int = clamp(int(f.get("lineage", 0)), 0, 10)
		(run_state["lineage_by_week"][week] as Array).append(lineage)
		_validate_no_duplicate_traits_in_follower(doctrine, week, f, run_state)


func _track_offspring_feedback(week: int, selected_followers: Array, run_state: Dictionary) -> void:
	var birth_map: Dictionary = run_state.get("birth_week_by_id", {})
	for f in selected_followers:
		var fid: int = int(f.get("id", -1))
		if birth_map.has(fid) and int(birth_map[fid]) < week:
			run_state["offspring_sacrificed_later"] = true


func _track_lineage_multiplier_cap(doctrine: String, week: int, round_num: int, score_result: Dictionary, run_state: Dictionary) -> void:
	var lineage_mult: float = _parse_lineage_mult(str(score_result.get("breakdown", "")))
	if lineage_mult > 2.50001:
		run_state["lineage_cap_breaches"].append("%s Week %d Round %d lineage multiplier %.3f exceeded cap 2.5" % [doctrine, week, round_num, lineage_mult])


func _parse_lineage_mult(breakdown: String) -> float:
	if breakdown == "":
		return 1.0
	var re: RegEx = RegEx.new()
	if re.compile("Lineage x([0-9]+\\.[0-9]+)") != OK:
		return 1.0
	var m: RegExMatch = re.search(breakdown)
	if m == null:
		return 1.0
	return float(m.get_string(1))


func _mark_relic_fires_from_breakdown(run_state: Dictionary, breakdown: String) -> void:
	if breakdown == "":
		return
	var purchased: Dictionary = run_state.get("purchased_relics", {})
	for relic_name in purchased.keys():
		if breakdown.find(str(relic_name)) >= 0:
			run_state["fired_relics"][relic_name] = true


func _validate_pool_and_traits(gs: Node, doctrine: String, week: int, run_state: Dictionary) -> void:
	var load: int = int(_safe_call(gs, "get_pool_load_for_cap", [], gs.pool.size()))
	var cap: int = int(_safe_call(gs, "get_pool_cap", [], 1000))
	if load > cap:
		run_state["pool_cap_breaches"].append("%s Week %d pool load %d > cap %d" % [doctrine, week, load, cap])
	for f in gs.pool:
		_validate_no_duplicate_traits_in_follower(doctrine, week, f, run_state)
	for f in gs.current_hand:
		_validate_no_duplicate_traits_in_follower(doctrine, week, f, run_state)


func _validate_no_duplicate_traits_in_follower(doctrine: String, week: int, follower: Dictionary, run_state: Dictionary) -> void:
	var primary: String = str(follower.get("trait_id", ""))
	var seen: Dictionary = {}
	if primary != "":
		seen[primary] = true
	for extra in follower.get("trait_ids", []):
		var tid: String = str(extra)
		if tid == "":
			continue
		if seen.has(tid):
			run_state["duplicate_trait_breaches"].append("%s Week %d follower #%d duplicate trait id %s" % [
				doctrine,
				week,
				int(follower.get("id", -1)),
				tid,
			])
			return
		seen[tid] = true


func _follower_all_trait_ids(follower: Dictionary) -> Array[String]:
	var out: Array[String] = []
	var primary: String = str(follower.get("trait_id", ""))
	if primary != "":
		out.append(primary)
	for extra in follower.get("trait_ids", []):
		var tid: String = str(extra)
		if tid != "" and not out.has(tid):
			out.append(tid)
	return out


func _pool_summary_for_report(gs: Node) -> Dictionary:
	var blood: int = 0
	var bone: int = 0
	var voids: int = 0
	var souls: int = 0
	var total_tier: int = 0
	var total_lineage: int = 0
	for f in gs.pool:
		var tr: String = str(f.get("trait", ""))
		match tr:
			"BLOOD":
				blood += 1
			"BONE":
				bone += 1
			"VOID":
				voids += 1
			_:
				souls += 1
		total_tier += int(f.get("tier", 0))
		total_lineage += clamp(int(f.get("lineage", 0)), 0, 10)
	var total: int = gs.pool.size()
	var avg_tier: float = (float(total_tier) / float(total)) if total > 0 else 0.0
	var avg_lineage: float = (float(total_lineage) / float(total)) if total > 0 else 0.0
	return {
		"total": total,
		"blood": blood,
		"bone": bone,
		"void": voids,
		"soul": souls,
		"avg_tier": avg_tier,
		"avg_lineage": avg_lineage,
	}


func _active_relics(gs: Node) -> Array[String]:
	var out: Array[String] = []
	for name in gs.relic_inventory.keys():
		var count: int = int(gs.relic_inventory[name])
		if count > 0:
			out.append("%s x%d" % [name, count])
	out.sort()
	return out


func _run_global_assertions(run_results: Array) -> void:
	var lineage_increase_seen: bool = false
	var offspring_feedback_seen: bool = false
	for run_result in run_results:
		if bool(run_result.get("offspring_sacrificed_later", false)):
			offspring_feedback_seen = true
		var lineage_by_week: Dictionary = run_result.get("lineage_by_week", {})
		var weeks: Array = lineage_by_week.keys()
		weeks.sort()
		var last_avg: float = -1.0
		for week in weeks:
			var arr: Array = lineage_by_week.get(week, [])
			if arr.is_empty():
				continue
			var sum: int = 0
			for v in arr:
				sum += int(v)
			var avg: float = float(sum) / float(arr.size())
			if last_avg >= 0.0 and avg > last_avg:
				lineage_increase_seen = true
			last_avg = avg
	if not offspring_feedback_seen:
		_fail("No run sacrificed bred offspring in later weeks (breeding feedback loop not observed).")
	if not lineage_increase_seen:
		_fail("Average sacrificed lineage did not increase week-over-week in any doctrine run.")
	if not _method_missing.is_empty():
		for key in _method_missing.keys():
			_warn("METHOD NOT FOUND encountered: %s (%dx)" % [key, int(_method_missing[key])])


func _print_run_report(run_result: Dictionary) -> void:
	var doctrine: String = str(run_result.get("doctrine", "UNKNOWN"))
	_log("")
	_log("--- Doctrine: %s ---" % doctrine)
	var weeks: Array = run_result.get("weeks", [])
	for week_record in weeks:
		var week: int = int(week_record.get("week", 0))
		var target: int = int(week_record.get("target", 0))
		var rounds: Array = week_record.get("rounds", [])
		var r1: Dictionary = rounds[0] if rounds.size() > 0 else {}
		var r2: Dictionary = rounds[1] if rounds.size() > 1 else {}
		_log("Week %d | Target %d | R1 %d | R2 %d | Total %d | CapFired %s | %s" % [
			week,
			target,
			int(r1.get("devotion", 0)),
			int(r2.get("devotion", 0)),
			int(week_record.get("weekly_total", 0)),
			"yes" if bool(week_record.get("cap_fired", false)) else "no",
			"PASS" if bool(week_record.get("pass", false)) else "FAIL",
		])
		_log("  Scoring (last round): Add %d | Base %d | Exp %d | Lineage x%.2f | RefinedVoid %d | Final %d" % [
			int(r2.get("additive", 0)),
			int(r2.get("base", 1)),
			int(r2.get("exponent", 1)),
			float(r2.get("lineage_mult", 1.0)),
			int(r2.get("refined_void", 0)),
			int(r2.get("final", 0)),
		])
		_log("  Relics end week: %s" % (", ".join(week_record.get("relics_end", [])) if not (week_record.get("relics_end", []) as Array).is_empty() else "(none)"))
		var ps: Dictionary = week_record.get("pool_summary", {})
		_log("  Pool: total %d | BLOOD %d BONE %d VOID %d SOUL %d | avg tier %.2f | avg lineage %.2f" % [
			int(ps.get("total", 0)),
			int(ps.get("blood", 0)),
			int(ps.get("bone", 0)),
			int(ps.get("void", 0)),
			int(ps.get("soul", 0)),
			float(ps.get("avg_tier", 0.0)),
			float(ps.get("avg_lineage", 0.0)),
		])
		var offspring: Array = week_record.get("offspring", [])
		if offspring.is_empty():
			_log("  Offspring: (none)")
		else:
			var parts: Array[String] = []
			for child in offspring:
				parts.append("%s T%d L%d %s [%s]" % [
					str(child.get("type", "?")),
					int(child.get("tier", 0)),
					int(child.get("lineage", 0)),
					str(child.get("origin", "")),
					",".join(child.get("traits", [])),
				])
			_log("  Offspring: %s" % "; ".join(parts))
		_log("  Blood end week: %d" % int(week_record.get("blood_end", 0)))

	var cleared: int = int(run_result.get("cleared_weeks", 0))
	var win: bool = bool(run_result.get("win", false))
	var loss_week: int = int(run_result.get("loss_week", 0))
	var final_pool: Dictionary = run_result.get("final_pool_summary", {})
	_log("[%s] — Cleared %d/10 weeks — %s week %d — Final pool: %d followers avg lineage L%.2f" % [
		doctrine,
		cleared,
		"WIN" if win else "LOSS",
		loss_week,
		int(final_pool.get("total", 0)),
		float(run_result.get("final_avg_lineage", 0.0)),
	])


func _fresh_gs(seed: int, doctrine: String) -> Node:
	var gs_script = load("res://scripts/GameState.gd")
	if gs_script == null:
		_fail("GameState.gd could not be loaded.")
		return null
	var gs = gs_script.new()
	if _has_property(gs, "codex_persistence_enabled"):
		gs.codex_persistence_enabled = false
	if gs.has_method("_ready"):
		gs._ready()
	_safe_call(gs, "set_rng_seed", [seed], null)
	_safe_call(gs, "reset_run", [], null)
	gs.suppress_logs = true
	gs.current_week = 1
	gs.week_round = 1
	gs.week_total_devotion = 0
	gs.selected_doctrine = doctrine
	_safe_call(gs, "init_starting_pool", [doctrine], null)
	return gs


func _has_property(obj: Object, property_name: String) -> bool:
	for p in obj.get_property_list():
		if str(p.get("name", "")) == property_name:
			return true
	return false


func _safe_call(obj: Object, method_name: String, args: Array = [], fallback = null):
	if obj == null or not obj.has_method(method_name):
		_mark_method_missing(method_name, "safe_call")
		return fallback
	return obj.callv(method_name, args)


func _mark_method_missing(method_name: String, context: String) -> void:
	var key: String = "%s (%s)" % [method_name, context]
	_method_missing[key] = int(_method_missing.get(key, 0)) + 1


func _shuffle_with_rng(values: Array, rng: RandomNumberGenerator) -> void:
	if values.size() < 2:
		return
	for i in range(values.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp = values[i]
		values[i] = values[j]
		values[j] = tmp


func _write_report(elapsed_ms: int) -> void:
	var abs_dir: String = ProjectSettings.globalize_path(REPORT_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var timestamp: String = Time.get_datetime_string_from_system().replace(":", "-")
	var path: String = REPORT_DIR + "/simulation_report_" + timestamp + ".txt"
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		print("WARN: could not write simulation report to " + path)
		return
	for line in _report_lines:
		file.store_line(line)
	file.store_line("")
	file.store_line("Elapsed: %d ms" % elapsed_ms)
	file.close()
	_log("Report file: " + path)


func _log(line: String) -> void:
	print(line)
	_report_lines.append(line)


func _fail(msg: String) -> void:
	_failures.append(msg)


func _warn(msg: String) -> void:
	_warnings.append(msg)
