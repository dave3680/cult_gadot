extends Control

const DraggablePoolRowScript = preload("res://scripts/DraggablePoolRow.gd")
const NestSlotScript = preload("res://scripts/NestSlot.gd")

const NEST_FOCUS_NONE := "NONE"
const NEST_FOCUS_RARITY := "RARITY"
const NEST_FOCUS_TIER := "TIER"
const NEST_FOCUS_FAMILY := "FAMILY"

@onready var screen_title: Label = $RootVBox/TopBar/TopBarVBox/TopMainRow/ScreenTitle
@onready var blood_label: Label = $RootVBox/TopBar/TopBarVBox/TopMainRow/RightControls/BloodWrap/BloodLabel
@onready var menu_button: Button = $RootVBox/TopBar/TopBarVBox/TopMainRow/RightControls/MenuButton
@onready var pool_summary_label: Label = $RootVBox/TopBar/TopBarVBox/InfoRow/PoolSummary
@onready var pool_list: VBoxContainer = $RootVBox/MainHBox/PoolColumn/PoolVBox/PoolScroll/PoolList
@onready var nest_list: VBoxContainer = $RootVBox/MainHBox/NestColumn/NestVBox/NestList
@onready var continue_button: Button = $RootVBox/BottomBar/BottomHBox/ContinueButton

@onready var details_overlay: Control = $DetailsOverlay
@onready var details_dimmer: ColorRect = $DetailsOverlay/Dimmer
@onready var details_panel: PanelContainer = $DetailsOverlay/DetailsCenter/DetailsPanel
@onready var details_title: Label = $DetailsOverlay/DetailsCenter/DetailsPanel/DetailsVBox/DetailsHeader/DetailsTitle
@onready var details_close_x: Button = $DetailsOverlay/DetailsCenter/DetailsPanel/DetailsVBox/DetailsHeader/CloseX
@onready var parent_a_card: PanelContainer = $DetailsOverlay/DetailsCenter/DetailsPanel/DetailsVBox/ParentsRow/ParentACard
@onready var parent_b_card: PanelContainer = $DetailsOverlay/DetailsCenter/DetailsPanel/DetailsVBox/ParentsRow/ParentBCard
@onready var no_focus_label: Label = $DetailsOverlay/DetailsCenter/DetailsPanel/DetailsVBox/NoFocusLabel
@onready var rarity_button: Button = $DetailsOverlay/DetailsCenter/DetailsPanel/DetailsVBox/FocusOptions/OptionRarity/OptionRarityVBox/RarityButton
@onready var tier_button: Button = $DetailsOverlay/DetailsCenter/DetailsPanel/DetailsVBox/FocusOptions/OptionTier/OptionTierVBox/TierButton
@onready var family_button: Button = $DetailsOverlay/DetailsCenter/DetailsPanel/DetailsVBox/FocusOptions/OptionFamily/OptionFamilyVBox/FamilyButton
@onready var option_rarity_panel: PanelContainer = $DetailsOverlay/DetailsCenter/DetailsPanel/DetailsVBox/FocusOptions/OptionRarity
@onready var option_tier_panel: PanelContainer = $DetailsOverlay/DetailsCenter/DetailsPanel/DetailsVBox/FocusOptions/OptionTier
@onready var option_family_panel: PanelContainer = $DetailsOverlay/DetailsCenter/DetailsPanel/DetailsVBox/FocusOptions/OptionFamily
@onready var prediction_label: Label = $DetailsOverlay/DetailsCenter/DetailsPanel/DetailsVBox/PredictionLabel
@onready var details_done_button: Button = $DetailsOverlay/DetailsCenter/DetailsPanel/DetailsVBox/DoneButton
@onready var gs: Node = get_node("/root/GameState")

var nest_slots: Array[Dictionary] = []
var dragging_follower_id: int = -1
var details_nest_index: int = -1
var status_line: String = ""

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	details_close_x.pressed.connect(_close_details_modal)
	details_done_button.pressed.connect(_close_details_modal)
	details_dimmer.gui_input.connect(_on_overlay_gui_input)
	rarity_button.toggle_mode = true
	tier_button.toggle_mode = true
	family_button.toggle_mode = true
	rarity_button.pressed.connect(_on_focus_button_pressed.bind(NEST_FOCUS_RARITY))
	tier_button.pressed.connect(_on_focus_button_pressed.bind(NEST_FOCUS_TIER))
	family_button.pressed.connect(_on_focus_button_pressed.bind(NEST_FOCUS_FAMILY))

	_apply_theme()
	_build_nest_panels()
	_refresh_all()

func _process(_delta: float) -> void:
	_update_drag_hover_visuals()

