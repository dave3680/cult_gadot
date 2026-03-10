extends CanvasLayer

const DRAWER_WIDTH := 280.0
const DRAWER_MAX_HEIGHT := 400.0
const HOVER_DELAY_SEC := 0.2
const TOOLTIP_WIDTH := 320.0
const TOOLTIP_MAX_HEIGHT := 300.0
const TOOLTIP_MAX_LINES := 9

@onready var root: Control = $Root
@onready var anchor: Control = $Root/Anchor
@onready var toggle_button: Button = $Root/Anchor/DrawerVBox/ToggleButton
@onready var drawer_panel: PanelContainer = $Root/Anchor/DrawerVBox/DrawerPanel
@onready var drawer_scroll: ScrollContainer = $Root/Anchor/DrawerVBox/DrawerPanel/PanelMargin/Scroll
@onready var relic_rows: VBoxContainer = $Root/Anchor/DrawerVBox/DrawerPanel/PanelMargin/Scroll/RelicRows
@onready var tooltip_panel: PanelContainer = $Root/TooltipPanel
@onready var tooltip_name: Label = $Root/TooltipPanel/TooltipMargin/TooltipVBox/TooltipName
@onready var tooltip_meta: Label = $Root/TooltipPanel/TooltipMargin/TooltipVBox/TooltipMeta
@onready var tooltip_desc: Label = $Root/TooltipPanel/TooltipMargin/TooltipVBox/TooltipDesc
@onready var tooltip_owned: Label = $Root/TooltipPanel/TooltipMargin/TooltipVBox/TooltipOwned
@onready var hover_timer: Timer = $HoverTimer
@onready var gs: Node = get_node_or_null("/root/GameState")

var _expanded: bool = false
var _hover_row: Control = null
var _hover_data: Dictionary = {}

func _ready() -> void:
	layer = 10
	_apply_theme()
	toggle_button.pressed.connect(_on_toggle_pressed)
	hover_timer.wait_time = HOVER_DELAY_SEC
	hover_timer.one_shot = true
	hover_timer.timeout.connect(_on_hover_delay_timeout)
	get_viewport().size_changed.connect(_position_anchor)
	call_deferred("_position_anchor")
	set_process(true)
	_set_expanded(false)
	_refresh_button_text()

func _process(_delta: float) -> void:
	_position_anchor()

func _input(event: InputEvent) -> void:
	if not _expanded:
		return
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			if not _point_in_open_ui(mb.position):
				_set_expanded(false)

func _on_toggle_pressed() -> void:
	_set_expanded(not _expanded)

func _set_expanded(open: bool) -> void:
	_expanded = open
	drawer_panel.visible = open
	if not open:
		hover_timer.stop()
		_hide_tooltip()
		return
	_position_anchor()
	_refresh_rows()
	drawer_scroll.scroll_vertical = 0

func _refresh_button_text() -> void:
	var total: int = 0
	if gs != null:
		var inv: Dictionary = gs.get("relic_inventory")
		for relic_name in inv.keys():
			total += max(0, int(inv.get(relic_name, 0)))
	toggle_button.text = "Relics (%d)" % total

func _refresh_rows() -> void:
	_refresh_button_text()
	for child in relic_rows.get_children():
		child.queue_free()
	var entries: Array[Dictionary] = _get_sorted_entries()
	if entries.is_empty():
		var empty := Label.new()
		empty.text = "No relics acquired yet."
		empty.modulate = Color(0.68, 0.68, 0.72)
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		relic_rows.add_child(empty)
		_apply_scroll_height(1)
		return
	for entry in entries:
		var row: PanelContainer = _build_row(entry)
		relic_rows.add_child(row)
	_apply_scroll_height(entries.size())

