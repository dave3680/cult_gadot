extends Node

const TEST_SEED := 7263491
const RUNS_PER_DOCTRINE := 2500
const RUN_BALANCE_SIM := true

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
	test_relic_scoring_exhaustive()
	test_relic_special_counts()
	test_relic_non_scoring_exhaustive()
	test_exactly_three_conditions()
	test_trait_effects()
	test_trait_multiplier_cap()
	test_breeding_rules()
	test_pool_cap_modifiers()
	test_intentional_failure()
	if RUN_BALANCE_SIM:
		run_balance_sim()

func _print_header() -> void:
	_log("")
	_log("=== Cult of Accumulation: Exhaustive Test Runner ===")
	_log("Seed: %d" % TEST_SEED)

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
	var doctrines = ["FLESH", "RUIN", "SILENCE"]
	for doctrine in doctrines:
		var week_passes = [0, 0, 0, 0, 0]
		var week_loss_count = [0, 0, 0, 0, 0]
		var week_loss_relics_sum = [0, 0, 0, 0, 0]
		var week_round_sum = [0, 0, 0, 0, 0]
		var week_round_count = [0, 0, 0, 0, 0]
		var week_total_sum = [0, 0, 0, 0, 0]
		for run_idx in range(RUNS_PER_DOCTRINE):
			var gs = _fresh_gs()
			gs.selected_doctrine = doctrine
			gs.init_starting_pool(doctrine)
			for week in range(1, 6):
				gs.current_week = week
				gs.start_week()
				var target = gs.get_week_target(week)
				var week_cleared := false
				for round in range(2):
					gs.draw_hand_from_pool()
					var required = 3
					if gs.relic_inventory["Black Contract"] > 0 and gs.contract_used_week != week:
						if gs._rng.randf() < 0.5:
							gs.contract_allow_four = true
					if gs.contract_allow_four:
						required = 4
					var picks = _random_unique_indices(gs.current_hand.size(), required, gs._rng)
					var result = gs.score_selected(picks)
					gs.week_total_devotion += int(result.get("final_devotion", 0))
					var overflow_now: int = max(0, gs.week_total_devotion - target)
					var overflow_delta: int = overflow_now - gs.week_overflow_blood_granted
					if overflow_delta > 0:
						gs.week_overflow_blood_granted += overflow_delta
						gs.add_blood(overflow_delta)
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
							gs.add_blood(20)
						week_cleared = true
						break
				week_total_sum[week - 1] += gs.week_total_devotion
				if week_cleared or gs.week_total_devotion >= target:
					week_passes[week - 1] += 1
					_simulate_shop(gs, week)
					gs.perform_weekly_breeding(week)
				else:
					# Failed week ends run early; still count remainder as fail
					week_loss_count[week - 1] += 1
					week_loss_relics_sum[week - 1] += _count_total_relics(gs)
					break
			gs.free()

		_log("")
		_log("Doctrine: %s" % doctrine)
		for w in range(5):
			var pass_rate = float(week_passes[w]) / float(RUNS_PER_DOCTRINE)
			var avg_round = 0.0
			if week_round_count[w] > 0:
				avg_round = float(week_round_sum[w]) / float(week_round_count[w])
			var avg_week = float(week_total_sum[w]) / float(RUNS_PER_DOCTRINE)
			var avg_loss_relics = 0.0
			if week_loss_count[w] > 0:
				avg_loss_relics = float(week_loss_relics_sum[w]) / float(week_loss_count[w])
			_log("Week %d | PassRate: %.1f%% | AvgRound: %.2f | AvgWeek: %.2f" % [
				w + 1,
				pass_rate * 100.0,
				avg_round,
				avg_week
			])
			if week_loss_count[w] > 0:
				_log("Losses: %d | AvgRelicsOnLoss: %.2f" % [week_loss_count[w], avg_loss_relics])

func _random_unique_indices(size: int, count: int, rng: RandomNumberGenerator) -> Array:
	var indices = []
	for i in range(size):
		indices.append(i)
	indices.shuffle()
	var picks = []
	for i in range(min(count, indices.size())):
		picks.append(indices[i])
	return picks

func _count_total_relics(gs: Node) -> int:
	var total := 0
	for k in gs.relic_inventory.keys():
		total += int(gs.relic_inventory[k])
	return total

func _simulated_relic_offers(gs: Node, week: int) -> Array:
	var slots = gs.get_shop_rarity_slots(week)
	var offers = []
	for rarity in slots:
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
		pool.shuffle()
		offers.append(pool[0])
	return offers

