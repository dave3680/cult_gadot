extends PanelContainer

signal drag_started(follower_id: int)
signal drag_finished(follower_id: int, successful: bool)

var follower_id: int = -1
var follower_payload: Dictionary = {}

var _type_strip: ColorRect
var _tier_label: Label
var _type_label: Label
var _trait_label: Label
var _rarity_label: Label
var _multi_label: Label
var _origin_label: Label
var _favored_label: Label
var _is_dragging: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(0, 56)
	_build_layout()
	_apply_style(false, false)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func configure(data: Dictionary) -> void:
	follower_payload = data.duplicate(true)
	follower_id = int(follower_payload.get("id", -1))
	if _type_strip == null:
		_build_layout()
	_type_strip.color = follower_payload.get("type_color", Color(0.45, 0.45, 0.45))
	_tier_label.text = str(follower_payload.get("tier_text", "T0"))
	_type_label.text = str(follower_payload.get("type_text", ""))
	_trait_label.text = str(follower_payload.get("trait_text", "-"))
	_rarity_label.text = str(follower_payload.get("rarity_text", ""))
	_multi_label.text = str(follower_payload.get("multi_text", ""))
	_origin_label.text = str(follower_payload.get("origin_text", ""))
	_favored_label.text = "Fav" if bool(follower_payload.get("favored", false)) else ""
	_rarity_label.add_theme_color_override("font_color", follower_payload.get("rarity_color", Color(0.75, 0.75, 0.75)))
	_type_label.add_theme_color_override("font_color", follower_payload.get("type_label_color", Color(0.72, 0.72, 0.74)))
	_trait_label.add_theme_color_override("font_color", follower_payload.get("trait_color", Color(0.9, 0.9, 0.92)))
	_origin_label.add_theme_color_override("font_color", Color(0.58, 0.58, 0.62))
	_favored_label.add_theme_color_override("font_color", Color(0.95, 0.75, 0.3))
	_apply_style(false, false)

func _build_layout() -> void:
	if _type_strip != null:
		return
	var margin: MarginContainer = MarginContainer.new()
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.offset_left = 8.0
	margin.offset_top = 6.0
	margin.offset_right = -8.0
	margin.offset_bottom = -6.0
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)

	var row: HBoxContainer = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.alignment = BoxContainer.ALIGNMENT_BEGIN
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(row)

	_type_strip = ColorRect.new()
	_type_strip.custom_minimum_size = Vector2(8, 0)
	_type_strip.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_type_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_type_strip)

	_tier_label = Label.new()
	_tier_label.add_theme_font_size_override("font_size", 20)
	_tier_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_tier_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_tier_label)

	_type_label = Label.new()
	_type_label.add_theme_font_size_override("font_size", 14)
	_type_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_type_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_type_label)

	_trait_label = Label.new()
	_trait_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_trait_label.add_theme_font_size_override("font_size", 14)
	_trait_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_trait_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_trait_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_trait_label)

	_rarity_label = Label.new()
	_rarity_label.add_theme_font_size_override("font_size", 13)
	_rarity_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_rarity_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_rarity_label)

	_multi_label = Label.new()
	_multi_label.add_theme_font_size_override("font_size", 13)
	_multi_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_multi_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
	_multi_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_multi_label)

	_origin_label = Label.new()
	_origin_label.add_theme_font_size_override("font_size", 12)
	_origin_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_origin_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_origin_label)

	_favored_label = Label.new()
	_favored_label.add_theme_font_size_override("font_size", 12)
	_favored_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_favored_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_favored_label)

func _apply_style(ghosted: bool, hovered: bool) -> void:
	var base_tint: Color = follower_payload.get("bg_tint", Color(0.2, 0.2, 0.23, 0.25))
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = base_tint if not ghosted else Color(0.15, 0.15, 0.16, 0.1)
	sb.border_color = Color(0.35, 0.35, 0.39, 0.9) if not ghosted else Color(0.82, 0.82, 0.86, 0.55)
	sb.border_width_left = 1
	sb.border_width_right = 1
	sb.border_width_top = 1
	sb.border_width_bottom = 1
	sb.corner_radius_top_left = 9
	sb.corner_radius_top_right = 9
	sb.corner_radius_bottom_left = 9
	sb.corner_radius_bottom_right = 9
	sb.shadow_color = Color(0.0, 0.0, 0.0, 0.4)
	sb.shadow_size = 8 if hovered else 4
	add_theme_stylebox_override("panel", sb)
	modulate = Color(1, 1, 1, 0.42) if ghosted else Color(1, 1, 1, 1)

func _on_mouse_entered() -> void:
	if _is_dragging:
		return
	_apply_style(false, true)

func _on_mouse_exited() -> void:
	if _is_dragging:
		return
	_apply_style(false, false)

func _get_drag_data(_at_position: Vector2) -> Variant:
	if follower_id < 0:
		return null
	_is_dragging = true
	_apply_style(true, false)
	drag_started.emit(follower_id)
	var preview: Control = _build_drag_preview()
	set_drag_preview(preview)
	return {"follower_id": follower_id}

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END and _is_dragging:
		var successful: bool = is_drag_successful()
		_is_dragging = false
		_apply_style(false, false)
		drag_finished.emit(follower_id, successful)

func _build_drag_preview() -> Control:
	var card: PanelContainer = PanelContainer.new()
	var w: float = max(320.0, size.x)
	var h: float = max(52.0, custom_minimum_size.y)
	card.custom_minimum_size = Vector2(w, h)
	card.size = card.custom_minimum_size
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = follower_payload.get("bg_tint", Color(0.2, 0.2, 0.23, 0.28))
	sb.border_color = Color(0.82, 0.82, 0.86, 0.95)
	sb.border_width_left = 1
	sb.border_width_right = 1
	sb.border_width_top = 1
	sb.border_width_bottom = 1
	sb.corner_radius_top_left = 9
	sb.corner_radius_top_right = 9
	sb.corner_radius_bottom_left = 9
	sb.corner_radius_bottom_right = 9
	sb.shadow_color = Color(0.0, 0.0, 0.0, 0.52)
	sb.shadow_size = 10
	card.add_theme_stylebox_override("panel", sb)
	card.scale = Vector2(1.05, 1.05)
	card.pivot_offset = card.custom_minimum_size * 0.5
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var m: MarginContainer = MarginContainer.new()
	m.anchor_right = 1.0
	m.anchor_bottom = 1.0
	m.offset_left = 8.0
	m.offset_top = 6.0
	m.offset_right = -8.0
	m.offset_bottom = -6.0
	m.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(m)

	var label: Label = Label.new()
	label.anchor_right = 1.0
	label.anchor_bottom = 1.0
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = "%s  %s  %s  %s %s" % [
		str(follower_payload.get("tier_text", "T0")),
		str(follower_payload.get("type_text", "")),
		str(follower_payload.get("trait_text", "-")),
		str(follower_payload.get("rarity_text", "")),
		str(follower_payload.get("multi_text", "")),
	]
	m.add_child(label)
	return card
