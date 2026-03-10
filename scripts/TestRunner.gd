extends Node

const TEST_SEED := 7263491
const RUNS_PER_DOCTRINE := 600
const RUN_BALANCE_SIM := true
const RUN_ONLY_SIM := false
const DOCTRINES := ["FLESH", "RUIN", "SILENCE"]
const RUN_DOCTRINE := ""
const BALANCE_PROFILES := ["expert", "average"]
const PHASE1_TOP_BOTTOM_COUNT := 10
const BALANCE_TARGETS := {
	"expert": {
		"pass_rate_start": {"min": 0.90, "max": 0.99},
		"pass_rate_end": {"min": 0.60, "max": 0.85},
		"avg_week_target_mult": {"min": 0.95, "max": 1.35},
		"avg_round_target_mult": {"min": 0.55, "max": 0.90},
		"blood_earned_start": {"min": 5.0, "max": 14.0},
		"blood_earned_end": {"min": 8.0, "max": 22.0},
	},
	"average": {
		"pass_rate_start": {"min": 0.75, "max": 0.92},
		"pass_rate_end": {"min": 0.25, "max": 0.55},
		"avg_week_target_mult": {"min": 0.80, "max": 1.15},
		"avg_round_target_mult": {"min": 0.40, "max": 0.70},
		"blood_earned_start": {"min": 3.0, "max": 10.0},
		"blood_earned_end": {"min": 5.0, "max": 16.0},
	},
}

var failures := []
var warnings := []
var report_lines := []
var test_count := 0
var pass_count := 0
var _allocated_gs: Array[Node] = []

func _ready() -> void:
	var started = Time.get_ticks_msec()
	run_all()
	_cleanup_allocated_gs()
	var elapsed = Time.get_ticks_msec() - started
	_print_summary(elapsed)
	_write_report(elapsed)
	var exit_code := 0
	if failures.size() > 0:
		exit_code = 1
	get_tree().quit(exit_code)

func run_all() -> void:
	_print_header()
	if RUN_ONLY_SIM and RUN_BALANCE_SIM:
		run_balance_sim()
		return
	test_relic_scoring_exhaustive()
	test_relic_special_counts()
	test_relic_non_scoring_exhaustive()
	test_exactly_three_conditions()
	test_trait_effects()
	test_trait_multiplier_cap()
	test_lineage_multiplier()
	test_breeding_rules()
	test_codex_meta_progression()
	test_new_relics_batch1()
	test_new_relics_batch2()
	test_pool_cap_modifiers()
	if RUN_BALANCE_SIM:
		run_balance_sim()

func _print_header() -> void:
	_log("")
	_log("=== Cult of Accumulation: Exhaustive Test Runner ===")
	_log("Seed: %d" % TEST_SEED)
	if RUN_DOCTRINE != "":
		_log("Doctrine filter: %s" % RUN_DOCTRINE)

func _get_active_doctrines() -> Array:
	if RUN_DOCTRINE == "":
		return DOCTRINES
	var filtered: Array = []
	for d in DOCTRINES:
		if d == RUN_DOCTRINE:
			filtered.append(d)
	if filtered.is_empty():
		return DOCTRINES
	return filtered

func _print_summary(elapsed_ms: int) -> void:
	_log("")
	_log("=== Summary ===")
	_log("Tests: %d" % test_count)
	_log("Passing: %d" % pass_count)
	_log("Failures: %d" % failures.size())
	_log("Warnings: %d" % warnings.size())
	_log("Elapsed: %d ms" % elapsed_ms)
	if failures.size() > 0:
		for f in failures:
			_log("FAIL: " + f)
	if warnings.size() > 0:
		for w in warnings:
			_log("WARN: " + w)
	if failures.size() == 0:
		_log("PASS")

func _log(line: String) -> void:
	print(line)
	report_lines.append(line)

func _write_report(elapsed_ms: int) -> void:
	var date_str = Time.get_datetime_string_from_system()
	var dir_path = "res://docs/test_reports"
	var abs_dir = ProjectSettings.globalize_path(dir_path)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var file_path = dir_path + "/exhaustive_report_" + date_str.replace(":", "-") + ".txt"
	var f = FileAccess.open(file_path, FileAccess.WRITE)
	if f == null:
		print("WARN: Failed to write report to " + file_path)
		return
	for line in report_lines:
		f.store_line(line)
	f.store_line("")
	f.store_line("Report file: " + file_path)
	f.close()

func _fail(msg: String) -> void:
	failures.append(msg)

func _warn(msg: String) -> void:
	warnings.append(msg)

func _assert_true(cond: bool, msg: String) -> void:
	test_count += 1
	if not cond:
		_fail(msg)
	else:
		pass_count += 1

func _assert_eq(a, b, msg: String) -> void:
	test_count += 1
	if a != b:
		_fail("%s (got %s expected %s)" % [msg, str(a), str(b)])
	else:
		pass_count += 1

func _fresh_gs() -> Node:
	var GS = load("res://scripts/GameState.gd")
	var gs = GS.new()
	gs.codex_persistence_enabled = false
	gs._ready()
	gs._rng.seed = TEST_SEED
	gs.reset_run()
	gs.suppress_logs = true
	gs.current_week = 1
	gs.week_round = 1
	gs.week_total_devotion = 0
	gs.selected_doctrine = ""
	gs.doctrine_used_this_play = false
	gs.ritual_card_active = ""
	gs.contract_allow_four = false
	gs.contract_used_week = -1
	_allocated_gs.append(gs)
	return gs

func _cleanup_allocated_gs() -> void:
	for n in _allocated_gs:
		if is_instance_valid(n):
			n.free()
	_allocated_gs.clear()

func _to_typed_indices(indices: Array, context: String) -> Array[int]:
	var typed: Array[int] = []
	for idx in indices:
		var t: int = typeof(idx)
		if t != TYPE_INT and t != TYPE_FLOAT:
			_fail("%s invalid index type: %s" % [context, type_string(t)])
			return []
		typed.append(int(idx))
	return typed

func _resolve_play_and_update_pool_safe(gs: Node, indices: Array, context: String) -> void:
	var typed: Array[int] = _to_typed_indices(indices, context)
	if typed.is_empty() and not indices.is_empty():
		return
	gs.resolve_play_and_update_pool(typed)

func _make_exhaustive_hand(gs: Node) -> Array:
	var hand = []
	for tier in range(1, 7):
		hand.append(gs._make_specific_follower("BLOOD", tier, "test"))
	for tier in range(1, 7):
		hand.append(gs._make_specific_follower("BONE", tier, "test"))
	for i in range(6):
		hand.append(gs._make_specific_follower("VOID", 1, "test"))
	return hand

func _set_hand(gs: Node, hand: Array) -> void:
	gs.current_hand.clear()
	for f in hand:
		gs.current_hand.append(f)

func _score(gs: Node, indices: Array) -> Dictionary:
	return gs.preview_selected(indices)

func _has_line(text: String, needle: String) -> bool:
	var lines = text.split("\n")
	for l in lines:
		if l.find(needle) >= 0:
			return true
	return false

func run_balance_sim() -> void:
	_log("")
	_log("=== BalanceSim (Random Plays, With Relics) ===")
	var temp_gs = _fresh_gs()
	var max_weeks: int = int(temp_gs.get_max_weeks())
	var target_values: Array[int] = []
	for w in range(1, max_weeks + 1):
		target_values.append(int(temp_gs.get_week_target(w)))
	temp_gs.free()

	var all_profile_results: Array = []
	var expert_result: Dictionary = {}

	for profile in BALANCE_PROFILES:
		var include_relics: bool = profile == "expert"
		var result = _run_balance_sim_profile(profile, max_weeks, target_values, include_relics)
		all_profile_results.append(result)
		_validate_balance_profile(profile, max_weeks, target_values, result)
		if profile == "expert":
			expert_result = result
	if not expert_result.is_empty():
		_log_phase1_rankings(expert_result)
	_write_sim_csv(max_weeks, target_values, all_profile_results)