func _get_sorted_entries() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if gs == null:
		return out
	var inv: Dictionary = gs.get("relic_inventory")
	var defs: Dictionary = gs.get("RELIC_DEFS")
	for relic_name in inv.keys():
		var count: int = int(inv.get(relic_name, 0))
		if count <= 0:
			continue
		var def: Dictionary = defs.get(str(relic_name), {})
		var rarity: String = str(def.get("rarity", "COMMON"))
		var category: String = str(def.get("category", "RELIC"))
		var desc: String = str(def.get("desc", ""))
		var stacks: bool = bool(def.get("stacks", false))
		out.append({
			"name": str(relic_name),
			"count": count,
			"rarity": rarity,
			"category": category,
			"desc": desc,
			"stacks": stacks,
		})
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ar: int = _rarity_rank(str(a.get("rarity", "COMMON")))
		var br: int = _rarity_rank(str(b.get("rarity", "COMMON")))
		if ar != br:
			return ar < br
		return str(a.get("name", "")).to_lower() < str(b.get("name", "")).to_lower()
	)
	return out

func _build_row(entry: Dictionary) -> PanelContainer:
	var row := PanelContainer.new()
	row.custom_minimum_size = Vector2(DRAWER_WIDTH - 12.0, 50.0)
	row.mouse_filter = Control.MOUSE_FILTER_STOP
	var row_style := StyleBoxFlat.new()
	row_style.bg_color = Color(0.11, 0.11, 0.12, 0.95)
	row_style.corner_radius_top_left = 6
	row_style.corner_radius_top_right = 6
	row_style.corner_radius_bottom_left = 6
	row_style.corner_radius_bottom_right = 6
	row.add_theme_stylebox_override("panel", row_style)

	var h := HBoxContainer.new()
	h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(h)

	var strip := ColorRect.new()
	strip.custom_minimum_size = Vector2(6, 50)
	strip.color = _rarity_color(str(entry.get("rarity", "COMMON")))
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(strip)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 2)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(content)

	var name := Label.new()
	name.text = str(entry.get("name", "Unknown"))
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	name.add_theme_font_size_override("font_size", 14)
	name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(name)

	var meta := Label.new()
	meta.text = str(entry.get("category", "RELIC"))
	meta.modulate = Color(0.69, 0.69, 0.73)
	meta.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	meta.add_theme_font_size_override("font_size", 11)
	meta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(meta)

	var count_label := Label.new()
	count_label.custom_minimum_size = Vector2(36, 0)
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	count_label.modulate = Color(0.72, 0.72, 0.76)
	count_label.add_theme_font_size_override("font_size", 12)
	count_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var stacks: bool = bool(entry.get("stacks", false))
	var count: int = int(entry.get("count", 0))
	count_label.text = "x%d" % count if stacks and count > 1 else ""
	h.add_child(count_label)

	row.mouse_entered.connect(_on_row_mouse_entered.bind(row, entry))
	row.mouse_exited.connect(_on_row_mouse_exited.bind(row))
	return row

func _on_row_mouse_entered(row: Control, entry: Dictionary) -> void:
	_hover_row = row
	_hover_data = entry.duplicate(true)
	hover_timer.stop()
	hover_timer.start()

func _on_row_mouse_exited(row: Control) -> void:
	if row == _hover_row:
		_hover_row = null
		_hover_data = {}
		hover_timer.stop()
	_hide_tooltip()

func _on_hover_delay_timeout() -> void:
	if _hover_row == null or _hover_data.is_empty():
		return
	_show_tooltip(_hover_data)

func _show_tooltip(entry: Dictionary) -> void:
	tooltip_name.text = str(entry.get("name", "Unknown"))
	tooltip_meta.text = "%s  |  %s" % [str(entry.get("rarity", "COMMON")), str(entry.get("category", "RELIC"))]
	tooltip_desc.text = str(entry.get("desc", ""))
	var stacks: bool = bool(entry.get("stacks", false))
	var count: int = int(entry.get("count", 0))
	if stacks:
		tooltip_owned.visible = true
		tooltip_owned.text = "Owned: %dx" % count
	else:
		tooltip_owned.visible = false
	tooltip_panel.visible = true
	call_deferred("_finalize_tooltip_layout")

func _finalize_tooltip_layout() -> void:
	if not tooltip_panel.visible:
		return
	_position_tooltip()

