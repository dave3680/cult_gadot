extends Control

@onready var report_label: Label = $RootVBox/TopBar/TopBarVBox/TopMainRow/ReportLabel
@onready var blood_label: Label = $RootVBox/TopBar/TopBarVBox/TopMainRow/RightControls/BloodWrap/BloodLabel
@onready var menu_button: Button = $RootVBox/TopBar/TopBarVBox/TopMainRow/RightControls/MenuButton
@onready var nest_sections: VBoxContainer = $RootVBox/ContentArea/ContentScroll/ContentVBox/NestSections
@onready var wild_section: PanelContainer = $RootVBox/ContentArea/ContentScroll/ContentVBox/WildSection
@onready var wild_subtitle: Label = $RootVBox/ContentArea/ContentScroll/ContentVBox/WildSection/WildVBox/WildSubtitle
@onready var wild_cards: GridContainer = $RootVBox/ContentArea/ContentScroll/ContentVBox/WildSection/WildVBox/WildCards
@onready var wild_empty_label: Label = $RootVBox/ContentArea/ContentScroll/ContentVBox/WildSection/WildVBox/WildEmptyLabel
@onready var summary_line: Label = $RootVBox/ContentArea/ContentScroll/ContentVBox/SummaryLine
@onready var continue_button: Button = $RootVBox/BottomBar/BottomHBox/ContinueButton
@onready var gs: Node = get_node("/root/GameState")

var _nest_visual_refs: Array[Dictionary] = []
var _continue_pulse_tween: Tween
var _reveals_complete: bool = false

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	_apply_theme()
	_build_report_content()
	prepare_reveal_state()
	call_deferred("_run_reveal_sequence")

func _apply_theme() -> void:
	_set_panel_style($RootVBox/TopBar, Color(0.12, 0.11, 0.14, 0.94), Color(0.22, 0.2, 0.24, 0.9), 1, 8)
	_set_panel_style($RootVBox/ContentArea, Color(0.13, 0.12, 0.16, 0.96), Color(0.24, 0.22, 0.27, 0.9), 1, 10)
	_set_panel_style($RootVBox/BottomBar, Color(0.11, 0.1, 0.13, 0.96), Color(0.22, 0.2, 0.24, 0.9), 1, 8)
	_set_panel_style(wild_section, Color(0.16, 0.15, 0.2, 0.96), Color(0.31, 0.29, 0.35, 0.9), 1, 10)

	report_label.add_theme_font_size_override("font_size", 30)
	blood_label.add_theme_font_size_override("font_size", 24)
	summary_line.add_theme_font_size_override("font_size", 13)
	summary_line.add_theme_color_override("font_color", Color(0.66, 0.66, 0.7))
	wild_subtitle.add_theme_font_size_override("font_size", 12)
	wild_subtitle.add_theme_color_override("font_color", Color(0.68, 0.68, 0.72))
	wild_empty_label.add_theme_font_size_override("font_size", 13)
	wild_empty_label.add_theme_color_override("font_color", Color(0.62, 0.62, 0.66))
	continue_button.add_theme_font_size_override("font_size", 20)

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

func _build_report_content() -> void:
	blood_label.text = str(gs.blood_currency)
	continue_button.disabled = true
	continue_button.scale = Vector2.ONE

	for child in nest_sections.get_children():
		nest_sections.remove_child(child)
		child.queue_free()
	_nest_visual_refs.clear()
	for child in wild_cards.get_children():
		wild_cards.remove_child(child)
		child.queue_free()

	var nest_results: Array = gs.last_nest_results
	for item in nest_results:
		_nest_visual_refs.append(_build_nest_section(item))

	var parsed: Dictionary = _parse_breeding_summary(gs.last_breeding_summary)
	var wild_newborns: Array[Dictionary] = _recent_wild_newborns(int(parsed.get("wild_newborns", 0)))
	if wild_newborns.is_empty():
		wild_subtitle.visible = false
		wild_empty_label.visible = true
	else:
		wild_subtitle.visible = true
		wild_empty_label.visible = false
		for baby in wild_newborns:
			wild_cards.add_child(_create_compact_card(baby, 250, false))

	summary_line.text = "Week %d - Pool: %d -> %d | Nest newborns: %d | Wild newborns: %d | Trimmed: %d" % [
		int(parsed.get("week", gs.current_week)),
		int(parsed.get("pool_before", gs.pool.size())),
		int(parsed.get("pool_after", gs.pool.size())),
		int(parsed.get("nest_newborns", 0)),
		int(parsed.get("wild_newborns", 0)),
		int(parsed.get("trimmed", 0)),
	]