func _apply_theme() -> void:
	_set_panel_style($RootVBox/TopBar, Color(0.12, 0.11, 0.14, 0.94), Color(0.22, 0.2, 0.24, 0.9), 1, 8)
	_set_panel_style($RootVBox/MainHBox/PoolColumn, Color(0.14, 0.13, 0.17, 0.96), Color(0.24, 0.22, 0.27, 0.9), 1, 10)
	_set_panel_style($RootVBox/MainHBox/NestColumn, Color(0.13, 0.12, 0.16, 0.96), Color(0.24, 0.22, 0.27, 0.9), 1, 10)
	_set_panel_style($RootVBox/BottomBar, Color(0.11, 0.1, 0.13, 0.96), Color(0.22, 0.2, 0.24, 0.9), 1, 8)
	_set_panel_style(details_panel, Color(0.12, 0.11, 0.15, 0.98), Color(0.26, 0.24, 0.29, 0.9), 1, 10)

	screen_title.add_theme_font_size_override("font_size", 30)
	pool_summary_label.add_theme_font_size_override("font_size", 13)
	pool_summary_label.add_theme_color_override("font_color", Color(0.66, 0.66, 0.7))
	blood_label.add_theme_font_size_override("font_size", 24)
	continue_button.add_theme_font_size_override("font_size", 18)

	$RootVBox/MainHBox/PoolColumn/PoolVBox/FollowersLabel.add_theme_font_size_override("font_size", 13)
	$RootVBox/MainHBox/PoolColumn/PoolVBox/FollowersLabel.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8))
	$RootVBox/MainHBox/NestColumn/NestVBox/NestsLabel.add_theme_font_size_override("font_size", 13)
	$RootVBox/MainHBox/NestColumn/NestVBox/NestsLabel.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8))

	no_focus_label.add_theme_color_override("font_color", Color(0.66, 0.66, 0.7))
	prediction_label.add_theme_color_override("font_color", Color(0.76, 0.76, 0.8))
	prediction_label.add_theme_font_size_override("font_size", 14)

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

func _build_nest_panels() -> void:
	for child in nest_list.get_children():
		child.queue_free()
	nest_slots.clear()

	var display_count: int = max(3, gs.nests.size())
	for i in range(display_count):
		var panel: PanelContainer = PanelContainer.new()
		panel.custom_minimum_size = Vector2(0, 218)
		nest_list.add_child(panel)

		var outer: VBoxContainer = VBoxContainer.new()
		outer.anchor_right = 1.0
		outer.anchor_bottom = 1.0
		outer.offset_left = 10.0
		outer.offset_top = 8.0
		outer.offset_right = -10.0
		outer.offset_bottom = -8.0
		outer.add_theme_constant_override("separation", 6)
		panel.add_child(outer)

		var header: HBoxContainer = HBoxContainer.new()
		header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		outer.add_child(header)

		var title: Label = Label.new()
		title.text = "Nest %d" % (i + 1)
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title.add_theme_font_size_override("font_size", 17)
		header.add_child(title)

		var details_button: Button = Button.new()
		details_button.text = "Details"
		details_button.custom_minimum_size = Vector2(74, 30)
		details_button.pressed.connect(_on_details_pressed.bind(i))
		header.add_child(details_button)

		var divider: HSeparator = HSeparator.new()
		outer.add_child(divider)

		var ovals_row: HBoxContainer = HBoxContainer.new()
		ovals_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		ovals_row.alignment = BoxContainer.ALIGNMENT_CENTER
		ovals_row.add_theme_constant_override("separation", 10)
		outer.add_child(ovals_row)

		var left_wrap: VBoxContainer = VBoxContainer.new()
		left_wrap.custom_minimum_size = Vector2(170, 114)
		left_wrap.add_theme_constant_override("separation", 2)
		ovals_row.add_child(left_wrap)

		var slot_a = NestSlotScript.new()
		slot_a.nest_index = i
		slot_a.parent_slot = 0
		slot_a.custom_minimum_size = Vector2(170, 86)
		slot_a.clip_contents = true
		slot_a.follower_dropped.connect(_on_nest_slot_dropped)
		left_wrap.add_child(slot_a)

		var slot_a_content: Dictionary = _build_slot_contents(slot_a)

		var parent_a_label: Label = Label.new()
		parent_a_label.text = "Parent A"
		parent_a_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		parent_a_label.add_theme_font_size_override("font_size", 12)
		parent_a_label.add_theme_color_override("font_color", Color(0.62, 0.62, 0.66))
		left_wrap.add_child(parent_a_label)

		var clear_a: Button = Button.new()
		clear_a.text = "Clear A"
		clear_a.flat = true
		clear_a.visible = false
		clear_a.add_theme_font_size_override("font_size", 11)
		clear_a.pressed.connect(_on_clear_slot.bind(i, 0))
		left_wrap.add_child(clear_a)

		var link_label: Label = Label.new()
		link_label.text = "<3"
		link_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		link_label.add_theme_color_override("font_color", Color(0.72, 0.4, 0.45))
		ovals_row.add_child(link_label)

		var right_wrap: VBoxContainer = VBoxContainer.new()
		right_wrap.custom_minimum_size = Vector2(170, 114)
		right_wrap.add_theme_constant_override("separation", 2)
		ovals_row.add_child(right_wrap)

		var slot_b = NestSlotScript.new()
		slot_b.nest_index = i
		slot_b.parent_slot = 1
		slot_b.custom_minimum_size = Vector2(170, 86)
		slot_b.clip_contents = true
		slot_b.follower_dropped.connect(_on_nest_slot_dropped)
		right_wrap.add_child(slot_b)

		var slot_b_content: Dictionary = _build_slot_contents(slot_b)

		var parent_b_label: Label = Label.new()
		parent_b_label.text = "Parent B"
		parent_b_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		parent_b_label.add_theme_font_size_override("font_size", 12)
		parent_b_label.add_theme_color_override("font_color", Color(0.62, 0.62, 0.66))
		right_wrap.add_child(parent_b_label)

		var clear_b: Button = Button.new()
		clear_b.text = "Clear B"
		clear_b.flat = true
		clear_b.visible = false
		clear_b.add_theme_font_size_override("font_size", 11)
		clear_b.pressed.connect(_on_clear_slot.bind(i, 1))
		right_wrap.add_child(clear_b)

		var status: Label = Label.new()
		status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		status.add_theme_font_size_override("font_size", 13)
		status.add_theme_color_override("font_color", Color(0.7, 0.7, 0.74))
		outer.add_child(status)

		nest_slots.append({
			"panel": panel,
			"title": title,
			"details": details_button,
			"slot_a": slot_a,
			"slot_b": slot_b,
			"a_tier": slot_a_content["tier"],
			"a_type": slot_a_content["type"],
			"a_badge": slot_a_content["badge"],
			"a_hint": slot_a_content["hint"],
			"b_tier": slot_b_content["tier"],
			"b_type": slot_b_content["type"],
			"b_badge": slot_b_content["badge"],
			"b_hint": slot_b_content["hint"],
			"label_a": parent_a_label,
			"label_b": parent_b_label,
			"clear_a": clear_a,
			"clear_b": clear_b,
			"status": status,
			"link": link_label,
		})