func _position_tooltip() -> void:
	var drawer_rect: Rect2 = _drawer_global_rect()
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	tooltip_panel.size = Vector2(TOOLTIP_WIDTH, tooltip_panel.size.y)
	tooltip_desc.custom_minimum_size = Vector2(TOOLTIP_WIDTH - 24.0, 0.0)
	tooltip_desc.update_minimum_size()
	tooltip_panel.update_minimum_size()
	var min_size: Vector2 = tooltip_panel.get_combined_minimum_size()
	var tip_size := Vector2(max(TOOLTIP_WIDTH, min_size.x), clamp(min_size.y, 88.0, TOOLTIP_MAX_HEIGHT))
	tooltip_panel.size = tip_size
	var x: float = drawer_rect.position.x + drawer_rect.size.x + 8.0
	if x + tip_size.x > viewport_size.x - 8.0:
		x = drawer_rect.position.x - tip_size.x - 8.0
	var y: float = clamp(drawer_rect.position.y, 8.0, max(8.0, viewport_size.y - tip_size.y - 8.0))
	tooltip_panel.global_position = Vector2(x, y)

func _hide_tooltip() -> void:
	tooltip_panel.visible = false

func _apply_scroll_height(item_count: int) -> void:
	var estimated: float = float(item_count) * 56.0
	var target_h: float = min(DRAWER_MAX_HEIGHT, max(64.0, estimated))
	drawer_scroll.custom_minimum_size = Vector2(DRAWER_WIDTH - 12.0, target_h)

func _point_in_open_ui(point: Vector2) -> bool:
	if _control_contains_point(toggle_button, point):
		return true
	if drawer_panel.visible and _control_contains_point(drawer_panel, point):
		return true
	if tooltip_panel.visible and _control_contains_point(tooltip_panel, point):
		return true
	return false

func _control_contains_point(node: Control, point: Vector2) -> bool:
	return Rect2(node.global_position, node.size).has_point(point)

func _drawer_global_rect() -> Rect2:
	if drawer_panel.visible:
		return Rect2(drawer_panel.global_position, drawer_panel.size)
	return Rect2(toggle_button.global_position, toggle_button.size)

func _position_anchor() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var button_size: Vector2 = toggle_button.size
	if button_size.x <= 1.0 or button_size.y <= 1.0:
		button_size = toggle_button.get_combined_minimum_size()
	var fallback_x: float = max(8.0, viewport_size.x - button_size.x - 12.0)
	var fallback_y: float = 12.0
	var right_controls: Control = _find_right_controls()
	if right_controls != null:
		var menu_btn: Control = right_controls.get_node_or_null("MenuButton") as Control
		if menu_btn != null:
			var target_size: Vector2 = menu_btn.get_combined_minimum_size()
			if target_size.x > 0.0 and target_size.y > 0.0:
				toggle_button.custom_minimum_size = target_size
				toggle_button.size = target_size
				button_size = target_size
				fallback_x = max(8.0, viewport_size.x - button_size.x - 12.0)
		var rc_size: Vector2 = right_controls.size
		if rc_size.x <= 1.0 or rc_size.y <= 1.0:
			rc_size = right_controls.get_combined_minimum_size()
		var x: float = right_controls.global_position.x - button_size.x - 8.0
		var y: float = right_controls.global_position.y + max(0.0, (rc_size.y - button_size.y) * 0.5)
		var clamped_x: float = clamp(x, 8.0, fallback_x)
		var clamped_y: float = clamp(y, 8.0, max(8.0, viewport_size.y - button_size.y - 8.0))
		anchor.position = Vector2(clamped_x, clamped_y)
		return
	anchor.position = Vector2(fallback_x, fallback_y)