func _build_nest_section(item: Dictionary) -> Dictionary:
	var section: PanelContainer = PanelContainer.new()
	_set_panel_style(section, Color(0.16, 0.15, 0.2, 0.96), Color(0.31, 0.29, 0.35, 0.9), 1, 10)
	section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nest_sections.add_child(section)

	var outer: VBoxContainer = VBoxContainer.new()
	outer.anchor_right = 1.0
	outer.anchor_bottom = 1.0
	outer.offset_left = 12.0
	outer.offset_top = 10.0
	outer.offset_right = -12.0
	outer.offset_bottom = -10.0
	outer.add_theme_constant_override("separation", 8)
	section.add_child(outer)

	var nest_no: int = int(item.get("nest", 0))
	var header: Label = Label.new()
	header.text = "Nest %d" % nest_no
	header.add_theme_font_size_override("font_size", 16)
	header.add_theme_color_override("font_color", Color(0.84, 0.84, 0.89))
	outer.add_child(header)

	var divider: HSeparator = HSeparator.new()
	outer.add_child(divider)

	var parent_center: CenterContainer = CenterContainer.new()
	parent_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer.add_child(parent_center)

	var parent_row: HBoxContainer = HBoxContainer.new()
	parent_row.alignment = BoxContainer.ALIGNMENT_CENTER
	parent_row.add_theme_constant_override("separation", 10)
	parent_center.add_child(parent_row)

	var parent_a: Dictionary = _follower_by_id(int(item.get("a_id", -1)))
	var parent_b: Dictionary = _follower_by_id(int(item.get("b_id", -1)))
	parent_row.add_child(_create_compact_card(parent_a, 280, true))

	var plus_label: Label = Label.new()
	plus_label.text = "+"
	plus_label.add_theme_font_size_override("font_size", 30)
	plus_label.add_theme_color_override("font_color", Color(0.72, 0.72, 0.76))
	parent_row.add_child(plus_label)

	parent_row.add_child(_create_compact_card(parent_b, 280, true))

	var arrow_center: CenterContainer = CenterContainer.new()
	arrow_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	arrow_center.custom_minimum_size = Vector2(0, 32)
	outer.add_child(arrow_center)

	var arrow_label: Label = Label.new()
	arrow_label.text = "v"
	arrow_label.add_theme_font_size_override("font_size", 16)
	arrow_label.add_theme_color_override("font_color", Color(0.72, 0.72, 0.76))
	arrow_center.add_child(arrow_label)

	var offspring_center: CenterContainer = CenterContainer.new()
	offspring_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer.add_child(offspring_center)

	var offspring_card: Control

	var success: bool = bool(item.get("success", false))
	if success:
		var baby: Dictionary = item.get("baby", {})
		offspring_card = _create_offspring_card(baby)
	else:
		var reason: String = str(item.get("reason", "no offspring"))
		var msg: String = "No offspring this week"
		if reason == "missing parent":
			msg = "Nest was empty"
		offspring_card = _create_offspring_placeholder(msg)
	for child in offspring_center.get_children():
		offspring_center.remove_child(child)
		child.queue_free()
	offspring_center.add_child(offspring_card)
	var offspring_h: float = max(offspring_card.custom_minimum_size.y, offspring_card.get_combined_minimum_size().y)
	offspring_center.custom_minimum_size = Vector2(0, offspring_h)

	return {
		"root": section,
		"arrow": arrow_label,
		"offspring": offspring_card,
	}