func _build_slot_contents(slot: PanelContainer) -> Dictionary:
	var hint: Label = Label.new()
	hint.anchor_left = 0.0
	hint.anchor_top = 0.0
	hint.anchor_right = 1.0
	hint.anchor_bottom = 0.0
	hint.offset_top = 4.0
	hint.offset_bottom = 20.0
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", Color(0.95, 0.9, 0.78))
	hint.visible = false
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(hint)

	var margin: MarginContainer = MarginContainer.new()
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.offset_left = 8.0
	margin.offset_top = 8.0
	margin.offset_right = -8.0
	margin.offset_bottom = -8.0
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(margin)

	var center: CenterContainer = CenterContainer.new()
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(center)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 1)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(vbox)

	var tier: Label = Label.new()
	tier.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tier.add_theme_font_size_override("font_size", 24)
	tier.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(tier)

	var type_line: Label = Label.new()
	type_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	type_line.add_theme_font_size_override("font_size", 12)
	type_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(type_line)

	var badge: Label = Label.new()
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 12)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(badge)

	return {"hint": hint, "tier": tier, "type": type_line, "badge": badge}

func _refresh_all() -> void:
	_refresh_top_bar()
	_refresh_pool()
	_refresh_nests()
	if details_overlay.visible and details_nest_index >= 0:
		_refresh_details_modal()

func _refresh_top_bar() -> void:
	blood_label.text = str(gs.blood_currency)
	var s: Dictionary = gs.pool_summary_counts()
	var text: String = "Pool: %d | Blood: %d | Bone: %d | Void: %d | Soul: %d" % [
		int(s.get("total", 0)),
		int(s.get("blood", 0)),
		int(s.get("bone", 0)),
		int(s.get("void", 0)),
		int(s.get("soul", 0)),
	]
	if status_line != "":
		text += " | " + status_line
	pool_summary_label.text = text

	var pending_focus_cost: int = int(gs.get_nest_focus_total_cost())
	if pending_focus_cost > 0:
		continue_button.text = "Continue to Battle (-%d Blood Focus)" % pending_focus_cost
	else:
		continue_button.text = "Continue to Battle"
	continue_button.disabled = pending_focus_cost > int(gs.blood_currency)

