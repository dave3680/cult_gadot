extends Control

@onready var blood_label: Label = $RootVBox/TopBar/TopBarHBox/BloodLabel
@onready var skip_button: Button = $RootVBox/BottomArea/BottomHBox/SkipButton
@onready var shop_tab: Button = $RootVBox/TopBar/TopBarHBox/Tabs/ShopTab
@onready var pool_tab: Button = $RootVBox/TopBar/TopBarHBox/Tabs/PoolTab
@onready var offer_area: Control = $RootVBox/OfferArea
@onready var reroll_button: Button = $RootVBox/RelicControls/RerollRelics
@onready var directors_cut: Button = $RootVBox/RelicControls/DirectorsCut
@onready var ritual_panel: Control = $RootVBox/RitualPanel
@onready var ritual_desc: Label = $RootVBox/RitualPanel/RitualVBox/RitualDesc
@onready var ritual_buy: Button = $RootVBox/RitualPanel/RitualVBox/RitualBuy
@onready var recruit_panel: Control = $RootVBox/RecruitPanel
@onready var recruit_msg: Label = $RootVBox/RecruitPanel/RecruitVBox/RecruitMsg
@onready var pool_area: Control = $RootVBox/PoolArea
@onready var pool_summary: Label = $RootVBox/PoolArea/PoolVBox/PoolSummary
@onready var pool_list: VBoxContainer = $RootVBox/PoolArea/PoolVBox/PoolScroll/PoolList
@onready var pool_cull: Button = $RootVBox/PoolArea/PoolVBox/PoolActions/CullSelected
@onready var pool_fav_a: Button = $RootVBox/PoolArea/PoolVBox/PoolActions/Favored1
@onready var pool_fav_b: Button = $RootVBox/PoolArea/PoolVBox/PoolActions/Favored2
@onready var pool_ascend: Button = $RootVBox/PoolArea/PoolVBox/PoolActions/AscendSelected
@onready var pool_apostle: Button = $RootVBox/PoolArea/PoolVBox/PoolActions/SetApostle
@onready var gs: Node = get_node("/root/GameState")

var offer_nodes: Array[Dictionary] = []
var offers: Array = []
var recruit_nodes: Array[Dictionary] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var selected_pool_id: int = -1

