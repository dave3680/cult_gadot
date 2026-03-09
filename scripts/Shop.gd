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
@onready var pool_pack: Button = $RootVBox/PoolArea/PoolVBox/PoolActions/RelicPack
@onready var gs: Node = get_node("/root/GameState")

var offer_nodes: Array[Dictionary] = []
var offers: Array = []
var recruit_nodes: Array[Dictionary] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var selected_pool_id: int = -1
var pack_select_mode: bool = false
var pack_selected_ids: Array[int] = []
var pack_panel: PanelContainer
var pack_label: Label
var pack_buttons: Array[Button] = []
var pack_offers: Array[String] = []

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
	for i in range(offer_nodes.size()):
		var relic_buy: Button = offer_nodes[i]["buy"]
		relic_buy.pressed.connect(_on_buy_pressed.bind(i))
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
	pool_pack.pressed.connect(_on_pool_pack_pressed)
	_build_pack_panel()
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
	offers = _roll_offers(3, week_cleared)
	_offer_legendary_if_needed()
	_render_offers(week_cleared)
	_setup_ritual_offer()
	_update_directors_cut()

func _on_buy_pressed(index: int) -> void:
	if index < 0 or index >= offers.size():
		return
	var offer_name: String = offers[index]
	if offer_name == "":
		return
	var rarity: String = str(gs.RELIC_DEFS[offer_name]["rarity"])
	var cost: int = gs.get_shop_cost(gs.current_week, rarity)
	if not gs.can_afford_relic(cost):
		return
	gs.spend_blood_for_relic(cost)
	gs.add_relic(offer_name)
	offers[index] = ""
	blood_label.text = "Blood: %d" % gs.blood_currency
	_render_offers(gs.current_week)
	_update_reroll_button()

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

func _update_reroll_button() -> void:
	var reroll_cost: int = 5
	if gs.shop_rerolls_used == 0 and (gs.relic_inventory["Sharpened Chalk"] > 0 or gs.shop_free_reroll_available):
		reroll_cost = 0
	reroll_button.text = "Reroll Relics (%d)" % reroll_cost
	reroll_button.disabled = gs.blood_currency < reroll_cost or gs.shop_rerolls_used >= 1

func _render_offers(week_cleared: int) -> void:
	for i in range(offer_nodes.size()):
		var offer_name: String = offers[i]
		var node: Dictionary = offer_nodes[i]
		var buy_button: Button = node["buy"]
		if offer_name == "":
			node["name"].text = "-"
			node["rarity"].text = ""
			node["category"].text = ""
			node["desc"].text = "Sold out"
			node["cost"].text = ""
			buy_button.disabled = true
		else:
			node["name"].text = offer_name
			var rarity: String = gs.RELIC_DEFS[offer_name]["rarity"]
			var cost: int = gs.get_shop_cost(week_cleared, rarity)
			node["rarity"].text = "Rarity: %s" % rarity
			node["rarity"].add_theme_color_override("font_color", _rarity_color(rarity))
			var category: String = gs.RELIC_DEFS[offer_name]["category"]
			node["category"].text = "Category: %s" % category
			node["desc"].text = gs.RELIC_DEFS[offer_name]["desc"]
			node["cost"].text = "Cost: %d Blood" % cost
			buy_button.disabled = not gs.can_afford_relic(cost)

func _offer_legendary_if_needed() -> void:
	return

func _setup_ritual_offer() -> void:
	ritual_panel.visible = true
	if gs.relic_inventory["Scarlet Planetarium"] <= 0:
		ritual_desc.text = "Locked: Requires Scarlet Planetarium."
		ritual_buy.disabled = true
		return
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
	if gs.ritual_card_slot != "":
		ritual_desc.text += "\nHeld: %s" % gs.ritual_card_slot