func _create_compact_card(follower: Dictionary, width: int, include_origin: bool) -> PanelContainer:
	var card: PanelContainer = PanelContainer.new()
	card.custom_minimum_size = Vector2(width, 64)
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.tooltip_text = _follower_trait_tooltip_text(follower)

	var sb: StyleBoxFlat = StyleBoxFlat.new()
	var trait_name: String = _follower_type_for_card(follower)
	if follower.is_empty():
		sb.bg_color = Color(0.15, 0.15, 0.16, 0.9)
	else:
		sb.bg_color = _trait_color(trait_name).lerp(Color(0.12, 0.12, 0.14, 1.0), 0.82)
	sb.border_color = Color(0.34, 0.34, 0.38, 0.85)
	sb.border_width_left = 1
	sb.border_width_right = 1
	sb.border_width_top = 1
	sb.border_width_bottom = 1
	sb.corner_radius_top_left = 9
	sb.corner_radius_top_right = 9
	sb.corner_radius_bottom_left = 9
	sb.corner_radius_bottom_right = 9
	card.add_theme_stylebox_override("panel", sb)

	var margin: MarginContainer = MarginContainer.new()
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.offset_left = 8.0
	margin.offset_top = 6.0
	margin.offset_right = -8.0
	margin.offset_bottom = -6.0
	card.add_child(margin)

	var row: HBoxContainer = HBoxContainer.new()
	row.anchor_right = 1.0
	row.anchor_bottom = 1.0
	row.add_theme_constant_override("separation", 6)
	margin.add_child(row)

	var strip: ColorRect = ColorRect.new()
	strip.custom_minimum_size = Vector2(8, 0)
	strip.size_flags_vertical = Control.SIZE_EXPAND_FILL
	strip.color = _trait_color(trait_name) if not follower.is_empty() else Color(0.38, 0.38, 0.4)
	row.add_child(strip)

	var tier_label: Label = Label.new()
	var type_label: Label = Label.new()
	var trait_label: Label = Label.new()
	var rarity_label: Label = Label.new()
	var multi_label: Label = Label.new()
	var origin_label: Label = Label.new()

	if follower.is_empty():
		tier_label.text = "--"
		type_label.text = "EMPTY"
		trait_label.text = "-"
		rarity_label.text = ""
		multi_label.text = ""
		origin_label.text = ""
	else:
		var trait_id: String = str(follower.get("trait_id", ""))
		tier_label.text = "T%d" % int(follower.get("tier", 0))
		type_label.text = trait_name
		trait_label.text = _trait_name(trait_id)
		rarity_label.text = _rarity_badge(_trait_rarity(trait_id))
		rarity_label.add_theme_color_override("font_color", _rarity_color(_trait_rarity(trait_id)))
		multi_label.text = _multi_trait_badge(follower)
		origin_label.text = str(follower.get("origin_tag", ""))

	tier_label.add_theme_font_size_override("font_size", 20)
	type_label.add_theme_font_size_override("font_size", 13)
	type_label.add_theme_color_override("font_color", Color(0.74, 0.74, 0.78))
	trait_label.add_theme_font_size_override("font_size", 14)
	trait_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rarity_label.add_theme_font_size_override("font_size", 13)
	multi_label.add_theme_font_size_override("font_size", 12)
	multi_label.add_theme_color_override("font_color", Color(0.84, 0.84, 0.88))
	origin_label.add_theme_font_size_override("font_size", 12)
	origin_label.add_theme_color_override("font_color", Color(0.62, 0.62, 0.66))

	row.add_child(tier_label)
	row.add_child(type_label)
	row.add_child(trait_label)
	row.add_child(rarity_label)
	row.add_child(multi_label)
	if include_origin:
		row.add_child(origin_label)
	_set_descendants_mouse_ignore(card)
	_update_lineage_badge(card, follower)

	return card