func _refresh_pool() -> void:
	for child in pool_list.get_children():
		child.queue_free()

	for f in gs.pool:
		var follower_id: int = int(f.get("id", -1))
		if follower_id < 0:
			continue
		if gs.is_follower_nested(follower_id):
			continue
		var trait_name: String = str(f.get("trait", ""))
		var trait_id: String = str(f.get("trait_id", ""))
		var rarity: String = _trait_rarity(trait_id)
		var row = DraggablePoolRowScript.new()
		row.configure({
			"id": follower_id,
			"type_color": _trait_color(trait_name),
			"tier_text": "T%d" % int(f.get("tier", 0)),
			"type_text": trait_name,
			"trait_text": _trait_name(trait_id),
			"rarity_text": _rarity_badge(rarity),
			"rarity_color": _rarity_color(rarity),
			"multi_text": _follower_trait_badge(f),
			"origin_text": str(f.get("origin_tag", "")),
			"favored": _is_favored_follower(follower_id),
			"type_label_color": Color(0.74, 0.74, 0.78),
			"trait_color": Color(0.9, 0.9, 0.93),
			"bg_tint": _trait_color(trait_name).lerp(Color(0.12, 0.12, 0.14, 1.0), 0.82),
		})
		row.tooltip_text = _follower_trait_tooltip_text(f)
		row.drag_started.connect(_on_row_drag_started)
		row.drag_finished.connect(_on_row_drag_finished)
		pool_list.add_child(row)

	if pool_list.get_child_count() == 0:
		var empty: Label = Label.new()
		empty.text = "No available followers."
		empty.add_theme_color_override("font_color", Color(0.66, 0.66, 0.7))
		empty.add_theme_font_size_override("font_size", 13)
		pool_list.add_child(empty)

func _refresh_nests() -> void:
	var available_nests: int = gs.nests.size()
	for i in range(nest_slots.size()):
		var slot_info: Dictionary = nest_slots[i]
		var available: bool = i < available_nests
		var panel: PanelContainer = slot_info["panel"]
		var details_button: Button = slot_info["details"]
		var status: Label = slot_info["status"]
		var slot_a: PanelContainer = slot_info["slot_a"]
		var slot_b: PanelContainer = slot_info["slot_b"]
		var clear_a: Button = slot_info["clear_a"]
		var clear_b: Button = slot_info["clear_b"]
		var link_label: Label = slot_info["link"]

		if not available:
			_set_panel_style(panel, Color(0.16, 0.16, 0.18, 0.9), Color(0.34, 0.34, 0.37, 0.8), 1, 10)
			panel.modulate = Color(0.6, 0.6, 0.6, 0.9)
			details_button.disabled = true
			slot_a.mouse_filter = Control.MOUSE_FILTER_IGNORE
			slot_b.mouse_filter = Control.MOUSE_FILTER_IGNORE
			clear_a.visible = false
			clear_b.visible = false
			_set_slot_empty(slot_info, "a")
			_set_slot_empty(slot_info, "b")
			slot_a.set_meta("filled", false)
			slot_b.set_meta("filled", false)
			slot_a.set_meta("follower_id", -1)
			slot_b.set_meta("follower_id", -1)
			slot_a.tooltip_text = "Requires The Deep Pool."
			slot_b.tooltip_text = "Requires The Deep Pool."
			status.text = "Requires The Deep Pool"
			link_label.text = "LOCK"
			_apply_nest_slot_style(slot_a, false, false)
			_apply_nest_slot_style(slot_b, false, false)
			continue

		panel.modulate = Color(1, 1, 1, 1)
		_set_panel_style(panel, Color(0.16, 0.15, 0.2, 0.96), Color(0.31, 0.29, 0.35, 0.9), 1, 10)
		details_button.disabled = false
		slot_a.mouse_filter = Control.MOUSE_FILTER_STOP
		slot_b.mouse_filter = Control.MOUSE_FILTER_STOP
		link_label.text = "<3"
		var entry: Dictionary = gs.nests[i]
		var a_id: int = int(entry.get("a", -1))
		var b_id: int = int(entry.get("b", -1))
		_set_slot_follower(slot_info, "a", a_id)
		_set_slot_follower(slot_info, "b", b_id)
		slot_a.set_meta("filled", a_id >= 0)
		slot_b.set_meta("filled", b_id >= 0)
		slot_a.set_meta("follower_id", a_id)
		slot_b.set_meta("follower_id", b_id)
		clear_a.visible = a_id >= 0
		clear_b.visible = b_id >= 0
		slot_info["label_a"].text = "Parent A"
		slot_info["label_b"].text = "Parent B"
		slot_a.tooltip_text = _follower_tooltip_for_id(a_id)
		slot_b.tooltip_text = _follower_tooltip_for_id(b_id)
		_apply_nest_slot_style(slot_a, a_id >= 0, false)
		_apply_nest_slot_style(slot_b, b_id >= 0, false)

		var preview: Dictionary = gs.get_nest_preview(i)
		status.text = _nest_status_text(preview, a_id, b_id)