func _ready() -> void:
	_rng.randomize()
	offer_nodes = [
		{
			"name": $RootVBox/OfferArea/Offer1/Offer1VBox/Offer1Name,
			"rarity": $RootVBox/OfferArea/Offer1/Offer1VBox/Offer1Rarity,
			"category": $RootVBox/OfferArea/Offer1/Offer1VBox/Offer1Category,
			"desc": $RootVBox/OfferArea/Offer1/Offer1VBox/Offer1Desc,
			"cost": $RootVBox/OfferArea/Offer1/Offer1VBox/Offer1Cost,
			"buy": $RootVBox/OfferArea/Offer1/Offer1VBox/Offer1Buy,
		},
		{
			"name": $RootVBox/OfferArea/Offer2/Offer2VBox/Offer2Name,
			"rarity": $RootVBox/OfferArea/Offer2/Offer2VBox/Offer2Rarity,
			"category": $RootVBox/OfferArea/Offer2/Offer2VBox/Offer2Category,
			"desc": $RootVBox/OfferArea/Offer2/Offer2VBox/Offer2Desc,
			"cost": $RootVBox/OfferArea/Offer2/Offer2VBox/Offer2Cost,
			"buy": $RootVBox/OfferArea/Offer2/Offer2VBox/Offer2Buy,
		},
		{
			"name": $RootVBox/OfferArea/Offer3/Offer3VBox/Offer3Name,
			"rarity": $RootVBox/OfferArea/Offer3/Offer3VBox/Offer3Rarity,
			"category": $RootVBox/OfferArea/Offer3/Offer3VBox/Offer3Category,
			"desc": $RootVBox/OfferArea/Offer3/Offer3VBox/Offer3Desc,
			"cost": $RootVBox/OfferArea/Offer3/Offer3VBox/Offer3Cost,
			"buy": $RootVBox/OfferArea/Offer3/Offer3VBox/Offer3Buy,
		},
	]
	recruit_nodes = [
		{
			"trait": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit1/Recruit1VBox/Recruit1Trait,
			"stripe": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit1/Recruit1VBox/Recruit1Stripe,
			"tier": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit1/Recruit1VBox/Recruit1Tier,
			"origin": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit1/Recruit1VBox/Recruit1Origin,
			"buy": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit1/Recruit1VBox/Recruit1Buy,
		},
		{
			"trait": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit2/Recruit2VBox/Recruit2Trait,
			"stripe": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit2/Recruit2VBox/Recruit2Stripe,
			"tier": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit2/Recruit2VBox/Recruit2Tier,
			"origin": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit2/Recruit2VBox/Recruit2Origin,
			"buy": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit2/Recruit2VBox/Recruit2Buy,
		},
		{
			"trait": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit3/Recruit3VBox/Recruit3Trait,
			"stripe": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit3/Recruit3VBox/Recruit3Stripe,
			"tier": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit3/Recruit3VBox/Recruit3Tier,
			"origin": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit3/Recruit3VBox/Recruit3Origin,
			"buy": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit3/Recruit3VBox/Recruit3Buy,
		},
		{
			"trait": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit4/Recruit4VBox/Recruit4Trait,
			"stripe": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit4/Recruit4VBox/Recruit4Stripe,
			"tier": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit4/Recruit4VBox/Recruit4Tier,
			"origin": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit4/Recruit4VBox/Recruit4Origin,
			"buy": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit4/Recruit4VBox/Recruit4Buy,
		},
	]
	for i in range(recruit_nodes.size()):
		var buy_button: Button = recruit_nodes[i]["buy"]
		buy_button.pressed.connect(_on_buy_recruit.bind(i))

	skip_button.pressed.connect(_on_skip_pressed)
	shop_tab.pressed.connect(_on_shop_tab)
	pool_tab.pressed.connect(_on_pool_tab)
	reroll_button.pressed.connect(_on_reroll_pressed)
	directors_cut.pressed.connect(_on_directors_cut)
	ritual_buy.pressed.connect(_on_buy_ritual)
	pool_cull.pressed.connect(_on_pool_cull)
	pool_fav_a.pressed.connect(_on_pool_favored_a)
	pool_fav_b.pressed.connect(_on_pool_favored_b)
	pool_ascend.pressed.connect(_on_pool_ascend)
	pool_apostle.pressed.connect(_on_pool_apostle)
	gs.shop_rerolls_used = 0
	gs.shop_cull_used = false
	if gs.free_reroll_next_shop:
		gs.shop_free_reroll_available = true
		gs.free_reroll_next_shop = false
	gs.ritual_card_offer = ""
	if gs.relic_inventory["Spare Chalice"] > 0 and gs.blood_currency == 0:
		gs.add_blood(2)
	_setup_offers()
	gs.generate_shop_recruits()
	_setup_recruits()
	_show_shop_view()

func _setup_offers() -> void:
	blood_label.text = "Blood: %d" % gs.blood_currency

	var week_cleared: int = gs.current_week
	var slots: Array[String] = gs.get_shop_rarity_slots(week_cleared)
	offers = _roll_offers(slots)
	_offer_legendary_if_needed()
	var cost: int = gs.get_shop_cost(week_cleared)

	for i in range(offer_nodes.size()):
		var offer_name: String = offers[i]
		var node: Dictionary = offer_nodes[i]
		node["name"].text = offer_name
		var rarity: String = gs.RELIC_DEFS[offer_name]["rarity"]
		node["rarity"].text = "Rarity: %s" % rarity
		node["rarity"].add_theme_color_override("font_color", _rarity_color(rarity))
		var category: String = gs.RELIC_DEFS[offer_name]["category"]
		node["category"].text = "Category: %s" % category
		node["desc"].text = gs.RELIC_DEFS[offer_name]["desc"]
		node["cost"].text = "Cost: %d Blood" % cost
		var buy_button: Button = node["buy"]
		buy_button.disabled = not gs.can_afford_relic(cost)
		buy_button.pressed.connect(_on_buy_pressed.bind(i))

	_update_reroll_button(cost)
	_setup_ritual_offer()
	_update_directors_cut()

func _on_buy_pressed(index: int) -> void:
	var cost: int = gs.get_shop_cost(gs.current_week)
	if not gs.can_afford_relic(cost):
		return
	gs.spend_blood_for_relic(cost)
	gs.add_relic(offers[index])
	_setup_offers()