func _simulate_shop(gs: Node, week: int) -> void:
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

	# Relic offers (random), allow multiple purchases
	var cost = gs.get_shop_cost(week)
	var safety := 0
	while gs.can_afford_relic(cost) and safety < 10:
		safety += 1
		if gs._rng.randf() > 0.7:
			break
		var offers = _simulated_relic_offers(gs, week)
		if offers.size() == 0:
			break
		offers.shuffle()
		var pick = offers[0]
		gs.spend_blood_for_relic(cost)
		gs.add_relic(pick)

	# Recruits: generate and buy randomly while blood remains
	gs.generate_shop_recruits()
	for i in range(gs.shop_recruit_offers.size()):
		if gs.blood_currency <= 0:
			break
		if gs._rng.randf() < 0.5:
			gs.buy_shop_recruit(i)

	# Crimson Interest after shop
	var interest_copies = int(gs.relic_inventory.get("Crimson Interest", 0))
	if interest_copies > 0:
		var interest_gain = int(floor(float(gs.blood_currency) / 5.0)) * interest_copies
		if interest_gain > 0:
			gs.add_blood(interest_gain)

	gs.boost_pool_tiers_weekly()

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
	_assert_eq(with_devout - base, 1, "Devout should add +1 additive")

	hand[1]["trait_id"] = "stalwart"
	var with_stalwart = int(_score(gs, [0, 1, 2]).get("final_devotion", 0))
	_assert_true(with_stalwart - with_devout >= 2, "Stalwart should add +2 additive when BONE")

	# Fervent: +1 Blood if exactly 3
	hand[0]["trait_id"] = ""
	hand[1]["trait_id"] = ""
	hand[2]["trait_id"] = ""
	var base_blood = int(_score(gs, [0, 1, 2]).get("blood_gain", 0))
	hand[0]["trait_id"] = "fervent"
	var result = _score(gs, [0, 1, 2])
	_assert_eq(int(result.get("blood_gain", 0)), base_blood + 1, "Fervent should grant +1 Blood on exactly 3")

	# Twinborn: +3 additive if another shares tier
	hand[0]["trait_id"] = ""
	hand[1]["trait_id"] = ""
	hand[2]["trait_id"] = ""
	hand[0]["tier"] = 2
	hand[1]["tier"] = 2
	hand[2]["tier"] = 4
	var base2 = int(_score(gs, [0, 1, 2]).get("final_devotion", 0))
	hand[0]["trait_id"] = "twinborn"
	var with2 = int(_score(gs, [0, 1, 2]).get("final_devotion", 0))
	_assert_eq(with2 - base2, 3, "Twinborn should add +3 additive when tiers match")

	# Ossuary King: +12 additive if 2+ BONE
	hand = [
		gs._make_specific_follower("BONE", 1, "test", "ossuary_king"),
		gs._make_specific_follower("BONE", 1, "test"),
		gs._make_specific_follower("BLOOD", 1, "test"),
	]
	_set_hand(gs, hand)
	var r1 = _score(gs, [0, 1, 2])
	_assert_true(int(r1.get("final_devotion", 0)) >= 12, "Ossuary King should add +12 additive")

	# Martyr's Ledger: +2 Blood
	var base_blood2 = int(_score(gs, [0, 1, 2]).get("blood_gain", 0))
	hand[0]["trait_id"] = "martyrs_ledger"
	var r2 = _score(gs, [0, 1, 2])
	_assert_eq(int(r2.get("blood_gain", 0)), base_blood2 + 2, "Martyr's Ledger should grant +2 Blood")

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
	_assert_true(_has_line(str(r4.get("breakdown", "")), "multiplier exponent +1"), "Straight Rite should report exponent bonus")

	# Void Herald: multiplier base +1 if exactly 1 VOID
	hand = [
		gs._make_specific_follower("VOID", 1, "test", "void_herald"),
		gs._make_specific_follower("BLOOD", 1, "test"),
		gs._make_specific_follower("BONE", 1, "test"),
	]
	_set_hand(gs, hand)
	var r5 = _score(gs, [0, 1, 2])
	_assert_true(_has_line(str(r5.get("breakdown", "")), "multiplier base +1"), "Void Herald should report base bonus")

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
	_assert_true(_has_line(breakdown, "multiplier base +1"), "One multiplier trait should apply")
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

func test_intentional_failure() -> void:
	_assert_true(false, "Intentional failing test to verify runner reports failures")