func _run_balance_sim_profile(profile: String, max_weeks: int, target_values: Array[int], include_relic_impact: bool) -> Dictionary:
	_log("")
	_log("Profile: %s" % profile)
	var relic_run_counts: Dictionary = {}
	var relic_run_end_week_sum: Dictionary = {}
	var relic_run_avg_score_sum: Dictionary = {}
	var relic_offer_counts: Dictionary = {}
	var trait_run_counts: Dictionary = {}
	var trait_run_end_week_sum: Dictionary = {}
	var trait_run_avg_score_sum: Dictionary = {}
	var trait_trigger_rounds: Dictionary = {}
	var trait_additive_sum: Dictionary = {}
	var trait_blood_sum: Dictionary = {}
	var run_avg_score_sum_total: float = 0.0
	var run_avg_score_count_total: int = 0
	var doctrine_summary: Dictionary = {}
	var doctrine_week_reached: Dictionary = {}
	var doctrine_blood_gained: Dictionary = {}
	var doctrine_blood_spent: Dictionary = {}
	var doctrines = _get_active_doctrines()
	var profile_week_passes: Array = []
	var profile_week_round_sum: Array = []
	var profile_week_round_count: Array = []
	var profile_week_total_sum: Array = []
	var profile_week_overflow_sum: Array = []
	var profile_week_early_sum: Array = []
	var profile_week_blood_earned_sum: Array = []
	var profile_week_blood_spent_sum: Array = []
	var profile_week_pool_size_sum: Array = []
	var profile_week_pool_size_count: Array = []
	var profile_week_relics_end_sum: Array = []
	var profile_week_relics_end_count: Array = []
	var profile_week_shop_entry_blood_sum: Array = []
	var profile_week_shop_entry_blood_count: Array = []
	var profile_week_trait_trigger_rounds: Array = []
	var profile_week_trait_round_count: Array = []
	var profile_week_trait_additive_sum: Array = []
	var profile_week_trait_blood_sum: Array = []
	var profile_week_nest_active_sum: Array = []
	var profile_week_nest_total_sum: Array = []
	var profile_week_nest_newborn_sum: Array = []
	var profile_week_wild_newborn_sum: Array = []
	var profile_week_newborn_tier_sum: Array = []
	var profile_week_newborn_count: Array = []
	var profile_week_newborn_common_sum: Array = []
	var profile_week_newborn_rare_sum: Array = []
	var profile_week_newborn_legendary_sum: Array = []
	var profile_week_newborn_none_sum: Array = []
	var profile_week_expected_nest_newborn_sum: Array = []
	var profile_week_expected_nest_tier_sum: Array = []
	var profile_week_expected_nest_common_sum: Array = []
	var profile_week_expected_nest_rare_sum: Array = []
	var profile_week_expected_nest_legendary_sum: Array = []
	var profile_week_actual_nest_tier_sum: Array = []
	var profile_week_actual_nest_count: Array = []
	var profile_week_actual_nest_common_sum: Array = []
	var profile_week_actual_nest_rare_sum: Array = []
	var profile_week_actual_nest_legendary_sum: Array = []
	var profile_week_actual_nest_none_sum: Array = []
	var profile_runs_with_nesting: int = 0
	var profile_runs_without_nesting: int = 0
	var profile_wins_with_nesting: int = 0
	var profile_wins_without_nesting: int = 0
	var profile_end_week_sum_with_nesting: int = 0
	var profile_end_week_sum_without_nesting: int = 0

	for i in range(max_weeks):
		profile_week_passes.append(0)
		profile_week_round_sum.append(0)
		profile_week_round_count.append(0)
		profile_week_total_sum.append(0)
		profile_week_overflow_sum.append(0)
		profile_week_early_sum.append(0)
		profile_week_blood_earned_sum.append(0)
		profile_week_blood_spent_sum.append(0)
		profile_week_pool_size_sum.append(0)
		profile_week_pool_size_count.append(0)
		profile_week_relics_end_sum.append(0)
		profile_week_relics_end_count.append(0)
		profile_week_shop_entry_blood_sum.append(0)
		profile_week_shop_entry_blood_count.append(0)
		profile_week_trait_trigger_rounds.append(0)
		profile_week_trait_round_count.append(0)
		profile_week_trait_additive_sum.append(0)
		profile_week_trait_blood_sum.append(0)
		profile_week_nest_active_sum.append(0)
		profile_week_nest_total_sum.append(0)
		profile_week_nest_newborn_sum.append(0)
		profile_week_wild_newborn_sum.append(0)
		profile_week_newborn_tier_sum.append(0)
		profile_week_newborn_count.append(0)
		profile_week_newborn_common_sum.append(0)
		profile_week_newborn_rare_sum.append(0)
		profile_week_newborn_legendary_sum.append(0)
		profile_week_newborn_none_sum.append(0)
		profile_week_expected_nest_newborn_sum.append(0.0)
		profile_week_expected_nest_tier_sum.append(0.0)
		profile_week_expected_nest_common_sum.append(0.0)
		profile_week_expected_nest_rare_sum.append(0.0)
		profile_week_expected_nest_legendary_sum.append(0.0)
		profile_week_actual_nest_tier_sum.append(0.0)
		profile_week_actual_nest_count.append(0)
		profile_week_actual_nest_common_sum.append(0)
		profile_week_actual_nest_rare_sum.append(0)
		profile_week_actual_nest_legendary_sum.append(0)
		profile_week_actual_nest_none_sum.append(0)

	for doctrine in doctrines:
		doctrine_week_reached[doctrine] = {}
		doctrine_summary[doctrine] = {
			"runs": 0,
			"total_devotion": 0,
			"total_weeks_played": 0,
		}
		doctrine_blood_gained[doctrine] = 0
		doctrine_blood_spent[doctrine] = 0

		var week_passes: Array = []
		var week_loss_count: Array = []
		var week_loss_relics_sum: Array = []
		var week_round_sum: Array = []
		var week_round_count: Array = []
		var week_total_sum: Array = []
		var week_overflow_sum: Array = []
		var week_early_sum: Array = []
		var week_blood_earned_sum: Array = []
		var week_blood_spent_sum: Array = []
		var week_pool_size_sum: Array = []
		var week_pool_size_count: Array = []
		var week_relics_end_sum: Array = []
		var week_relics_end_count: Array = []
		var week_win_relics_sum: Array = []
		var week_win_count: Array = []
		var week_shop_entry_blood_sum: Array = []
		var week_shop_entry_blood_count: Array = []
		var week_trait_trigger_rounds: Array = []
		var week_trait_round_count: Array = []
		var week_trait_additive_sum: Array = []
		var week_trait_blood_sum: Array = []
		var week_nest_active_sum: Array = []
		var week_nest_total_sum: Array = []
		var week_nest_newborn_sum: Array = []
		var week_wild_newborn_sum: Array = []
		var week_newborn_tier_sum: Array = []
		var week_newborn_count: Array = []
		var week_newborn_common_sum: Array = []
		var week_newborn_rare_sum: Array = []
		var week_newborn_legendary_sum: Array = []
		var week_newborn_none_sum: Array = []
		var week_expected_nest_newborn_sum: Array = []
		var week_expected_nest_tier_sum: Array = []
		var week_expected_nest_common_sum: Array = []
		var week_expected_nest_rare_sum: Array = []
		var week_expected_nest_legendary_sum: Array = []
		var week_actual_nest_tier_sum: Array = []
		var week_actual_nest_count: Array = []
		var week_actual_nest_common_sum: Array = []
		var week_actual_nest_rare_sum: Array = []
		var week_actual_nest_legendary_sum: Array = []
		var week_actual_nest_none_sum: Array = []
		var run_end_relic_sum_by_week: Dictionary = {}
		var run_end_count_by_week: Dictionary = {}

		for i in range(max_weeks):
			week_passes.append(0)
			week_loss_count.append(0)
			week_loss_relics_sum.append(0)
			week_round_sum.append(0)
			week_round_count.append(0)
			week_total_sum.append(0)
			week_overflow_sum.append(0)
			week_early_sum.append(0)
			week_blood_earned_sum.append(0)
			week_blood_spent_sum.append(0)
			week_pool_size_sum.append(0)
			week_pool_size_count.append(0)
			week_relics_end_sum.append(0)
			week_relics_end_count.append(0)
			week_win_relics_sum.append(0)
			week_win_count.append(0)
			week_shop_entry_blood_sum.append(0)
			week_shop_entry_blood_count.append(0)
			week_trait_trigger_rounds.append(0)
			week_trait_round_count.append(0)
			week_trait_additive_sum.append(0)
			week_trait_blood_sum.append(0)
			week_nest_active_sum.append(0)
			week_nest_total_sum.append(0)
			week_nest_newborn_sum.append(0)
			week_wild_newborn_sum.append(0)
			week_newborn_tier_sum.append(0)
			week_newborn_count.append(0)
			week_newborn_common_sum.append(0)
			week_newborn_rare_sum.append(0)
			week_newborn_legendary_sum.append(0)
			week_newborn_none_sum.append(0)
			week_expected_nest_newborn_sum.append(0.0)
			week_expected_nest_tier_sum.append(0.0)
			week_expected_nest_common_sum.append(0.0)
			week_expected_nest_rare_sum.append(0.0)
			week_expected_nest_legendary_sum.append(0.0)
			week_actual_nest_tier_sum.append(0.0)
			week_actual_nest_count.append(0)
			week_actual_nest_common_sum.append(0)
			week_actual_nest_rare_sum.append(0)
			week_actual_nest_legendary_sum.append(0)
			week_actual_nest_none_sum.append(0)

		for run_idx in range(RUNS_PER_DOCTRINE):
			var gs = _fresh_gs()
			var doctrine_offset: int = doctrines.find(doctrine) + 1
			var profile_offset: int = 1 if profile == "average" else 0
			var run_seed: int = TEST_SEED + (profile_offset * 1000000) + (doctrine_offset * 100000) + run_idx
			gs.set_rng_seed(run_seed)
			gs.selected_doctrine = doctrine
			gs.init_starting_pool(doctrine)
			var run_relics: Dictionary = {}
			var run_relic_offers_seen: Dictionary = {}
			var run_traits_seen: Dictionary = {}
			var run_total_devotion: int = 0
			var run_weeks_played: int = 0
			var run_end_week: int = 0
			var run_blood_gained: int = 0
			var run_blood_spent: int = 0
			var run_used_nesting: bool = false
			var week_prestarted: bool = false

			for week in range(1, max_weeks + 1):
				gs.current_week = week
				if not week_prestarted:
					gs.start_week()
				else:
					week_prestarted = false
				var target = target_values[week - 1]
				var week_cleared := false
				var last_round_result: Dictionary = {}
				var week_overflow_blood: int = 0
				var week_early_blood: int = 0
				var week_blood_spent: int = 0
				var start_blood: int = gs.blood_currency

				for round in range(2):
					gs.draw_hand_from_pool()
					if str(gs.ritual_card_slot) != "":
						var ritual_use_chance: float = 1.0 if profile == "expert" else 0.60
						if gs._rng.randf() < ritual_use_chance:
							gs.ritual_card_active = gs.ritual_card_slot
							gs.ritual_card_slot = ""
					var required: int = _simulate_choose_required_sacrifice_count(gs, week, profile)
					var picks = _pick_indices(gs, required, profile)
					if picks.size() < required and required > 3:
						gs.contract_allow_four = false
						gs.contract_allow_five = false
						required = 3
						picks = _pick_indices(gs, required, profile)
					if picks.is_empty():
						break
					var blood_before: int = gs.blood_currency
					if bool(gs.contract_allow_five):
						gs.contract_five_used_week = week
						gs.contract_allow_five = false
					elif bool(gs.contract_allow_four):
						gs.contract_used_week = week
						gs.contract_allow_four = false
					var result = gs._score_selected_internal(picks, true, false, false)
					last_round_result = result
					week_trait_round_count[week - 1] += 1
					var trait_trigger_count: int = int(result.get("trait_trigger_count", 0))
					if trait_trigger_count > 0:
						week_trait_trigger_rounds[week - 1] += 1
					week_trait_additive_sum[week - 1] += int(result.get("trait_additive_total", 0))
					week_trait_blood_sum[week - 1] += int(result.get("trait_blood_bonus", 0))
					for pick_idx in picks:
						if int(pick_idx) < 0 or int(pick_idx) >= gs.current_hand.size():
							continue
						var picked: Dictionary = gs.current_hand[int(pick_idx)]
						var tid: String = str(picked.get("trait_id", ""))
						if tid != "":
							run_traits_seen[tid] = true
					gs.week_total_devotion += int(result.get("final_devotion", 0))
					run_total_devotion += int(result.get("final_devotion", 0))
					gs.apply_week_devotion_cap(target)

					var overflow_grant: int = gs.apply_overflow_blood_for_target(target)
					if overflow_grant > 0:
						week_overflow_blood += overflow_grant

					if int(gs.relic_inventory.get("The Bleeding Edge", 0)) > 0 and int(result.get("final_devotion", 0)) < int(result.get("target", 0)):
						var bleed_loss: int = 3 * int(gs.relic_inventory.get("The Bleeding Edge", 0))
						gs.blood_currency = max(0, gs.blood_currency - bleed_loss)
					if int(gs.relic_inventory.get("Clean Hands", 0)) > 0 and gs.week_total_devotion >= target and int(result.get("void_count", 0)) == 0:
						gs.free_reroll_next_shop = true
					var blood_after: int = gs.blood_currency
					if blood_after > blood_before:
						run_blood_gained += (blood_after - blood_before)
					week_round_sum[week - 1] += int(result.get("final_devotion", 0))
					week_round_count[week - 1] += 1
					_resolve_play_and_update_pool_safe(gs, picks, "balance_sim week %d round %d" % [week, round + 1])

					if gs.week_total_devotion >= target:
						if round == 0:
							var early_bonus: int = gs.get_early_win_bonus()
							var blood_before_bonus: int = gs.blood_currency
							gs.add_blood(early_bonus)
							run_blood_gained += (gs.blood_currency - blood_before_bonus)
							week_early_blood += early_bonus
						week_cleared = true
						break
					if round == 0:
						gs.week_round = 2
						if int(gs.relic_inventory.get("The Awakening Bell", 0)) > 0 and int(gs.awakening_bell_used_week) != week:
							gs.clear_exhausted()
							gs.awakening_bell_used_week = week

				run_weeks_played += 1
				run_end_week = week
				week_total_sum[week - 1] += gs.week_total_devotion

				if week_cleared or gs.week_total_devotion >= target:
					week_passes[week - 1] += 1
					var clear_gain: int = _simulate_on_week_clear_success(gs, last_round_result)
					if clear_gain > 0:
						run_blood_gained += clear_gain
					if week < max_weeks:
						# Live order: week clear -> breeding -> shop -> nest selection for next week.
						var breeding_metrics: Dictionary = _simulate_weekly_breeding(gs, week)
						week_nest_active_sum[week - 1] += int(breeding_metrics.get("active_nests", 0))
						week_nest_total_sum[week - 1] += int(breeding_metrics.get("total_nests", 0))
						week_nest_newborn_sum[week - 1] += int(breeding_metrics.get("nest_newborns", 0))
						week_wild_newborn_sum[week - 1] += int(breeding_metrics.get("wild_newborns", 0))
						week_newborn_tier_sum[week - 1] += int(breeding_metrics.get("newborn_tier_sum", 0))
						week_newborn_count[week - 1] += int(breeding_metrics.get("newborn_count", 0))
						week_newborn_common_sum[week - 1] += int(breeding_metrics.get("common", 0))
						week_newborn_rare_sum[week - 1] += int(breeding_metrics.get("rare", 0))
						week_newborn_legendary_sum[week - 1] += int(breeding_metrics.get("legendary", 0))
						week_newborn_none_sum[week - 1] += int(breeding_metrics.get("none", 0))
						week_expected_nest_newborn_sum[week - 1] += float(breeding_metrics.get("expected_nest_newborns", 0.0))
						week_expected_nest_tier_sum[week - 1] += float(breeding_metrics.get("expected_nest_tier_sum", 0.0))
						week_expected_nest_common_sum[week - 1] += float(breeding_metrics.get("expected_nest_common", 0.0))
						week_expected_nest_rare_sum[week - 1] += float(breeding_metrics.get("expected_nest_rare", 0.0))
						week_expected_nest_legendary_sum[week - 1] += float(breeding_metrics.get("expected_nest_legendary", 0.0))
						week_actual_nest_tier_sum[week - 1] += float(breeding_metrics.get("actual_nest_tier_sum", 0.0))
						week_actual_nest_count[week - 1] += int(breeding_metrics.get("actual_nest_count", 0))
						week_actual_nest_common_sum[week - 1] += int(breeding_metrics.get("actual_nest_common", 0))
						week_actual_nest_rare_sum[week - 1] += int(breeding_metrics.get("actual_nest_rare", 0))
						week_actual_nest_legendary_sum[week - 1] += int(breeding_metrics.get("actual_nest_legendary", 0))
						week_actual_nest_none_sum[week - 1] += int(breeding_metrics.get("actual_nest_none", 0))
						if int(breeding_metrics.get("active_nests", 0)) > 0:
							run_used_nesting = true

						var blood_before_shop_phase: int = gs.blood_currency
						var shop_result: Dictionary = _simulate_shop(gs, week, run_relics, profile, max_weeks)
						var shop_spent: int = int(shop_result.get("blood_spent", 0))
						week_blood_spent += shop_spent
						run_blood_spent += shop_spent
						week_shop_entry_blood_sum[week - 1] += int(shop_result.get("shop_entry_blood", 0))
						week_shop_entry_blood_count[week - 1] += 1
						if gs.blood_currency > blood_before_shop_phase:
							run_blood_gained += (gs.blood_currency - blood_before_shop_phase)
						var offers_seen: Dictionary = shop_result.get("offers_seen", {})
						for offered_name in offers_seen.keys():
							run_relic_offers_seen[offered_name] = true

						var blood_before_start_week: int = gs.blood_currency
						gs.current_week = week + 1
						gs.start_week()
						if gs.blood_currency > blood_before_start_week:
							run_blood_gained += (gs.blood_currency - blood_before_start_week)
						week_prestarted = true
						var nest_state: Dictionary = _simulate_nest_selection(gs, profile)
						var focus_spent: int = int(nest_state.get("focus_blood_spent", 0))
						if focus_spent > 0:
							week_blood_spent += focus_spent
							run_blood_spent += focus_spent
						if int(nest_state.get("active_nests", 0)) > 0:
							run_used_nesting = true
					var relics_after_win: int = _count_total_relics(gs)
					week_win_relics_sum[week - 1] += relics_after_win
					week_win_count[week - 1] += 1
				else:
					# Failed week ends run early; still count remainder as fail
					week_loss_count[week - 1] += 1
					week_loss_relics_sum[week - 1] += _count_total_relics(gs)

				var end_blood: int = gs.blood_currency
				var week_earned: int = (end_blood - start_blood) + week_blood_spent
				week_overflow_sum[week - 1] += week_overflow_blood
				week_early_sum[week - 1] += week_early_blood
				week_blood_earned_sum[week - 1] += week_earned
				week_blood_spent_sum[week - 1] += week_blood_spent
				week_pool_size_sum[week - 1] += gs.pool.size()
				week_pool_size_count[week - 1] += 1
				week_relics_end_sum[week - 1] += _count_total_relics(gs)
				week_relics_end_count[week - 1] += 1

				if not week_cleared and gs.week_total_devotion < target:
					break

			var avg_score_run: float = 0.0
			if run_weeks_played > 0:
				avg_score_run = float(run_total_devotion) / float(run_weeks_played)
			doctrine_summary[doctrine]["runs"] = int(doctrine_summary[doctrine]["runs"]) + 1
			doctrine_summary[doctrine]["total_devotion"] = int(doctrine_summary[doctrine]["total_devotion"]) + run_total_devotion
			doctrine_summary[doctrine]["total_weeks_played"] = int(doctrine_summary[doctrine]["total_weeks_played"]) + run_weeks_played
			var reached = doctrine_week_reached[doctrine]
			reached[run_end_week] = int(reached.get(run_end_week, 0)) + 1
			var run_end_relics: int = _count_total_relics(gs)
			run_end_relic_sum_by_week[run_end_week] = int(run_end_relic_sum_by_week.get(run_end_week, 0)) + run_end_relics
			run_end_count_by_week[run_end_week] = int(run_end_count_by_week.get(run_end_week, 0)) + 1
			doctrine_blood_gained[doctrine] = int(doctrine_blood_gained[doctrine]) + run_blood_gained
			doctrine_blood_spent[doctrine] = int(doctrine_blood_spent[doctrine]) + run_blood_spent
			var run_won: bool = run_end_week >= max_weeks
			if run_used_nesting:
				profile_runs_with_nesting += 1
				profile_end_week_sum_with_nesting += run_end_week
				if run_won:
					profile_wins_with_nesting += 1
			else:
				profile_runs_without_nesting += 1
				profile_end_week_sum_without_nesting += run_end_week
				if run_won:
					profile_wins_without_nesting += 1

			if include_relic_impact:
				run_avg_score_sum_total += avg_score_run
				run_avg_score_count_total += 1
				for offered_name in run_relic_offers_seen.keys():
					relic_offer_counts[offered_name] = int(relic_offer_counts.get(offered_name, 0)) + 1
				for relic_name in run_relics.keys():
					relic_run_counts[relic_name] = int(relic_run_counts.get(relic_name, 0)) + 1
					relic_run_end_week_sum[relic_name] = int(relic_run_end_week_sum.get(relic_name, 0)) + run_end_week
					relic_run_avg_score_sum[relic_name] = float(relic_run_avg_score_sum.get(relic_name, 0.0)) + avg_score_run
				for trait_id in run_traits_seen.keys():
					trait_run_counts[trait_id] = int(trait_run_counts.get(trait_id, 0)) + 1
					trait_run_end_week_sum[trait_id] = int(trait_run_end_week_sum.get(trait_id, 0)) + run_end_week
					trait_run_avg_score_sum[trait_id] = float(trait_run_avg_score_sum.get(trait_id, 0.0)) + avg_score_run
			gs.free()

		_log("")
		_log("Doctrine: %s" % doctrine)
		for w in range(max_weeks):
			var pass_rate = float(week_passes[w]) / float(RUNS_PER_DOCTRINE)
			var avg_round = 0.0
			if week_round_count[w] > 0:
				avg_round = float(week_round_sum[w]) / float(week_round_count[w])
			var avg_week = float(week_total_sum[w]) / float(RUNS_PER_DOCTRINE)
			var avg_loss_relics = 0.0
			if week_loss_count[w] > 0:
				avg_loss_relics = float(week_loss_relics_sum[w]) / float(week_loss_count[w])
			var avg_overflow = float(week_overflow_sum[w]) / float(RUNS_PER_DOCTRINE)
			var avg_early = float(week_early_sum[w]) / float(RUNS_PER_DOCTRINE)
			var avg_blood_earned = float(week_blood_earned_sum[w]) / float(RUNS_PER_DOCTRINE)
			var avg_blood_spent = float(week_blood_spent_sum[w]) / float(RUNS_PER_DOCTRINE)
			var avg_pool = 0.0
			if week_pool_size_count[w] > 0:
				avg_pool = float(week_pool_size_sum[w]) / float(week_pool_size_count[w])
			var avg_relics_end = 0.0
			if week_relics_end_count[w] > 0:
				avg_relics_end = float(week_relics_end_sum[w]) / float(week_relics_end_count[w])
			var avg_shop_entry_blood = 0.0
			if week_shop_entry_blood_count[w] > 0:
				avg_shop_entry_blood = float(week_shop_entry_blood_sum[w]) / float(week_shop_entry_blood_count[w])
			var trait_trigger_rate: float = 0.0
			var avg_trait_additive_round: float = 0.0
			var avg_trait_blood_round: float = 0.0
			if week_trait_round_count[w] > 0:
				trait_trigger_rate = float(week_trait_trigger_rounds[w]) / float(week_trait_round_count[w])
				avg_trait_additive_round = float(week_trait_additive_sum[w]) / float(week_trait_round_count[w])
				avg_trait_blood_round = float(week_trait_blood_sum[w]) / float(week_trait_round_count[w])
			var nest_usage_rate: float = 0.0
			if week_nest_total_sum[w] > 0:
				nest_usage_rate = float(week_nest_active_sum[w]) / float(week_nest_total_sum[w])
			var avg_newborn_tier: float = 0.0
			if week_newborn_count[w] > 0:
				avg_newborn_tier = float(week_newborn_tier_sum[w]) / float(week_newborn_count[w])
			var expected_nest_tier: float = 0.0
			var expected_nest_rare_share: float = 0.0
			if float(week_expected_nest_newborn_sum[w]) > 0.0:
				expected_nest_tier = float(week_expected_nest_tier_sum[w]) / float(week_expected_nest_newborn_sum[w])
				expected_nest_rare_share = float(week_expected_nest_rare_sum[w]) / float(week_expected_nest_newborn_sum[w])
			var actual_nest_tier: float = 0.0
			var actual_nest_rare_share: float = 0.0
			if int(week_actual_nest_count[w]) > 0:
				actual_nest_tier = float(week_actual_nest_tier_sum[w]) / float(week_actual_nest_count[w])
				actual_nest_rare_share = float(week_actual_nest_rare_sum[w]) / float(week_actual_nest_count[w])
			_log("Week %d | PassRate: %.1f%% | AvgRound: %.2f | AvgWeek: %.2f | AvgOverflow: %.2f | AvgEarly: %.2f | AvgEarned: %.2f | AvgSpent: %.2f | AvgPool: %.2f" % [
				w + 1,
				pass_rate * 100.0,
				avg_round,
				avg_week,
				avg_overflow,
				avg_early,
				avg_blood_earned,
				avg_blood_spent,
				avg_pool,
			])
			_log("PowerFeel | TraitTrig: %.1f%% | TraitAdd/Round: %.2f | TraitBlood/Round: %.2f | NestUse: %.1f%% | NestBorn: %.2f | WildBorn: %.2f | NewbornTier: %.2f | Rarity C/R/L/N: %.2f/%.2f/%.2f/%.2f" % [
				trait_trigger_rate * 100.0,
				avg_trait_additive_round,
				avg_trait_blood_round,
				nest_usage_rate * 100.0,
				float(week_nest_newborn_sum[w]) / float(RUNS_PER_DOCTRINE),
				float(week_wild_newborn_sum[w]) / float(RUNS_PER_DOCTRINE),
				avg_newborn_tier,
				(float(week_newborn_common_sum[w]) / float(week_newborn_count[w])) if week_newborn_count[w] > 0 else 0.0,
				(float(week_newborn_rare_sum[w]) / float(week_newborn_count[w])) if week_newborn_count[w] > 0 else 0.0,
				(float(week_newborn_legendary_sum[w]) / float(week_newborn_count[w])) if week_newborn_count[w] > 0 else 0.0,
				(float(week_newborn_none_sum[w]) / float(week_newborn_count[w])) if week_newborn_count[w] > 0 else 0.0,
			])
			_log("BreedingEV | ExpNestTier: %.2f | ActNestTier: %.2f | DeltaTier: %+0.2f | ExpNestRare: %.2f | ActNestRare: %.2f | DeltaRare: %+0.2f" % [
				expected_nest_tier,
				actual_nest_tier,
				actual_nest_tier - expected_nest_tier,
				expected_nest_rare_share,
				actual_nest_rare_share,
				actual_nest_rare_share - expected_nest_rare_share,
			])
			_log("AvgRelicsEndWeek: %.2f" % avg_relics_end)
			_log("AvgShopEntryBlood: %.2f" % avg_shop_entry_blood)
			if week_win_count[w] > 0:
				var avg_relics_on_win: float = float(week_win_relics_sum[w]) / float(week_win_count[w])
				_log("Wins: %d | AvgRelicsOnWin: %.2f" % [week_win_count[w], avg_relics_on_win])
			if week_loss_count[w] > 0:
				_log("Losses: %d | AvgRelicsOnLoss: %.2f" % [week_loss_count[w], avg_loss_relics])

		_log("Run-End Relics By End Week:")
		for rw in range(1, max_weeks + 1):
			var c: int = int(run_end_count_by_week.get(rw, 0))
			if c <= 0:
				continue
			var avg_end_relics: float = float(run_end_relic_sum_by_week.get(rw, 0)) / float(c)
			_log("- End Week %d: Runs %d | AvgRelicsAtEnd %.2f" % [rw, c, avg_end_relics])

		for w in range(max_weeks):
			profile_week_passes[w] += int(week_passes[w])
			profile_week_round_sum[w] += int(week_round_sum[w])
			profile_week_round_count[w] += int(week_round_count[w])
			profile_week_total_sum[w] += int(week_total_sum[w])
			profile_week_overflow_sum[w] += int(week_overflow_sum[w])
			profile_week_early_sum[w] += int(week_early_sum[w])
			profile_week_blood_earned_sum[w] += int(week_blood_earned_sum[w])
			profile_week_blood_spent_sum[w] += int(week_blood_spent_sum[w])
			profile_week_pool_size_sum[w] += int(week_pool_size_sum[w])
			profile_week_pool_size_count[w] += int(week_pool_size_count[w])
			profile_week_relics_end_sum[w] += int(week_relics_end_sum[w])
			profile_week_relics_end_count[w] += int(week_relics_end_count[w])
			profile_week_shop_entry_blood_sum[w] += int(week_shop_entry_blood_sum[w])
			profile_week_shop_entry_blood_count[w] += int(week_shop_entry_blood_count[w])
			profile_week_trait_trigger_rounds[w] += int(week_trait_trigger_rounds[w])
			profile_week_trait_round_count[w] += int(week_trait_round_count[w])
			profile_week_trait_additive_sum[w] += int(week_trait_additive_sum[w])
			profile_week_trait_blood_sum[w] += int(week_trait_blood_sum[w])
			profile_week_nest_active_sum[w] += int(week_nest_active_sum[w])
			profile_week_nest_total_sum[w] += int(week_nest_total_sum[w])
			profile_week_nest_newborn_sum[w] += int(week_nest_newborn_sum[w])
			profile_week_wild_newborn_sum[w] += int(week_wild_newborn_sum[w])
			profile_week_newborn_tier_sum[w] += int(week_newborn_tier_sum[w])
			profile_week_newborn_count[w] += int(week_newborn_count[w])
			profile_week_newborn_common_sum[w] += int(week_newborn_common_sum[w])
			profile_week_newborn_rare_sum[w] += int(week_newborn_rare_sum[w])
			profile_week_newborn_legendary_sum[w] += int(week_newborn_legendary_sum[w])
			profile_week_newborn_none_sum[w] += int(week_newborn_none_sum[w])
			profile_week_expected_nest_newborn_sum[w] += float(week_expected_nest_newborn_sum[w])
			profile_week_expected_nest_tier_sum[w] += float(week_expected_nest_tier_sum[w])
			profile_week_expected_nest_common_sum[w] += float(week_expected_nest_common_sum[w])
			profile_week_expected_nest_rare_sum[w] += float(week_expected_nest_rare_sum[w])
			profile_week_expected_nest_legendary_sum[w] += float(week_expected_nest_legendary_sum[w])
			profile_week_actual_nest_tier_sum[w] += float(week_actual_nest_tier_sum[w])
			profile_week_actual_nest_count[w] += int(week_actual_nest_count[w])
			profile_week_actual_nest_common_sum[w] += int(week_actual_nest_common_sum[w])
			profile_week_actual_nest_rare_sum[w] += int(week_actual_nest_rare_sum[w])
			profile_week_actual_nest_legendary_sum[w] += int(week_actual_nest_legendary_sum[w])
			profile_week_actual_nest_none_sum[w] += int(week_actual_nest_none_sum[w])

	var pass_with_nesting: float = 0.0
	var pass_without_nesting: float = 0.0
	var avg_end_week_with_nesting: float = 0.0
	var avg_end_week_without_nesting: float = 0.0
	if profile_runs_with_nesting > 0:
		pass_with_nesting = float(profile_wins_with_nesting) / float(profile_runs_with_nesting)
		avg_end_week_with_nesting = float(profile_end_week_sum_with_nesting) / float(profile_runs_with_nesting)
	if profile_runs_without_nesting > 0:
		pass_without_nesting = float(profile_wins_without_nesting) / float(profile_runs_without_nesting)
		avg_end_week_without_nesting = float(profile_end_week_sum_without_nesting) / float(profile_runs_without_nesting)
	_log("")
	_log("Breeding Contribution | WithNesting Pass: %.1f%% (%d runs) | WithoutNesting Pass: %.1f%% (%d runs) | Delta: %+0.1f%%" % [
		pass_with_nesting * 100.0,
		profile_runs_with_nesting,
		pass_without_nesting * 100.0,
		profile_runs_without_nesting,
		(pass_with_nesting - pass_without_nesting) * 100.0,
	])
	_log("Breeding Contribution | AvgEndWeek With: %.2f | Without: %.2f | Delta: %+0.2f" % [
		avg_end_week_with_nesting,
		avg_end_week_without_nesting,
		avg_end_week_with_nesting - avg_end_week_without_nesting,
	])

	var relic_rows: Array = []
	var trait_rows: Array = []
	if include_relic_impact:
		var baseline_avg_score: float = 0.0
		if run_avg_score_count_total > 0:
			baseline_avg_score = run_avg_score_sum_total / float(run_avg_score_count_total)
		_log("")
		_log("=== Relic Impact (Avg Furthest Week, Avg Score) ===")
		for relic_name in relic_run_counts.keys():
			var count: int = int(relic_run_counts[relic_name])
			if count <= 0:
				continue
			var avg_week: float = float(relic_run_end_week_sum[relic_name]) / float(count)
			var avg_score: float = float(relic_run_avg_score_sum[relic_name]) / float(count)
			var offered_count: int = int(relic_offer_counts.get(relic_name, 0))
			var pick_rate: float = 0.0
			if offered_count > 0:
				pick_rate = float(count) / float(offered_count)
			relic_rows.append({
				"name": relic_name,
				"avg_week": avg_week,
				"avg_score": avg_score,
				"count": count,
				"offers": offered_count,
				"pick_rate": pick_rate,
				"avg_score_delta": avg_score - baseline_avg_score,
			})
		relic_rows.sort_custom(func(a, b):
			if a["avg_week"] == b["avg_week"]:
				return a["avg_score"] > b["avg_score"]
			return a["avg_week"] > b["avg_week"]
		)
		for i in range(relic_rows.size()):
			var r = relic_rows[i]
			_log("%d) %s | AvgWeek: %.2f | AvgScore: %.2f | Delta: %+0.2f | PickRate: %.1f%% | RunsWithRelic: %d" % [
				i + 1,
				r["name"],
				float(r["avg_week"]),
				float(r["avg_score"]),
				float(r["avg_score_delta"]),
				float(r["pick_rate"]) * 100.0,
				int(r["count"]),
			])
		_log("")
		_log("=== Trait Impact (Avg Furthest Week, Avg Score) ===")
		var trait_lookup_gs = _fresh_gs()
		for trait_id in trait_run_counts.keys():
			var tcount: int = int(trait_run_counts[trait_id])
			if tcount <= 0:
				continue
			var tavg_week: float = float(trait_run_end_week_sum[trait_id]) / float(tcount)
			var tavg_score: float = float(trait_run_avg_score_sum[trait_id]) / float(tcount)
			var tname: String = trait_id
			if trait_lookup_gs.TRAIT_REGISTRY.has(trait_id):
				tname = str(trait_lookup_gs.TRAIT_REGISTRY[trait_id].get("name", trait_id))
			trait_rows.append({
				"id": trait_id,
				"name": tname,
				"avg_week": tavg_week,
				"avg_score": tavg_score,
				"count": tcount,
				"appearance_rate": float(tcount) / float(run_avg_score_count_total) if run_avg_score_count_total > 0 else 0.0,
				"avg_score_delta": tavg_score - baseline_avg_score,
			})
		trait_lookup_gs.free()
		trait_rows.sort_custom(func(a, b):
			if a["avg_week"] == b["avg_week"]:
				return a["avg_score"] > b["avg_score"]
			return a["avg_week"] > b["avg_week"]
		)
		for i in range(trait_rows.size()):
			var t = trait_rows[i]
			_log("%d) %s | AvgWeek: %.2f | AvgScore: %.2f | Delta: %+0.2f | SeenInRuns: %.1f%% | RunsWithTrait: %d" % [
				i + 1,
				t["name"],
				float(t["avg_week"]),
				float(t["avg_score"]),
				float(t["avg_score_delta"]),
				float(t["appearance_rate"]) * 100.0,
				int(t["count"]),
			])

	return {
		"profile": profile,
		"doctrine_summary": doctrine_summary,
		"doctrine_week_reached": doctrine_week_reached,
		"doctrine_blood_gained": doctrine_blood_gained,
		"doctrine_blood_spent": doctrine_blood_spent,
		"week_passes": profile_week_passes,
		"week_round_sum": profile_week_round_sum,
		"week_round_count": profile_week_round_count,
		"week_total_sum": profile_week_total_sum,
		"week_overflow_sum": profile_week_overflow_sum,
		"week_early_sum": profile_week_early_sum,
		"week_blood_earned_sum": profile_week_blood_earned_sum,
		"week_blood_spent_sum": profile_week_blood_spent_sum,
		"week_pool_size_sum": profile_week_pool_size_sum,
		"week_pool_size_count": profile_week_pool_size_count,
		"week_relics_end_sum": profile_week_relics_end_sum,
		"week_relics_end_count": profile_week_relics_end_count,
		"week_shop_entry_blood_sum": profile_week_shop_entry_blood_sum,
		"week_shop_entry_blood_count": profile_week_shop_entry_blood_count,
		"week_trait_trigger_rounds": profile_week_trait_trigger_rounds,
		"week_trait_round_count": profile_week_trait_round_count,
		"week_trait_additive_sum": profile_week_trait_additive_sum,
		"week_trait_blood_sum": profile_week_trait_blood_sum,
		"week_nest_active_sum": profile_week_nest_active_sum,
		"week_nest_total_sum": profile_week_nest_total_sum,
		"week_nest_newborn_sum": profile_week_nest_newborn_sum,
		"week_wild_newborn_sum": profile_week_wild_newborn_sum,
		"week_newborn_tier_sum": profile_week_newborn_tier_sum,
		"week_newborn_count": profile_week_newborn_count,
		"week_newborn_common_sum": profile_week_newborn_common_sum,
		"week_newborn_rare_sum": profile_week_newborn_rare_sum,
		"week_newborn_legendary_sum": profile_week_newborn_legendary_sum,
		"week_newborn_none_sum": profile_week_newborn_none_sum,
		"week_expected_nest_newborn_sum": profile_week_expected_nest_newborn_sum,
		"week_expected_nest_tier_sum": profile_week_expected_nest_tier_sum,
		"week_expected_nest_common_sum": profile_week_expected_nest_common_sum,
		"week_expected_nest_rare_sum": profile_week_expected_nest_rare_sum,
		"week_expected_nest_legendary_sum": profile_week_expected_nest_legendary_sum,
		"week_actual_nest_tier_sum": profile_week_actual_nest_tier_sum,
		"week_actual_nest_count": profile_week_actual_nest_count,
		"week_actual_nest_common_sum": profile_week_actual_nest_common_sum,
		"week_actual_nest_rare_sum": profile_week_actual_nest_rare_sum,
		"week_actual_nest_legendary_sum": profile_week_actual_nest_legendary_sum,
		"week_actual_nest_none_sum": profile_week_actual_nest_none_sum,
		"breeding_contrib": {
			"runs_with_nesting": profile_runs_with_nesting,
			"runs_without_nesting": profile_runs_without_nesting,
			"wins_with_nesting": profile_wins_with_nesting,
			"wins_without_nesting": profile_wins_without_nesting,
			"avg_end_week_with_nesting": avg_end_week_with_nesting,
			"avg_end_week_without_nesting": avg_end_week_without_nesting,
			"pass_with_nesting": pass_with_nesting,
			"pass_without_nesting": pass_without_nesting,
			"pass_delta": pass_with_nesting - pass_without_nesting,
			"end_week_delta": avg_end_week_with_nesting - avg_end_week_without_nesting,
		},
		"relic_rows": relic_rows,
		"trait_rows": trait_rows,
	}