func _set_slot_empty(slot_info: Dictionary, prefix: String) -> void:
	var tier_label: Label = slot_info["%s_tier" % prefix]
	var type_label: Label = slot_info["%s_type" % prefix]
	var badge_label: Label = slot_info["%s_badge" % prefix]
	var hint_label: Label = slot_info["%s_hint" % prefix]
	tier_label.text = ""
	type_label.text = "Drop %s" % ("Parent A" if prefix == "a" else "Parent B")
	type_label.add_theme_color_override("font_color", Color(0.56, 0.56, 0.6))
	badge_label.text = ""
	hint_label.visible = false

func _set_slot_follower(slot_info: Dictionary, prefix: String, follower_id: int) -> void:
	var tier_label: Label = slot_info["%s_tier" % prefix]
	var type_label: Label = slot_info["%s_type" % prefix]
	var badge_label: Label = slot_info["%s_badge" % prefix]
	var hint_label: Label = slot_info["%s_hint" % prefix]
	if follower_id < 0:
		_set_slot_empty(slot_info, prefix)
		return
	var follower: Dictionary = _follower_by_id(follower_id)
	if follower.is_empty():
		_set_slot_empty(slot_info, prefix)
		type_label.text = "Missing #%d" % follower_id
		return
	var trait_name: String = str(follower.get("trait", ""))
	var trait_id: String = str(follower.get("trait_id", ""))
	tier_label.text = "T%d" % int(follower.get("tier", 0))
	type_label.text = trait_name
	type_label.add_theme_color_override("font_color", _trait_color(trait_name).lerp(Color(1, 1, 1), 0.2))
	badge_label.text = _rarity_badge(_trait_rarity(trait_id)) + _follower_trait_badge(follower)
	badge_label.add_theme_color_override("font_color", _rarity_color(_trait_rarity(trait_id)))
	hint_label.visible = false

func _update_drag_hover_visuals() -> void:
	for i in range(nest_slots.size()):
		var slot_info: Dictionary = nest_slots[i]
		var is_available: bool = i < gs.nests.size()
		var slot_a: PanelContainer = slot_info["slot_a"]
		var slot_b: PanelContainer = slot_info["slot_b"]
		var a_filled: bool = bool(slot_a.get_meta("filled", false))
		var b_filled: bool = bool(slot_b.get_meta("filled", false))
		var a_hint: Label = slot_info["a_hint"]
		var b_hint: Label = slot_info["b_hint"]
		if dragging_follower_id < 0 or not is_available:
			a_hint.visible = false
			b_hint.visible = false
			_apply_nest_slot_style(slot_a, a_filled, false)
			_apply_nest_slot_style(slot_b, b_filled, false)
			continue
		var mouse: Vector2 = get_global_mouse_position()
		var hover_a: bool = slot_a.get_global_rect().has_point(mouse)
		var hover_b: bool = slot_b.get_global_rect().has_point(mouse)
		a_hint.visible = hover_a
		b_hint.visible = hover_b
		a_hint.text = "Swap" if a_filled else "Drop"
		b_hint.text = "Swap" if b_filled else "Drop"
		_apply_nest_slot_style(slot_a, a_filled, hover_a)
		_apply_nest_slot_style(slot_b, b_filled, hover_b)

func _apply_nest_slot_style(slot: PanelContainer, filled: bool, hovered: bool) -> void:
	var type_name: String = ""
	var follower_id: int = int(slot.get_meta("follower_id", -1))
	if follower_id >= 0:
		var follower: Dictionary = _follower_by_id(follower_id)
		if not follower.is_empty():
			type_name = str(follower.get("trait", ""))
	var bg: Color = Color(0.08, 0.08, 0.1, 0.95)
	if filled:
		bg = _trait_color(type_name).lerp(Color(0.11, 0.11, 0.14, 1.0), 0.78)
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = bg
	sb.corner_radius_top_left = 44
	sb.corner_radius_top_right = 44
	sb.corner_radius_bottom_left = 44
	sb.corner_radius_bottom_right = 44
	if hovered and dragging_follower_id >= 0:
		sb.border_color = Color(0.95, 0.86, 0.6, 0.98)
		sb.border_width_left = 3
		sb.border_width_right = 3
		sb.border_width_top = 3
		sb.border_width_bottom = 3
		sb.shadow_color = Color(0.95, 0.86, 0.6, 0.35)
		sb.shadow_size = 8
	else:
		sb.border_color = Color(0.44, 0.42, 0.48, 0.88) if filled else Color(0.34, 0.34, 0.38, 0.72)
		sb.border_width_left = 2
		sb.border_width_right = 2
		sb.border_width_top = 2
		sb.border_width_bottom = 2
		sb.shadow_color = Color(0.0, 0.0, 0.0, 0.3)
		sb.shadow_size = 3
	slot.add_theme_stylebox_override("panel", sb)