func _create_offspring_card(follower: Dictionary) -> Control:
	var card_root: Control = Control.new()
	card_root.custom_minimum_size = Vector2(256, 120)
	card_root.mouse_filter = Control.MOUSE_FILTER_STOP
	card_root.tooltip_text = _follower_trait_tooltip_text(follower)
	var follower_type: String = str(follower.get("trait", "")).to_upper()
	var glow: Color = _offspring_type_color(follower_type)

	var card: PanelContainer = PanelContainer.new()
	card.anchor_right = 1.0
	card.anchor_bottom = 1.0
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = _offspring_type_color(str(follower.get("trait", "")).to_upper())
	sb.border_color = glow.lerp(Color(1, 1, 1, 1), 0.2)
	sb.border_width_left = 2
	sb.border_width_right = 2
	sb.border_width_top = 2
	sb.border_width_bottom = 2
	sb.corner_radius_top_left = 10
	sb.corner_radius_top_right = 10
	sb.corner_radius_bottom_left = 10
	sb.corner_radius_bottom_right = 10
	sb.shadow_color = Color(glow.r, glow.g, glow.b, 0.45)
	sb.shadow_size = 9
	card.add_theme_stylebox_override("panel", sb)
	card_root.add_child(card)

	var margin: MarginContainer = MarginContainer.new()
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.offset_left = 8.0
	margin.offset_top = 8.0
	margin.offset_right = -8.0
	margin.offset_bottom = -8.0
	card.add_child(margin)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 4)
	margin.add_child(vbox)

	var tier: Label = Label.new()
	tier.text = "T%d" % int(follower.get("tier", 0))
	tier.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tier.add_theme_font_size_override("font_size", 28)
	vbox.add_child(tier)

	var type_label: Label = Label.new()
	type_label.text = follower_type if follower_type != "" else "UNKNOWN"
	type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	type_label.add_theme_font_size_override("font_size", 14)
	type_label.add_theme_color_override("font_color", _trait_label_color(follower_type))
	vbox.add_child(type_label)

	var trait_id: String = str(follower.get("trait_id", ""))
	var trait_name_label: Label = Label.new()
	trait_name_label.text = _trait_name(trait_id)
	trait_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	trait_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	trait_name_label.add_theme_font_size_override("font_size", 13)
	vbox.add_child(trait_name_label)

	var rarity_label: Label = Label.new()
	rarity_label.text = "%s%s" % [_rarity_badge(_trait_rarity(trait_id)), _multi_trait_badge(follower)]
	rarity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rarity_label.add_theme_font_size_override("font_size", 12)
	rarity_label.add_theme_color_override("font_color", _rarity_color(_trait_rarity(trait_id)))
	vbox.add_child(rarity_label)

	var badge_panel: PanelContainer = PanelContainer.new()
	badge_panel.position = Vector2(8, 8)
	badge_panel.custom_minimum_size = Vector2(52, 22)
	badge_panel.size = badge_panel.custom_minimum_size
	badge_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var badge_sb: StyleBoxFlat = StyleBoxFlat.new()
	badge_sb.bg_color = Color(0.92, 0.72, 0.34, 0.98)
	badge_sb.corner_radius_top_left = 11
	badge_sb.corner_radius_top_right = 11
	badge_sb.corner_radius_bottom_left = 11
	badge_sb.corner_radius_bottom_right = 11
	badge_panel.add_theme_stylebox_override("panel", badge_sb)
	var badge: Label = Label.new()
	badge.anchor_right = 1.0
	badge.anchor_bottom = 1.0
	badge.text = "NEW"
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 13)
	badge.add_theme_color_override("font_color", Color(0.2, 0.12, 0.04))
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge_panel.add_child(badge)
	card_root.add_child(badge_panel)
	_update_lineage_badge(card_root, follower)
	_set_descendants_mouse_ignore(card_root)

	return card_root

func _create_offspring_placeholder(message: String) -> PanelContainer:
	var card: PanelContainer = PanelContainer.new()
	card.custom_minimum_size = Vector2(256, 112)
	_set_panel_style(card, Color(0.16, 0.16, 0.18, 0.92), Color(0.34, 0.34, 0.38, 0.85), 1, 10)
	var label: Label = Label.new()
	label.anchor_right = 1.0
	label.anchor_bottom = 1.0
	label.text = message
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.64))
	card.add_child(label)
	return card

func prepare_reveal_state() -> void:
	for entry in _nest_visual_refs:
		var root: Control = entry["root"]
		root.visible = false
		root.modulate = Color(1, 1, 1, 0)
		var arrow_node: Control = entry["arrow"]
		arrow_node.visible = true
		arrow_node.modulate = Color(1, 1, 1, 0)
		var offspring_node: Control = entry["offspring"]
		offspring_node.visible = true
		offspring_node.scale = Vector2.ZERO
		offspring_node.modulate = Color(1, 1, 1, 1)
	wild_section.visible = false
	wild_section.modulate = Color(1, 1, 1, 0)
	summary_line.visible = false
	summary_line.modulate = Color(1, 1, 1, 0)
	continue_button.disabled = true
	continue_button.scale = Vector2.ONE