func _pick_indices(gs: Node, required: int, profile: String) -> Array:
	if profile == "expert":
		return _best_indices(gs, required)
	return _random_unique_indices(gs.current_hand.size(), required, gs._rng)

func _simulate_choose_required_sacrifice_count(gs: Node, week: int, profile: String) -> int:
	gs.contract_allow_four = false
	gs.contract_allow_five = false
	var has_five: bool = int(gs.relic_inventory.get("The Expanding Contract", 0)) > 0 and int(gs.contract_five_used_week) != week
	var has_four: bool = int(gs.relic_inventory.get("Black Contract", 0)) > 0 and int(gs.contract_used_week) != week
	if has_five:
		var five_chance: float = 0.60 if profile == "expert" else 0.22
		if gs._rng.randf() < five_chance:
			gs.contract_allow_five = true
	if (not gs.contract_allow_five) and has_four:
		var four_chance: float = 0.50 if profile == "expert" else 0.25
		if gs._rng.randf() < four_chance:
			gs.contract_allow_four = true
	if bool(gs.contract_allow_five):
		return 5
	if bool(gs.contract_allow_four):
		return 4
	return 3

func _lerp(a: float, b: float, t: float) -> float:
	return a + (b - a) * t

func _build_linear_bands(max_weeks: int, start_min: float, start_max: float, end_min: float, end_max: float) -> Array:
	var bands: Array = []
	for i in range(max_weeks):
		var t: float = 0.0 if max_weeks == 1 else float(i) / float(max_weeks - 1)
		var min_v: float = _lerp(start_min, end_min, t)
		var max_v: float = _lerp(start_max, end_max, t)
		bands.append({"min": min_v, "max": max_v})
	return bands