func _on_row_drag_started(follower_id: int) -> void:
	dragging_follower_id = follower_id
	_update_drag_hover_visuals()

func _on_row_drag_finished(_follower_id: int, _successful: bool) -> void:
	dragging_follower_id = -1
	_update_drag_hover_visuals()

func _on_nest_slot_dropped(nest_index: int, parent_slot: int, follower_id: int) -> void:
	if gs.assign_follower_to_nest(nest_index, parent_slot, follower_id):
		dragging_follower_id = -1
		status_line = ""
		_refresh_all()

func _on_clear_slot(nest_index: int, parent_slot: int) -> void:
	gs.clear_nest_slot(nest_index, parent_slot)
	status_line = ""
	_refresh_all()

func _nest_status_text(preview: Dictionary, a_id: int, b_id: int) -> String:
	if a_id < 0 or b_id < 0:
		return "Assign both parents to breed"
	var blocked: String = str(preview.get("blocked_reason", ""))
	if blocked != "":
		return "Blocked: %s" % blocked
	return "Breeding possible"

func _on_details_pressed(nest_index: int) -> void:
	if nest_index < 0 or nest_index >= gs.nests.size():
		return
	details_nest_index = nest_index
	details_overlay.visible = true
	_refresh_details_modal()

func _on_overlay_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			_close_details_modal()
			accept_event()

func _close_details_modal() -> void:
	details_overlay.visible = false
	details_nest_index = -1

func _refresh_details_modal() -> void:
	if details_nest_index < 0 or details_nest_index >= gs.nests.size():
		_close_details_modal()
		return
	var nest_num: int = details_nest_index + 1
	details_title.text = "Nest %d - Details" % nest_num

	var entry: Dictionary = gs.nests[details_nest_index]
	var a_id: int = int(entry.get("a", -1))
	var b_id: int = int(entry.get("b", -1))
	var parent_a: Dictionary = _follower_by_id(a_id)
	var parent_b: Dictionary = _follower_by_id(b_id)
	_render_detail_parent_card(parent_a_card, parent_a, "Parent A")
	_render_detail_parent_card(parent_b_card, parent_b, "Parent B")

	var preview: Dictionary = gs.get_nest_preview(details_nest_index)
	var focus_mode: String = str(preview.get("focus", NEST_FOCUS_NONE))
	_update_focus_option_state(focus_mode)
	no_focus_label.visible = focus_mode == NEST_FOCUS_NONE
	prediction_label.text = _prediction_text(preview)

func _render_detail_parent_card(panel: PanelContainer, follower: Dictionary, parent_label: String) -> void:
	for child in panel.get_children():
		child.queue_free()

	var bg: Color = Color(0.16, 0.15, 0.19, 0.98)
	if not follower.is_empty():
		bg = _trait_color(str(follower.get("trait", ""))).lerp(Color(0.12, 0.12, 0.15, 1.0), 0.75)
	_set_panel_style(panel, bg, Color(0.3, 0.29, 0.35, 0.95), 1, 10)

	var m: MarginContainer = MarginContainer.new()
	m.anchor_right = 1.0
	m.anchor_bottom = 1.0
	m.offset_left = 10.0
	m.offset_top = 10.0
	m.offset_right = -10.0
	m.offset_bottom = -10.0
	panel.add_child(m)

	var v: VBoxContainer = VBoxContainer.new()
	v.anchor_right = 1.0
	v.anchor_bottom = 1.0
	v.add_theme_constant_override("separation", 4)
	m.add_child(v)

	var header: Label = Label.new()
	header.text = parent_label
	header.add_theme_font_size_override("font_size", 12)
	header.add_theme_color_override("font_color", Color(0.7, 0.7, 0.74))
	v.add_child(header)

	if follower.is_empty():
		var empty: Label = Label.new()
		empty.text = "No parent assigned"
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.size_flags_vertical = Control.SIZE_EXPAND_FILL
		empty.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty.add_theme_font_size_override("font_size", 18)
		empty.add_theme_color_override("font_color", Color(0.62, 0.62, 0.66))
		v.add_child(empty)
		panel.tooltip_text = "No parent assigned."
		return

	var tier: Label = Label.new()
	tier.text = "T%d" % int(follower.get("tier", 0))
	tier.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tier.add_theme_font_size_override("font_size", 36)
	v.add_child(tier)

	var type_line: Label = Label.new()
	type_line.text = str(follower.get("trait", ""))
	type_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	type_line.add_theme_font_size_override("font_size", 18)
	type_line.add_theme_color_override("font_color", _trait_color(str(follower.get("trait", ""))).lerp(Color(1, 1, 1), 0.2))
	v.add_child(type_line)

	var trait_id: String = str(follower.get("trait_id", ""))
	var trait_text: String = _trait_display(trait_id) + _follower_trait_badge(follower)
	var trait_line: Label = Label.new()
	trait_line.text = trait_text if trait_id != "" else "No Trait"
	trait_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	trait_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	trait_line.add_theme_font_size_override("font_size", 14)
	trait_line.add_theme_color_override("font_color", _rarity_color(_trait_rarity(trait_id)) if trait_id != "" else Color(0.62, 0.62, 0.66))
	v.add_child(trait_line)

	var extra_traits: Array[String] = _follower_all_trait_ids(follower)
	if extra_traits.size() > 1:
		var joined: String = ""
		for i in range(extra_traits.size()):
			if i > 0:
				joined += ", "
			joined += extra_traits[i]
		var extra_line: Label = Label.new()
		extra_line.text = "Traits: %s" % joined
		extra_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		extra_line.add_theme_font_size_override("font_size", 12)
		extra_line.add_theme_color_override("font_color", Color(0.8, 0.8, 0.84))
		v.add_child(extra_line)

	var origin: Label = Label.new()
	origin.text = "Origin: %s" % str(follower.get("origin_tag", ""))
	origin.add_theme_font_size_override("font_size", 12)
	origin.add_theme_color_override("font_color", Color(0.66, 0.66, 0.7))
	v.add_child(origin)

	panel.tooltip_text = _follower_trait_tooltip_text(follower)