func _rarity_color(rarity: String) -> Color:
	match rarity:
		"COMMON":
			return Color(0.9, 0.9, 0.9)
		"UNCOMMON":
			return Color(0.3, 0.8, 0.4)
		"RARE":
			return Color(0.4, 0.4, 0.9)
		"LEGENDARY":
			return Color(0.9, 0.7, 0.2)
		_:
			return Color(0.9, 0.9, 0.9)

func _update_reroll_button(cost: int) -> void:
	var reroll_cost: int = 2
	if gs.shop_rerolls_used == 0 and gs.relic_inventory["Sharpened Chalk"] > 0:
		reroll_cost = 0
	elif gs.shop_free_reroll_available:
		reroll_cost = 0
	else:
		reroll_cost = 2 + gs.shop_rerolls_used
	reroll_button.text = "Reroll Relics (%d)" % reroll_cost
	reroll_button.disabled = gs.blood_currency < reroll_cost

func _offer_legendary_if_needed() -> void:
	if gs.current_week < 4:
		return
	var roll: float = _rng.randf()
	if roll > 0.02:
		return
	var legendary_pool: Array[String] = []
	for name in gs.RELICS:
		if gs.RELIC_DEFS[name]["rarity"] == "LEGENDARY" and gs.can_offer_relic(name) and not offers.has(name):
			legendary_pool.append(name)
	if legendary_pool.is_empty():
		return
	legendary_pool.shuffle()
	offers[offers.size() - 1] = legendary_pool[0]

func _setup_ritual_offer() -> void:
	if gs.relic_inventory["Scarlet Planetarium"] <= 0:
		ritual_panel.visible = false
		return
	ritual_panel.visible = true
	if gs.ritual_card_offer == "":
		gs.ritual_card_offer = gs.RITUAL_CARDS[_rng.randi_range(0, gs.RITUAL_CARDS.size() - 1)]
	var desc: String = gs.ritual_card_offer
	match gs.ritual_card_offer:
		"Anoint":
			desc = "Anoint: +15 additive this play."
		"Silence":
			desc = "Silence: effective VOID +1 this play."
		"Rebirth":
			desc = "Rebirth: return 1 sacrificed follower."
	ritual_desc.text = desc
	ritual_buy.disabled = gs.blood_currency < 2 or gs.ritual_card_slot != ""

func _on_reroll_pressed() -> void:
	var reroll_cost: int = 2
	if gs.shop_rerolls_used == 0 and gs.relic_inventory["Sharpened Chalk"] > 0:
		reroll_cost = 0
	elif gs.shop_free_reroll_available:
		reroll_cost = 0
	else:
		reroll_cost = 2 + gs.shop_rerolls_used
	if gs.blood_currency < reroll_cost:
		return
	if reroll_cost > 0:
		gs.blood_currency -= reroll_cost
	if gs.shop_free_reroll_available:
		gs.shop_free_reroll_available = false
	gs.shop_rerolls_used += 1
	_setup_offers()
	blood_label.text = "Blood: %d" % gs.blood_currency

func _on_buy_ritual() -> void:
	if gs.ritual_card_offer == "" or gs.ritual_card_slot != "":
		return
	if gs.blood_currency < 2:
		return
	gs.blood_currency -= 2
	gs.ritual_card_slot = gs.ritual_card_offer
	gs.ritual_card_offer = ""
	_setup_ritual_offer()
	blood_label.text = "Blood: %d" % gs.blood_currency

func _update_directors_cut() -> void:
	if gs.relic_inventory["Director's Cut"] <= 0:
		directors_cut.visible = false
		return
	directors_cut.visible = true
	var next_week: int = gs.current_week + 1
	var base_target: int = gs.get_week_target(next_week)
	var used: bool = gs.next_week_target_overrides.has(next_week)
	directors_cut.disabled = used
	directors_cut.text = "Director's Cut: Next %d" % base_target

func _on_directors_cut() -> void:
	if gs.relic_inventory["Director's Cut"] <= 0:
		return
	var next_week: int = gs.current_week + 1
	if gs.next_week_target_overrides.has(next_week):
		return
	var base_target: int = gs.get_week_target(next_week)
	var min_target: int = int(ceil(float(base_target) * 0.85))
	var max_target: int = int(floor(float(base_target) * 1.15))
	var rerolled: int = _rng.randi_range(min_target, max_target)
	rerolled = max(base_target, rerolled)
	gs.next_week_target_overrides[next_week] = rerolled
	_update_directors_cut()

