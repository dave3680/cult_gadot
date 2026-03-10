extends Control

@onready var shop_label: Label = $RootVBox/TopBar/TopBarVBox/TopMainRow/ShopLabel
@onready var top_center_label: Label = $RootVBox/TopBar/TopBarVBox/TopMainRow/TopCenterLabel
@onready var blood_label: Label = $RootVBox/TopBar/TopBarVBox/TopMainRow/RightControls/BloodWrap/BloodLabel
@onready var menu_button: Button = $RootVBox/TopBar/TopBarVBox/TopMainRow/RightControls/MenuButton
@onready var skip_button: Button = $RootVBox/BottomArea/BottomHBox/SkipButton
@onready var shop_tab: Button = $RootVBox/TopBar/TopBarVBox/TopTabsRow/Tabs/ShopTab
@onready var pool_tab: Button = $RootVBox/TopBar/TopBarVBox/TopTabsRow/Tabs/PoolTab
@onready var offer_area: Control = $RootVBox/OfferArea
@onready var offer_row: HBoxContainer = $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow
@onready var reroll_button: Button = $RootVBox/RelicControls/RerollRelics
@onready var directors_cut: Button = $RootVBox/RelicControls/DirectorsCut
@onready var ritual_panel: Control = $RootVBox/RitualPanel
@onready var ritual_title: Label = $RootVBox/RitualPanel/RitualVBox/RitualTitle
@onready var ritual_desc: Label = $RootVBox/RitualPanel/RitualVBox/RitualDesc
@onready var ritual_buy: Button = $RootVBox/RitualPanel/RitualVBox/RitualBuy
@onready var recruit_panel: Control = $RootVBox/RecruitPanel
@onready var recruit_title: Label = $RootVBox/RecruitPanel/RecruitVBox/RecruitHeader/RecruitTitle
@onready var recruit_msg: Label = $RootVBox/RecruitPanel/RecruitVBox/RecruitHeader/RecruitMsg
@onready var pool_area: Control = $RootVBox/PoolArea
@onready var pool_summary: Label = $RootVBox/PoolArea/PoolVBox/PoolSummary
@onready var pool_list: VBoxContainer = $RootVBox/PoolArea/PoolVBox/PoolScroll/PoolList
@onready var pool_actions: HBoxContainer = $RootVBox/PoolArea/PoolVBox/PoolActions
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
var rotary_select_mode: bool = false
var rotary_selected_ids: Array[int] = []
var pool_rotary: Button
var pack_panel: PanelContainer
var pack_label: Label
var pack_buttons: Array[Button] = []
var pack_offers: Array[String] = []
var offer_hover_tweens: Dictionary = {}