func _update_focus_option_state(current_mode: String) -> void:
	var projected_rarity: int = int(gs.get_nest_focus_total_cost_with(details_nest_index, NEST_FOCUS_RARITY))
	var projected_tier: int = int(gs.get_nest_focus_total_cost_with(details_nest_index, NEST_FOCUS_TIER))
	var projected_family: int = int(gs.get_nest_focus_total_cost_with(details_nest_index, NEST_FOCUS_FAMILY))
	var blood: int = int(gs.blood_currency)

	rarity_button.button_pressed = current_mode == NEST_FOCUS_RARITY
	tier_button.button_pressed = current_mode == NEST_FOCUS_TIER
	family_button.button_pressed = current_mode == NEST_FOCUS_FAMILY
	rarity_button.text = "Rarity (%d)" % int(gs.get_nest_focus_cost(NEST_FOCUS_RARITY))
	tier_button.text = "Tier (%d)" % int(gs.get_nest_focus_cost(NEST_FOCUS_TIER))
	family_button.text = "Family (%d)" % int(gs.get_nest_focus_cost(NEST_FOCUS_FAMILY))

	rarity_button.disabled = (projected_rarity > blood) and current_mode != NEST_FOCUS_RARITY
	tier_button.disabled = (projected_tier > blood) and current_mode != NEST_FOCUS_TIER
	family_button.disabled = (projected_family > blood) and current_mode != NEST_FOCUS_FAMILY

	_style_focus_panel(option_rarity_panel, current_mode == NEST_FOCUS_RARITY)
	_style_focus_panel(option_tier_panel, current_mode == NEST_FOCUS_TIER)
	_style_focus_panel(option_family_panel, current_mode == NEST_FOCUS_FAMILY)

func _style_focus_panel(panel: PanelContainer, selected: bool) -> void:
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color(0.22, 0.2, 0.15, 0.9) if selected else Color(0.16, 0.15, 0.19, 0.9)
	sb.border_color = Color(0.95, 0.84, 0.52, 0.95) if selected else Color(0.3, 0.29, 0.34, 0.9)
	sb.border_width_left = 1
	sb.border_width_right = 1
	sb.border_width_top = 1
	sb.border_width_bottom = 1
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 8
	sb.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", sb)

func _on_focus_button_pressed(mode: String) -> void:
	if details_nest_index < 0 or details_nest_index >= gs.nests.size():
		return
	var current_mode: String = str(gs.get_nest_focus(details_nest_index))
	var target_mode: String = NEST_FOCUS_NONE if current_mode == mode else mode
	var result: Dictionary = gs.set_nest_focus(details_nest_index, target_mode)
	if not bool(result.get("ok", false)):
		status_line = "(Focus) %s" % str(result.get("reason", "Could not set focus."))
	else:
		status_line = ""
	_refresh_all()