func _on_reroll_pressed() -> void:
	if gs.shop_rerolls_used >= 1:
		return
	var reroll_cost: int = 5
	if gs.shop_rerolls_used == 0 and (gs.relic_inventory["Sharpened Chalk"] > 0 or gs.shop_free_reroll_available):
		reroll_cost = 0
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
	if next_week > gs.get_max_weeks():
		directors_cut.visible = false
		return
	var base_target: int = gs.get_week_target(next_week)
	var used: bool = gs.next_week_target_overrides.has(next_week)
	directors_cut.disabled = used
	directors_cut.text = "Director's Cut: Next %d" % base_target

func _on_directors_cut() -> void:
	if gs.relic_inventory["Director's Cut"] <= 0:
		return
	var next_week: int = gs.current_week + 1
	if next_week > gs.get_max_weeks():
		return
	if gs.next_week_target_overrides.has(next_week):
		return
	var base_target: int = gs.get_week_target(next_week)
	var min_target: int = int(ceil(float(base_target) * 0.85))
	var max_target: int = int(floor(float(base_target) * 1.15))
	var rerolled: int = _rng.randi_range(min_target, max_target)
	rerolled = int(round(float(rerolled) / 5.0)) * 5
	rerolled = max(5, rerolled)
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
	_update_reroll_button()
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
	gs.current_week += 1
	gs.start_week()
	get_tree().change_scene_to_file("res://scenes/NestSelect.tscn")

func _roll_offers(count: int, week: int) -> Array:
	var chosen: Array = []
	for i in range(count):
		var rarity: String = gs.roll_shop_rarity(week, _rng)
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
	ritual_panel.visible = true
	pool_area.visible = false
	if pack_panel:
		pack_panel.visible = false
	_update_directors_cut()
	_setup_recruits()

func _show_pool_view() -> void:
	shop_tab.button_pressed = false
	pool_tab.button_pressed = true
	offer_area.visible = false
	recruit_panel.visible = false
	ritual_panel.visible = false
	pool_area.visible = true
	if pack_panel:
		pack_panel.visible = false
	_set_pack_mode(false)
	_refresh_pool_list()

func _refresh_pool_list() -> void:
	for child in pool_list.get_children():
		child.queue_free()
	var summary: Dictionary = gs.pool_summary_counts()
	pool_summary.text = "Pool Size: %d | Blood: %d  Bone: %d  Void: %d  Soul: %d | Avg Tier: %.1f" % [
		summary["total"],
		summary["blood"],
		summary["bone"],
		summary["void"],
		summary["soul"],
		float(summary["avg_tier"]),
	]
	for f in gs.pool:
		var row: Button = Button.new()
		row.toggle_mode = true
		var fid: int = int(f.get("id", -1))
		var favored_a: int = int(gs.favored_breeder_ids[0]) if gs.favored_breeder_ids.size() > 0 else -1
		var favored_b: int = int(gs.favored_breeder_ids[1]) if gs.favored_breeder_ids.size() > 1 else -1
		var favored_mark: String = ""
		if fid == favored_a:
			favored_mark = " [Fav A]"
		elif fid == favored_b:
			favored_mark = " [Fav B]"
		row.text = "%s  T%d  %s  (%s #%d)" % [
			f["trait"],
			int(f["tier"]),
			_trait_display(str(f.get("trait_id", ""))),
			f["origin_tag"],
			fid,
		]
		row.text += favored_mark
		if pack_select_mode:
			row.button_pressed = pack_selected_ids.has(fid)
		else:
			row.button_pressed = (fid == selected_pool_id)
		var trait_rarity: String = str(gs._trait_rarity(str(f.get("trait_id", ""))))
		if trait_rarity == "RARE":
			row.add_theme_color_override("font_color", Color(0.85, 0.7, 0.2))
		elif trait_rarity == "LEGENDARY":
			row.add_theme_color_override("font_color", Color(0.95, 0.55, 0.2))
		row.pressed.connect(_on_pool_row_pressed.bind(fid))
		pool_list.add_child(row)

	_update_pool_actions()

func _trait_info(trait_id: String) -> Dictionary:
	if trait_id == "":
		return {}
	if gs.TRAIT_REGISTRY.has(trait_id):
		return gs.TRAIT_REGISTRY[trait_id]
	var combo_info: Dictionary = gs.get_combo_trait(trait_id)
	if not combo_info.is_empty():
		return combo_info
	return {}