func _run_reveal_sequence() -> void:
	await get_tree().create_timer(0.3).timeout
	for entry in _nest_visual_refs:
		var section_root: Control = entry["root"]
		var arrow_node: Control = entry["arrow"]
		var offspring_node: Control = entry["offspring"]

		section_root.visible = true
		await _fade_in_control(section_root, 0.25)

		await get_tree().create_timer(0.4).timeout
		await _fade_in_control(arrow_node, 0.12)

		await get_tree().create_timer(0.4).timeout
		offspring_node.scale = Vector2.ZERO
		offspring_node.modulate = Color(1, 1, 1, 1)
		await _spring_in(offspring_node)
		await get_tree().create_timer(0.2).timeout

	wild_section.visible = true
	await _fade_in_control(wild_section, 0.2)

	summary_line.visible = true
	await _fade_in_control(summary_line, 0.2)

	_reveals_complete = true
	continue_button.disabled = false
	_start_continue_pulse()

func _fade_in_control(node: Control, duration: float) -> void:
	node.modulate = Color(1, 1, 1, 0)
	var t: Tween = create_tween()
	t.set_trans(Tween.TRANS_SINE)
	t.set_ease(Tween.EASE_OUT)
	t.tween_property(node, "modulate:a", 1.0, duration)
	await t.finished

func _spring_in(node: Control) -> void:
	var node_size: Vector2 = node.size
	if node_size.x < 2.0 or node_size.y < 2.0:
		node_size = node.custom_minimum_size
	if node_size.x < 2.0 or node_size.y < 2.0:
		node_size = node.get_combined_minimum_size()
	node.pivot_offset = node_size * 0.5
	var t: Tween = create_tween()
	t.set_trans(Tween.TRANS_BACK)
	t.set_ease(Tween.EASE_OUT)
	t.tween_property(node, "scale", Vector2(1.08, 1.08), 0.2)
	t.tween_property(node, "scale", Vector2.ONE, 0.1)
	await t.finished

func _start_continue_pulse() -> void:
	if _continue_pulse_tween != null and is_instance_valid(_continue_pulse_tween):
		_continue_pulse_tween.kill()
	_continue_pulse_tween = create_tween()
	_continue_pulse_tween.set_loops()
	_continue_pulse_tween.set_trans(Tween.TRANS_SINE)
	_continue_pulse_tween.set_ease(Tween.EASE_IN_OUT)
	_continue_pulse_tween.tween_property(continue_button, "scale", Vector2(1.03, 1.03), 0.55)
	_continue_pulse_tween.tween_property(continue_button, "scale", Vector2.ONE, 0.55)

func _on_continue_pressed() -> void:
	if not _reveals_complete:
		return
	if _continue_pulse_tween != null and is_instance_valid(_continue_pulse_tween):
		_continue_pulse_tween.kill()
	continue_button.scale = Vector2.ONE
	get_tree().change_scene_to_file("res://scenes/Shop.tscn")

func _on_menu_pressed() -> void:
	var overlay: Node = get_node_or_null("/root/GlobalMenuOverlay")
	if overlay != null:
		if overlay.has_method("open_menu"):
			overlay.call("open_menu")
			return
		if overlay.has_method("_on_menu_pressed"):
			overlay.call("_on_menu_pressed")

func _parse_breeding_summary(summary: String) -> Dictionary:
	var parsed: Dictionary = {
		"week": gs.current_week,
		"pool_before": gs.pool.size(),
		"pool_after": gs.pool.size(),
		"nest_newborns": 0,
		"wild_newborns": 0,
		"trimmed": 0,
	}
	if summary == "":
		return parsed
	for raw in summary.split("\n"):
		var line: String = raw.strip_edges()
		if line.find("Week ") >= 0:
			parsed["week"] = _first_int(line, int(parsed["week"]))
		elif line.begins_with("Nest newborns:"):
			parsed["nest_newborns"] = _first_int(line, int(parsed["nest_newborns"]))
		elif line.begins_with("Wild newborns:"):
			parsed["wild_newborns"] = _first_int(line, int(parsed["wild_newborns"]))
		elif line.begins_with("Newborns:") and int(parsed["nest_newborns"]) == 0:
			parsed["nest_newborns"] = _first_int(line, int(parsed["nest_newborns"]))
		elif line.begins_with("Pool:"):
			var nums: Array[int] = _all_ints(line)
			if nums.size() >= 2:
				parsed["pool_before"] = nums[0]
				parsed["pool_after"] = nums[1]
		elif line.begins_with("Trimmed:"):
			parsed["trimmed"] = _first_int(line, int(parsed["trimmed"]))
	if int(parsed["pool_before"]) == int(parsed["pool_after"]) and not summary.contains("Pool:"):
		var after_pool: int = gs.pool.size()
		parsed["pool_after"] = after_pool
		parsed["pool_before"] = max(0, after_pool - int(parsed["nest_newborns"]) - int(parsed["wild_newborns"]) + int(parsed["trimmed"]))
	return parsed