func _prediction_text(preview: Dictionary) -> String:
	var blocked: String = str(preview.get("blocked_reason", ""))
	if blocked != "":
		return "Outcome blocked: %s" % blocked
	if not bool(preview.get("can_breed", false)):
		return "Outcome depends on parent traits and focus."

	var expected_tier: int = int(round(float(preview.get("expected_tier", 0.0))))
	var odds: Dictionary = preview.get("rarity_odds", {})
	var common_odds: float = float(odds.get("common", 0.0))
	var rare_odds: float = float(odds.get("rare", 0.0))
	var legendary_odds: float = float(odds.get("legendary", 0.0))
	var likely: String = "COMMON trait likely"
	if rare_odds >= common_odds and rare_odds >= legendary_odds:
		likely = "RARE trait likely"
	elif legendary_odds >= common_odds and legendary_odds >= rare_odds:
		likely = "LEGENDARY trait likely"
	return "Expected offspring: ~T%d, %s" % [expected_tier, likely]

func _on_continue_pressed() -> void:
	var commit_result: Dictionary = gs.commit_nest_focus_costs()
	if not bool(commit_result.get("ok", false)):
		status_line = "(Focus) %s" % str(commit_result.get("reason", "Could not pay for nest focus."))
		_refresh_top_bar()
		return
	get_tree().change_scene_to_file("res://scenes/RunGame.tscn")

func _on_menu_pressed() -> void:
	var overlay: Node = get_node_or_null("/root/GlobalMenuOverlay")
	if overlay != null:
		if overlay.has_method("open_menu"):
			overlay.call("open_menu")
			return
		if overlay.has_method("_on_menu_pressed"):
			overlay.call("_on_menu_pressed")

func _follower_by_id(follower_id: int) -> Dictionary:
	for f in gs.pool:
		if int(f.get("id", -1)) == follower_id:
			return f
	return {}

func _is_favored_follower(follower_id: int) -> bool:
	for fid in gs.favored_breeder_ids:
		if int(fid) == follower_id:
			return true
	return false

func _trait_info(trait_id: String) -> Dictionary:
	if trait_id == "":
		return {}
	if gs.TRAIT_REGISTRY.has(trait_id):
		return gs.TRAIT_REGISTRY[trait_id]
	var combo_info: Dictionary = gs.get_combo_trait(trait_id)
	if not combo_info.is_empty():
		return combo_info
	return {}

func _trait_name(trait_id: String) -> String:
	if trait_id == "":
		return "-"
	var info: Dictionary = _trait_info(trait_id)
	return str(info.get("name", trait_id))

func _trait_display(trait_id: String) -> String:
	if trait_id == "":
		return "None"
	var info: Dictionary = _trait_info(trait_id)
	if info.is_empty():
		return trait_id
	return "%s %s" % [_rarity_badge(str(info.get("rarity", "COMMON"))), str(info.get("name", trait_id))]

func _trait_rarity(trait_id: String) -> String:
	if trait_id == "":
		return "COMMON"
	return str(gs._trait_rarity(trait_id))

func _rarity_badge(rarity: String) -> String:
	match rarity:
		"LEGENDARY":
			return "[L]"
		"RARE":
			return "[R]"
		"UNCOMMON":
			return "[U]"
		_:
			return "[C]"

func _rarity_color(rarity: String) -> Color:
	match rarity:
		"UNCOMMON":
			return Color(0.45, 0.72, 0.46)
		"RARE":
			return Color(0.5, 0.46, 0.78)
		"LEGENDARY":
			return Color(0.9, 0.68, 0.32)
		_:
			return Color(0.7, 0.7, 0.74)

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

func _follower_trait_tooltip_text(follower: Dictionary) -> String:
	var lines: Array[String] = []
	lines.append(_get_trait_description(str(follower.get("trait", ""))))
	var all_traits: Array[String] = _follower_all_trait_ids(follower)
	if all_traits.is_empty():
		return "\n".join(lines)
	if all_traits.size() == 1:
		lines.append(_get_trait_description_from_registry(all_traits[0]))
		return "\n".join(lines)
	lines.append("Traits (%d total):" % all_traits.size())
	for i in range(all_traits.size()):
		var tid: String = all_traits[i]
		var prefix: String = "Primary" if i == 0 else "Extra %d" % i
		lines.append("- %s: %s" % [prefix, _get_trait_description_from_registry(tid)])
	return "\n".join(lines)

func _follower_tooltip_for_id(follower_id: int) -> String:
	if follower_id < 0:
		return "Empty slot."
	var follower: Dictionary = _follower_by_id(follower_id)
	if follower.is_empty():
		return "Missing follower #%d" % follower_id
	return _follower_trait_tooltip_text(follower)

func _get_trait_description(trait_name: String) -> String:
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

func _get_trait_description_from_registry(trait_id: String) -> String:
	if trait_id == "":
		return "Trait: None."
	var info: Dictionary = _trait_info(trait_id)
	if info.is_empty():
		return "Trait: " + trait_id
	var name: String = str(info.get("name", trait_id))
	var desc: String = str(info.get("desc", ""))
	return "%s: %s" % [name, desc]