func _find_right_controls() -> Control:
	var parent_node: Node = get_parent()
	if parent_node is Control and StringName(parent_node.name) == &"RightControls":
		return parent_node as Control
	if parent_node != null and parent_node.has_node("RootVBox/TopBar/TopBarVBox/TopMainRow/RightControls"):
		return parent_node.get_node("RootVBox/TopBar/TopBarVBox/TopMainRow/RightControls") as Control
	if parent_node != null and parent_node.has_node("RootVBox/BandTop/TopBandVBox/TopMainRow/RightControls"):
		return parent_node.get_node("RootVBox/BandTop/TopBandVBox/TopMainRow/RightControls") as Control
	var scene_root: Node = get_tree().current_scene
	if scene_root != null and scene_root.has_node("RootVBox/TopBar/TopBarVBox/TopMainRow/RightControls"):
		return scene_root.get_node("RootVBox/TopBar/TopBarVBox/TopMainRow/RightControls") as Control
	if scene_root != null and scene_root.has_node("RootVBox/BandTop/TopBandVBox/TopMainRow/RightControls"):
		return scene_root.get_node("RootVBox/BandTop/TopBandVBox/TopMainRow/RightControls") as Control
	return null

func _apply_theme() -> void:
	toggle_button.custom_minimum_size = Vector2(94, 34)
	var toggle_style := StyleBoxFlat.new()
	toggle_style.bg_color = Color(0.08, 0.08, 0.1, 0.92)
	toggle_style.border_color = Color(0.38, 0.4, 0.46, 1.0)
	toggle_style.border_width_left = 1
	toggle_style.border_width_right = 1
	toggle_style.border_width_top = 1
	toggle_style.border_width_bottom = 1
	toggle_style.corner_radius_top_left = 8
	toggle_style.corner_radius_top_right = 8
	toggle_style.corner_radius_bottom_left = 8
	toggle_style.corner_radius_bottom_right = 8
	toggle_button.add_theme_stylebox_override("normal", toggle_style)
	toggle_button.add_theme_stylebox_override("hover", toggle_style)
	toggle_button.add_theme_stylebox_override("pressed", toggle_style)

	drawer_panel.custom_minimum_size = Vector2(DRAWER_WIDTH, 0)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.08, 0.1, 0.96)
	panel_style.border_color = Color(0.34, 0.35, 0.4, 1.0)
	panel_style.border_width_left = 1
	panel_style.border_width_right = 1
	panel_style.border_width_top = 1
	panel_style.border_width_bottom = 1
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	drawer_panel.add_theme_stylebox_override("panel", panel_style)
	drawer_scroll.custom_minimum_size = Vector2(DRAWER_WIDTH - 12.0, 64.0)

	var tip_style := StyleBoxFlat.new()
	tip_style.bg_color = Color(0.06, 0.06, 0.08, 0.98)
	tip_style.border_color = Color(0.35, 0.36, 0.42, 1.0)
	tip_style.border_width_left = 1
	tip_style.border_width_right = 1
	tip_style.border_width_top = 1
	tip_style.border_width_bottom = 1
	tip_style.corner_radius_top_left = 8
	tip_style.corner_radius_top_right = 8
	tip_style.corner_radius_bottom_left = 8
	tip_style.corner_radius_bottom_right = 8
	tooltip_panel.add_theme_stylebox_override("panel", tip_style)
	tooltip_panel.custom_minimum_size = Vector2(TOOLTIP_WIDTH, 0)
	tooltip_panel.clip_contents = true
	tooltip_meta.modulate = Color(0.72, 0.72, 0.76)
	tooltip_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tooltip_desc.max_lines_visible = TOOLTIP_MAX_LINES
	tooltip_desc.custom_minimum_size = Vector2(TOOLTIP_WIDTH - 24.0, 0)
	tooltip_desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tooltip_desc.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	tooltip_owned.modulate = Color(0.82, 0.82, 0.86)

func _rarity_rank(rarity: String) -> int:
	match rarity:
		"LEGENDARY":
			return 0
		"RARE":
			return 1
		"UNCOMMON":
			return 2
		_:
			return 3

func _rarity_color(rarity: String) -> Color:
	match rarity:
		"LEGENDARY":
			return Color(0.72, 0.58, 0.32)
		"RARE":
			return Color(0.45, 0.44, 0.72)
		"UNCOMMON":
			return Color(0.40, 0.62, 0.46)
		_:
			return Color(0.56, 0.60, 0.68)