func _setup_recruits() -> void:
	recruit_msg.text = ""
	for i in range(recruit_nodes.size()):
		var node: Dictionary = recruit_nodes[i]
		if i >= gs.shop_recruit_offers.size():
			node["trait"].get_parent().get_parent().visible = false
			continue
		node["trait"].get_parent().get_parent().visible = true
		var f: Dictionary = gs.shop_recruit_offers[i]
		node["trait"].text = "Trait: %s" % f["trait"]
		node["stripe"].color = _trait_color(f["trait"])
		node["tier"].text = "Tier: %d" % int(f["tier"])
		node["origin"].text = "Recruit"
		var buy_button: Button = node["buy"]
		var can_copy: bool = gs.shop_recruit_purchased[i] and gs.relic_inventory["Votive Mirror"] > 0 and not gs.shop_copy_used
		buy_button.disabled = (gs.blood_currency < 1) or (gs.shop_recruit_purchased[i] and not can_copy) or gs.pool.size() >= gs.get_pool_cap()
		if gs.shop_recruit_purchased[i] and not can_copy:
			buy_button.text = "Hired"
		elif can_copy:
			buy_button.text = "Buy Copy (1)"
		else:
			buy_button.text = "Hire (1)"

func _on_buy_recruit(index: int) -> void:
	var result: Dictionary = gs.buy_shop_recruit(index)
	if not result["ok"]:
		if result["reason"] == "full":
			recruit_msg.text = "Pool is full."
		elif result["reason"] == "blood":
			recruit_msg.text = "Not enough Blood."
		return
	blood_label.text = "Blood: %d" % gs.blood_currency
	_setup_ritual_offer()
	_update_reroll_button(gs.get_shop_cost(gs.current_week))
	_setup_recruits()
	if pool_area.visible:
		_refresh_pool_list()

func _on_skip_pressed() -> void:
	_finish_shop()

func _finish_shop() -> void:
	var before: int = gs.blood_currency
	var interest_copies: int = gs.relic_inventory["Crimson Interest"]
	var interest_gain: int = 0
	if interest_copies > 0:
		interest_gain = int(floor(float(gs.blood_currency) / 5.0)) * interest_copies
		gs.add_blood(interest_gain)
	var after: int = gs.blood_currency
	gs.log_message("SHOP END | Week %d | Blood %d->%d (+%d interest) | Relics: %s | Offers: %s" % [
		gs.current_week,
		before,
		after,
		interest_gain,
		gs._relic_summary(),
		str(offers),
	])
	gs.boost_pool_tiers_weekly()
	gs.perform_weekly_breeding(gs.current_week)
	gs.current_week += 1
	gs.start_week()
	get_tree().change_scene_to_file("res://scenes/RunGame.tscn")

func _roll_offers(slots: Array[String]) -> Array:
	var chosen: Array = []
	for rarity in slots:
		var pick: String = _pick_from_rarity(rarity, chosen)
		if pick == "":
			pick = _pick_from_rarity(_fallback_rarity(rarity), chosen)
		if pick != "":
			chosen.append(pick)
	return chosen

func _pick_from_rarity(rarity: String, exclude: Array) -> String:
	var pool: Array = []
	for name in gs.RELICS:
		if exclude.has(name):
			continue
		if not gs.can_offer_relic(name):
			continue
		if gs.RELIC_DEFS[name]["rarity"] == rarity:
			pool.append(name)
	if pool.is_empty():
		return ""
	pool.shuffle()
	return pool[0]

func _fallback_rarity(rarity: String) -> String:
	if rarity == "RARE":
		return "UNCOMMON"
	if rarity == "UNCOMMON":
		return "COMMON"
	return "COMMON"

func _on_shop_tab() -> void:
	_show_shop_view()

func _on_pool_tab() -> void:
	_show_pool_view()

func _show_shop_view() -> void:
	shop_tab.button_pressed = true
	pool_tab.button_pressed = false
	offer_area.visible = true
	recruit_panel.visible = true
	ritual_panel.visible = gs.relic_inventory["Scarlet Planetarium"] > 0
	pool_area.visible = false
	_update_directors_cut()
	_setup_recruits()