func _validate_balance_profile(profile: String, max_weeks: int, target_values: Array[int], result: Dictionary) -> void:
	if not BALANCE_TARGETS.has(profile):
		_warn("No balance targets configured for profile: %s" % profile)
		return
	var total_runs: int = RUNS_PER_DOCTRINE * _get_active_doctrines().size()
	var cfg: Dictionary = BALANCE_TARGETS[profile]
	var pass_rate_bands: Array = _build_linear_bands(
		max_weeks,
		float(cfg["pass_rate_start"]["min"]),
		float(cfg["pass_rate_start"]["max"]),
		float(cfg["pass_rate_end"]["min"]),
		float(cfg["pass_rate_end"]["max"])
	)
	var blood_bands: Array = _build_linear_bands(
		max_weeks,
		float(cfg["blood_earned_start"]["min"]),
		float(cfg["blood_earned_start"]["max"]),
		float(cfg["blood_earned_end"]["min"]),
		float(cfg["blood_earned_end"]["max"])
	)
	var week_passes: Array = result["week_passes"]
	var week_round_sum: Array = result["week_round_sum"]
	var week_round_count: Array = result["week_round_count"]
	var week_total_sum: Array = result["week_total_sum"]
	var week_blood_earned_sum: Array = result["week_blood_earned_sum"]

	for w in range(max_weeks):
		var pass_rate: float = float(week_passes[w]) / float(total_runs)
		var pass_band: Dictionary = pass_rate_bands[w]
		if pass_rate < float(pass_band["min"]) or pass_rate > float(pass_band["max"]):
			_fail("%s pass rate out of band week %d: %.2f (target %.2f-%.2f)" % [
				profile,
				w + 1,
				pass_rate,
				float(pass_band["min"]),
				float(pass_band["max"]),
			])

		var avg_week: float = float(week_total_sum[w]) / float(total_runs)
		var week_target: float = float(target_values[w])
		var min_week: float = week_target * float(cfg["avg_week_target_mult"]["min"])
		var max_week: float = week_target * float(cfg["avg_week_target_mult"]["max"])
		if avg_week < min_week or avg_week > max_week:
			_fail("%s avg week devotion out of band week %d: %.2f (target %.2f-%.2f)" % [
				profile,
				w + 1,
				avg_week,
				min_week,
				max_week,
			])

		var avg_round: float = 0.0
		if int(week_round_count[w]) > 0:
			avg_round = float(week_round_sum[w]) / float(week_round_count[w])
		var min_round: float = week_target * float(cfg["avg_round_target_mult"]["min"])
		var max_round: float = week_target * float(cfg["avg_round_target_mult"]["max"])
		if avg_round < min_round or avg_round > max_round:
			_warn("%s avg round devotion outside band week %d: %.2f (target %.2f-%.2f)" % [
				profile,
				w + 1,
				avg_round,
				min_round,
				max_round,
			])

		var avg_blood_earned: float = float(week_blood_earned_sum[w]) / float(total_runs)
		var blood_band: Dictionary = blood_bands[w]
		if avg_blood_earned < float(blood_band["min"]) or avg_blood_earned > float(blood_band["max"]):
			_warn("%s avg blood earned outside band week %d: %.2f (target %.2f-%.2f)" % [
				profile,
				w + 1,
				avg_blood_earned,
				float(blood_band["min"]),
				float(blood_band["max"]),
			])

func _random_unique_indices(size: int, count: int, rng: RandomNumberGenerator) -> Array:
	var indices = []
	for i in range(size):
		indices.append(i)
	_shuffle_with_rng(indices, rng)
	var picks = []
	for i in range(min(count, indices.size())):
		picks.append(indices[i])
	return picks