func _recent_wild_newborns(expected_count: int) -> Array[Dictionary]:
	if expected_count <= 0:
		return []
	var wild_candidates: Array[Dictionary] = []
	for f in gs.pool:
		if str(f.get("origin_tag", "")) == "wild_bred":
			wild_candidates.append(f)
	wild_candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("id", -1)) > int(b.get("id", -1))
	)
	var picked: Array[Dictionary] = []
	for i in range(min(expected_count, wild_candidates.size())):
		picked.append(wild_candidates[i])
	picked.reverse()
	return picked

func _follower_by_id(follower_id: int) -> Dictionary:
	if follower_id < 0:
		return {}
	for f in gs.pool:
		if int(f.get("id", -1)) == follower_id:
			return f
	return {}

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

func _trait_rarity(trait_id: String) -> String:
	if trait_id == "":
		return "COMMON"
	return str(gs._trait_rarity(trait_id))

func _rarity_badge(rarity: String) -> String:
	match rarity.to_upper():
		"LEGENDARY":
			return "[L]"
		"RARE":
			return "[R]"
		"UNCOMMON":
			return "[U]"
		_:
			return "[C]"

func _rarity_color(rarity: String) -> Color:
	match rarity.to_upper():
		"UNCOMMON":
			return Color(0.45, 0.72, 0.46)
		"RARE":
			return Color(0.5, 0.46, 0.78)
		"LEGENDARY":
			return Color(0.9, 0.68, 0.32)
		_:
			return Color(0.7, 0.7, 0.74)

func _multi_trait_badge(follower: Dictionary) -> String:
	var ids: Array[String] = []
	var primary: String = str(follower.get("trait_id", ""))
	if primary != "":
		ids.append(primary)
	for raw in follower.get("trait_ids", []):
		var tid: String = str(raw)
		if tid != "" and not ids.has(tid):
			ids.append(tid)
	if ids.size() <= 1:
		return ""
	return " x%d" % ids.size()

