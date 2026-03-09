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

func _ready() -> void:
	var started = Time.get_ticks_msec()
	run_all()
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
	test_breeding_rules()
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
	return gs

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

			for week in range(1, max_weeks + 1):
				gs.current_week = week
				gs.start_week()
				var target = target_values[week - 1]
				var week_cleared := false
				var week_overflow_blood: int = 0
				var week_early_blood: int = 0
				var week_blood_spent: int = 0
				var start_blood: int = gs.blood_currency

				for round in range(2):
					gs.draw_hand_from_pool()
					var required = 3
					if gs.relic_inventory["Black Contract"] > 0 and gs.contract_used_week != week:
						if gs._rng.randf() < 0.5:
							gs.contract_allow_four = true
					if gs.contract_allow_four:
						required = 4
					var picks = _pick_indices(gs, required, profile)
					var blood_before: int = gs.blood_currency
					var result = gs._score_selected_internal(picks, true, false, false)
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

					var overflow_grant: int = gs.apply_overflow_blood_for_target(target)
					if overflow_grant > 0:
						week_overflow_blood += overflow_grant

					var blood_after: int = gs.blood_currency
					if blood_after > blood_before:
						run_blood_gained += (blood_after - blood_before)
					week_round_sum[week - 1] += int(result.get("final_devotion", 0))
					week_round_count[week - 1] += 1
					var typed_picks: Array[int] = []
					for p in picks:
						typed_picks.append(int(p))
					gs.resolve_play_and_update_pool(typed_picks)
					gs.week_round += 1
					gs.contract_allow_four = false

					if gs.week_total_devotion >= target:
						if round == 0:
							var early_bonus: int = gs.get_early_win_bonus()
							var blood_before_bonus: int = gs.blood_currency
							gs.add_blood(early_bonus)
							run_blood_gained += (gs.blood_currency - blood_before_bonus)
							week_early_blood += early_bonus
						week_cleared = true
						break

				run_weeks_played += 1
				run_end_week = week
				week_total_sum[week - 1] += gs.week_total_devotion

				if week_cleared or gs.week_total_devotion >= target:
					week_passes[week - 1] += 1
					var shop_result: Dictionary = _simulate_shop(gs, week, run_relics)
					week_blood_spent = int(shop_result.get("blood_spent", 0))
					run_blood_spent += week_blood_spent
					week_shop_entry_blood_sum[week - 1] += int(shop_result.get("shop_entry_blood", 0))
					week_shop_entry_blood_count[week - 1] += 1
					var offers_seen: Dictionary = shop_result.get("offers_seen", {})
					for offered_name in offers_seen.keys():
						run_relic_offers_seen[offered_name] = true
					var breeding_metrics: Dictionary = _simulate_weekly_breeding(gs, week, profile)
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
		"relic_rows": relic_rows,
		"trait_rows": trait_rows,
	}

func _pick_indices(gs: Node, required: int, profile: String) -> Array:
	if profile == "expert":
		return _best_indices(gs, required)
	return _random_unique_indices(gs.current_hand.size(), required, gs._rng)

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

func _simulated_relic_offers(gs: Node, week: int) -> Array:
	var offers = []
	for i in range(3):
		var rarity = gs.roll_shop_rarity(week, gs._rng)
		var pool = []
		for name in gs.RELICS:
			if not gs.RELIC_DEFS.has(name):
				continue
			var def = gs.RELIC_DEFS[name]
			if str(def.get("rarity", "")) != rarity:
				continue
			if not gs.can_offer_relic(name):
				continue
			pool.append(name)
		if pool.is_empty():
			continue
		_shuffle_with_rng(pool, gs._rng)
		offers.append(pool[0])
	return offers