func _ready() -> void:
	_rng.randomize()
	offer_nodes = [
		{
			"card": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer1,
			"banner": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer1/Offer1VBox/Offer1Banner,
			"name": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer1/Offer1VBox/Offer1Name,
			"rarity": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer1/Offer1VBox/Offer1Banner/Offer1Rarity,
			"category": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer1/Offer1VBox/Offer1Category,
			"desc": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer1/Offer1VBox/Offer1Desc,
			"cost": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer1/Offer1VBox/Offer1Cost,
			"buy": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer1/Offer1VBox/Offer1Buy,
		},
		{
			"card": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer2,
			"banner": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer2/Offer2VBox/Offer2Banner,
			"name": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer2/Offer2VBox/Offer2Name,
			"rarity": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer2/Offer2VBox/Offer2Banner/Offer2Rarity,
			"category": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer2/Offer2VBox/Offer2Category,
			"desc": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer2/Offer2VBox/Offer2Desc,
			"cost": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer2/Offer2VBox/Offer2Cost,
			"buy": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer2/Offer2VBox/Offer2Buy,
		},
		{
			"card": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer3,
			"banner": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer3/Offer3VBox/Offer3Banner,
			"name": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer3/Offer3VBox/Offer3Name,
			"rarity": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer3/Offer3VBox/Offer3Banner/Offer3Rarity,
			"category": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer3/Offer3VBox/Offer3Category,
			"desc": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer3/Offer3VBox/Offer3Desc,
			"cost": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer3/Offer3VBox/Offer3Cost,
			"buy": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer3/Offer3VBox/Offer3Buy,
		},
		{
			"card": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer4,
			"banner": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer4/Offer4VBox/Offer4Banner,
			"name": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer4/Offer4VBox/Offer4Name,
			"rarity": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer4/Offer4VBox/Offer4Banner/Offer4Rarity,
			"category": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer4/Offer4VBox/Offer4Category,
			"desc": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer4/Offer4VBox/Offer4Desc,
			"cost": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer4/Offer4VBox/Offer4Cost,
			"buy": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer4/Offer4VBox/Offer4Buy,
		},
		{
			"card": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer5,
			"banner": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer5/Offer5VBox/Offer5Banner,
			"name": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer5/Offer5VBox/Offer5Name,
			"rarity": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer5/Offer5VBox/Offer5Banner/Offer5Rarity,
			"category": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer5/Offer5VBox/Offer5Category,
			"desc": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer5/Offer5VBox/Offer5Desc,
			"cost": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer5/Offer5VBox/Offer5Cost,
			"buy": $RootVBox/OfferArea/OfferMargin/OfferCenter/OfferRow/Offer5/Offer5VBox/Offer5Buy,
		},
	]
	for i in range(offer_nodes.size()):
		var relic_buy: Button = offer_nodes[i]["buy"]
		relic_buy.pressed.connect(_on_buy_pressed.bind(i))
		var card: PanelContainer = offer_nodes[i]["card"]
		card.mouse_entered.connect(_on_offer_hover.bind(i, true))
		card.mouse_exited.connect(_on_offer_hover.bind(i, false))
	recruit_nodes = [
		{
			"trait": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit1/Recruit1VBox/Recruit1Trait,
			"stripe": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit1/Recruit1VBox/Recruit1Stripe,
			"tier": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit1/Recruit1VBox/Recruit1Tier,
			"origin": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit1/Recruit1VBox/Recruit1Origin,
			"cost": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit1/Recruit1VBox/Recruit1Cost,
			"card": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit1,
			"buy": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit1/Recruit1VBox/Recruit1Buy,
		},
		{
			"trait": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit2/Recruit2VBox/Recruit2Trait,
			"stripe": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit2/Recruit2VBox/Recruit2Stripe,
			"tier": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit2/Recruit2VBox/Recruit2Tier,
			"origin": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit2/Recruit2VBox/Recruit2Origin,
			"cost": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit2/Recruit2VBox/Recruit2Cost,
			"card": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit2,
			"buy": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit2/Recruit2VBox/Recruit2Buy,
		},
		{
			"trait": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit3/Recruit3VBox/Recruit3Trait,
			"stripe": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit3/Recruit3VBox/Recruit3Stripe,
			"tier": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit3/Recruit3VBox/Recruit3Tier,
			"origin": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit3/Recruit3VBox/Recruit3Origin,
			"cost": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit3/Recruit3VBox/Recruit3Cost,
			"card": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit3,
			"buy": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit3/Recruit3VBox/Recruit3Buy,
		},
		{
			"trait": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit4/Recruit4VBox/Recruit4Trait,
			"stripe": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit4/Recruit4VBox/Recruit4Stripe,
			"tier": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit4/Recruit4VBox/Recruit4Tier,
			"origin": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit4/Recruit4VBox/Recruit4Origin,
			"cost": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit4/Recruit4VBox/Recruit4Cost,
			"card": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit4,
			"buy": $RootVBox/RecruitPanel/RecruitVBox/RecruitRow/Recruit4/Recruit4VBox/Recruit4Buy,
		},
	]
	for i in range(recruit_nodes.size()):
		var buy_button: Button = recruit_nodes[i]["buy"]
		buy_button.pressed.connect(_on_buy_recruit.bind(i))

	skip_button.pressed.connect(_on_skip_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
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
	_build_rotary_button()
	_build_pack_panel()
	gs.start_shop_visit()
	gs.shop_rerolls_used = 0
	gs.shop_cull_used = false
	gs.shop_copy_used = false
	if gs.free_reroll_next_shop:
		gs.shop_free_reroll_available = true
		gs.free_reroll_next_shop = false
	gs.ritual_card_offer = ""
	if gs.relic_inventory["Spare Chalice"] > 0 and gs.blood_currency == 0:
		gs.add_blood(2)
	_apply_ui_theme()
	_setup_offers()
	gs.generate_shop_recruits()
	_setup_recruits()
	_show_shop_view()

func _setup_offers() -> void:
	_update_top_bar()

	var week_cleared: int = gs.current_week
	offers = _roll_offers(3, week_cleared, gs.guaranteed_rare_next_shop)
	gs.guaranteed_rare_next_shop = false
	_offer_legendary_if_needed()
	_record_codex_offer_discoveries()
	_render_offers(week_cleared)
	_update_reroll_button()
	_setup_ritual_offer()
	_update_directors_cut()

func _record_codex_offer_discoveries() -> void:
	_record_codex_relic_discoveries(offers)

func _record_codex_pack_discoveries() -> void:
	_record_codex_relic_discoveries(pack_offers)

func _record_codex_relic_discoveries(relic_names: Array) -> void:
	for offer_name in relic_names:
		if str(offer_name) == "":
			continue
		gs.codex_mark_relic_seen(str(offer_name))

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
	if offer_name == "The Palimpsest":
		offers = _roll_offers(3, gs.current_week, false)
		_record_codex_offer_discoveries()
	else:
		offers[index] = ""
	_update_top_bar()
	_render_offers(gs.current_week)
	_update_reroll_button()

func _rarity_color(rarity: String) -> Color:
	match rarity:
		"COMMON":
			return Color(0.56, 0.6, 0.68)
		"UNCOMMON":
			return Color(0.4, 0.62, 0.46)
		"RARE":
			return Color(0.45, 0.44, 0.72)
		"LEGENDARY":
			return Color(0.72, 0.58, 0.32)
		_:
			return Color(0.56, 0.6, 0.68)

func _update_reroll_button() -> void:
	var reroll_cost: int = 5
	if gs.shop_rerolls_used == 0 and (gs.relic_inventory["Sharpened Chalk"] > 0 or gs.shop_free_reroll_available):
		reroll_cost = 0
	reroll_button.text = "Reroll Relics (%d)" % reroll_cost
	reroll_button.disabled = gs.blood_currency < reroll_cost or gs.shop_rerolls_used >= 1

func _render_offers(week_cleared: int) -> void:
	var visible_count: int = min(offers.size(), offer_nodes.size())
	for i in range(offer_nodes.size()):
		var node: Dictionary = offer_nodes[i]
		var card: PanelContainer = node["card"]
		var buy_button: Button = node["buy"]
		(node["rarity"] as Label).add_theme_font_size_override("font_size", 12)
		(node["category"] as Label).add_theme_font_size_override("font_size", 11)
		(node["category"] as Label).add_theme_color_override("font_color", Color(0.7, 0.7, 0.74))
		(node["name"] as Label).add_theme_font_size_override("font_size", 24)
		(node["name"] as Label).add_theme_color_override("font_color", Color(0.93, 0.93, 0.96))
		(node["desc"] as Label).add_theme_font_size_override("font_size", 14)
		(node["cost"] as Label).add_theme_font_size_override("font_size", 16)
		(node["cost"] as Label).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if i >= offers.size():
			card.visible = false
			continue
		card.visible = true
		card.position.y = 0.0
		var offer_name: String = offers[i]
		if offer_name == "":
			node["name"].text = "-"
			node["rarity"].text = "SOLD OUT"
			node["category"].text = ""
			node["desc"].text = "This slot is sold out."
			node["cost"].text = ""
			node["cost"].remove_theme_color_override("font_color")
			buy_button.disabled = true
			buy_button.text = "Owned"
			_apply_offer_card_style(card, "COMMON", true, false)
		else:
			var relic_def: Dictionary = gs.RELIC_DEFS[offer_name]
			var rarity: String = str(relic_def.get("rarity", "COMMON"))
			var category: String = str(relic_def.get("category", "RELIC"))
			var stackable: bool = bool(relic_def.get("stacks", false))
			var already_owned: bool = int(gs.relic_inventory.get(offer_name, 0)) > 0
			var owned_non_stackable: bool = already_owned and not stackable
			node["name"].text = offer_name
			var cost: int = gs.get_shop_cost(week_cleared, rarity)
			node["rarity"].text = rarity
			node["rarity"].add_theme_color_override("font_color", Color(0.95, 0.95, 0.98))
			node["category"].text = category
			node["desc"].text = str(relic_def.get("desc", ""))
			node["cost"].text = "%d Blood" % cost
			var can_afford: bool = gs.can_afford_relic(cost)
			node["cost"].add_theme_color_override("font_color", Color(0.9, 0.38, 0.38) if (not can_afford and not owned_non_stackable) else Color(0.9, 0.9, 0.9))
			buy_button.disabled = owned_non_stackable or not can_afford
			buy_button.text = "Owned" if owned_non_stackable else "Buy"
			_apply_offer_card_style(card, rarity, owned_non_stackable, false)
	_layout_offer_cards(visible_count)

func _layout_offer_cards(visible_count: int) -> void:
	var widths := {
		1: 420.0,
		2: 320.0,
		3: 270.0,
		4: 230.0,
		5: 200.0,
	}
	var card_w: float = widths.get(clampi(visible_count, 1, 5), 240.0)
	for node in offer_nodes:
		var card: PanelContainer = node["card"]
		if not card.visible:
			continue
		card.custom_minimum_size = Vector2(card_w, 340)
		card.size = card.custom_minimum_size

func _update_top_bar() -> void:
	shop_label.text = "Shop"
	top_center_label.text = "Week %d/%d" % [gs.current_week, gs.get_max_weeks()]
	blood_label.text = str(gs.blood_currency)

func _on_menu_pressed() -> void:
	var overlay: Node = get_node_or_null("/root/GlobalMenuOverlay")
	if overlay != null:
		if overlay.has_method("open_menu"):
			overlay.call("open_menu")
			return
		if overlay.has_method("_on_menu_pressed"):
			overlay.call("_on_menu_pressed")

func _apply_ui_theme() -> void:
	_set_panel_style($RootVBox/TopBar, Color(0.12, 0.11, 0.14, 0.94), Color(0.22, 0.2, 0.24, 0.9), 1, 8)
	_set_panel_style($RootVBox/RecruitPanel, Color(0.13, 0.12, 0.16, 0.95), Color(0.24, 0.22, 0.27, 0.9), 1, 10)
	_set_panel_style($RootVBox/RitualPanel, Color(0.13, 0.12, 0.16, 0.95), Color(0.24, 0.22, 0.27, 0.9), 1, 10)
	_set_panel_style($RootVBox/BottomArea, Color(0.11, 0.1, 0.13, 0.96), Color(0.22, 0.2, 0.24, 0.9), 1, 8)
	$RootVBox/TopBar/TopBarVBox/TopMainRow/RightControls/BloodWrap/BloodIcon.color = Color(0.65, 0.1, 0.12, 1.0)
	shop_label.add_theme_font_size_override("font_size", 30)
	top_center_label.add_theme_font_size_override("font_size", 16)
	top_center_label.add_theme_color_override("font_color", Color(0.72, 0.72, 0.77))
	blood_label.add_theme_font_size_override("font_size", 24)
	shop_tab.custom_minimum_size = Vector2(120, 34)
	pool_tab.custom_minimum_size = Vector2(120, 34)
	recruit_title.add_theme_font_size_override("font_size", 20)
	recruit_msg.add_theme_color_override("font_color", Color(0.9, 0.55, 0.55))
	skip_button.custom_minimum_size = Vector2(520, 56)
	reroll_button.add_theme_font_size_override("font_size", 14)
	var reroll_style: StyleBoxFlat = StyleBoxFlat.new()
	reroll_style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	reroll_style.border_color = Color(0.8, 0.8, 0.85, 0.95)
	reroll_style.border_width_left = 2
	reroll_style.border_width_right = 2
	reroll_style.border_width_top = 2
	reroll_style.border_width_bottom = 2
	reroll_style.corner_radius_top_left = 8
	reroll_style.corner_radius_top_right = 8
	reroll_style.corner_radius_bottom_left = 8
	reroll_style.corner_radius_bottom_right = 8
	reroll_button.add_theme_stylebox_override("normal", reroll_style)
	reroll_button.add_theme_stylebox_override("hover", reroll_style)
	reroll_button.add_theme_stylebox_override("pressed", reroll_style)
	reroll_button.add_theme_stylebox_override("disabled", reroll_style)

func _set_panel_style(panel: PanelContainer, bg: Color, border: Color, border_width: int, radius: int) -> void:
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.border_width_left = border_width
	sb.border_width_right = border_width
	sb.border_width_top = border_width
	sb.border_width_bottom = border_width
	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = radius
	sb.corner_radius_bottom_left = radius
	sb.corner_radius_bottom_right = radius
	panel.add_theme_stylebox_override("panel", sb)

func _apply_offer_card_style(card: PanelContainer, rarity: String, desaturated: bool, hovered: bool) -> void:
	var bg: Color = Color(0.16, 0.15, 0.19, 0.98)
	var border: Color = Color(0.28, 0.27, 0.33, 0.9)
	if desaturated:
		bg = Color(0.14, 0.14, 0.15, 0.95)
		border = Color(0.34, 0.34, 0.34, 0.9)
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.border_width_left = 1
	sb.border_width_right = 1
	sb.border_width_top = 1
	sb.border_width_bottom = 1
	sb.corner_radius_top_left = 10
	sb.corner_radius_top_right = 10
	sb.corner_radius_bottom_left = 10
	sb.corner_radius_bottom_right = 10
	sb.shadow_color = Color(0.0, 0.0, 0.0, 0.45)
	sb.shadow_size = 9 if hovered else 5
	card.add_theme_stylebox_override("panel", sb)
	card.modulate = Color(0.72, 0.72, 0.72, 1.0) if desaturated else Color(1, 1, 1, 1)
	var rarity_banner: PanelContainer = offer_nodes[_offer_card_index(card)]["banner"]
	var rb: StyleBoxFlat = StyleBoxFlat.new()
	rb.bg_color = _rarity_color(rarity)
	if desaturated:
		rb.bg_color = rb.bg_color.lerp(Color(0.3, 0.3, 0.3), 0.65)
	rb.corner_radius_top_left = 6
	rb.corner_radius_top_right = 6
	rb.corner_radius_bottom_left = 4
	rb.corner_radius_bottom_right = 4
	rarity_banner.add_theme_stylebox_override("panel", rb)

func _offer_card_index(card: PanelContainer) -> int:
	for i in range(offer_nodes.size()):
		if offer_nodes[i]["card"] == card:
			return i
	return 0

func _on_offer_hover(index: int, entering: bool) -> void:
	if index < 0 or index >= offer_nodes.size():
		return
	var node: Dictionary = offer_nodes[index]
	var card: PanelContainer = node["card"]
	if not card.visible:
		return
	if offer_hover_tweens.has(index):
		var existing: Tween = offer_hover_tweens[index]
		if existing != null and is_instance_valid(existing):
			existing.kill()
	var t: Tween = create_tween()
	offer_hover_tweens[index] = t
	t.set_trans(Tween.TRANS_SINE)
	t.set_ease(Tween.EASE_OUT)
	var y_target: float = -5.0 if entering else 0.0
	t.tween_property(card, "position:y", y_target, 0.1)
	var rarity_text: String = str((node["rarity"] as Label).text)
	_apply_offer_card_style(card, rarity_text, (node["buy"] as Button).text == "Owned", entering)

func _apply_recruit_card_style(card: PanelContainer) -> void:
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color(0.17, 0.16, 0.19, 0.98)
	sb.border_color = Color(0.3, 0.29, 0.34, 0.9)
	sb.border_width_left = 1
	sb.border_width_right = 1
	sb.border_width_top = 1
	sb.border_width_bottom = 1
	sb.corner_radius_top_left = 10
	sb.corner_radius_top_right = 10
	sb.corner_radius_bottom_left = 10
	sb.corner_radius_bottom_right = 10
	sb.shadow_color = Color(0.0, 0.0, 0.0, 0.42)
	sb.shadow_size = 4
	card.add_theme_stylebox_override("panel", sb)

func _apply_ritual_style(locked: bool) -> void:
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color(0.15, 0.15, 0.16, 0.96) if locked else Color(0.15, 0.12, 0.17, 0.96)
	sb.border_color = Color(0.35, 0.35, 0.37, 0.9) if locked else Color(0.36, 0.28, 0.4, 0.9)
	sb.border_width_left = 1
	sb.border_width_right = 1
	sb.border_width_top = 1
	sb.border_width_bottom = 1
	sb.corner_radius_top_left = 10
	sb.corner_radius_top_right = 10
	sb.corner_radius_bottom_left = 10
	sb.corner_radius_bottom_right = 10
	(ritual_panel as PanelContainer).add_theme_stylebox_override("panel", sb)

func _offer_legendary_if_needed() -> void:
	# Guarantee at least one legendary offer on week 6+ if none has appeared yet.
	if gs.legendary_seen_in_shop:
		return
	if gs.current_week < 6:
		return
	# Check if a legendary is already in the current offers.
	for offer_name in offers:
		if offer_name != "" and gs.RELIC_DEFS[offer_name]["rarity"] == "LEGENDARY":
			gs.legendary_seen_in_shop = true
			return
	# Force a legendary into a random slot, replacing the lowest-value offer.
	var legendary_pick: String = _pick_from_rarity("LEGENDARY", offers)
	if legendary_pick == "":
		return
	# Replace the first non-empty offer slot (slot 0).
	for i in range(offers.size()):
		if offers[i] != "":
			offers[i] = legendary_pick
			gs.legendary_seen_in_shop = true
			return

func _setup_ritual_offer() -> void:
	ritual_panel.visible = true
	if gs.relic_inventory["Scarlet Planetarium"] <= 0:
		ritual_title.text = "Ritual Card [LOCKED]"
		ritual_desc.text = "Requires Scarlet Planetarium to unlock ritual offers."
		ritual_buy.text = "Locked"
		ritual_buy.disabled = true
		_apply_ritual_style(true)
		return
	ritual_title.text = "Ritual Card (Cost: 2 Blood)"
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
	ritual_buy.text = "Buy Ritual"
	if gs.ritual_card_slot != "":
		ritual_desc.text += "\nHeld: %s" % gs.ritual_card_slot
	_apply_ritual_style(false)

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
	_update_top_bar()

func _on_buy_ritual() -> void:
	if gs.ritual_card_offer == "" or gs.ritual_card_slot != "":
		return
	if gs.blood_currency < 2:
		return
	gs.blood_currency -= 2
	gs.ritual_card_slot = gs.ritual_card_offer
	gs.ritual_card_offer = ""
	gs.shop_any_purchase_this_visit = true
	_setup_ritual_offer()
	_update_top_bar()

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
	var max_uses: int = gs.get_directors_cut_max_uses()
	var used: bool = gs.director_uses_this_shop >= max_uses
	directors_cut.disabled = used
	directors_cut.text = "Director's Cut: Next %d (%d/%d)" % [base_target, gs.director_uses_this_shop, max_uses]

func _on_directors_cut() -> void:
	if gs.relic_inventory["Director's Cut"] <= 0:
		return
	var next_week: int = gs.current_week + 1
	if next_week > gs.get_max_weeks():
		return
	if gs.director_uses_this_shop >= gs.get_directors_cut_max_uses():
		return
	var base_target: int = gs.get_week_target(next_week)
	var pct: float = gs.get_directors_cut_range_pct()
	var min_target: int = int(ceil(float(base_target) * (1.0 - pct)))
	var max_target: int = int(floor(float(base_target) * (1.0 + pct)))
	var rerolled: int = _rng.randi_range(min_target, max_target)
	rerolled = int(round(float(rerolled) / 5.0)) * 5
	rerolled = max(5, rerolled)
	gs.next_week_target_overrides[next_week] = rerolled
	gs.director_uses_this_shop += 1
	_update_directors_cut()

func _setup_recruits() -> void:
	recruit_msg.text = ""
	recruit_title.text = "Recruits"
	for i in range(recruit_nodes.size()):
		var node: Dictionary = recruit_nodes[i]
		if i >= gs.shop_recruit_offers.size():
			(node["card"] as Control).visible = false
			continue
		var card: PanelContainer = node["card"]
		card.visible = true
		var f: Dictionary = gs.shop_recruit_offers[i]
		var trait_name: String = str(f.get("trait", ""))
		var trait_id: String = str(f.get("trait_id", ""))
		(node["stripe"] as ColorRect).color = _trait_color(trait_name)
		var tier_label: Label = node["tier"]
		tier_label.text = "T%d" % int(f["tier"])
		tier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tier_label.add_theme_font_size_override("font_size", 28)
		var type_label: Label = node["origin"]
		type_label.text = trait_name
		type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		type_label.add_theme_font_size_override("font_size", 14)
		type_label.add_theme_color_override("font_color", _trait_color(trait_name).lerp(Color(1, 1, 1), 0.2))
		var trait_line: String = "No Trait"
		if trait_id != "":
			trait_line = _trait_display(trait_id)
		trait_line += _follower_trait_badge(f)
		var trait_label: Label = node["trait"]
		trait_label.text = trait_line
		trait_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		trait_label.add_theme_font_size_override("font_size", 12)
		trait_label.add_theme_color_override("font_color", Color(0.62, 0.62, 0.66) if trait_id == "" else Color(0.86, 0.86, 0.9))
		var buy_button: Button = node["buy"]
		var is_free: bool = i < gs.shop_recruit_free.size() and bool(gs.shop_recruit_free[i])
		var can_copy: bool = gs.shop_recruit_purchased[i] and gs.relic_inventory["Votive Mirror"] > 0 and not gs.shop_copy_used
		buy_button.disabled = ((not is_free) and gs.blood_currency < 1) or (gs.shop_recruit_purchased[i] and not can_copy) or gs.is_pool_at_capacity()
		(node["cost"] as Label).text = "%d Blood" % (0 if is_free else 1)
		(node["cost"] as Label).add_theme_color_override("font_color", Color(0.9, 0.38, 0.38) if (not is_free and gs.blood_currency < 1) else Color(0.9, 0.9, 0.9))
		(node["cost"] as Label).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if gs.shop_recruit_purchased[i] and not can_copy:
			buy_button.text = "Hired"
		elif can_copy:
			buy_button.text = "Buy Copy (%d)" % (0 if is_free else 1)
		else:
			buy_button.text = "Hire (%d)" % (0 if is_free else 1)
		_apply_recruit_card_style(card)

func _on_buy_recruit(index: int) -> void:
	var result: Dictionary = gs.buy_shop_recruit(index)
	if not result["ok"]:
		if result["reason"] == "full":
			recruit_msg.text = "Pool is full."
		elif result["reason"] == "blood":
			recruit_msg.text = "Not enough Blood."
		return
	_update_top_bar()
	_setup_ritual_offer()
	_update_reroll_button()
	_setup_recruits()
	if pool_area.visible:
		_refresh_pool_list()

func _on_skip_pressed() -> void:
	_finish_shop()

func _finish_shop() -> void:
	var before: int = gs.blood_currency
	var interest_copies: int = int(gs.relic_inventory.get("Crimson Interest", 0)) + int(gs.tithe_accelerator_interest_bonus)
	var crimson_compound_copies: int = int(gs.relic_inventory.get("Crimson Compound", 0))
	var usurer_copies: int = int(gs.relic_inventory.get("Usurer's Mark", 0))
	var interest_gain: int = 0
	if interest_copies > 0:
		var divisor: int = max(1, 5 - crimson_compound_copies)
		var fires: int = 1 + max(0, usurer_copies - 1)
		for i in range(fires):
			var gain_i: int = int(floor(float(gs.blood_currency) / float(divisor))) * interest_copies
			if gain_i <= 0:
				continue
			gs.add_blood(gain_i)
			interest_gain += gain_i
	if gs.relic_inventory.get("The Waiting Bell", 0) > 0 and not gs.shop_any_purchase_this_visit:
		gs.add_blood(10)
		interest_gain += 10
	gs.finalize_shop_visit()
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

func _roll_offers(count: int, week: int, guarantee_rare_shop: bool = false) -> Array:
	var chosen: Array = []
	for i in range(count):
		var guarantee_slot: bool = guarantee_rare_shop and i == 0
		var rarity: String = gs.roll_shop_rarity(week, _rng, 0.0, 0.0, guarantee_slot)
		if gs.shop_rerolls_used > 0 and gs.relic_inventory.get("The Faithful Scribe", 0) > 0:
			rarity = _raise_rarity_floor(rarity, int(gs.relic_inventory.get("The Faithful Scribe", 0)))
		var pick: String = _pick_from_rarity(rarity, chosen)
		if pick == "":
			pick = _pick_from_rarity(_fallback_rarity(rarity), chosen)
		if pick != "":
			chosen.append(pick)
			if gs.RELIC_DEFS[pick]["rarity"] == "LEGENDARY":
				gs.legendary_seen_in_shop = true
	return chosen

func _raise_rarity_floor(rarity: String, steps: int) -> String:
	var order: Array[String] = ["COMMON", "UNCOMMON", "RARE", "LEGENDARY"]
	var idx: int = order.find(rarity)
	if idx < 0:
		idx = 0
	idx = min(order.size() - 1, idx + max(0, steps))
	return order[idx]

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
	_update_top_bar()
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
	_update_top_bar()
	_refresh_pool_list()

func _build_rotary_button() -> void:
	pool_rotary = Button.new()
	pool_rotary.name = "RotarySwap"
	pool_rotary.text = "Rotary Swap"
	pool_rotary.custom_minimum_size = Vector2(140, 36)
	pool_rotary.pressed.connect(_on_pool_rotary_pressed)
	pool_actions.add_child(pool_rotary)
	pool_actions.move_child(pool_rotary, pool_pack.get_index())

func _refresh_pool_list() -> void:
	for child in pool_list.get_children():
		child.queue_free()
	var summary: Dictionary = gs.pool_summary_counts()
	pool_summary.text = "Pool Size: %d (Cap Load %d/%d) | Blood: %d  Bone: %d  Void: %d  Soul: %d | Avg Tier: %.1f" % [
		summary["total"],
		gs.get_pool_load_for_cap(),
		gs.get_pool_cap(),
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
			_trait_display(str(f.get("trait_id", ""))) + _follower_trait_badge(f),
			f["origin_tag"],
			fid,
		]
		row.text += favored_mark
		if pack_select_mode:
			row.button_pressed = pack_selected_ids.has(fid)
		elif rotary_select_mode:
			row.button_pressed = rotary_selected_ids.has(fid)
		else:
			row.button_pressed = (fid == selected_pool_id)
		var trait_rarity: String = str(gs._trait_rarity(str(f.get("trait_id", ""))))
		if trait_rarity == "RARE":
			row.add_theme_color_override("font_color", Color(0.85, 0.7, 0.2))
		elif trait_rarity == "LEGENDARY":
			row.add_theme_color_override("font_color", Color(0.95, 0.55, 0.2))
		row.tooltip_text = _follower_trait_tooltip_text(f)
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

func _follower_trait_badge(follower: Dictionary) -> String:
	var count: int = _follower_all_trait_ids(follower).size()
	if count <= 1:
		return ""
	return " x%d" % count

func _trait_base_description(trait_name: String) -> String:
	match trait_name:
		"BLOOD":
			return "BLOOD: Adds tier to additive devotion. Counts for Blood-based bonuses."
		"BONE":
			return "BONE: Adds double tier to additive devotion. Counts for Bone-based bonuses."
		"VOID":
			return "VOID: Adds to multiplier base. Some effects scale with VOID count."
		"SOUL":
			return "SOUL: Exhausted follower. No devotion, no bonuses."
		_:
			return "Unknown trait."

func _trait_description_from_registry(trait_id: String) -> String:
	if trait_id == "":
		return "Trait: None."
	var info: Dictionary = _trait_info(trait_id)
	if info.is_empty():
		return "Trait: " + trait_id
	var name: String = str(info.get("name", trait_id))
	var desc: String = str(info.get("desc", ""))
	return "%s: %s" % [name, desc]

func _follower_trait_tooltip_text(follower: Dictionary) -> String:
	var lines: Array[String] = []
	lines.append(_trait_base_description(str(follower.get("trait", ""))))
	var all_traits: Array[String] = _follower_all_trait_ids(follower)
	if all_traits.is_empty():
		return "\n".join(lines)
	if all_traits.size() == 1:
		lines.append(_trait_description_from_registry(all_traits[0]))
		return "\n".join(lines)
	lines.append("Traits (%d total):" % all_traits.size())
	for i in range(all_traits.size()):
		var tid: String = all_traits[i]
		var prefix: String = "Primary" if i == 0 else "Extra %d" % i
		lines.append("- %s: %s" % [prefix, _trait_description_from_registry(tid)])
	return "\n".join(lines)

func _trait_color(trait_name: String) -> Color:
	match trait_name:
		"BLOOD":
			return Color(0.52, 0.12, 0.12)
		"BONE":
			return Color(0.79, 0.79, 0.75)
		"VOID":
			return Color(0.24, 0.14, 0.34)
		"SOUL":
			return Color(0.78, 0.67, 0.42)
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
	elif rotary_select_mode:
		if rotary_selected_ids.has(follower_id):
			rotary_selected_ids.erase(follower_id)
		else:
			if rotary_selected_ids.size() >= 2:
				return
			rotary_selected_ids.append(follower_id)
		if rotary_selected_ids.size() == 2:
			if gs.use_rotary_swap(rotary_selected_ids[0], rotary_selected_ids[1]):
				rotary_select_mode = false
				rotary_selected_ids.clear()
				selected_pool_id = -1
	else:
		if selected_pool_id == follower_id:
			selected_pool_id = -1
		else:
			selected_pool_id = follower_id
	_refresh_pool_list()

func _pool_trait_swap_candidate_count() -> int:
	return gs.pool.size()

func _update_pool_actions() -> void:
	var rotary_block: bool = rotary_select_mode
	var culling_knife_ok: bool = gs.relic_inventory.get("Culling Knife", 0) > 0 and not gs.shop_cull_used
	var pruning_hook_ok: bool = gs.relic_inventory.get("The Pruning Hook", 0) > 0 and not gs.pruning_hook_used_shop
	var cull_ok: bool = (culling_knife_ok or pruning_hook_ok) and selected_pool_id >= 0
	if gs.apostle_id == selected_pool_id:
		cull_ok = false
	pool_cull.disabled = pack_select_mode or rotary_block or not cull_ok
	var can_set_favored: bool = gs.relic_inventory["Selective Breeding Scroll"] > 0 and selected_pool_id >= 0
	pool_fav_a.disabled = pack_select_mode or rotary_block or not can_set_favored
	pool_fav_b.disabled = pack_select_mode or rotary_block or not can_set_favored
	pool_ascend.disabled = pack_select_mode or rotary_block or not (gs.relic_inventory["The Soul Lantern"] > 0 and not gs.soul_lantern_used and selected_pool_id >= 0)
	pool_apostle.disabled = pack_select_mode or rotary_block or not (gs.relic_inventory["First Apostle"] > 0 and gs.apostle_id == -1 and selected_pool_id >= 0)
	var rotary_relic_owned: bool = int(gs.relic_inventory.get("The Rotary", 0)) > 0
	var rotary_candidates_ok: bool = _pool_trait_swap_candidate_count() >= 2
	if rotary_select_mode:
		pool_rotary.text = "Cancel Rotary (%d/2)" % rotary_selected_ids.size()
		pool_rotary.disabled = false
	elif not rotary_relic_owned:
		pool_rotary.text = "Rotary Swap"
		pool_rotary.disabled = true
	elif gs.rotary_used_shop:
		pool_rotary.text = "Rotary Used"
		pool_rotary.disabled = true
	elif not rotary_candidates_ok:
		pool_rotary.text = "Rotary Swap"
		pool_rotary.disabled = true
	else:
		pool_rotary.text = "Rotary Swap"
		pool_rotary.disabled = pack_select_mode
	if pack_select_mode:
		pool_pack.text = "Relic Pack (%d/10)" % pack_selected_ids.size()
		pool_pack.disabled = pack_selected_ids.size() != 10
	else:
		pool_pack.text = "Relic Pack (0/10)"
		pool_pack.disabled = rotary_block or gs.pool.size() < 10

func _on_pool_rotary_pressed() -> void:
	if pack_select_mode:
		return
	if rotary_select_mode:
		rotary_select_mode = false
		rotary_selected_ids.clear()
		_refresh_pool_list()
		return
	if int(gs.relic_inventory.get("The Rotary", 0)) <= 0:
		return
	if gs.rotary_used_shop:
		return
	if _pool_trait_swap_candidate_count() < 2:
		return
	selected_pool_id = -1
	rotary_select_mode = true
	rotary_selected_ids.clear()
	_refresh_pool_list()

func _on_pool_cull() -> void:
	if selected_pool_id < 0:
		return
	if gs.cull_follower_by_id(selected_pool_id):
		if gs.relic_inventory.get("Culling Knife", 0) > 0 and not gs.shop_cull_used:
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
		_update_top_bar()
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
	rotary_select_mode = false
	rotary_selected_ids.clear()
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
	_record_codex_pack_discoveries()

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