func _follower_all_trait_ids(follower: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	var primary: String = str(follower.get("trait_id", ""))
	if primary != "":
		ids.append(primary)
	for raw in follower.get("trait_ids", []):
		var tid: String = str(raw)
		if tid != "" and not ids.has(tid):
			ids.append(tid)
	return ids

func _follower_trait_tooltip_text(follower: Dictionary) -> String:
	if follower.is_empty():
		return "No parent assigned."
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
	return "%s: %s" % [str(info.get("name", trait_id)), str(info.get("desc", ""))]

func _set_descendants_mouse_ignore(root: Control) -> void:
	for child in root.get_children():
		if child is Control:
			var control_child: Control = child as Control
			control_child.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_set_descendants_mouse_ignore(control_child)

func _follower_type_for_card(follower: Dictionary) -> String:
	var t: String = str(follower.get("trait", "")).to_upper()
	if t == "":
		if follower.has("type"):
			t = str(follower.get("type", "")).to_upper()
		elif follower.has("follower_type"):
			t = str(follower.get("follower_type", "")).to_upper()
	match t:
		"BLOOD", "BONE", "VOID", "SOUL":
			return t
		_:
			if int(follower.get("tier", -1)) == 0:
				return "VOID"
			return ""

func _lineage_value(follower: Dictionary) -> int:
	return clamp(int(follower.get("lineage", 0)), 0, 10)

func _lineage_badge_color(lineage: int) -> Color:
	if lineage >= 10:
		return Color(1.0, 0.95, 0.8)
	if lineage >= 7:
		return Color(0.9, 0.75, 0.1)
	if lineage >= 4:
		return Color(0.8, 0.6, 0.2)
	return Color(0.3, 0.6, 0.6)

func _lineage_badge_text_color(lineage: int) -> Color:
	return Color(0.2, 0.16, 0.08) if lineage >= 4 else Color(0.9, 0.95, 0.95)

func _lineage_pulse_stop(node: CanvasItem) -> void:
	var pulse_tween: Tween = node.get_meta("_lineage_pulse_tween", null) as Tween
	if pulse_tween != null and is_instance_valid(pulse_tween):
		pulse_tween.kill()
	node.set_meta("_lineage_pulse_tween", null)
	node.modulate = Color(1, 1, 1, 1)

func _lineage_pulse_start(node: CanvasItem) -> void:
	_lineage_pulse_stop(node)
	var pulse_tween: Tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.set_trans(Tween.TRANS_SINE)
	pulse_tween.set_ease(Tween.EASE_IN_OUT)
	pulse_tween.tween_property(node, "modulate:a", 0.9, 0.75)
	pulse_tween.tween_property(node, "modulate:a", 1.0, 0.75)
	node.set_meta("_lineage_pulse_tween", pulse_tween)

func _update_lineage_badge(card_root: Control, follower: Dictionary) -> void:
	var lineage: int = _lineage_value(follower)
	var badge: PanelContainer = card_root.get_node_or_null("LineageBadge") as PanelContainer
	if lineage <= 0:
		if badge != null:
			_lineage_pulse_stop(badge)
			badge.visible = false
		return
	if badge == null:
		badge = PanelContainer.new()
		badge.name = "LineageBadge"
		badge.anchor_left = 1.0
		badge.anchor_top = 1.0
		badge.anchor_right = 1.0
		badge.anchor_bottom = 1.0
		badge.offset_left = -44.0
		badge.offset_top = -24.0
		badge.offset_right = -8.0
		badge.offset_bottom = -8.0
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var label: Label = Label.new()
		label.name = "LineageBadgeLabel"
		label.anchor_right = 1.0
		label.anchor_bottom = 1.0
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 11)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge.add_child(label)
		card_root.add_child(badge)
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = _lineage_badge_color(lineage)
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 8
	sb.corner_radius_bottom_right = 8
	sb.content_margin_left = 4
	sb.content_margin_right = 4
	sb.content_margin_top = 2
	sb.content_margin_bottom = 2
	badge.add_theme_stylebox_override("panel", sb)
	var label_node: Label = badge.get_node("LineageBadgeLabel") as Label
	label_node.text = "L%d" % lineage
	label_node.add_theme_color_override("font_color", _lineage_badge_text_color(lineage))
	badge.visible = true
	if lineage >= 10:
		_lineage_pulse_start(badge)
	else:
		_lineage_pulse_stop(badge)

func _trait_label_color(trait_name: String) -> Color:
	match trait_name:
		"BLOOD":
			return Color(0.88, 0.42, 0.42)
		"BONE":
			return Color(0.92, 0.92, 0.88)
		"VOID":
			return Color(0.62, 0.44, 0.88)
		"SOUL":
			return Color(0.95, 0.82, 0.46)
		_:
			return Color(0.8, 0.8, 0.84)

func _offspring_type_color(type_name: String) -> Color:
	match type_name:
		"BLOOD":
			return Color(0.45, 0.08, 0.08)
		"BONE":
			return Color(0.75, 0.73, 0.68)
		"VOID":
			return Color(0.22, 0.13, 0.35)
		"SOUL":
			return Color(0.65, 0.58, 0.25)
		_:
			return Color(0.2, 0.2, 0.2)

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

func _all_ints(text: String) -> Array[int]:
	var nums: Array[int] = []
	var regex := RegEx.new()
	if regex.compile("\\d+") != OK:
		return nums
	for m in regex.search_all(text):
		nums.append(int(m.get_string()))
	return nums

func _first_int(text: String, fallback: int) -> int:
	var nums: Array[int] = _all_ints(text)
	return fallback if nums.is_empty() else nums[0]