func _simulate_shop(gs: Node, week: int, run_relics: Dictionary) -> Dictionary:
	var blood_spent: int = 0
	var offers_seen: Dictionary = {}
	# Success bonuses before shop
	var bonus_cup = int(gs.relic_inventory.get("Ceremonial Cup", 0))
	var bonus_geo = int(gs.relic_inventory.get("Blasphemous Geometry", 0))
	var bonus_bowl = int(gs.relic_inventory.get("Brass Tithe Bowl", 0))
	if bonus_cup > 0:
		gs.add_blood(bonus_cup)
	if bonus_geo > 0:
		gs.add_blood(bonus_geo * 3)
	if bonus_bowl > 0:
		gs.add_blood(bonus_bowl)
	var shop_entry_blood: int = gs.blood_currency

	# Relic offers (random), allow multiple purchases
	var offers = _simulated_relic_offers(gs, week)
	for offered in offers:
		offers_seen[str(offered)] = true
	for i in range(offers.size()):
		var pick = _pick_rarest_relic(gs, offers)
		if pick == "":
			break
		var rarity: String = str(gs.RELIC_DEFS[pick]["rarity"])
		var cost: int = gs.get_shop_cost(week, rarity)
		if not gs.can_afford_relic(cost):
			break
		blood_spent += cost
		gs.spend_blood_for_relic(cost)
		gs.add_relic(pick)
		run_relics[pick] = true
		# Remove purchased relic from this shop's offers (no auto-restock)
		offers.erase(pick)

	# One reroll per shop, cost 5 (free if chalk or free reroll available)
	if gs.shop_rerolls_used == 0:
		var reroll_cost: int = 5
		if gs.relic_inventory["Sharpened Chalk"] > 0 or gs.shop_free_reroll_available:
			reroll_cost = 0
		if gs.blood_currency >= reroll_cost:
			if reroll_cost > 0:
				blood_spent += reroll_cost
				gs.blood_currency -= reroll_cost
			gs.shop_rerolls_used += 1
			gs.shop_free_reroll_available = false
			offers = _simulated_relic_offers(gs, week)
			for offered2 in offers:
				offers_seen[str(offered2)] = true
			for i in range(offers.size()):
				var pick2 = _pick_rarest_relic(gs, offers)
				if pick2 == "":
					break
				var rarity2: String = str(gs.RELIC_DEFS[pick2]["rarity"])
				var cost2: int = gs.get_shop_cost(week, rarity2)
				if not gs.can_afford_relic(cost2):
					break
				blood_spent += cost2
				gs.spend_blood_for_relic(cost2)
				gs.add_relic(pick2)
				run_relics[pick2] = true
				offers.erase(pick2)

	# Recruits: generate and buy randomly while blood remains
	gs.generate_shop_recruits()
	for i in range(gs.shop_recruit_offers.size()):
		if gs.blood_currency <= 0:
			break
		if gs._rng.randf() < 0.5:
			var before_recruit: int = gs.blood_currency
			gs.buy_shop_recruit(i)
			var after_recruit: int = gs.blood_currency
			if after_recruit < before_recruit:
				blood_spent += (before_recruit - after_recruit)

	# Crimson Interest after shop
	var interest_copies = int(gs.relic_inventory.get("Crimson Interest", 0))
	if interest_copies > 0:
		var interest_gain = int(floor(float(gs.blood_currency) / 5.0)) * interest_copies
		if interest_gain > 0:
			gs.add_blood(interest_gain)

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
	return {"active_nests": active_nests, "total_nests": gs.nests.size()}

func _simulate_weekly_breeding(gs: Node, week: int, profile: String) -> Dictionary:
	var nest_state: Dictionary = _simulate_nest_selection(gs, profile)
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
	for f in gs.pool:
		var fid: int = int(f.get("id", -1))
		if before_ids.has(fid):
			continue
		newborn_count += 1
		newborn_tier_sum += int(f.get("tier", 0))
		var origin: String = str(f.get("origin_tag", ""))
		if origin == "nest_bred":
			nest_newborns += 1
		elif origin == "wild_bred":
			wild_newborns += 1
		var rarity: String = gs._trait_rarity(str(f.get("trait_id", "")))
		if rarity == "COMMON":
			common += 1
		elif rarity == "RARE":
			rare += 1
		elif rarity == "LEGENDARY":
			legendary += 1
		else:
			none += 1
	return {
		"active_nests": int(nest_state.get("active_nests", 0)),
		"total_nests": int(nest_state.get("total_nests", 0)),
		"nest_newborns": nest_newborns,
		"wild_newborns": wild_newborns,
		"newborn_tier_sum": newborn_tier_sum,
		"newborn_count": newborn_count,
		"common": common,
		"rare": rare,
		"legendary": legendary,
		"none": none,
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
	f.store_line("section,profile,doctrine,week,target,pass_rate,avg_round,avg_week,avg_overflow,avg_early,avg_blood_earned,avg_blood_spent,avg_pool,avg_week_target_min,avg_week_target_max,pass_rate_min,pass_rate_max,relic,avg_week_relic,avg_score_relic,runs_with_relic,runs,total_devotion,total_weeks_played,avg_score_per_week,blood_gained,blood_spent,count,trait_trigger_rate,avg_trait_additive_round,avg_trait_blood_round,nest_usage_rate,avg_nest_newborns,avg_wild_newborns,avg_newborn_tier,newborn_common_share,newborn_rare_share,newborn_legendary_share,newborn_none_share,pick_rate,marginal_score_delta")
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
					elif relic == "Bone Idol" or relic == "Ossuary Standards" or relic == "Calcify" or relic == "Bone Polisher":
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
		gs._make_specific_follower("VOID", 1, "test", "void_herald"),
		gs._make_specific_follower("BLOOD", 1, "test", "whispered"),
		gs._make_specific_follower("BONE", 1, "test"),
	]
	_set_hand(gs, hand)
	var r = _score(gs, [0, 1, 2])
	var breakdown = str(r.get("breakdown", ""))
	_assert_true(_has_line(breakdown, "multiplier base +"), "One multiplier trait should apply")
	_assert_true(_has_line(breakdown, "multiplier trait cap"), "Extra multiplier trait should be capped")

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

func test_pool_cap_modifiers() -> void:
	var gs = _fresh_gs()
	gs.relic_inventory["Salt Circle"] = 3
	var cap = gs.get_pool_cap()
	_assert_eq(cap, 1000 + 12, "Salt Circle should increase pool cap by +4 per copy")
	gs.relic_inventory["Ectoplasm Jar"] = 2
	var cap2 = gs.get_pool_cap()
	_assert_eq(cap2, 1000 + 12 - 12, "Ectoplasm Jar should reduce pool cap by -6 per copy")