func _trait_display(trait_id: String) -> String:
	if trait_id == "":
		return "None"
	var info: Dictionary = _trait_info(trait_id)
	if info.is_empty():
		return trait_id
	var rarity: String = str(info.get("rarity", ""))
	var name: String = str(info.get("name", trait_id))
	var mark: String = "[C]"
	if rarity == "RARE":
		mark = "[R]"
	elif rarity == "LEGENDARY":
		mark = "[L]"
	return "%s %s" % [mark, name]

func _trait_color(trait_name: String) -> Color:
	match trait_name:
		"BLOOD":
			return Color(0.75, 0.2, 0.2)
		"BONE":
			return Color(0.85, 0.85, 0.85)
		"VOID":
			return Color(0.25, 0.2, 0.35)
		"SOUL":
			return Color(0.55, 0.55, 0.55)
		_:
			return Color(0.5, 0.5, 0.5)

func _on_pool_row_pressed(follower_id: int) -> void:
	if pack_select_mode:
		if pack_selected_ids.has(follower_id):
			pack_selected_ids.erase(follower_id)
		else:
			if pack_selected_ids.size() >= 10:
				return
			pack_selected_ids.append(follower_id)
	else:
		if selected_pool_id == follower_id:
			selected_pool_id = -1
		else:
			selected_pool_id = follower_id
	_refresh_pool_list()

func _update_pool_actions() -> void:
	var cull_ok: bool = gs.relic_inventory["Culling Knife"] > 0 and not gs.shop_cull_used and selected_pool_id >= 0
	if gs.apostle_id == selected_pool_id:
		cull_ok = false
	pool_cull.disabled = pack_select_mode or not cull_ok
	var can_set_favored: bool = gs.relic_inventory["Selective Breeding Scroll"] > 0 and selected_pool_id >= 0
	pool_fav_a.disabled = pack_select_mode or not can_set_favored
	pool_fav_b.disabled = pack_select_mode or not can_set_favored
	pool_ascend.disabled = pack_select_mode or not (gs.relic_inventory["The Soul Lantern"] > 0 and not gs.soul_lantern_used and selected_pool_id >= 0)
	pool_apostle.disabled = pack_select_mode or not (gs.relic_inventory["First Apostle"] > 0 and gs.apostle_id == -1 and selected_pool_id >= 0)
	if pack_select_mode:
		pool_pack.text = "Relic Pack (%d/10)" % pack_selected_ids.size()
		pool_pack.disabled = pack_selected_ids.size() != 10
	else:
		pool_pack.text = "Relic Pack (0/10)"
		pool_pack.disabled = gs.pool.size() < 10

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
	if gs.relic_inventory["Selective Breeding Scroll"] <= 0:
		return
	gs.set_favored_breeder(selected_pool_id, 0)
	_refresh_pool_list()

func _on_pool_favored_b() -> void:
	if selected_pool_id < 0:
		return
	if gs.relic_inventory["Selective Breeding Scroll"] <= 0:
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

func _build_pack_panel() -> void:
	pack_panel = PanelContainer.new()
	pack_panel.visible = false
	pack_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	pack_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var center := CenterContainer.new()
	pack_panel.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(520, 220)
	center.add_child(panel)
	var vbox := VBoxContainer.new()
	panel.add_child(vbox)
	pack_label = Label.new()
	pack_label.text = "Choose a relic"
	pack_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(pack_label)
	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(hbox)
	for i in range(2):
		var choice_panel := PanelContainer.new()
		choice_panel.custom_minimum_size = Vector2(240, 160)
		var choice_vbox := VBoxContainer.new()
		choice_panel.add_child(choice_vbox)
		var name_label := Label.new()
		name_label.text = "-"
		name_label.autowrap_mode = 3
		choice_vbox.add_child(name_label)
		var rarity_label := Label.new()
		rarity_label.text = ""
		choice_vbox.add_child(rarity_label)
		var desc_label := Label.new()
		desc_label.text = ""
		desc_label.autowrap_mode = 3
		desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		choice_vbox.add_child(desc_label)
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(200, 36)
		btn.text = "Choose"
		btn.pressed.connect(_on_pack_choice.bind(i))
		choice_vbox.add_child(btn)
		hbox.add_child(choice_panel)
		pack_buttons.append(btn)
	add_child(pack_panel)