func _shuffle_with_rng(values: Array, rng: RandomNumberGenerator) -> void:
	if values.size() < 2:
		return
	for i in range(values.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp = values[i]
		values[i] = values[j]
		values[j] = tmp

func _best_indices(gs: Node, required: int) -> Array:
	var size: int = gs.current_hand.size()
	if required <= 0 or size == 0:
		return []
	if required == 3:
		return _best_indices_3(gs, size)
	if required == 4:
		return _best_indices_4(gs, size)
	return _random_unique_indices(size, required, gs._rng)

func _best_indices_3(gs: Node, size: int) -> Array:
	var best: Array = []
	var best_score: int = -1
	var best_blood: int = -1
	for i in range(size - 2):
		for j in range(i + 1, size - 1):
			for k in range(j + 1, size):
				var combo = [i, j, k]
				var preview: Dictionary = gs.preview_selected(combo)
				var score: int = int(preview.get("final_devotion", 0))
				var blood: int = int(preview.get("blood_gain", 0))
				if score > best_score or (score == best_score and blood > best_blood):
					best_score = score
					best_blood = blood
					best = combo
	return best

func _best_indices_4(gs: Node, size: int) -> Array:
	var best: Array = []
	var best_score: int = -1
	var best_blood: int = -1
	for i in range(size - 3):
		for j in range(i + 1, size - 2):
			for k in range(j + 1, size - 1):
				for l in range(k + 1, size):
					var combo = [i, j, k, l]
					var preview: Dictionary = gs.preview_selected(combo)
					var score: int = int(preview.get("final_devotion", 0))
					var blood: int = int(preview.get("blood_gain", 0))
					if score > best_score or (score == best_score and blood > best_blood):
						best_score = score
						best_blood = blood
						best = combo
	return best

func _count_total_relics(gs: Node) -> int:
	var total := 0
	for k in gs.relic_inventory.keys():
		total += int(gs.relic_inventory[k])
	return total

func _simulate_on_week_clear_success(gs: Node, last_result: Dictionary) -> int:
	var blood_before: int = gs.blood_currency
	var bonus_cup: int = int(gs.relic_inventory.get("Ceremonial Cup", 0))
	var bonus_geo: int = int(gs.relic_inventory.get("Blasphemous Geometry", 0))
	var bonus_bowl: int = int(gs.relic_inventory.get("Brass Tithe Bowl", 0))
	var bonus_total: int = bonus_cup + (bonus_geo * 3) + bonus_bowl
	if bonus_total > 0:
		gs.add_blood(bonus_total)
	if int(gs.relic_inventory.get("The Red Covenant", 0)) > 0 and int(gs.red_covenant_active_week) == int(gs.current_week):
		gs.add_blood(30)
		gs.guaranteed_rare_next_shop = true
	if int(gs.relic_inventory.get("Ossuary Standards", 0)) > 0:
		var standards_bones: int = int(last_result.get("bone_count", 0))
		if standards_bones > 0:
			gs.ossuary_standards_bonus += standards_bones * int(gs.relic_inventory.get("Ossuary Standards", 0))
	if int(gs.relic_inventory.get("The Ossuary Engine", 0)) > 0 and int(last_result.get("bone_count", 0)) >= 2:
		gs.ossuary_engine_bonus += 2 * int(gs.relic_inventory.get("The Ossuary Engine", 0))
	if int(gs.relic_inventory.get("The Skeleton Archive", 0)) > 0 and not bool(gs.skeleton_archive_awarded_run) and int(gs.current_week) >= 5:
		var pool_counts: Dictionary = gs.pool_summary_counts()
		var bone_majority: bool = int(pool_counts.get("bone", 0)) >= int(pool_counts.get("blood", 0)) and int(pool_counts.get("bone", 0)) >= int(pool_counts.get("void", 0))
		if str(gs.selected_doctrine) == "RUIN" or bone_majority:
			gs.skeleton_archive_bonus += int(gs.relic_inventory.get("The Skeleton Archive", 0))
			gs.skeleton_archive_awarded_run = true
	return max(0, gs.blood_currency - blood_before)

func _sim_roll_offers(gs: Node, count: int, week: int, guarantee_rare_shop: bool = false) -> Array:
	var chosen: Array = []
	for i in range(count):
		var guarantee_slot: bool = guarantee_rare_shop and i == 0
		var rarity: String = gs.roll_shop_rarity(week, gs._rng, 0.0, 0.0, guarantee_slot)
		if int(gs.shop_rerolls_used) > 0 and int(gs.relic_inventory.get("The Faithful Scribe", 0)) > 0:
			rarity = _sim_raise_rarity_floor(rarity, int(gs.relic_inventory.get("The Faithful Scribe", 0)))
		var pick: String = _sim_pick_from_rarity(gs, rarity, chosen)
		if pick == "":
			pick = _sim_pick_from_rarity(gs, _sim_fallback_rarity(rarity), chosen)
		if pick != "":
			chosen.append(pick)
			if str(gs.RELIC_DEFS[pick].get("rarity", "")) == "LEGENDARY":
				gs.legendary_seen_in_shop = true
	return chosen

func _sim_raise_rarity_floor(rarity: String, steps: int) -> String:
	var order: Array[String] = ["COMMON", "UNCOMMON", "RARE", "LEGENDARY"]
	var idx: int = order.find(rarity)
	if idx < 0:
		idx = 0
	idx = min(order.size() - 1, idx + max(0, steps))
	return order[idx]

func _sim_pick_from_rarity(gs: Node, rarity: String, exclude: Array) -> String:
	var pool: Array = []
	for name in gs.RELICS:
		if exclude.has(name):
			continue
		if not gs.can_offer_relic(name):
			continue
		if str(gs.RELIC_DEFS[name].get("rarity", "")) == rarity:
			pool.append(name)
	if pool.is_empty():
		return ""
	_shuffle_with_rng(pool, gs._rng)
	return str(pool[0])

func _sim_fallback_rarity(rarity: String) -> String:
	if rarity == "RARE":
		return "UNCOMMON"
	if rarity == "UNCOMMON":
		return "COMMON"
	return "COMMON"

func _sim_offer_legendary_if_needed(gs: Node, offers: Array, week: int) -> Array:
	if bool(gs.legendary_seen_in_shop):
		return offers
	if week < 6:
		return offers
	for offer_name in offers:
		if str(offer_name) != "" and str(gs.RELIC_DEFS[str(offer_name)].get("rarity", "")) == "LEGENDARY":
			gs.legendary_seen_in_shop = true
			return offers
	var legendary_pick: String = _sim_pick_from_rarity(gs, "LEGENDARY", offers)
	if legendary_pick == "":
		return offers
	for i in range(offers.size()):
		if str(offers[i]) != "":
			offers[i] = legendary_pick
			gs.legendary_seen_in_shop = true
			break
	return offers

func _buy_best_relic_offers(gs: Node, offers: Array, week: int, run_relics: Dictionary, offers_seen: Dictionary) -> int:
	var blood_spent: int = 0
	var guard: int = 0
	var current_offers: Array = offers.duplicate()
	while not current_offers.is_empty() and guard < 24:
		guard += 1
		for offered in current_offers:
			var offered_name: String = str(offered)
			if offered_name != "":
				offers_seen[offered_name] = true
		var pick: String = _pick_rarest_relic(gs, current_offers)
		if pick == "":
			break
		var rarity: String = str(gs.RELIC_DEFS[pick].get("rarity", "COMMON"))
		var cost: int = gs.get_shop_cost(week, rarity)
		if not gs.can_afford_relic(cost):
			break
		var before_buy: int = gs.blood_currency
		gs.spend_blood_for_relic(cost)
		blood_spent += max(0, before_buy - gs.blood_currency)
		gs.add_relic(pick)
		run_relics[pick] = true
		if pick == "The Palimpsest":
			current_offers = _sim_roll_offers(gs, 3, week, false)
			current_offers = _sim_offer_legendary_if_needed(gs, current_offers, week)
			continue
		current_offers.erase(pick)
	return blood_spent

func _simulate_shop(gs: Node, week: int, run_relics: Dictionary, profile: String, max_weeks: int) -> Dictionary:
	var blood_spent: int = 0
	var offers_seen: Dictionary = {}
	gs.start_shop_visit()
	gs.shop_rerolls_used = 0
	gs.shop_cull_used = false
	gs.shop_copy_used = false
	if bool(gs.free_reroll_next_shop):
		gs.shop_free_reroll_available = true
		gs.free_reroll_next_shop = false
	gs.ritual_card_offer = ""
	if int(gs.relic_inventory.get("Spare Chalice", 0)) > 0 and gs.blood_currency == 0:
		gs.add_blood(2)
	var shop_entry_blood: int = gs.blood_currency

	if int(gs.relic_inventory.get("Director's Cut", 0)) > 0:
		var next_week: int = week + 1
		if next_week <= max_weeks:
			var use_chance: float = 0.65 if profile == "expert" else 0.30
			var max_uses: int = int(gs.get_directors_cut_max_uses())
			while int(gs.director_uses_this_shop) < max_uses and gs._rng.randf() < use_chance:
				var base_target: int = int(gs.get_week_target(next_week))
				var pct: float = float(gs.get_directors_cut_range_pct())
				var min_target: int = int(ceil(float(base_target) * (1.0 - pct)))
				var max_target: int = int(floor(float(base_target) * (1.0 + pct)))
				var rerolled: int = gs._rng.randi_range(min_target, max_target)
				rerolled = int(round(float(rerolled) / 5.0)) * 5
				rerolled = max(5, rerolled)
				gs.next_week_target_overrides[next_week] = rerolled
				gs.director_uses_this_shop += 1
				use_chance *= 0.5

	var offers: Array = _sim_roll_offers(gs, 3, week, bool(gs.guaranteed_rare_next_shop))
	gs.guaranteed_rare_next_shop = false
	offers = _sim_offer_legendary_if_needed(gs, offers, week)
	blood_spent += _buy_best_relic_offers(gs, offers, week, run_relics, offers_seen)

	if int(gs.relic_inventory.get("Scarlet Planetarium", 0)) > 0 and str(gs.ritual_card_slot) == "":
		if str(gs.ritual_card_offer) == "" and gs.RITUAL_CARDS.size() > 0:
			gs.ritual_card_offer = gs.RITUAL_CARDS[gs._rng.randi_range(0, gs.RITUAL_CARDS.size() - 1)]
		var ritual_buy_chance: float = 0.75 if profile == "expert" else 0.35
		if gs.blood_currency >= 2 and gs._rng.randf() < ritual_buy_chance and str(gs.ritual_card_offer) != "":
			gs.blood_currency -= 2
			blood_spent += 2
			gs.ritual_card_slot = gs.ritual_card_offer
			gs.ritual_card_offer = ""
			gs.shop_any_purchase_this_visit = true

	# One reroll per shop, cost 5 (free if chalk or free reroll available)
	if gs.shop_rerolls_used == 0:
		var reroll_cost: int = 5
		if gs.shop_rerolls_used == 0 and (int(gs.relic_inventory.get("Sharpened Chalk", 0)) > 0 or bool(gs.shop_free_reroll_available)):
			reroll_cost = 0
		if gs.blood_currency >= reroll_cost:
			if reroll_cost > 0:
				blood_spent += max(0, reroll_cost)
				gs.blood_currency -= reroll_cost
			if bool(gs.shop_free_reroll_available):
				gs.shop_free_reroll_available = false
			gs.shop_rerolls_used += 1
			var reroll_offers: Array = _sim_roll_offers(gs, 3, week, false)
			reroll_offers = _sim_offer_legendary_if_needed(gs, reroll_offers, week)
			blood_spent += _buy_best_relic_offers(gs, reroll_offers, week, run_relics, offers_seen)

	# Recruits: generate and buy randomly while blood remains
	gs.generate_shop_recruits()
	for i in range(gs.shop_recruit_offers.size()):
		if gs._rng.randf() < 0.5:
			var before_recruit: int = gs.blood_currency
			var recruit_result: Dictionary = gs.buy_shop_recruit(i)
			var after_recruit: int = gs.blood_currency
			if bool(recruit_result.get("ok", false)) and after_recruit < before_recruit:
				blood_spent += (before_recruit - after_recruit)

	# Shop-end effects (mirror Shop._finish_shop order).
	var interest_copies: int = int(gs.relic_inventory.get("Crimson Interest", 0)) + int(gs.tithe_accelerator_interest_bonus)
	var crimson_compound_copies: int = int(gs.relic_inventory.get("Crimson Compound", 0))
	var usurer_copies: int = int(gs.relic_inventory.get("Usurer's Mark", 0))
	if interest_copies > 0:
		var divisor: int = max(1, 5 - crimson_compound_copies)
		var fires: int = 1 + max(0, usurer_copies - 1)
		for _i in range(fires):
			var gain_i: int = int(floor(float(gs.blood_currency) / float(divisor))) * interest_copies
			if gain_i <= 0:
				continue
			gs.add_blood(gain_i)
	if int(gs.relic_inventory.get("The Waiting Bell", 0)) > 0 and not bool(gs.shop_any_purchase_this_visit):
		gs.add_blood(10)
	gs.finalize_shop_visit()
	gs.boost_pool_tiers_weekly()
	return {
		"blood_spent": blood_spent,
		"shop_entry_blood": shop_entry_blood,
		"offers_seen": offers_seen,
	}

func _simulate_nest_selection(gs: Node, profile: String) -> Dictionary:
	for i in range(gs.nests.size()):
		gs.clear_nest_slot(i, 0)
		gs.clear_nest_slot(i, 1)
		gs.set_nest_focus(i, "NONE")
	var candidates: Array = []
	for f in gs.pool:
		if str(f.get("trait", "")) == "SOUL":
			continue
		candidates.append(f)
	candidates.sort_custom(func(a, b):
		var tier_a: int = int(a.get("tier", 0))
		var tier_b: int = int(b.get("tier", 0))
		if tier_a != tier_b:
			return tier_a > tier_b
		var rarity_a: int = int(gs._rarity_rank(gs._trait_rarity(str(a.get("trait_id", ""))))
		)
		var rarity_b: int = int(gs._rarity_rank(gs._trait_rarity(str(b.get("trait_id", ""))))
		)
		if rarity_a != rarity_b:
			return rarity_a > rarity_b
		return int(a.get("id", 0)) < int(b.get("id", 0))
	)
	var target_nests: int = gs.nests.size()
	if profile != "expert":
		target_nests = int(ceil(float(gs.nests.size()) * 0.5))
		if gs._rng.randf() < 0.25:
			target_nests = 0
	var ptr: int = 0
	for nest_idx in range(target_nests):
		if ptr + 1 >= candidates.size():
			break
		var a_id: int = int(candidates[ptr].get("id", -1))
		var b_id: int = int(candidates[ptr + 1].get("id", -1))
		ptr += 2
		gs.assign_follower_to_nest(nest_idx, 0, a_id)
		gs.assign_follower_to_nest(nest_idx, 1, b_id)
	var active_nests: int = 0
	for entry in gs.nests:
		if int(entry.get("a", -1)) >= 0 and int(entry.get("b", -1)) >= 0:
			active_nests += 1
	var focus_blood_spent: int = 0
	for nest_idx in range(gs.nests.size()):
		var preview: Dictionary = gs.get_nest_preview(nest_idx)
		if not bool(preview.get("can_breed", false)):
			continue
		var desired_focus: String = "NONE"
		var cost_rarity: int = int(preview.get("focus_cost_rarity", 0))
		var cost_tier: int = int(preview.get("focus_cost_tier", 0))
		var cost_family: int = int(preview.get("focus_cost_family", 0))
		if profile == "expert":
			var combo_eligible: bool = bool(preview.get("combo_eligible", false))
			var expected_tier: float = float(preview.get("expected_tier", 0.0))
			var odds: Dictionary = preview.get("rarity_odds", {})
			var rare_plus: float = float(odds.get("rare", 0.0)) + float(odds.get("legendary", 0.0))
			if combo_eligible and gs.blood_currency >= cost_family:
				desired_focus = "FAMILY"
			elif expected_tier < 4.0 and gs.blood_currency >= cost_tier:
				desired_focus = "TIER"
			elif rare_plus < 0.45 and gs.blood_currency >= cost_rarity:
				desired_focus = "RARITY"
		else:
			if gs._rng.randf() < 0.30:
					if bool(preview.get("combo_eligible", false)) and gs.blood_currency >= cost_family:
						desired_focus = "FAMILY"
					elif float(preview.get("expected_tier", 0.0)) < 3.5 and gs.blood_currency >= cost_tier:
						desired_focus = "TIER"
					elif gs.blood_currency >= cost_rarity and gs._rng.randf() < 0.5:
						desired_focus = "RARITY"
		var projected_total: int = int(gs.get_nest_focus_total_cost_with(nest_idx, desired_focus))
		if projected_total <= gs.blood_currency:
			gs.set_nest_focus(nest_idx, desired_focus)
		else:
			gs.set_nest_focus(nest_idx, "NONE")
	var blood_before_commit: int = gs.blood_currency
	var commit_result: Dictionary = gs.commit_nest_focus_costs()
	if bool(commit_result.get("ok", false)):
		focus_blood_spent = max(0, blood_before_commit - gs.blood_currency)
	else:
		for i in range(gs.nests.size()):
			gs.set_nest_focus(i, "NONE")
		var fallback_commit: Dictionary = gs.commit_nest_focus_costs()
		if not bool(fallback_commit.get("ok", false)):
			_fail("Deferred nest focus commit failed in sim fallback.")
	return {"active_nests": active_nests, "total_nests": gs.nests.size(), "focus_blood_spent": focus_blood_spent}

func _simulate_weekly_breeding(gs: Node, week: int) -> Dictionary:
	var active_nests: int = 0
	for entry in gs.nests:
		if int(entry.get("a", -1)) >= 0 and int(entry.get("b", -1)) >= 0:
			active_nests += 1
	var expected_nest_newborns: float = 0.0
	var expected_nest_tier_sum: float = 0.0
	var expected_nest_common: float = 0.0
	var expected_nest_rare: float = 0.0
	var expected_nest_legendary: float = 0.0
	for nest_idx in range(gs.nests.size()):
		var preview: Dictionary = gs.get_nest_preview(nest_idx)
		if not bool(preview.get("can_breed", false)):
			continue
		var expected_count: float = float(preview.get("expected_newborns", 0.0))
		var expected_tier: float = float(preview.get("expected_tier", 0.0))
		var odds: Dictionary = preview.get("rarity_odds", {})
		expected_nest_newborns += expected_count
		expected_nest_tier_sum += expected_count * expected_tier
		expected_nest_common += expected_count * float(odds.get("common", 0.0))
		expected_nest_rare += expected_count * float(odds.get("rare", 0.0))
		expected_nest_legendary += expected_count * float(odds.get("legendary", 0.0))
	var before_ids: Dictionary = {}
	for f in gs.pool:
		before_ids[int(f.get("id", -1))] = true
	gs.perform_weekly_breeding(week)
	var nest_newborns: int = 0
	var wild_newborns: int = 0
	var newborn_tier_sum: int = 0
	var newborn_count: int = 0
	var common: int = 0
	var rare: int = 0
	var legendary: int = 0
	var none: int = 0
	var actual_nest_tier_sum: int = 0
	var actual_nest_count: int = 0
	var actual_nest_common: int = 0
	var actual_nest_rare: int = 0
	var actual_nest_legendary: int = 0
	var actual_nest_none: int = 0
	for f in gs.pool:
		var fid: int = int(f.get("id", -1))
		if before_ids.has(fid):
			continue
		newborn_count += 1
		newborn_tier_sum += int(f.get("tier", 0))
		var origin: String = str(f.get("origin_tag", ""))
		if origin == "nest_bred":
			nest_newborns += 1
			actual_nest_count += 1
			actual_nest_tier_sum += int(f.get("tier", 0))
		elif origin == "wild_bred":
			wild_newborns += 1
		var rarity: String = gs._trait_rarity(str(f.get("trait_id", "")))
		if rarity == "COMMON":
			common += 1
			if origin == "nest_bred":
				actual_nest_common += 1
		elif rarity == "RARE":
			rare += 1
			if origin == "nest_bred":
				actual_nest_rare += 1
		elif rarity == "LEGENDARY":
			legendary += 1
			if origin == "nest_bred":
				actual_nest_legendary += 1
		else:
			none += 1
			if origin == "nest_bred":
				actual_nest_none += 1
	return {
		"active_nests": active_nests,
		"total_nests": gs.nests.size(),
		"focus_blood_spent": 0,
		"nest_newborns": nest_newborns,
		"wild_newborns": wild_newborns,
		"newborn_tier_sum": newborn_tier_sum,
		"newborn_count": newborn_count,
		"common": common,
		"rare": rare,
		"legendary": legendary,
		"none": none,
		"expected_nest_newborns": expected_nest_newborns,
		"expected_nest_tier_sum": expected_nest_tier_sum,
		"expected_nest_common": expected_nest_common,
		"expected_nest_rare": expected_nest_rare,
		"expected_nest_legendary": expected_nest_legendary,
		"actual_nest_tier_sum": actual_nest_tier_sum,
		"actual_nest_count": actual_nest_count,
		"actual_nest_common": actual_nest_common,
		"actual_nest_rare": actual_nest_rare,
		"actual_nest_legendary": actual_nest_legendary,
		"actual_nest_none": actual_nest_none,
	}

func _log_phase1_rankings(expert_result: Dictionary) -> void:
	var relic_rows: Array = expert_result.get("relic_rows", [])
	var trait_rows: Array = expert_result.get("trait_rows", [])
	if relic_rows.is_empty() and trait_rows.is_empty():
		return
	_log("")
	_log("=== Phase1 Power-Feel Summary (Expert) ===")
	if not relic_rows.is_empty():
		var weak_relics: Array = relic_rows.duplicate()
		weak_relics.sort_custom(func(a, b):
			if float(a.get("avg_score_delta", 0.0)) == float(b.get("avg_score_delta", 0.0)):
				return float(a.get("pick_rate", 0.0)) < float(b.get("pick_rate", 0.0))
			return float(a.get("avg_score_delta", 0.0)) < float(b.get("avg_score_delta", 0.0))
		)
		_log("Weakest relics (by marginal score delta):")
		for i in range(min(PHASE1_TOP_BOTTOM_COUNT, weak_relics.size())):
			var r: Dictionary = weak_relics[i]
			_log("- %s | Delta %+0.2f | PickRate %.1f%% | AvgWeek %.2f" % [
				str(r.get("name", "")),
				float(r.get("avg_score_delta", 0.0)),
				float(r.get("pick_rate", 0.0)) * 100.0,
				float(r.get("avg_week", 0.0)),
			])
	if not trait_rows.is_empty():
		var weak_traits: Array = trait_rows.duplicate()
		weak_traits.sort_custom(func(a, b):
			if float(a.get("avg_score_delta", 0.0)) == float(b.get("avg_score_delta", 0.0)):
				return float(a.get("appearance_rate", 0.0)) < float(b.get("appearance_rate", 0.0))
			return float(a.get("avg_score_delta", 0.0)) < float(b.get("avg_score_delta", 0.0))
		)
		_log("Weakest traits (by marginal score delta):")
		for i in range(min(PHASE1_TOP_BOTTOM_COUNT, weak_traits.size())):
			var t: Dictionary = weak_traits[i]
			_log("- %s | Delta %+0.2f | SeenInRuns %.1f%% | AvgWeek %.2f" % [
				str(t.get("name", "")),
				float(t.get("avg_score_delta", 0.0)),
				float(t.get("appearance_rate", 0.0)) * 100.0,
				float(t.get("avg_week", 0.0)),
			])

func _csv_join(values: Array) -> String:
	var out: PackedStringArray = PackedStringArray()
	for v in values:
		out.append(str(v))
	return ",".join(out)

func _write_sim_csv(max_weeks: int, target_values: Array[int], profile_results: Array) -> void:
	var date_str = Time.get_datetime_string_from_system().replace(":", "-")
	var dir_path = "res://docs/test_reports"
	var abs_dir = ProjectSettings.globalize_path(dir_path)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var file_path = dir_path + "/sim_metrics_" + date_str + ".csv"
	var f = FileAccess.open(file_path, FileAccess.WRITE)
	if f == null:
		_log("WARN: Failed to write CSV to " + file_path)
		return
	f.store_line("section,profile,doctrine,week,target,pass_rate,avg_round,avg_week,avg_overflow,avg_early,avg_blood_earned,avg_blood_spent,avg_pool,avg_week_target_min,avg_week_target_max,pass_rate_min,pass_rate_max,relic,avg_week_relic,avg_score_relic,runs_with_relic,runs,total_devotion,total_weeks_played,avg_score_per_week,blood_gained,blood_spent,count,trait_trigger_rate,avg_trait_additive_round,avg_trait_blood_round,nest_usage_rate,avg_nest_newborns,avg_wild_newborns,avg_newborn_tier,newborn_common_share,newborn_rare_share,newborn_legendary_share,newborn_none_share,pick_rate,marginal_score_delta,expected_nest_newborns,expected_nest_tier,expected_nest_rare_share,actual_nest_tier,actual_nest_rare_share,nest_tier_delta,nest_rare_delta,pass_with_nesting,pass_without_nesting,pass_delta,avg_end_week_with_nesting,avg_end_week_without_nesting,end_week_delta")
	var total_runs: int = RUNS_PER_DOCTRINE * _get_active_doctrines().size()
	for result in profile_results:
		var profile: String = str(result.get("profile", ""))
		if not BALANCE_TARGETS.has(profile):
			continue
		var cfg: Dictionary = BALANCE_TARGETS[profile]
		var pass_rate_bands: Array = _build_linear_bands(
			max_weeks,
			float(cfg["pass_rate_start"]["min"]),
			float(cfg["pass_rate_start"]["max"]),
			float(cfg["pass_rate_end"]["min"]),
			float(cfg["pass_rate_end"]["max"])
		)
		var week_passes: Array = result["week_passes"]
		var week_round_sum: Array = result["week_round_sum"]
		var week_round_count: Array = result["week_round_count"]
		var week_total_sum: Array = result["week_total_sum"]
		var week_overflow_sum: Array = result["week_overflow_sum"]
		var week_early_sum: Array = result["week_early_sum"]
		var week_blood_earned_sum: Array = result["week_blood_earned_sum"]
		var week_blood_spent_sum: Array = result["week_blood_spent_sum"]
		var week_pool_size_sum: Array = result["week_pool_size_sum"]
		var week_pool_size_count: Array = result["week_pool_size_count"]
		var week_trait_trigger_rounds: Array = result["week_trait_trigger_rounds"]
		var week_trait_round_count: Array = result["week_trait_round_count"]
		var week_trait_additive_sum: Array = result["week_trait_additive_sum"]
		var week_trait_blood_sum: Array = result["week_trait_blood_sum"]
		var week_nest_active_sum: Array = result["week_nest_active_sum"]
		var week_nest_total_sum: Array = result["week_nest_total_sum"]
		var week_nest_newborn_sum: Array = result["week_nest_newborn_sum"]
		var week_wild_newborn_sum: Array = result["week_wild_newborn_sum"]
		var week_newborn_tier_sum: Array = result["week_newborn_tier_sum"]
		var week_newborn_count: Array = result["week_newborn_count"]
		var week_newborn_common_sum: Array = result["week_newborn_common_sum"]
		var week_newborn_rare_sum: Array = result["week_newborn_rare_sum"]
		var week_newborn_legendary_sum: Array = result["week_newborn_legendary_sum"]
		var week_newborn_none_sum: Array = result["week_newborn_none_sum"]
		var week_expected_nest_newborn_sum: Array = result["week_expected_nest_newborn_sum"]
		var week_expected_nest_tier_sum: Array = result["week_expected_nest_tier_sum"]
		var week_expected_nest_rare_sum: Array = result["week_expected_nest_rare_sum"]
		var week_actual_nest_tier_sum: Array = result["week_actual_nest_tier_sum"]
		var week_actual_nest_count: Array = result["week_actual_nest_count"]
		var week_actual_nest_rare_sum: Array = result["week_actual_nest_rare_sum"]
		var breeding_contrib: Dictionary = result.get("breeding_contrib", {})
		for w in range(max_weeks):
			var pass_rate: float = float(week_passes[w]) / float(total_runs)
			var avg_round: float = 0.0
			if int(week_round_count[w]) > 0:
				avg_round = float(week_round_sum[w]) / float(week_round_count[w])
			var avg_week: float = float(week_total_sum[w]) / float(total_runs)
			var avg_overflow: float = float(week_overflow_sum[w]) / float(total_runs)
			var avg_early: float = float(week_early_sum[w]) / float(total_runs)
			var avg_blood_earned: float = float(week_blood_earned_sum[w]) / float(total_runs)
			var avg_blood_spent: float = float(week_blood_spent_sum[w]) / float(total_runs)
			var avg_pool: float = 0.0
			if int(week_pool_size_count[w]) > 0:
				avg_pool = float(week_pool_size_sum[w]) / float(week_pool_size_count[w])
			var trait_trigger_rate: float = 0.0
			var avg_trait_additive_round: float = 0.0
			var avg_trait_blood_round: float = 0.0
			if int(week_trait_round_count[w]) > 0:
				trait_trigger_rate = float(week_trait_trigger_rounds[w]) / float(week_trait_round_count[w])
				avg_trait_additive_round = float(week_trait_additive_sum[w]) / float(week_trait_round_count[w])
				avg_trait_blood_round = float(week_trait_blood_sum[w]) / float(week_trait_round_count[w])
			var nest_usage_rate: float = 0.0
			if int(week_nest_total_sum[w]) > 0:
				nest_usage_rate = float(week_nest_active_sum[w]) / float(week_nest_total_sum[w])
			var avg_nest_newborns: float = float(week_nest_newborn_sum[w]) / float(total_runs)
			var avg_wild_newborns: float = float(week_wild_newborn_sum[w]) / float(total_runs)
			var avg_newborn_tier: float = 0.0
			var newborn_common_share: float = 0.0
			var newborn_rare_share: float = 0.0
			var newborn_legendary_share: float = 0.0
			var newborn_none_share: float = 0.0
			if int(week_newborn_count[w]) > 0:
				avg_newborn_tier = float(week_newborn_tier_sum[w]) / float(week_newborn_count[w])
				newborn_common_share = float(week_newborn_common_sum[w]) / float(week_newborn_count[w])
				newborn_rare_share = float(week_newborn_rare_sum[w]) / float(week_newborn_count[w])
				newborn_legendary_share = float(week_newborn_legendary_sum[w]) / float(week_newborn_count[w])
				newborn_none_share = float(week_newborn_none_sum[w]) / float(week_newborn_count[w])
			var expected_nest_newborns: float = float(week_expected_nest_newborn_sum[w]) / float(total_runs)
			var expected_nest_tier: float = 0.0
			var expected_nest_rare_share: float = 0.0
			if float(week_expected_nest_newborn_sum[w]) > 0.0:
				expected_nest_tier = float(week_expected_nest_tier_sum[w]) / float(week_expected_nest_newborn_sum[w])
				expected_nest_rare_share = float(week_expected_nest_rare_sum[w]) / float(week_expected_nest_newborn_sum[w])
			var actual_nest_tier: float = 0.0
			var actual_nest_rare_share: float = 0.0
			if int(week_actual_nest_count[w]) > 0:
				actual_nest_tier = float(week_actual_nest_tier_sum[w]) / float(week_actual_nest_count[w])
				actual_nest_rare_share = float(week_actual_nest_rare_sum[w]) / float(week_actual_nest_count[w])
			var week_target: float = float(target_values[w])
			var min_week: float = week_target * float(cfg["avg_week_target_mult"]["min"])
			var max_week: float = week_target * float(cfg["avg_week_target_mult"]["max"])
			var pass_band: Dictionary = pass_rate_bands[w]
			f.store_line(_csv_join([
				"week_metrics", profile, "", w + 1, int(week_target),
				"%.4f" % pass_rate, "%.2f" % avg_round, "%.2f" % avg_week, "%.2f" % avg_overflow, "%.2f" % avg_early,
				"%.2f" % avg_blood_earned, "%.2f" % avg_blood_spent, "%.2f" % avg_pool,
				"%.2f" % min_week, "%.2f" % max_week, "%.4f" % float(pass_band["min"]), "%.4f" % float(pass_band["max"]),
				"", "", "", "", "", "", "", "", "", "", "",
				"%.4f" % trait_trigger_rate, "%.2f" % avg_trait_additive_round, "%.2f" % avg_trait_blood_round,
				"%.4f" % nest_usage_rate, "%.2f" % avg_nest_newborns, "%.2f" % avg_wild_newborns, "%.2f" % avg_newborn_tier,
				"%.4f" % newborn_common_share, "%.4f" % newborn_rare_share, "%.4f" % newborn_legendary_share, "%.4f" % newborn_none_share,
				"", "",
				"%.2f" % expected_nest_newborns,
				"%.2f" % expected_nest_tier,
				"%.4f" % expected_nest_rare_share,
				"%.2f" % actual_nest_tier,
				"%.4f" % actual_nest_rare_share,
				"%.2f" % (actual_nest_tier - expected_nest_tier),
				"%.4f" % (actual_nest_rare_share - expected_nest_rare_share),
				"%.4f" % float(breeding_contrib.get("pass_with_nesting", 0.0)),
				"%.4f" % float(breeding_contrib.get("pass_without_nesting", 0.0)),
				"%.4f" % float(breeding_contrib.get("pass_delta", 0.0)),
				"%.2f" % float(breeding_contrib.get("avg_end_week_with_nesting", 0.0)),
				"%.2f" % float(breeding_contrib.get("avg_end_week_without_nesting", 0.0)),
				"%.2f" % float(breeding_contrib.get("end_week_delta", 0.0)),
			]))

		var doctrine_summary: Dictionary = result["doctrine_summary"]
		var doctrine_week_reached: Dictionary = result["doctrine_week_reached"]
		var doctrine_blood_gained: Dictionary = result["doctrine_blood_gained"]
		var doctrine_blood_spent: Dictionary = result["doctrine_blood_spent"]
		for doctrine in doctrine_summary.keys():
			var summary = doctrine_summary[doctrine]
			var runs: int = int(summary["runs"])
			var total_devotion: int = int(summary["total_devotion"])
			var total_weeks: int = int(summary["total_weeks_played"])
			var avg_score: float = 0.0
			if total_weeks > 0:
				avg_score = float(total_devotion) / float(total_weeks)
			var gained: int = int(doctrine_blood_gained[doctrine])
			var spent: int = int(doctrine_blood_spent[doctrine])
			f.store_line(_csv_join([
				"doctrine_summary", profile, doctrine, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
				"", "", "", runs, total_devotion, total_weeks, "%.2f" % avg_score, gained, spent, "",
				"", "", "", "", "", "", "", "", "", "", "", "", "",
			]))
			var reached = doctrine_week_reached[doctrine]
			for w in range(1, max_weeks + 1):
				var count: int = int(reached.get(w, 0))
				f.store_line(_csv_join([
					"week_reached", profile, doctrine, w, "", "", "", "", "", "", "", "", "", "", "", "", "", "",
					"", "", "", "", "", "", "", "", "", count,
					"", "", "", "", "", "", "", "", "", "", "", "", "",
				]))
		f.store_line(_csv_join([
			"breeding_contrib", profile, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
			"", "", "", "", "", "", "", "", "", "",
			"", "", "", "", "", "", "", "", "", "", "", "", "",
			"", "", "", "", "", "", "",
			"%.4f" % float(breeding_contrib.get("pass_with_nesting", 0.0)),
			"%.4f" % float(breeding_contrib.get("pass_without_nesting", 0.0)),
			"%.4f" % float(breeding_contrib.get("pass_delta", 0.0)),
			"%.2f" % float(breeding_contrib.get("avg_end_week_with_nesting", 0.0)),
			"%.2f" % float(breeding_contrib.get("avg_end_week_without_nesting", 0.0)),
			"%.2f" % float(breeding_contrib.get("end_week_delta", 0.0)),
		]))
		var relic_rows: Array = result.get("relic_rows", [])
		for r in relic_rows:
			f.store_line(_csv_join([
				"relic_impact", profile, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
				r.get("name", ""), "%.2f" % float(r.get("avg_week", 0.0)), "%.2f" % float(r.get("avg_score", 0.0)),
				int(r.get("count", 0)), "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
				"%.4f" % float(r.get("pick_rate", 0.0)), "%.2f" % float(r.get("avg_score_delta", 0.0)),
			]))
		var trait_rows: Array = result.get("trait_rows", [])
		for t in trait_rows:
			f.store_line(_csv_join([
				"trait_impact", profile, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
				t.get("name", ""), "%.2f" % float(t.get("avg_week", 0.0)), "%.2f" % float(t.get("avg_score", 0.0)),
				int(t.get("count", 0)), "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
				"%.4f" % float(t.get("appearance_rate", 0.0)), "%.2f" % float(t.get("avg_score_delta", 0.0)),
			]))
	f.close()

func _pick_rarest_relic(gs: Node, offers: Array) -> String:
	var best: String = ""
	var best_rank: int = -1
	for name in offers:
		if not gs.RELIC_DEFS.has(name):
			continue
		var rarity: String = str(gs.RELIC_DEFS[name].get("rarity", ""))
		var rank: int = _rarity_rank(rarity)
		if rank > best_rank:
			best_rank = rank
			best = name
	if best == "" and offers.size() > 0:
		return str(offers[0])
	return best

func _rarity_rank(rarity: String) -> int:
	match rarity:
		"LEGENDARY":
			return 4
		"RARE":
			return 3
		"UNCOMMON":
			return 2
		"COMMON":
			return 1
		_:
			return 0

func test_relic_scoring_exhaustive() -> void:
	var scoring = [
		"Ritual Knife",
		"Bone Idol",
		"Crimson Book",
		"Hollow Chant",
		"Sacrificial Order",
		"Quick Chant",
		"Ossuary Standard",
		"Bone Polisher",
		"Calcify",
		"Void Prism",
		"Black Candle",
		"The Third Knife",
		"Balanced Offering",
		"Prayer Beads",
		"Wax Seal",
		"Choir Robes",
		"Ossuary Standards",
		"Hollow Abacus",
		"Triune Reliquary",
		"Bloodright Almanac",
		"Cold Incense",
		"Ectoplasm Jar",
	]
	var gs = _fresh_gs()
	var hand = _make_exhaustive_hand(gs)
	_set_hand(gs, hand)

	var n = hand.size()
	for relic in scoring:
		for k in gs.relic_inventory.keys():
			gs.relic_inventory[k] = 0
		gs.relic_inventory[relic] = 1
		for i in range(n - 2):
			for j in range(i + 1, n - 1):
				for k in range(j + 1, n):
					var combo = [i, j, k]
					for rk in gs.relic_inventory.keys():
						gs.relic_inventory[rk] = 0
					var base = int(_score(gs, combo).get("final_devotion", 0))
					gs.relic_inventory[relic] = 1
					var with_relic = int(_score(gs, combo).get("final_devotion", 0))
					_assert_true(with_relic >= base, "Scoring relic reduced devotion: %s" % relic)
					# Stronger assertions for pure additive triggers
					if relic == "Prayer Beads":
						var t0 = str(hand[i]["trait"])
						var t1 = str(hand[j]["trait"])
						var t2 = str(hand[k]["trait"])
						if t0 == t1 and t1 == t2:
							_assert_true(with_relic > base, "Prayer Beads should add devotion when all traits match")
					elif relic == "Wax Seal":
						var tiers = {}
						var t_a = int(hand[i]["tier"])
						var t_b = int(hand[j]["tier"])
						var t_c = int(hand[k]["tier"])
						tiers[t_a] = int(tiers.get(t_a, 0)) + 1
						tiers[t_b] = int(tiers.get(t_b, 0)) + 1
						tiers[t_c] = int(tiers.get(t_c, 0)) + 1
						var has_pair := false
						for key in tiers.keys():
							if int(tiers[key]) >= 2:
								has_pair = true
								break
						if has_pair:
							_assert_true(with_relic > base, "Wax Seal should add devotion when any pair exists")
					elif relic == "Choir Robes":
						var t_a2 = int(hand[i]["tier"])
						var t_b2 = int(hand[j]["tier"])
						var t_c2 = int(hand[k]["tier"])
						if t_a2 != t_b2 and t_a2 != t_c2 and t_b2 != t_c2:
							_assert_true(with_relic > base, "Choir Robes should add devotion for all different tiers")
					elif relic == "Triune Reliquary":
						var has_blood := false
						var has_bone := false
						var has_void := false
						for idx in combo:
							var tr = str(hand[idx]["trait"])
							if tr == "BLOOD":
								has_blood = true
							elif tr == "BONE":
								has_bone = true
							else:
								has_void = true
						if has_blood and has_bone and has_void:
							_assert_true(with_relic > base, "Triune Reliquary should add devotion for BLOOD+BONE+VOID")
					elif relic == "Ossuary Standard":
						var bone_count := 0
						if str(hand[i]["trait"]) == "BONE":
							bone_count += 1
						if str(hand[j]["trait"]) == "BONE":
							bone_count += 1
						if str(hand[k]["trait"]) == "BONE":
							bone_count += 1
						if bone_count >= 2:
							_assert_true(with_relic > base, "Ossuary Standard should add devotion with 2+ BONE")
					elif relic == "Crimson Book":
						if str(hand[i]["trait"]) == "BLOOD" or str(hand[j]["trait"]) == "BLOOD" or str(hand[k]["trait"]) == "BLOOD":
							_assert_true(with_relic > base, "Crimson Book should add devotion with any BLOOD")
					elif relic == "Bone Idol" or relic == "Calcify" or relic == "Bone Polisher":
						if str(hand[i]["trait"]) == "BONE" or str(hand[j]["trait"]) == "BONE" or str(hand[k]["trait"]) == "BONE":
							_assert_true(with_relic > base, "%s should add devotion with any BONE" % relic)
					elif relic == "Quick Chant":
						_assert_true(with_relic >= base, "Quick Chant should never reduce devotion")
					elif relic == "Sacrificial Order":
						if base > 0:
							_assert_true(with_relic > base, "Sacrificial Order should add devotion on 3 sacrifices")

func test_relic_special_counts() -> void:
	var gs = _fresh_gs()
	var hand = _make_exhaustive_hand(gs)
	_set_hand(gs, hand)

	# Thin Blade: 1 sacrifice only
	for k in gs.relic_inventory.keys():
		gs.relic_inventory[k] = 0
	var base1 = int(_score(gs, [0]).get("final_devotion", 0))
	gs.relic_inventory["Thin Blade"] = 1
	var with1 = int(_score(gs, [0]).get("final_devotion", 0))
	_assert_true(with1 > base1, "Thin Blade should apply on 1 sacrifice")

	# Ritual Symmetry: even-numbered sacrifices (2 or 4)
	for k in gs.relic_inventory.keys():
		gs.relic_inventory[k] = 0
	var base2 = int(_score(gs, [0, 1]).get("final_devotion", 0))
	gs.relic_inventory["Ritual Symmetry"] = 1
	var with2 = int(_score(gs, [0, 1]).get("final_devotion", 0))
	_assert_true(with2 > base2, "Ritual Symmetry should apply on 2 sacrifices")

func test_relic_non_scoring_exhaustive() -> void:
	var non_scoring = [
		"Ceremonial Cup",
		"Blood Abacus",
		"Tithe Discount",
		"Crimson Interest",
		"Blasphemous Geometry",
		"Brass Tithe Bowl",
		"Sharpened Chalk",
		"Bone Saw",
		"Red Thread",
		"Grave Ledger",
		"Culling Knife",
		"Salt Circle",
		"Spare Chalice",
		"Blood Market Stall",
		"Debt Scripture",
		"Votive Mirror",
		"Fertility Idol",
		"Selective Breeding Scroll",
		"Clean Hands",
		"Black Contract",
		"Omen Deck",
		"Director's Cut",
		"Scarlet Planetarium",
		"Seal of Inheritance",
		"The Soul Lantern",
		"First Apostle",
	]
	var gs = _fresh_gs()
	var hand = _make_exhaustive_hand(gs)
	_set_hand(gs, hand)
	var n = hand.size()
	for relic in non_scoring:
		for k in gs.relic_inventory.keys():
			gs.relic_inventory[k] = 0
		gs.relic_inventory[relic] = 1
		for i in range(n - 2):
			for j in range(i + 1, n - 1):
				for k in range(j + 1, n):
					var combo = [i, j, k]
					for rk in gs.relic_inventory.keys():
						gs.relic_inventory[rk] = 0
					var base = int(_score(gs, combo).get("final_devotion", 0))
					gs.relic_inventory[relic] = 1
					var with_relic = int(_score(gs, combo).get("final_devotion", 0))
					_assert_eq(with_relic, base, "Non-scoring relic changed devotion unexpectedly: %s" % relic)

func test_exactly_three_conditions() -> void:
	var gs = _fresh_gs()
	# Sacrificial Order: any 3 sacrifices
	var hand = [
		gs._make_specific_follower("BLOOD", 1, "test"),
		gs._make_specific_follower("BONE", 1, "test"),
		gs._make_specific_follower("BLOOD", 2, "test"),
		gs._make_specific_follower("VOID", 1, "test"),
	]
	_set_hand(gs, hand)
	var combo3 = [0, 1, 2]
	var combo4 = [0, 1, 2, 3]
	for k in gs.relic_inventory.keys():
		gs.relic_inventory[k] = 0
	var base3 = int(_score(gs, combo3).get("final_devotion", 0))
	var base4 = int(_score(gs, combo4).get("final_devotion", 0))
	gs.relic_inventory["Sacrificial Order"] = 1
	var with3 = int(_score(gs, combo3).get("final_devotion", 0))
	var with4 = int(_score(gs, combo4).get("final_devotion", 0))
	_assert_true(with3 > base3, "Sacrificial Order should apply on 3 sacrifices")
	_assert_eq(with4, base4, "Sacrificial Order should not apply on 4 sacrifices")

	# Prayer Beads: all same trait
	gs = _fresh_gs()
	hand = [
		gs._make_specific_follower("BLOOD", 1, "test"),
		gs._make_specific_follower("BLOOD", 2, "test"),
		gs._make_specific_follower("BLOOD", 3, "test"),
		gs._make_specific_follower("BONE", 1, "test"),
	]
	_set_hand(gs, hand)
	combo3 = [0, 1, 2]
	combo4 = [0, 1, 2, 3]
	for k in gs.relic_inventory.keys():
		gs.relic_inventory[k] = 0
	base3 = int(_score(gs, combo3).get("final_devotion", 0))
	base4 = int(_score(gs, combo4).get("final_devotion", 0))
	gs.relic_inventory["Prayer Beads"] = 1
	with3 = int(_score(gs, combo3).get("final_devotion", 0))
	with4 = int(_score(gs, combo4).get("final_devotion", 0))
	_assert_true(with3 > base3, "Prayer Beads should apply on 3 sacrifices")
	_assert_eq(with4, base4, "Prayer Beads should not apply on 4 sacrifices")

	# Choir Robes: all different tiers
	gs = _fresh_gs()
	hand = [
		gs._make_specific_follower("BLOOD", 1, "test"),
		gs._make_specific_follower("BONE", 2, "test"),
		gs._make_specific_follower("BLOOD", 3, "test"),
		gs._make_specific_follower("BONE", 3, "test"),
	]
	_set_hand(gs, hand)
	combo3 = [0, 1, 2]
	combo4 = [0, 1, 2, 3]
	for k in gs.relic_inventory.keys():
		gs.relic_inventory[k] = 0
	base3 = int(_score(gs, combo3).get("final_devotion", 0))
	base4 = int(_score(gs, combo4).get("final_devotion", 0))
	gs.relic_inventory["Choir Robes"] = 1
	with3 = int(_score(gs, combo3).get("final_devotion", 0))
	with4 = int(_score(gs, combo4).get("final_devotion", 0))
	_assert_true(with3 > base3, "Choir Robes should apply on 3 sacrifices")
	_assert_eq(with4, base4, "Choir Robes should not apply on 4 sacrifices")

	# Triune Reliquary: BLOOD + BONE + VOID
	gs = _fresh_gs()
	hand = [
		gs._make_specific_follower("BLOOD", 1, "test"),
		gs._make_specific_follower("BONE", 1, "test"),
		gs._make_specific_follower("VOID", 1, "test"),
		gs._make_specific_follower("BLOOD", 2, "test"),
	]
	_set_hand(gs, hand)
	combo3 = [0, 1, 2]
	combo4 = [0, 1, 2, 3]
	for k in gs.relic_inventory.keys():
		gs.relic_inventory[k] = 0
	base3 = int(_score(gs, combo3).get("final_devotion", 0))
	base4 = int(_score(gs, combo4).get("final_devotion", 0))
	gs.relic_inventory["Triune Reliquary"] = 1
	with3 = int(_score(gs, combo3).get("final_devotion", 0))
	with4 = int(_score(gs, combo4).get("final_devotion", 0))
	_assert_true(with3 > base3, "Triune Reliquary should apply on 3 sacrifices")
	_assert_eq(with4, base4, "Triune Reliquary should not apply on 4 sacrifices")

	# Bloodright Almanac: Blood Straight
	gs = _fresh_gs()
	hand = [
		gs._make_specific_follower("BLOOD", 1, "test"),
		gs._make_specific_follower("BLOOD", 2, "test"),
		gs._make_specific_follower("BLOOD", 3, "test"),
		gs._make_specific_follower("BONE", 1, "test"),
	]
	_set_hand(gs, hand)
	combo3 = [0, 1, 2]
	combo4 = [0, 1, 2, 3]
	for k in gs.relic_inventory.keys():
		gs.relic_inventory[k] = 0
	base3 = int(_score(gs, combo3).get("final_devotion", 0))
	base4 = int(_score(gs, combo4).get("final_devotion", 0))
	gs.relic_inventory["Bloodright Almanac"] = 1
	with3 = int(_score(gs, combo3).get("final_devotion", 0))
	with4 = int(_score(gs, combo4).get("final_devotion", 0))
	_assert_true(with3 > base3, "Bloodright Almanac should apply on 3 sacrifices")
	_assert_eq(with4, base4, "Bloodright Almanac should not apply on 4 sacrifices")

func test_trait_effects() -> void:
	var gs = _fresh_gs()
	var hand: Array = [
		gs._make_specific_follower("BLOOD", 2, "test"),
		gs._make_specific_follower("BONE", 2, "test"),
		gs._make_specific_follower("BLOOD", 1, "test"),
	]
	_set_hand(gs, hand)
	var base = int(_score(gs, [0, 1, 2]).get("final_devotion", 0))
	hand[0]["trait_id"] = "devout"
	var with_devout = int(_score(gs, [0, 1, 2]).get("final_devotion", 0))
	_assert_eq(with_devout - base, 2, "Devout should add +2 additive")

	hand[1]["trait_id"] = "stalwart"
	var with_stalwart = int(_score(gs, [0, 1, 2]).get("final_devotion", 0))
	_assert_true(with_stalwart - with_devout >= 4, "Stalwart should add +4 additive when BONE")

	# Fervent: +2 Blood if exactly 3
	hand[0]["trait_id"] = ""
	hand[1]["trait_id"] = ""
	hand[2]["trait_id"] = ""
	var base_blood = int(_score(gs, [0, 1, 2]).get("blood_gain", 0))
	hand[0]["trait_id"] = "fervent"
	var result = _score(gs, [0, 1, 2])
	_assert_eq(int(result.get("blood_gain", 0)), base_blood + 2, "Fervent should grant +2 Blood on exactly 3")

	# Twinborn: +5 additive if another shares tier
	hand[0]["trait_id"] = ""
	hand[1]["trait_id"] = ""
	hand[2]["trait_id"] = ""
	hand[0]["tier"] = 2
	hand[1]["tier"] = 2
	hand[2]["tier"] = 4
	var base2 = int(_score(gs, [0, 1, 2]).get("final_devotion", 0))
	hand[0]["trait_id"] = "twinborn"
	var with2 = int(_score(gs, [0, 1, 2]).get("final_devotion", 0))
	_assert_eq(with2 - base2, 5, "Twinborn should add +5 additive when tiers match")

	# Ossuary King: +18 additive if 2+ BONE
	hand = [
		gs._make_specific_follower("BONE", 1, "test", "ossuary_king"),
		gs._make_specific_follower("BONE", 1, "test"),
		gs._make_specific_follower("BLOOD", 1, "test"),
	]
	_set_hand(gs, hand)
	var r1 = _score(gs, [0, 1, 2])
	_assert_true(int(r1.get("final_devotion", 0)) >= 18, "Ossuary King should add +18 additive")

	# Martyr's Ledger: +3 Blood
	var base_blood2 = int(_score(gs, [0, 1, 2]).get("blood_gain", 0))
	hand[0]["trait_id"] = "martyrs_ledger"
	var r2 = _score(gs, [0, 1, 2])
	_assert_eq(int(r2.get("blood_gain", 0)), base_blood2 + 3, "Martyr's Ledger should grant +3 Blood")

	# Blood Prophet and Straight Rite: check multiplier lines
	hand = [
		gs._make_specific_follower("BLOOD", 1, "test", "blood_prophet"),
		gs._make_specific_follower("BLOOD", 2, "test"),
		gs._make_specific_follower("BLOOD", 3, "test"),
	]
	_set_hand(gs, hand)
	var r3 = _score(gs, [0, 1, 2])
	_assert_true(_has_line(str(r3.get("breakdown", "")), "multiplier exponent +1"), "Blood Prophet should report exponent bonus")

	hand[0]["trait_id"] = "straight_rite"
	var r4 = _score(gs, [0, 1, 2])
	_assert_true(_has_line(str(r4.get("breakdown", "")), "multiplier exponent +2"), "Straight Rite should report exponent bonus")

	# Void Herald: multiplier base +2 if exactly 1 VOID
	hand = [
		gs._make_specific_follower("VOID", 1, "test", "void_herald"),
		gs._make_specific_follower("BLOOD", 1, "test"),
		gs._make_specific_follower("BONE", 1, "test"),
	]
	_set_hand(gs, hand)
	var r5 = _score(gs, [0, 1, 2])
	_assert_true(_has_line(str(r5.get("breakdown", "")), "multiplier base +2"), "Void Herald should report base bonus")

	# Black Candlebearer: base min 2 if 0 VOID
	hand = [
		gs._make_specific_follower("BLOOD", 1, "test", "black_candlebearer"),
		gs._make_specific_follower("BLOOD", 1, "test"),
		gs._make_specific_follower("BONE", 1, "test"),
	]
	_set_hand(gs, hand)
	var r6 = _score(gs, [0, 1, 2])
	_assert_true(_has_line(str(r6.get("breakdown", "")), "multiplier base"), "Black Candlebearer should report base bonus")

func test_trait_multiplier_cap() -> void:
	var gs = _fresh_gs()
	var hand = [
		gs._make_specific_follower("BLOOD", 1, "test", "crimson_revelation"),
		gs._make_specific_follower("BLOOD", 2, "test", "blood_prophet"),
		gs._make_specific_follower("BLOOD", 3, "test", "straight_rite"),
	]
	_set_hand(gs, hand)
	var r = _score(gs, [0, 1, 2])
	var breakdown = str(r.get("breakdown", ""))
	_assert_true(_has_line(breakdown, "Crimson Revelation: multiplier exponent +2, +4 Blood"), "Crimson Revelation should apply within multiplier cap")
	_assert_true(_has_line(breakdown, "Blood Prophet: multiplier exponent +1"), "Second multiplier trait should still apply when cap is 2")
	_assert_true(_has_line(breakdown, "multiplier trait cap"), "Third multiplier trait should be capped")

func test_lineage_multiplier() -> void:
	var gs = _fresh_gs()
	var hand: Array = [
		gs._make_specific_follower("BLOOD", 4, "test"),
		gs._make_specific_follower("BONE", 4, "test"),
		gs._make_specific_follower("BLOOD", 2, "test"),
	]
	_set_hand(gs, hand)
	var no_lineage: Dictionary = _score(gs, [0, 1, 2])
	var base_final: int = int(no_lineage.get("final_devotion", 0))
	var base_breakdown: String = str(no_lineage.get("breakdown", ""))
	_assert_true(not _has_line(base_breakdown, "Lineage x"), "Lineage should not appear when no bred followers are sacrificed")

	hand = [
		gs._make_specific_follower("BLOOD", 4, "nest_bred"),
		gs._make_specific_follower("BONE", 4, "wild_bred"),
		gs._make_specific_follower("BLOOD", 2, "test"),
	]
	_set_hand(gs, hand)
	var with_lineage: Dictionary = _score(gs, [0, 1, 2])
	var with_lineage_final: int = int(with_lineage.get("final_devotion", 0))
	var with_lineage_breakdown: String = str(with_lineage.get("breakdown", ""))
	_assert_true(_has_line(with_lineage_breakdown, "Lineage x1.30 (2 bred)"), "Lineage should report x1.30 when two bred followers are sacrificed")
	_assert_eq(with_lineage_final, int(floor(float(base_final) * 1.3)), "Lineage multiplier should apply at x1.30 for two bred followers")

func test_breeding_rules() -> void:
	# Fertility Idol increases chance for non-VOID couples
	var gs = _fresh_gs()
	gs.relic_inventory["Fertility Idol"] = 2
	var chance = gs._breeding_chance("BLOOD", "BONE")
	_assert_true(chance >= 0.55, "Fertility Idol should increase breeding chance (expected >= 0.55)")

	# Seal of Inheritance: if parent has a trait, newborn should inherit
	gs = _fresh_gs()
	var parent_a = gs._make_specific_follower("BLOOD", 2, "test", "devout")
	var parent_b = gs._make_specific_follower("BONE", 2, "test")
	gs.relic_inventory["Seal of Inheritance"] = 1
	var trait_id = gs._roll_breeding_trait(parent_a, parent_b)
	_assert_eq(trait_id, "devout", "Seal of Inheritance should force parent trait when present")

	# Chosen of the Veil: newborn should always have a trait if parent has chosen_veil
	gs = _fresh_gs()
	parent_a = gs._make_specific_follower("BLOOD", 2, "test", "chosen_veil")
	parent_b = gs._make_specific_follower("BONE", 2, "test")
	var trait_id2 = gs._roll_breeding_trait(parent_a, parent_b)
	_assert_true(trait_id2 != "", "Chosen of the Veil should guarantee a trait")

	# Nest focus actions + preview telemetry
	gs = _fresh_gs()
	gs.init_starting_pool("FLESH")
	var parent_ids: Array[int] = []
	for f in gs.pool:
		if str(f.get("trait", "")) == "SOUL":
			continue
		parent_ids.append(int(f.get("id", -1)))
		if parent_ids.size() >= 2:
			break
	gs.assign_follower_to_nest(0, 0, parent_ids[0])
	gs.assign_follower_to_nest(0, 1, parent_ids[1])
	var base_preview: Dictionary = gs.get_nest_preview(0)
	_assert_true(bool(base_preview.get("can_breed", false)), "Nest preview should be breedable when both parents are set")
	var blocked_preview: Dictionary = gs.get_nest_preview(1)
	_assert_true(str(blocked_preview.get("blocked_reason", "")).find("Missing parent") >= 0, "Empty nest should report blocked reason")
	var odds: Dictionary = base_preview.get("rarity_odds", {})
	var odds_sum: float = float(odds.get("common", 0.0)) + float(odds.get("rare", 0.0)) + float(odds.get("legendary", 0.0))
	_assert_true(abs(odds_sum - 1.0) <= 0.001, "Nest preview rarity odds should sum to 1.0")
	var expected_base_tier: float = float(base_preview.get("expected_tier", 0.0))
	var blood_before_focus: int = gs.blood_currency
	var focus_result: Dictionary = gs.purchase_nest_focus(0, "TIER")
	_assert_true(bool(focus_result.get("ok", false)), "Tier focus purchase should succeed with enough blood")
	_assert_eq(gs.blood_currency, blood_before_focus - 3, "Tier focus should cost 3 Blood")
	var tier_preview: Dictionary = gs.get_nest_preview(0)
	_assert_true(float(tier_preview.get("expected_tier", 0.0)) > expected_base_tier, "Tier focus should increase expected newborn tier")

	# Deferred focus spend path used by NestSelect UI
	gs = _fresh_gs()
	gs.init_starting_pool("FLESH")
	parent_ids.clear()
	for f in gs.pool:
		if str(f.get("trait", "")) == "SOUL":
			continue
		parent_ids.append(int(f.get("id", -1)))
		if parent_ids.size() >= 2:
			break
	gs.assign_follower_to_nest(0, 0, parent_ids[0])
	gs.assign_follower_to_nest(0, 1, parent_ids[1])
	var blood_before_set: int = gs.blood_currency
	var set_focus_result: Dictionary = gs.set_nest_focus(0, "TIER")
	_assert_true(bool(set_focus_result.get("ok", false)), "Deferred focus set should succeed")
	_assert_eq(gs.blood_currency, blood_before_set, "Deferred focus set should not spend Blood immediately")
	_assert_eq(gs.get_nest_focus_total_cost(), 3, "Deferred focus total should reflect selected focus cost")
	var commit_focus_result: Dictionary = gs.commit_nest_focus_costs()
	_assert_true(bool(commit_focus_result.get("ok", false)), "Deferred focus commit should succeed")
	_assert_eq(gs.blood_currency, blood_before_set - 3, "Deferred focus should spend Blood on commit")

func test_codex_meta_progression() -> void:
	var gs = _fresh_gs()
	var original_codex: Dictionary = gs.codex_data.duplicate(true)

	# Run codex checks against a fresh isolated codex snapshot, then restore.
	gs.codex_data = gs._codex_default_data()
	gs._save_codex_data()

	var relic_name := "Thin Blade"
	_assert_true(not gs.codex_has_relic_seen(relic_name), "Codex should start with relic unseen")
	_assert_true(not gs.codex_is_relic_unlocked(relic_name), "Codex should start with relic locked")
	_assert_true(gs.codex_get_relic_description(relic_name).find("Purchase once") >= 0, "Locked relic description should be hidden")

	gs.codex_mark_relic_seen(relic_name)
	_assert_true(gs.codex_has_relic_seen(relic_name), "codex_mark_relic_seen should persist discovery")
	_assert_true(not gs.codex_is_relic_unlocked(relic_name), "Seen relic should remain locked until purchased")

	gs.codex_mark_relic_purchased(relic_name)
	_assert_true(gs.codex_is_relic_unlocked(relic_name), "codex_mark_relic_purchased should unlock relic entry")
	_assert_eq(gs.codex_get_relic_purchase_count(relic_name), 1, "First relic purchase should set codex purchase count to 1")
	_assert_eq(gs.codex_get_relic_description(relic_name), str(gs.RELIC_DEFS[relic_name].get("desc", "")), "Unlocked relic should show full description")

	gs.codex_mark_relic_purchased(relic_name)
	_assert_eq(gs.codex_get_relic_purchase_count(relic_name), 2, "Repeated relic purchases should increment codex purchase count")

	var trait_id := "devout"
	_assert_true(gs.codex_get_trait_description(trait_id).find("Undiscovered trait") >= 0, "Trait description should be hidden before discovery")
	gs.codex_mark_trait_seen(trait_id)
	_assert_true(gs.codex_has_trait_seen(trait_id), "codex_mark_trait_seen should persist trait discovery")
	_assert_true(gs.codex_get_trait_description(trait_id).find("Undiscovered trait") < 0, "Discovered trait should reveal description")

	var combo_catalog: Dictionary = gs.get_combo_trait_catalog()
	if combo_catalog.size() > 0:
		var combo_id: String = str(combo_catalog.keys()[0])
		_assert_true(not gs.codex_has_combo_trait_bred(combo_id), "Combo trait should start as unbred")
		gs.codex_mark_combo_trait_bred(combo_id)
		_assert_true(gs.codex_has_combo_trait_bred(combo_id), "codex_mark_combo_trait_bred should persist combo breed discovery")
		_assert_true(gs.codex_has_trait_seen(combo_id), "Breeding combo trait should also mark combo trait as seen")

	gs.codex_data = original_codex
	gs._save_codex_data()

func test_new_relics_batch1() -> void:
	var gs = _fresh_gs()
	var hand: Array = [
		gs._make_specific_follower("BLOOD", 8, "test"),
		gs._make_specific_follower("BLOOD", 5, "test"),
		gs._make_specific_follower("BLOOD", 5, "test"),
	]
	_set_hand(gs, hand)
	var base = int(_score(gs, [0, 1, 2]).get("final_devotion", 0))
	gs.relic_inventory["Iron Reliquary"] = 1
	var with_iron = int(_score(gs, [0, 1, 2]).get("final_devotion", 0))
	_assert_eq(with_iron - base, 20, "Iron Reliquary should add +20 when highest tier is 8+")

	gs.relic_inventory["Iron Reliquary"] = 0
	hand = [
		gs._make_specific_follower("BLOOD", 9, "test"),
		gs._make_specific_follower("BONE", 8, "test"),
		gs._make_specific_follower("BLOOD", 7, "test"),
	]
	_set_hand(gs, hand)
	var base_no_ivory = int(_score(gs, [0, 1, 2]).get("final_devotion", 0))
	gs.relic_inventory["Ivory Throne"] = 1
	var with_ivory = int(_score(gs, [0, 1, 2]).get("final_devotion", 0))
	_assert_eq(with_ivory - base_no_ivory, 15, "Ivory Throne should add +5 per tier above 7")

	gs.relic_inventory["Ivory Throne"] = 0
	hand = [
		gs._make_specific_follower("BLOOD", 6, "test"),
		gs._make_specific_follower("BLOOD", 6, "test"),
		gs._make_specific_follower("BLOOD", 6, "test"),
	]
	_set_hand(gs, hand)
	var base_no_asc = int(_score(gs, [0, 1, 2]).get("final_devotion", 0))
	gs.relic_inventory["Ascendant Mark"] = 1
	var with_asc = int(_score(gs, [0, 1, 2]).get("final_devotion", 0))
	_assert_eq(with_asc - base_no_asc, 25, "Ascendant Mark should add +25 for same-type tier-6+ trio")

	gs.relic_inventory["Ascendant Mark"] = 0
	gs.relic_inventory["Whetted Bone"] = 1
	hand = [
		gs._make_specific_follower("BONE", 4, "test"),
		gs._make_specific_follower("BLOOD", 1, "test"),
		gs._make_specific_follower("BLOOD", 1, "test"),
	]
	_set_hand(gs, hand)
	gs.relic_inventory["Whetted Bone"] = 0
	base = int(_score(gs, [0, 1, 2]).get("final_devotion", 0))
	gs.relic_inventory["Whetted Bone"] = 1
	var with_whetted = int(_score(gs, [0, 1, 2]).get("final_devotion", 0))
	_assert_eq(with_whetted, base - 2, "Whetted Bone should replace BONE base with tier+2")

	gs.relic_inventory["Whetted Bone"] = 0
	gs.summit_last_round_highest_tier = 5
	hand = [
		gs._make_specific_follower("BLOOD", 6, "test"),
		gs._make_specific_follower("BONE", 2, "test"),
		gs._make_specific_follower("BLOOD", 2, "test"),
	]
	_set_hand(gs, hand)
	var base_no_summit = int(_score(gs, [0, 1, 2]).get("final_devotion", 0))
	gs.relic_inventory["The Summit"] = 1
	var with_summit = int(_score(gs, [0, 1, 2]).get("final_devotion", 0))
	_assert_eq(with_summit - base_no_summit, 15, "The Summit should add +15 when beating last round high tier")

	gs = _fresh_gs()
	gs.relic_inventory["The Gilded Offering"] = 1
	hand = [
		gs._make_specific_follower("BLOOD", 10, "test"),
		gs._make_specific_follower("BLOOD", 1, "test"),
		gs._make_specific_follower("BONE", 1, "test"),
	]
	var saved_id: int = int(hand[0].get("id", -1))
	_set_hand(gs, hand)
	gs.score_selected([0, 1, 2])
	_resolve_play_and_update_pool_safe(gs, [0, 1, 2], "test_new_relics_batch1 gilded")
	var found_gilded: bool = false
	for f in gs.pool:
		if int(f.get("id", -1)) == saved_id:
			found_gilded = true
			break
	_assert_true(found_gilded, "The Gilded Offering should return sacrificed tier-10 follower")

	gs = _fresh_gs()
	gs.relic_inventory["Dynasty Seal"] = 1
	var p1 = gs._make_specific_follower("BLOOD", 8, "test")
	var p2 = gs._make_specific_follower("BLOOD", 8, "test")
	gs.pool.clear()
	gs.pool.append(p1)
	gs.pool.append(p2)
	gs.assign_follower_to_nest(0, 0, int(p1.get("id", -1)))
	gs.assign_follower_to_nest(0, 1, int(p2.get("id", -1)))
	gs.resolve_nest_breeding(1)
	var dynasty_tier: int = -1
	for f in gs.pool:
		if str(f.get("origin_tag", "")) == "nest_bred":
			dynasty_tier = int(f.get("tier", -1))
			break
	_assert_true(dynasty_tier >= 6, "Dynasty Seal offspring should start at tier 6 or higher after modifiers")

	gs = _fresh_gs()
	gs.relic_inventory["The Last Rung"] = 1
	hand = [
		gs._make_specific_follower("BLOOD", 10, "test"),
		gs._make_specific_follower("BLOOD", 1, "test"),
		gs._make_specific_follower("BONE", 1, "test"),
	]
	_set_hand(gs, hand)
	var rung_result: Dictionary = _score(gs, [0, 1, 2])
	_assert_eq(int(rung_result.get("base", 0)), 6, "The Last Rung should add +5 base for tier-10 sacrifice")

	gs = _fresh_gs()
	gs.relic_inventory["Void Cradle"] = 1
	hand = [
		gs._make_specific_follower("VOID", 1, "test"),
		gs._make_specific_follower("BLOOD", 1, "test"),
		gs._make_specific_follower("BONE", 1, "test"),
	]
	var void_id: int = int(hand[0].get("id", -1))
	_set_hand(gs, hand)
	gs.score_selected([0, 1, 2])
	_resolve_play_and_update_pool_safe(gs, [0, 1, 2], "test_new_relics_batch1 void_cradle")
	var void_returned: bool = false
	var void_tier_locked: bool = false
	for f in gs.pool:
		if int(f.get("id", -1)) == void_id:
			void_returned = true
			void_tier_locked = int(f.get("tier", 0)) == 0
			break
	_assert_true(void_returned and void_tier_locked, "Void Cradle should return sacrificed VOID with tier locked at 0")

	gs = _fresh_gs()
	gs.relic_inventory["The Hollow Register"] = 1
	hand = [
		gs._make_specific_follower("VOID", 1, "test"),
		gs._make_specific_follower("BLOOD", 1, "test"),
		gs._make_specific_follower("BONE", 1, "test"),
	]
	_set_hand(gs, hand)
	gs.score_selected([0, 1, 2])
	_assert_eq(gs.hollow_register_stacks, 1, "The Hollow Register should gain a stack on exactly-1-VOID week play")

	gs = _fresh_gs()
	gs.relic_inventory["The Empty Pyre"] = 1
	hand = [
		gs._make_specific_follower("VOID", 1, "test"),
		gs._make_specific_follower("BLOOD", 1, "test"),
		gs._make_specific_follower("BONE", 1, "test"),
	]
	_set_hand(gs, hand)
	var pyre_res: Dictionary = _score(gs, [0, 1, 2])
	_assert_eq(int(pyre_res.get("base", 0)), 2, "The Empty Pyre should only boost multiplier base from tiered VOID above tier 1")

	gs = _fresh_gs()
	gs.relic_inventory["Refinery of Silence"] = 1
	hand = [
		gs._make_specific_follower("VOID", 1, "test"),
		gs._make_specific_follower("BLOOD", 2, "test"),
		gs._make_specific_follower("BONE", 2, "test"),
	]
	_set_hand(gs, hand)
	var base_refined = int(_score(gs, [0, 1, 2]).get("final_devotion", 0))
	gs.relic_inventory["Refinery of Silence"] = 0
	var base_plain = int(_score(gs, [0, 1, 2]).get("final_devotion", 0))
	_assert_true(base_refined > base_plain, "Refinery of Silence should increase refined VOID multiplier factor")

	gs = _fresh_gs()
	gs.relic_inventory["The Absent Crown"] = 1
	hand = [
		gs._make_specific_follower("VOID", 1, "test"),
		gs._make_specific_follower("VOID", 1, "test"),
		gs._make_specific_follower("BLOOD", 2, "test"),
	]
	_set_hand(gs, hand)
	var absent_res: Dictionary = _score(gs, [0, 1, 2])
	_assert_true(float(absent_res.get("final_devotion", 0)) > float(absent_res.get("additive_total", 0)), "The Absent Crown should treat both VOID as refined")

	gs = _fresh_gs()
	gs.relic_inventory["Void Recursion"] = 1
	hand = [
		gs._make_specific_follower("VOID", 1, "test"),
		gs._make_specific_follower("BLOOD", 1, "test"),
		gs._make_specific_follower("BONE", 1, "test"),
	]
	_set_hand(gs, hand)
	gs.score_selected([0, 1, 2])
	var had_recursion: bool = false
	for f in gs.pool:
		if str(f.get("origin_tag", "")) == "void_recursion":
			had_recursion = int(f.get("tier", 0)) == 0
			break
	_assert_true(had_recursion, "Void Recursion should spawn a VOID copy with tier locked at 0 once per week")

	gs = _fresh_gs()
	hand = [
		gs._make_specific_follower("VOID", 1, "test"),
		gs._make_specific_follower("BONE", 1, "test"),
		gs._make_specific_follower("SOUL", 1, "test"),
	]
	_set_hand(gs, hand)
	var one_void: int = int(_score(gs, [0, 1, 2]).get("final_devotion", 0))
	hand = [
		gs._make_specific_follower("VOID", 1, "test"),
		gs._make_specific_follower("VOID", 1, "test"),
		gs._make_specific_follower("BONE", 1, "test"),
	]
	_set_hand(gs, hand)
	var two_void: int = int(_score(gs, [0, 1, 2]).get("final_devotion", 0))
	_assert_true(two_void > one_void, "Void Resonance should reward selecting multiple VOID sacrifices")

	gs = _fresh_gs()
	gs.relic_inventory["Crown of Tiers"] = 1
	gs.blood_currency = 10
	var crown_target = gs._make_specific_follower("BLOOD", 4, "test")
	gs.pool.append(crown_target)
	var crown_result: Dictionary = gs.use_crown_of_tiers(int(crown_target.get("id", -1)))
	_assert_true(bool(crown_result.get("ok", false)), "Crown of Tiers should promote a follower when paid")
	_assert_eq(int(crown_result.get("after_tier", 0)), 7, "Crown of Tiers should add +3 tier")
	_assert_true(not bool(gs.use_crown_of_tiers(int(crown_target.get("id", -1))).get("ok", true)), "Crown of Tiers should be once per week")

	gs = _fresh_gs()
	gs.relic_inventory["Bloodline Register"] = 2
	gs.blood_currency = 0
	var reg_target = gs._make_specific_follower("BLOOD", 9, "test")
	gs.pool.append(reg_target)
	gs.boost_pool_tiers_weekly()
	_assert_eq(gs.blood_currency, 2, "Bloodline Register should grant +1 Blood per copy when follower reaches tier 10")

func test_pool_cap_modifiers() -> void:
	var gs = _fresh_gs()
	gs.relic_inventory["Salt Circle"] = 3
	var cap = gs.get_pool_cap()
	_assert_eq(cap, 1000 + 12, "Salt Circle should increase pool cap by +4 per copy")
	gs.relic_inventory["Ectoplasm Jar"] = 2
	var cap2 = gs.get_pool_cap()
	_assert_eq(cap2, 1000 + 12 - 12, "Ectoplasm Jar should reduce pool cap by -6 per copy")

func test_new_relics_batch2() -> void:
	var gs = _fresh_gs()
	var must_exist: Array[String] = [
		"Null Covenant", "The Deepest Void", "Ossuary Absolute", "Crimson Absolute",
		"The Absolute Trinity", "The Great Cull", "The Compound Covenant",
		"The Expanding Contract", "The Eternal Line", "The Damnation Seal",
		"The Faithful Scribe", "The Archive Key",
	]
	for relic_name in must_exist:
		_assert_true(gs.RELICS.has(relic_name), "RELICS should include %s" % relic_name)
		_assert_true(gs.RELIC_DEFS.has(relic_name), "RELIC_DEFS should include %s" % relic_name)
		_assert_true(gs.relic_inventory.has(relic_name), "relic_inventory should include %s" % relic_name)

	gs = _fresh_gs()
	gs.relic_inventory["The Deep Pool"] = 2
	gs.relic_inventory["The Hollow Pact"] = 1
	_assert_eq(gs.get_pool_cap(), int(ceil(float(1000 + 12) / 2.0)), "Deep Pool + Hollow Pact should adjust pool cap correctly")
	gs._sanitize_nests()
	_assert_eq(gs.nests.size(), 3, "The Deep Pool at 2+ copies should unlock 3 nests")

	gs = _fresh_gs()
	var hand: Array = [
		gs._make_specific_follower("BLOOD", 8, "test"),
		gs._make_specific_follower("BLOOD", 8, "test"),
		gs._make_specific_follower("BLOOD", 8, "test"),
	]
	_set_hand(gs, hand)
	var base_res: Dictionary = _score(gs, [0, 1, 2])
	gs.relic_inventory["Crimson Absolute"] = 1
	var abs_res: Dictionary = _score(gs, [0, 1, 2])
	_assert_true(int(abs_res.get("final_devotion", 0)) > int(base_res.get("final_devotion", 0)), "Crimson Absolute should increase high-tier all-BLOOD final devotion")

	gs = _fresh_gs()
	hand = [gs._make_specific_follower("BONE", 6, "test")]
	_set_hand(gs, hand)
	var no_single: Dictionary = _score(gs, [0])
	gs.relic_inventory["Single Rite"] = 1
	var yes_single: Dictionary = _score(gs, [0])
	_assert_eq(int(yes_single.get("final_devotion", 0)), int(no_single.get("final_devotion", 0)), "Single Rite should not change immediate score")
	var single_id: int = int(hand[0].get("id", -1))
	gs.score_selected([0])
	_resolve_play_and_update_pool_safe(gs, [0], "test_new_relics_batch2 single_rite")
	var single_returned: bool = false
	var single_tier: int = -1
	for f in gs.pool:
		if int(f.get("id", -1)) == single_id:
			single_returned = true
			single_tier = int(f.get("tier", 0))
			break
	_assert_true(single_returned and single_tier == 7, "Single Rite should return lone sacrifice with +1 tier")

	gs = _fresh_gs()
	gs.relic_inventory["The Expanding Contract"] = 1
	hand = [
		gs._make_specific_follower("BLOOD", 3, "test"),
		gs._make_specific_follower("BONE", 3, "test"),
		gs._make_specific_follower("VOID", 1, "test"),
		gs._make_specific_follower("BLOOD", 3, "test"),
		gs._make_specific_follower("BONE", 5, "test"),
	]
	_set_hand(gs, hand)
	var five_res: Dictionary = _score(gs, [0, 1, 2, 3, 4])
	_assert_true(int(five_res.get("final_devotion", 0)) > 0, "Expanding Contract 5-sacrifice scoring should resolve")