func _show_pool_view() -> void:
	shop_tab.button_pressed = false
	pool_tab.button_pressed = true
	offer_area.visible = false
	recruit_panel.visible = false
	ritual_panel.visible = false
	pool_area.visible = true
	_refresh_pool_list()

func _refresh_pool_list() -> void:
	for child in pool_list.get_children():
		child.queue_free()
	var summary: Dictionary = gs.pool_summary_counts()
	pool_summary.text = "Pool Size: %d | Blood: %d  Bone: %d  Void: %d | Avg Tier: %.1f" % [
		summary["total"],
		summary["blood"],
		summary["bone"],
		summary["void"],
		float(summary["avg_tier"]),
	]
	for f in gs.pool:
		var row: Button = Button.new()
		row.toggle_mode = true
		row.text = "%s  T%d  %s  (%s #%d)" % [
			f["trait"],
			int(f["tier"]),
			_trait_display(str(f.get("trait_id", ""))),
			f["origin_tag"],
			int(f["id"]),
		]
		if int(f.get("id", -1)) == selected_pool_id:
			row.button_pressed = true
		if str(f.get("trait_rarity", "")) == "RARE":
			row.add_theme_color_override("font_color", Color(0.85, 0.7, 0.2))
		row.pressed.connect(_on_pool_row_pressed.bind(int(f.get("id", -1))))
		pool_list.add_child(row)

	_update_pool_actions()

func _trait_display(trait_id: String) -> String:
	if trait_id == "":
		return "None"
	if not gs.TRAIT_REGISTRY.has(trait_id):
		return trait_id
	var info: Dictionary = gs.TRAIT_REGISTRY[trait_id]
	var rarity: String = str(info.get("rarity", ""))
	var name: String = str(info.get("name", trait_id))
	var mark: String = "[C]" if rarity == "COMMON" else "[R]"
	return "%s %s" % [mark, name]

func _trait_color(trait_name: String) -> Color:
	match trait_name:
		"BLOOD":
			return Color(0.75, 0.2, 0.2)
		"BONE":
			return Color(0.85, 0.85, 0.85)
		"VOID":
			return Color(0.25, 0.2, 0.35)
		_:
			return Color(0.5, 0.5, 0.5)

func _on_pool_row_pressed(follower_id: int) -> void:
	if selected_pool_id == follower_id:
		selected_pool_id = -1
	else:
		selected_pool_id = follower_id
	_refresh_pool_list()

func _update_pool_actions() -> void:
	var cull_ok: bool = gs.relic_inventory["Culling Knife"] > 0 and not gs.shop_cull_used and selected_pool_id >= 0
	if gs.apostle_id == selected_pool_id:
		cull_ok = false
	pool_cull.disabled = not cull_ok
	pool_fav_a.disabled = not (gs.relic_inventory["Selective Breeding Scroll"] > 0 and selected_pool_id >= 0)
	pool_fav_b.disabled = not (gs.relic_inventory["Selective Breeding Scroll"] > 0 and selected_pool_id >= 0)
	pool_ascend.disabled = not (gs.relic_inventory["The Soul Lantern"] > 0 and not gs.soul_lantern_used and selected_pool_id >= 0)
	pool_apostle.disabled = not (gs.relic_inventory["First Apostle"] > 0 and gs.apostle_id == -1 and selected_pool_id >= 0)

func _on_pool_cull() -> void:
	if selected_pool_id < 0:
		return
	if gs.cull_follower_by_id(selected_pool_id):
		gs.shop_cull_used = true
		selected_pool_id = -1
		_refresh_pool_list()

func _on_pool_favored_a() -> void:
	if selected_pool_id < 0:
		return
	gs.set_favored_breeder(selected_pool_id, 0)
	_refresh_pool_list()

func _on_pool_favored_b() -> void:
	if selected_pool_id < 0:
		return
	gs.set_favored_breeder(selected_pool_id, 1)
	_refresh_pool_list()

func _on_pool_ascend() -> void:
	if selected_pool_id < 0:
		return
	if gs.ascend_follower_by_id(selected_pool_id):
		selected_pool_id = -1
		blood_label.text = "Blood: %d" % gs.blood_currency
		_refresh_pool_list()

func _on_pool_apostle() -> void:
	if selected_pool_id < 0:
		return
	if gs.set_apostle(selected_pool_id):
		selected_pool_id = -1
		_refresh_pool_list()