func _set_pack_mode(enabled: bool) -> void:
	pack_select_mode = enabled
	pack_selected_ids.clear()
	selected_pool_id = -1
	_update_pool_actions()

func _on_pool_pack_pressed() -> void:
	if not pack_select_mode:
		_set_pack_mode(true)
		_refresh_pool_list()
		return
	if pack_selected_ids.size() != 10:
		return
	_start_relic_pack()

func _start_relic_pack() -> void:
	var selected: Array[Dictionary] = []
	for f in gs.pool:
		if pack_selected_ids.has(int(f.get("id", -1))):
			selected.append(f)
	if selected.size() != 10:
		return
	for f in selected:
		for i in range(gs.pool.size()):
			if int(gs.pool[i].get("id", -1)) == int(f.get("id", -1)):
				gs.pool.remove_at(i)
				break
	_generate_pack_offers(selected)
	_show_pack_panel()
	_set_pack_mode(false)
	_refresh_pool_list()

func _generate_pack_offers(selected: Array[Dictionary]) -> void:
	pack_offers.clear()
	var total_tier: int = 0
	for f in selected:
		total_tier += int(f.get("tier", 0))
	var avg_tier: float = float(total_tier) / 10.0
	var rare_bonus: float = clamp((avg_tier - 5.0) * 0.02, 0.0, 0.10)
	var legendary_bonus: float = clamp((avg_tier - 7.0) * 0.01, 0.0, 0.04)
	var rarity_a: String = gs.roll_shop_rarity(gs.current_week, _rng, rare_bonus, legendary_bonus, true)
	var pick_a: String = _pick_from_rarity(rarity_a, pack_offers)
	if pick_a == "":
		pick_a = _pick_from_rarity(_fallback_rarity(rarity_a), pack_offers)
	if pick_a != "":
		pack_offers.append(pick_a)
	var rarity_b: String = gs.roll_shop_rarity(gs.current_week, _rng, rare_bonus, legendary_bonus, false)
	var pick_b: String = _pick_from_rarity(rarity_b, pack_offers)
	if pick_b == "":
		pick_b = _pick_from_rarity(_fallback_rarity(rarity_b), pack_offers)
	if pick_b != "":
		pack_offers.append(pick_b)
	while pack_offers.size() < 2:
		var fallback: String = _pick_from_rarity("COMMON", pack_offers)
		if fallback == "":
			break
		pack_offers.append(fallback)

func _show_pack_panel() -> void:
	var hbox := pack_buttons[0].get_parent().get_parent()
	for i in range(pack_buttons.size()):
		var choice_panel: PanelContainer = hbox.get_child(i)
		var choice_vbox: VBoxContainer = choice_panel.get_child(0)
		var name_label: Label = choice_vbox.get_child(0)
		var rarity_label: Label = choice_vbox.get_child(1)
		var desc_label: Label = choice_vbox.get_child(2)
		var pick: String = pack_offers[i] if i < pack_offers.size() else ""
		if pick == "":
			name_label.text = "-"
			rarity_label.text = ""
			desc_label.text = ""
			pack_buttons[i].disabled = true
		else:
			name_label.text = pick
			var rarity: String = gs.RELIC_DEFS[pick]["rarity"]
			rarity_label.text = "Rarity: %s" % rarity
			rarity_label.add_theme_color_override("font_color", _rarity_color(rarity))
			desc_label.text = gs.RELIC_DEFS[pick]["desc"]
			pack_buttons[i].disabled = false
	pack_panel.visible = true

func _on_pack_choice(index: int) -> void:
	if index < 0 or index >= pack_offers.size():
		return
	var pick: String = pack_offers[index]
	if pick == "":
		return
	gs.add_relic(pick)
	pack_panel.visible = false
	pack_offers.clear()
	_render_offers(gs.current_week)
