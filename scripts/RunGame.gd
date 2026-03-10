extends Control
const TutorialOverlayScript = preload("res://scripts/TutorialOverlay.gd")

const DRAG_THRESHOLD := 10.0
const PIT_HIGHLIGHT_COLOR := Color(0.82, 0.42, 0.22, 0.95)
const PIT_IDLE_BORDER_COLOR := Color(0.46, 0.2, 0.12, 0.85)
const TARGET_PASS_COLOR := Color(0.38, 0.85, 0.45)
const TARGET_DEFAULT_COLOR := Color(0.93, 0.86, 0.77)
const LINEAGE_MULT_PER_POINT := 0.04
const LINEAGE_MULT_CAP := 2.5

@onready var week_label: Label = $RootVBox/BandTop/TopBandVBox/TopMainRow/WeekLabel
@onready var target_value: Label = $RootVBox/BandTop/TopBandVBox/TopMainRow/TargetCenter/TargetValue
@onready var blood_label: Label = $RootVBox/BandTop/TopBandVBox/TopMainRow/RightControls/BloodWrap/BloodLabel
@onready var doctrine_top_label: Label = $RootVBox/BandTop/TopBandVBox/TopSecondaryRow/DoctrineTopLabel

@onready var band_top: PanelContainer = $RootVBox/BandTop
@onready var band_follower: PanelContainer = $RootVBox/BandFollower
@onready var band_pit: PanelContainer = $RootVBox/BandPit
@onready var band_context: PanelContainer = $RootVBox/BandContext
@onready var follower_band_bounds: Control = $RootVBox/BandFollower

@onready var menu_button: Button = $RootVBox/BandTop/TopBandVBox/TopMainRow/RightControls/MenuButton
@onready var follower_row: HBoxContainer = $RootVBox/BandFollower/FollowerMargin/FollowerCenter/FollowerRow
@onready var pit_drop_area: PanelContainer = $RootVBox/BandPit/PitMargin/PitVBox/PitDropArea
@onready var pit_cards_row: HBoxContainer = $RootVBox/BandPit/PitMargin/PitVBox/PitDropArea/PitDropMargin/PitDropVBox/PitCardsCenter/PitCardsRow
@onready var pit_counter: Label = $RootVBox/BandPit/PitMargin/PitVBox/PitTopRow/PitCounter

@onready var confirm_button: Button = $RootVBox/BandPit/PitMargin/PitVBox/PitDropArea/PitDropMargin/PitDropVBox/PitActionCenter/ConfirmButton
@onready var clear_button: Button = $RootVBox/BandPit/PitMargin/PitVBox/PitDropArea/PitDropMargin/PitDropVBox/ClearButton
@onready var contract_toggle: Button = $RootVBox/BandPit/PitMargin/PitVBox/PitTopRow/ContractToggle

@onready var preview_panel: Control = $RootVBox/BandContext/ContextMargin/ContextRoot/PreviewPanel
@onready var breakdown_panel: Control = $RootVBox/BandContext/ContextMargin/ContextRoot/BreakdownPanel
@onready var doctrine_button: Button = $RootVBox/BandContext/ContextMargin/ContextRoot/PreviewPanel/PreviewLeft/DoctrineAction
@onready var doctrine_hint: Label = $RootVBox/BandContext/ContextMargin/ContextRoot/PreviewPanel/PreviewLeft/DoctrineHint
@onready var ritual_use: Button = $RootVBox/BandContext/ContextMargin/ContextRoot/PreviewPanel/PreviewLeft/RitualUse
@onready var preview_text: RichTextLabel = $RootVBox/BandContext/ContextMargin/ContextRoot/PreviewPanel/PreviewRightPanel/PreviewRightVBox/PreviewText
@onready var breakdown_lines: VBoxContainer = $RootVBox/BandContext/ContextMargin/ContextRoot/BreakdownPanel/BreakdownVBox/BreakdownScroll/BreakdownLines
@onready var pool_button: Button = $RootVBox/BandContext/ContextMargin/ContextRoot/BreakdownPanel/BreakdownVBox/BreakdownBottom/PoolButton
@onready var continue_button: Button = $RootVBox/BandContext/ContextMargin/ContextRoot/BreakdownPanel/BreakdownVBox/BreakdownBottom/ContinueButton

@onready var pool_overlay: Control = $PoolOverlay
@onready var pool_summary: Label = $PoolOverlay/PoolCenter/PoolPanel/PoolVBox/PoolSummary
@onready var pool_breed: Button = $PoolOverlay/PoolCenter/PoolPanel/PoolVBox/PoolBreed
@onready var pool_list: VBoxContainer = $PoolOverlay/PoolCenter/PoolPanel/PoolVBox/PoolScroll/PoolList
@onready var pool_close: Button = $PoolOverlay/PoolCenter/PoolPanel/PoolVBox/PoolClose
@onready var gs: Node = get_node("/root/GameState")

var hand_card_nodes: Array[Dictionary] = []
var pit_indices: Array[int] = []
var consumed_indices: Array[int] = []
var selected_hand_index: int = -1

var confirmed: bool = false
var confirmed_pass: bool = false
var last_selected_indices: Array[int] = []
var scene_change_queued: bool = false
var last_result: Dictionary = {}
var info_message: String = ""

var drag_tracking: bool = false
var drag_active: bool = false
var drag_source: String = ""
var drag_index: int = -1
var drag_start_pos: Vector2 = Vector2.ZERO
var drag_preview_card: Control
var pit_hovered: bool = false
var tutorial_overlay: CanvasLayer
var tutorial_callout_running: bool = false

func _ready() -> void:
	_init_hand_cards()
	_apply_static_theme()
	preview_text.bbcode_enabled = true
	preview_text.scroll_active = false
	pool_breed.visible = false

	menu_button.pressed.connect(_on_menu_pressed)
	confirm_button.pressed.connect(_on_confirm_pressed)
	clear_button.pressed.connect(_on_clear_pressed)
	contract_toggle.pressed.connect(_on_contract_toggle)
	ritual_use.pressed.connect(_on_ritual_use)
	doctrine_button.pressed.connect(_on_doctrine_pressed)
	pool_button.pressed.connect(_on_pool_pressed)
	pool_close.pressed.connect(_on_pool_close_pressed)
	pool_breed.pressed.connect(_on_pool_breed_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	pit_drop_area.gui_input.connect(_on_pit_gui_input)

	if gs.current_hand.size() != 6:
		gs.draw_hand_from_pool()

	if gs.pending_confirmed and gs.pending_sacrifice_indices.size() > 0:
		confirmed = true
		confirmed_pass = gs.pending_pass
		last_selected_indices = gs.pending_sacrifice_indices.duplicate()
		consumed_indices = gs.pending_sacrifice_indices.duplicate()
		pit_indices = []
		selected_hand_index = -1

	_refresh_ui(false)
	call_deferred("_start_tutorial_callouts")

func _input(event: InputEvent) -> void:
	if not drag_tracking:
		return
	if event is InputEventMouseMotion:
		if not drag_active:
			if drag_start_pos.distance_to(get_global_mouse_position()) >= DRAG_THRESHOLD:
				_start_drag()
		else:
			_update_drag_preview_position()
		return
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		if mb.button_index == MOUSE_BUTTON_LEFT and not mb.pressed:
			if drag_active:
				_finish_drag()
			else:
				_handle_click_action(drag_source, drag_index)
			_end_drag_tracking()

func _process(_delta: float) -> void:
	if drag_active:
		_update_drag_preview_position()
		_update_pit_hover_state()

func _init_hand_cards() -> void:
	hand_card_nodes.clear()
	for i in range(6):
		var root: PanelContainer = follower_row.get_node("Card%d" % (i + 1)) as PanelContainer
		_set_descendants_mouse_ignore(root)
		var badge_nodes: Dictionary = _ensure_hand_card_badge_layout(root)
		root.gui_input.connect(_on_hand_card_gui_input.bind(i))
		hand_card_nodes.append({
			"root": root,
			"tier": root.get_node("CardMargin/CardVBox/TierLabel"),
			"type": root.get_node("CardMargin/CardVBox/TypeLabel"),
			"trait": root.get_node("CardMargin/CardVBox/TraitLabel"),
			"lineage_badge": badge_nodes.get("lineage_badge", null),
			"lineage_label": badge_nodes.get("lineage_label", null),
			"trait_slots": badge_nodes.get("trait_slots", []),
		})

func _ensure_hand_card_badge_layout(root: PanelContainer) -> Dictionary:
	var vbox: VBoxContainer = root.get_node("CardMargin/CardVBox") as VBoxContainer
	var trait_label: Label = vbox.get_node_or_null("TraitLabel") as Label
	if trait_label != null:
		trait_label.visible = false
	var lineage_row: HBoxContainer = vbox.get_node_or_null("LineageRow") as HBoxContainer
	if lineage_row == null:
		lineage_row = HBoxContainer.new()
		lineage_row.name = "LineageRow"
		lineage_row.alignment = BoxContainer.ALIGNMENT_CENTER
		lineage_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lineage_row.custom_minimum_size = Vector2(0, 20)
		vbox.add_child(lineage_row)
		vbox.move_child(lineage_row, 2)
	var lineage_badge: PanelContainer = lineage_row.get_node_or_null("LineageInlineBadge") as PanelContainer
	if lineage_badge == null:
		lineage_badge = PanelContainer.new()
		lineage_badge.name = "LineageInlineBadge"
		lineage_badge.custom_minimum_size = Vector2(28, 16)
		lineage_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var lineage_label: Label = Label.new()
		lineage_label.name = "LineageInlineLabel"
		lineage_label.anchor_right = 1.0
		lineage_label.anchor_bottom = 1.0
		lineage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lineage_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lineage_label.add_theme_font_size_override("font_size", 10)
		lineage_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lineage_badge.add_child(lineage_label)
		lineage_row.add_child(lineage_badge)
	var trait_row: HBoxContainer = vbox.get_node_or_null("TraitBadgeRow") as HBoxContainer
	if trait_row == null:
		trait_row = HBoxContainer.new()
		trait_row.name = "TraitBadgeRow"
		trait_row.alignment = BoxContainer.ALIGNMENT_CENTER
		trait_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		trait_row.add_theme_constant_override("separation", 4)
		vbox.add_child(trait_row)
	var slots: Array = []
	for i in range(4):
		var slot: PanelContainer = trait_row.get_node_or_null("TraitSlot%d" % i) as PanelContainer
		if slot == null:
			slot = PanelContainer.new()
			slot.name = "TraitSlot%d" % i
			slot.custom_minimum_size = Vector2(24, 16)
			slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var slot_label: Label = Label.new()
			slot_label.name = "TraitSlotLabel"
			slot_label.anchor_right = 1.0
			slot_label.anchor_bottom = 1.0
			slot_label.offset_top = -1.0
			slot_label.offset_bottom = -1.0
			slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			slot_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			slot_label.add_theme_font_size_override("font_size", 10)
			slot_label.add_theme_constant_override("outline_size", 1)
			slot_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.55))
			slot_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			slot.add_child(slot_label)
			trait_row.add_child(slot)
		slots.append(slot)
	return {
		"lineage_badge": lineage_badge,
		"lineage_label": lineage_badge.get_node("LineageInlineLabel") as Label,
		"trait_slots": slots,
	}

func _set_descendants_mouse_ignore(root: Control) -> void:
	for child in root.get_children():
		if child is Control:
			var c: Control = child as Control
			c.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_set_descendants_mouse_ignore(c)

func _apply_static_theme() -> void:
	_set_panel_style(band_top, Color(0.12, 0.11, 0.14, 0.94), Color(0.22, 0.2, 0.24, 0.9), 1, 8)
	_set_panel_style(band_follower, Color(0.2, 0.17, 0.16, 0.9), Color(0.34, 0.24, 0.2, 0.9), 1, 10)
	_set_panel_style(band_pit, Color(0.12, 0.08, 0.08, 0.95), Color(0.3, 0.16, 0.1, 0.9), 1, 10)
	_set_panel_style(band_context, Color(0.14, 0.13, 0.16, 0.95), Color(0.24, 0.22, 0.26, 0.9), 1, 10)
	_update_pit_drop_style()

	week_label.add_theme_font_size_override("font_size", 14)
	week_label.add_theme_color_override("font_color", Color(0.72, 0.72, 0.77))
	target_value.add_theme_font_size_override("font_size", 54)
	target_value.add_theme_color_override("font_color", TARGET_DEFAULT_COLOR)
	blood_label.add_theme_font_size_override("font_size", 22)
	blood_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.84))
	doctrine_top_label.add_theme_font_size_override("font_size", 13)
	doctrine_top_label.add_theme_color_override("font_color", Color(0.62, 0.62, 0.66))
	doctrine_hint.add_theme_color_override("font_color", Color(0.78, 0.74, 0.69))

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

func _make_card_style(bg: Color, border: Color, border_w: int) -> StyleBoxFlat:
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.border_width_left = border_w
	sb.border_width_right = border_w
	sb.border_width_top = border_w
	sb.border_width_bottom = border_w
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 8
	sb.corner_radius_bottom_right = 8
	sb.content_margin_left = 6
	sb.content_margin_right = 6
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	return sb

func _refresh_ui(animate_context: bool = false) -> void:
	_enforce_pit_limit()
	_refresh_top_bar()
	_update_doctrine_ui()
	_update_contract_ui()
	_update_ritual_ui()
	_refresh_hand_cards()
	_refresh_pit_cards()
	_update_pit_counter()
	_update_confirm_state()
	if confirmed or gs.pending_confirmed:
		_render_breakdown_from_state()
		_set_context_breakdown(animate_context)
	else:
		_set_context_preview()
		_update_breakdown_preview()
	_update_pit_drop_style()

func _refresh_top_bar() -> void:
	week_label.text = "Week %d/%d (Round %d/2)" % [gs.current_week, gs.get_max_weeks(), gs.week_round]
	target_value.text = str(gs.get_week_target(gs.current_week))
	target_value.add_theme_color_override("font_color", TARGET_DEFAULT_COLOR)
	blood_label.text = str(gs.blood_currency)
	doctrine_top_label.text = "Doctrine: %s" % _doctrine_display_name(gs.selected_doctrine)

func _set_context_preview() -> void:
	preview_panel.visible = true
	preview_panel.modulate = Color(1.0, 1.0, 1.0, 1.0)
	breakdown_panel.visible = false
	breakdown_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)

func _set_context_breakdown(animate: bool) -> void:
	if animate and preview_panel.visible:
		breakdown_panel.visible = true
		breakdown_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
		var t: Tween = create_tween()
		t.set_trans(Tween.TRANS_SINE)
		t.set_ease(Tween.EASE_OUT)
		t.parallel().tween_property(preview_panel, "modulate:a", 0.0, 0.15)
		t.parallel().tween_property(breakdown_panel, "modulate:a", 1.0, 0.15)
		t.finished.connect(func() -> void:
			preview_panel.visible = false
			preview_panel.modulate = Color(1.0, 1.0, 1.0, 1.0)
		)
		return
	preview_panel.visible = false
	breakdown_panel.visible = true
	breakdown_panel.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _update_pit_drop_style() -> void:
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color(0.07, 0.05, 0.06, 0.98)
	sb.border_color = PIT_HIGHLIGHT_COLOR if pit_hovered else PIT_IDLE_BORDER_COLOR
	var bw: int = 3 if pit_hovered else 2
	sb.border_width_left = bw
	sb.border_width_right = bw
	sb.border_width_top = bw
	sb.border_width_bottom = bw
	sb.corner_radius_top_left = 12
	sb.corner_radius_top_right = 12
	sb.corner_radius_bottom_left = 12
	sb.corner_radius_bottom_right = 12
	sb.shadow_color = Color(0.0, 0.0, 0.0, 0.5)
	sb.shadow_size = 6
	pit_drop_area.add_theme_stylebox_override("panel", sb)

func _update_pit_counter() -> void:
	pit_counter.text = "%d / %d" % [pit_indices.size(), _get_required_sacrifice_count()]

func _refresh_hand_cards() -> void:
	for i in range(hand_card_nodes.size()):
		_update_hand_card_visual(i)

func _update_hand_card_visual(i: int) -> void:
	var node: Dictionary = hand_card_nodes[i]
	var root: PanelContainer = node["root"] as PanelContainer
	var tier_label: Label = node["tier"] as Label
	var type_label: Label = node["type"] as Label
	var trait_label: Label = node["trait"] as Label

	root.visible = not consumed_indices.has(i)
	if not root.visible:
		return

	var follower: Dictionary = gs.current_hand[i]
	var trait_name: String = str(follower.get("trait", ""))
	var exhausted: bool = bool(follower.get("exhausted", false))
	var committed: bool = pit_indices.has(i)
	var selected: bool = selected_hand_index == i and not committed and not confirmed
	var ghosting: bool = drag_active and drag_source == "hand" and drag_index == i

	tier_label.text = "T%d" % int(follower.get("tier", 0))
	type_label.text = trait_name
	trait_label.visible = false

	tier_label.add_theme_font_size_override("font_size", 34)
	type_label.add_theme_font_size_override("font_size", 20)
	tier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var bg: Color = _get_trait_color(trait_name)
	if committed:
		bg = bg.lerp(Color(0.16, 0.16, 0.16), 0.65)
	elif exhausted:
		bg = bg.lerp(Color(0.14, 0.14, 0.14), 0.35)
	if ghosting:
		bg = Color(bg.r, bg.g, bg.b, 0.15)
	var border: Color = Color(0.1, 0.1, 0.1, 0.92)
	var border_w: int = 1
	if committed:
		border = Color(0.48, 0.48, 0.48, 0.8)
	elif selected:
		border = Color(0.95, 0.82, 0.3, 0.95)
		border_w = 3
	elif exhausted:
		border = Color(0.52, 0.45, 0.45, 0.9)
	if ghosting:
		border = Color(0.84, 0.84, 0.84, 0.45)
		border_w = 2
	root.add_theme_stylebox_override("panel", _make_card_style(bg, border, border_w))

	var type_color: Color = _get_trait_font_color(trait_name)
	if committed:
		type_color = type_color.lerp(Color(0.52, 0.52, 0.52), 0.55)
	type_label.add_theme_color_override("font_color", type_color)
	_update_hand_trait_slots(node.get("trait_slots", []), follower, committed or exhausted or ghosting)

	root.tooltip_text = "\n".join(_follower_trait_tooltip_lines(follower))
	_update_lineage_badge(root, follower)
	if confirmed or committed or exhausted:
		root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		root.mouse_filter = Control.MOUSE_FILTER_STOP

func _update_hand_trait_slots(slot_nodes: Array, follower: Dictionary, dimmed: bool) -> void:
	var trait_ids: Array[String] = _follower_all_trait_ids(follower)
	for i in range(slot_nodes.size()):
		var slot: PanelContainer = slot_nodes[i] as PanelContainer
		if slot == null:
			continue
		var slot_label: Label = slot.get_node_or_null("TraitSlotLabel") as Label
		var has_trait: bool = i < trait_ids.size()
		var rarity: String = "COMMON"
		if has_trait:
			rarity = _trait_rarity_key(trait_ids[i])
		var bg: Color = _trait_rarity_slot_color(rarity) if has_trait else Color(0.17, 0.17, 0.2, 0.5)
		var border: Color = bg.lerp(Color(0.05, 0.05, 0.07), 0.4) if has_trait else Color(0.3, 0.3, 0.34, 0.4)
		var text_color: Color = _trait_rarity_slot_text_color(rarity) if has_trait else Color(0.6, 0.6, 0.66)
		if dimmed:
			bg = bg.lerp(Color(0.2, 0.2, 0.2, bg.a), 0.5)
			border = border.lerp(Color(0.28, 0.28, 0.28, border.a), 0.5)
			text_color = text_color.lerp(Color(0.62, 0.62, 0.62), 0.45)
		var sb: StyleBoxFlat = StyleBoxFlat.new()
		sb.bg_color = bg
		sb.border_color = border
		sb.border_width_left = 1
		sb.border_width_top = 1
		sb.border_width_right = 1
		sb.border_width_bottom = 1
		sb.corner_radius_top_left = 6
		sb.corner_radius_top_right = 6
		sb.corner_radius_bottom_left = 6
		sb.corner_radius_bottom_right = 6
		sb.content_margin_left = 2
		sb.content_margin_top = 1
		sb.content_margin_right = 2
		sb.content_margin_bottom = 1
		slot.add_theme_stylebox_override("panel", sb)
		if slot_label != null:
			slot_label.offset_top = -1.0
			slot_label.offset_bottom = -1.0
			slot_label.text = _trait_rarity_slot_mark(rarity) if has_trait else ""
			slot_label.add_theme_color_override("font_color", text_color)
			slot_label.add_theme_font_size_override("font_size", 10)
			slot_label.add_theme_constant_override("outline_size", 1)
			slot_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.55))

func _trait_rarity_key(trait_id: String) -> String:
	if trait_id == "":
		return "COMMON"
	var info: Dictionary = _trait_info(trait_id)
	var rarity: String = str(info.get("rarity", "COMMON")).to_upper()
	match rarity:
		"UNCOMMON", "RARE", "LEGENDARY":
			return rarity
		_:
			return "COMMON"

func _trait_rarity_slot_mark(rarity: String) -> String:
	match rarity:
		"UNCOMMON":
			return "[U]"
		"RARE":
			return "[R]"
		"LEGENDARY":
			return "[L]"
		_:
			return "[C]"

func _trait_rarity_slot_color(rarity: String) -> Color:
	match rarity:
		"UNCOMMON":
			return Color(0.34, 0.62, 0.36)
		"RARE":
			return Color(0.41, 0.34, 0.68)
		"LEGENDARY":
			return Color(0.86, 0.67, 0.22)
		_:
			return Color(0.55, 0.56, 0.6)

func _trait_rarity_slot_text_color(rarity: String) -> Color:
	match rarity:
		"RARE":
			return Color(0.95, 0.93, 0.99)
		"LEGENDARY":
			return Color(0.2, 0.15, 0.06)
		_:
			return Color(0.08, 0.08, 0.1)

func _refresh_pit_cards() -> void:
	for child in pit_cards_row.get_children():
		child.queue_free()
	for idx in pit_indices:
		var card: PanelContainer = _build_small_card(idx)
		card.gui_input.connect(_on_pit_card_gui_input.bind(idx, card))
		pit_cards_row.add_child(card)

func _build_small_card(hand_index: int) -> PanelContainer:
	var dragging_this: bool = drag_active and drag_source == "pit" and drag_index == hand_index
	return _build_compact_card(hand_index, Vector2(108, 126), dragging_this, Control.MOUSE_FILTER_STOP)

func _build_compact_card(hand_index: int, card_size: Vector2, dimmed: bool, mouse_mode: int) -> PanelContainer:
	var follower: Dictionary = gs.current_hand[hand_index]
	var card: PanelContainer = PanelContainer.new()
	card.custom_minimum_size = card_size
	card.size = card_size
	card.mouse_filter = mouse_mode

	var margin: MarginContainer = MarginContainer.new()
	margin.name = "CardMargin"
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.offset_left = 6.0
	margin.offset_top = 6.0
	margin.offset_right = -6.0
	margin.offset_bottom = -6.0
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(margin)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.name = "CardVBox"
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 2)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(vbox)

	var tier: Label = Label.new()
	tier.name = "TierLabel"
	tier.text = "T%d" % int(follower.get("tier", 0))
	tier.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tier.add_theme_font_size_override("font_size", 24)
	tier.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(tier)

	var tlabel: Label = Label.new()
	tlabel.name = "TypeLabel"
	tlabel.text = str(follower.get("trait", ""))
	tlabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tlabel.add_theme_font_size_override("font_size", 14)
	tlabel.add_theme_color_override("font_color", _get_trait_font_color(str(follower.get("trait", ""))))
	tlabel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(tlabel)

	var trait_label: Label = Label.new()
	trait_label.name = "TraitLabel"
	trait_label.text = _get_trait_display(str(follower.get("trait_id", ""))) + _follower_trait_badge(follower)
	trait_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	trait_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	trait_label.add_theme_font_size_override("font_size", 11)
	trait_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(trait_label)

	var badge_nodes: Dictionary = _ensure_hand_card_badge_layout(card)
	_update_hand_trait_slots(badge_nodes.get("trait_slots", []), follower, dimmed)

	var bg: Color = _get_trait_color(str(follower.get("trait", ""))).lerp(Color(0.08, 0.08, 0.08), 0.18)
	if dimmed:
		bg = Color(bg.r, bg.g, bg.b, 0.2)
	card.add_theme_stylebox_override("panel", _make_card_style(bg, Color(0.12, 0.12, 0.12, 0.95), 1))
	card.tooltip_text = "\n".join(_follower_trait_tooltip_lines(follower))
	_update_lineage_badge(card, follower)
	_set_descendants_mouse_ignore(card)
	return card

func _on_hand_card_gui_input(event: InputEvent, index: int) -> void:
	if confirmed:
		return
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		if mb.button_index != MOUSE_BUTTON_LEFT or not mb.pressed:
			return
		if pit_indices.has(index) or consumed_indices.has(index):
			return
		if bool(gs.current_hand[index].get("exhausted", false)):
			_show_info("(Info) Exhausted: cannot sacrifice this play.")
			return
		_begin_pointer_tracking("hand", index)
		accept_event()

func _on_pit_card_gui_input(event: InputEvent, index: int, _card: Control) -> void:
	if confirmed:
		return
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		if mb.button_index != MOUSE_BUTTON_LEFT or not mb.pressed:
			return
		if not pit_indices.has(index):
			return
		_begin_pointer_tracking("pit", index)
		accept_event()

func _on_pit_gui_input(event: InputEvent) -> void:
	if confirmed or drag_active:
		return
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		if mb.button_index == MOUSE_BUTTON_LEFT and not mb.pressed and selected_hand_index >= 0:
			_move_hand_to_pit(selected_hand_index)
			accept_event()

func _begin_pointer_tracking(source: String, index: int) -> void:
	drag_tracking = true
	drag_active = false
	drag_source = source
	drag_index = index
	drag_start_pos = get_global_mouse_position()

func _start_drag() -> void:
	if drag_source == "hand":
		if drag_index < 0 or drag_index >= gs.current_hand.size():
			return
		if pit_indices.has(drag_index) or bool(gs.current_hand[drag_index].get("exhausted", false)):
			return
	elif drag_source == "pit":
		if not pit_indices.has(drag_index):
			return
	else:
		return
	drag_active = true
	drag_preview_card = _build_drag_preview(drag_index, drag_source == "pit")
	drag_preview_card.z_index = 500
	add_child(drag_preview_card)
	_update_drag_preview_position()
	_update_pit_hover_state()
	_refresh_hand_cards()
	_refresh_pit_cards()

func _build_drag_preview(hand_index: int, compact: bool) -> Control:
	var card: Control
	if compact:
		card = _build_compact_drag_preview(hand_index)
	else:
		card = ((hand_card_nodes[hand_index]["root"] as Control).duplicate() as Control)
	_set_descendants_mouse_ignore(card)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.scale = Vector2(1.1, 1.1)
	var base_size: Vector2 = card.custom_minimum_size
	if base_size.x < 8.0 or base_size.y < 8.0:
		base_size = card.size
	if base_size.x < 8.0 or base_size.y < 8.0:
		base_size = Vector2(112, 126) if compact else Vector2(152, 176)
	card.custom_minimum_size = base_size
	card.size = base_size
	card.set_meta("drag_size", base_size)
	card.pivot_offset = base_size * 0.5
	return card

func _build_compact_drag_preview(hand_index: int) -> Control:
	return _build_compact_card(hand_index, Vector2(112, 126), false, Control.MOUSE_FILTER_IGNORE)

func _update_drag_preview_position() -> void:
	if drag_preview_card == null:
		return
	var mouse: Vector2 = get_global_mouse_position()
	var base_size: Vector2 = drag_preview_card.get_meta("drag_size", Vector2.ZERO) as Vector2
	if base_size.x < 8.0 or base_size.y < 8.0:
		base_size = drag_preview_card.custom_minimum_size
	if base_size.x < 8.0 or base_size.y < 8.0:
		base_size = drag_preview_card.size
	if base_size.x < 8.0 or base_size.y < 8.0:
		base_size = Vector2(112, 126)
	var size: Vector2 = base_size * drag_preview_card.scale
	drag_preview_card.position = mouse - (size * 0.5)

func _finish_drag() -> void:
	var mouse: Vector2 = get_global_mouse_position()
	var over_pit: bool = pit_drop_area.get_global_rect().has_point(mouse)
	var over_followers: bool = follower_band_bounds.get_global_rect().has_point(mouse)
	if drag_source == "hand":
		if over_pit:
			_move_hand_to_pit(drag_index)
	elif drag_source == "pit":
		if over_followers:
			_remove_from_pit(drag_index)

func _update_pit_hover_state() -> void:
	if not drag_active:
		if pit_hovered:
			pit_hovered = false
			_update_pit_drop_style()
		return
	var now_over: bool = pit_drop_area.get_global_rect().has_point(get_global_mouse_position())
	if now_over != pit_hovered:
		pit_hovered = now_over
		_update_pit_drop_style()

func _end_drag_tracking() -> void:
	drag_tracking = false
	drag_active = false
	drag_source = ""
	drag_index = -1
	if drag_preview_card != null and is_instance_valid(drag_preview_card):
		drag_preview_card.queue_free()
	drag_preview_card = null
	pit_hovered = false
	_update_pit_drop_style()
	_refresh_hand_cards()
	_refresh_pit_cards()

func _handle_click_action(source: String, index: int) -> void:
	if source == "hand":
		_toggle_hand_selection(index)
	elif source == "pit":
		_remove_from_pit(index)

func _toggle_hand_selection(index: int) -> void:
	if confirmed:
		return
	if consumed_indices.has(index) or pit_indices.has(index):
		return
	if bool(gs.current_hand[index].get("exhausted", false)):
		_show_info("(Info) Exhausted: cannot sacrifice this play.")
		return
	selected_hand_index = -1 if selected_hand_index == index else index
	_clear_info()
	_refresh_ui(false)

func _move_hand_to_pit(index: int) -> void:
	if confirmed:
		return
	if consumed_indices.has(index) or pit_indices.has(index):
		return
	if bool(gs.current_hand[index].get("exhausted", false)):
		_show_info("(Info) Exhausted: cannot sacrifice this play.")
		return
	var max_allowed: int = _get_required_sacrifice_count()
	if pit_indices.size() >= max_allowed:
		_show_info("(Info) Max %d sacrifices per play." % max_allowed)
		return
	pit_indices.append(index)
	selected_hand_index = -1
	_clear_info()
	_refresh_ui(false)

func _remove_from_pit(index: int) -> void:
	if confirmed:
		return
	if not pit_indices.has(index):
		return
	pit_indices.erase(index)
	_clear_info()
	_refresh_ui(false)

func _enforce_pit_limit() -> void:
	var max_allowed: int = _get_required_sacrifice_count()
	if pit_indices.size() <= max_allowed:
		return
	while pit_indices.size() > max_allowed:
		pit_indices.pop_back()
	info_message = "(Info) Max %d sacrifices per play." % max_allowed

func _update_breakdown_preview() -> void:
	if confirmed or gs.pending_confirmed:
		return
	var remaining_target: int = max(0, gs.get_week_target(gs.current_week) - gs.week_total_devotion)
	var max_allowed: int = _get_required_sacrifice_count()
	if pit_indices.is_empty():
		target_value.add_theme_color_override("font_color", TARGET_DEFAULT_COLOR)
		var base_text: String = "Base:        0\nAdditive:   +0\nMultiplier:  x1\n----------------------\nTotal:       0  /  Target: %d  WAIT" % remaining_target
		if info_message == "":
			preview_text.text = "Select 1 to %d followers and place them in the altar.\n\n%s" % [max_allowed, base_text]
		else:
			preview_text.text = "[color=#ffcf8f]%s[/color]\n\n%s" % [info_message, base_text]
		return

	var preview: Dictionary = gs.preview_selected(pit_indices)
	var numbers: Dictionary = _extract_preview_numbers(preview)
	var total_val: int = int(numbers.get("total", 0))
	var pass_target: bool = total_val >= remaining_target
	target_value.add_theme_color_override("font_color", TARGET_PASS_COLOR if pass_target else TARGET_DEFAULT_COLOR)
	var line_color: String = "#73df90" if pass_target else "#df7a7a"
	var status: String = "PASS" if pass_target else "FAIL"
	var lineage_preview: Dictionary = _pit_lineage_preview()
	var lineage_score: int = int(lineage_preview.get("score", 0))
	var lineage_line: String = ""
	if lineage_score > 0:
		lineage_line = "\nLineage:  x%.2f  (%dpts)" % [float(lineage_preview.get("mult", 1.0)), lineage_score]
	var body: String = "Base:      %d\nAdditive: +%d\nMultiplier: x%d%s\n----------------------\n[color=%s]Total:     %d  /  Target: %d  %s[/color]" % [
		int(numbers.get("base", 0)),
		int(numbers.get("additive", 0)),
		int(numbers.get("multiplier", 1)),
		lineage_line,
		line_color,
		total_val,
		remaining_target,
		status,
	]
	preview_text.text = body if info_message == "" else "[color=#ffcf8f]%s[/color]\n\n%s" % [info_message, body]

func _extract_preview_numbers(preview: Dictionary) -> Dictionary:
	var additive_total: int = int(preview.get("additive_total", 0))
	var base_total: int = 0
	for raw_line in str(preview.get("breakdown", "")).split("\n"):
		var line: String = raw_line.strip_edges()
		if line.begins_with("Subtotal (Followers):"):
			base_total = _last_int_from_text(line, 0)
			break
	return {
		"base": base_total,
		"additive": max(0, additive_total - base_total),
		"multiplier": int(preview.get("multiplier", 1)),
		"total": int(preview.get("final_devotion", 0)),
	}

func _pit_lineage_preview() -> Dictionary:
	var score: int = 0
	for idx in pit_indices:
		if idx < 0 or idx >= gs.current_hand.size():
			continue
		score += _lineage_value(gs.current_hand[idx])
	if score <= 0:
		return {"score": 0, "mult": 1.0}
	var mult: float = 1.0 + (float(score) * LINEAGE_MULT_PER_POINT)
	mult = min(mult, LINEAGE_MULT_CAP)
	return {"score": score, "mult": mult}

func _update_doctrine_ui() -> void:
	var name: String = str(gs.selected_doctrine)
	if name == "":
		doctrine_button.text = "Doctrine Unset\nChoose a doctrine"
		doctrine_hint.text = "Select exactly 1 follower."
		doctrine_button.disabled = true
		return
	doctrine_button.text = "%s\n%s" % [_doctrine_display_name(name), _doctrine_action_desc(name)]
	doctrine_hint.text = "Select exactly 1 follower."
	doctrine_button.disabled = gs.doctrine_used_this_play or confirmed or gs.pending_confirmed

func _doctrine_display_name(name: String) -> String:
	if name == "FLESH":
		return "Path of Flesh"
	if name == "RUIN":
		return "Path of Ruin"
	if name == "SILENCE":
		return "Path of Silence"
	return "-"

func _doctrine_action_desc(name: String) -> String:
	if name == "FLESH":
		return "Convert one follower to BLOOD"
	if name == "RUIN":
		return "Refine +1 tier, exhaust this play"
	if name == "SILENCE":
		return "Banish one follower, replace it"
	return "No doctrine selected"

func _update_confirm_state() -> void:
	if confirmed or gs.pending_confirmed:
		confirm_button.visible = true
		confirm_button.text = "Continue"
		confirm_button.disabled = scene_change_queued
		continue_button.visible = false
		continue_button.disabled = true
		contract_toggle.disabled = true
		doctrine_button.disabled = true
		ritual_use.disabled = true
		return
	confirm_button.visible = true
	confirm_button.text = "Confirm Sacrifice"
	continue_button.visible = false
	var selected_count: int = pit_indices.size()
	var max_allowed: int = _get_required_sacrifice_count()
	confirm_button.disabled = selected_count == 0 or selected_count > max_allowed
	continue_button.disabled = true
	doctrine_button.disabled = gs.doctrine_used_this_play or gs.selected_doctrine == ""

func _on_clear_pressed() -> void:
	if confirmed:
		return
	pit_indices.clear()
	selected_hand_index = -1
	_clear_info()
	_refresh_ui(false)

func _on_confirm_pressed() -> void:
	if gs.pending_confirmed or confirmed:
		_proceed_after_confirm()
		return
	var selected_indices: Array[int] = pit_indices.duplicate()
	var required: int = _get_required_sacrifice_count()
	if selected_indices.size() == 0 or selected_indices.size() > required:
		_show_info("(Info) Select 1 to %d followers." % required)
		return
	if gs.contract_allow_five and selected_indices.size() != 5:
		_show_info("(Info) Expanding Contract requires exactly 5 sacrifices.")
		return

	var blood_before: int = gs.blood_currency
	if gs.contract_allow_five:
		gs.contract_five_used_week = gs.current_week
		gs.contract_allow_five = false
		_update_contract_ui()
	elif gs.contract_allow_four:
		gs.contract_used_week = gs.current_week
		gs.contract_allow_four = false
		_update_contract_ui()

	var result: Dictionary = gs.score_selected(selected_indices)
	last_result = result.duplicate(true)
	last_selected_indices = selected_indices.duplicate()
	confirmed = true
	confirmed_pass = bool(result["pass"])
	gs.pending_sacrifice_indices = selected_indices.duplicate()
	gs.pending_confirmed = true
	gs.pending_week = gs.current_week
	gs.pending_round = gs.week_round
	gs.pending_pass = bool(result["pass"])
	gs.pending_target = int(result["target"])
	gs.week_total_devotion += int(result["final_devotion"])
	var overflow_target: int = gs.get_week_target(gs.current_week)
	gs.apply_week_devotion_cap(overflow_target)
	var overflow_grant: int = gs.apply_overflow_blood_for_target(overflow_target)

	if gs.relic_inventory.get("The Bleeding Edge", 0) > 0 and int(result.get("final_devotion", 0)) < int(result.get("target", 0)):
		var bleed_loss: int = 3 * int(gs.relic_inventory.get("The Bleeding Edge", 0))
		gs.blood_currency = max(0, gs.blood_currency - bleed_loss)
		gs.last_breakdown_text += "\nThe Bleeding Edge: -%d Blood (failed target)" % bleed_loss
	if gs.relic_inventory["Clean Hands"] > 0 and gs.week_total_devotion >= int(result["target"]) and int(result["void_count"]) == 0:
		gs.free_reroll_next_shop = true

	var round_header: String = "Round %d Result" % gs.week_round
	var combined_line: String = "Week total devotion: %d / Target %d" % [gs.week_total_devotion, result["target"]]
	var combined_status: String = "Status: %s" % ("ON TRACK" if gs.week_total_devotion >= result["target"] else "NEED MORE")
	var combined_block: String = round_header + "\n" + result["breakdown"] + "\n\n" + combined_line + "\n" + combined_status
	if gs.last_breakdown_text == "":
		gs.last_breakdown_text = combined_block
	else:
		gs.last_breakdown_text += "\n\n" + combined_block
	if overflow_grant > 0:
		gs.last_breakdown_text += "\nOverflow Bonus: +%d Blood" % overflow_grant
	blood_label.text = str(gs.blood_currency)
	var blood_after: int = gs.blood_currency
	var sacrifices: String = _sacrifice_summary(selected_indices)
	gs.log_message("ROUND | Week %d Round %d | Target %d | Devotion %d | Add %d | Mult %d (base %d exp %d) | Blood %d->%d | Sac: %s | Doctrine: %s | Relics: %s" % [
		gs.current_week,
		gs.week_round,
		result["target"],
		int(result["final_devotion"]),
		int(result["additive_total"]),
		int(result["multiplier"]),
		int(result["base"]),
		int(result["exponent"]),
		blood_before,
		blood_after,
		sacrifices,
		(gs.selected_doctrine if gs.selected_doctrine != "" else "none"),
		gs._relic_summary(),
	])

	await _play_pit_pop_animation()
	consumed_indices = selected_indices.duplicate()
	pit_indices.clear()
	selected_hand_index = -1
	_clear_info()
	_refresh_ui(true)
	call_deferred("_tutorial_post_confirm_callout")

func _play_pit_pop_animation() -> void:
	var cards: Array = pit_cards_row.get_children()
	if cards.is_empty():
		return
	var total_time: float = 0.0
	for i in range(cards.size()):
		var card: Control = cards[i]
		card.pivot_offset = card.size * 0.5
		var delay: float = float(i) * 0.05
		total_time = max(total_time, delay + 0.2)
		var t: Tween = create_tween()
		t.tween_interval(delay)
		t.tween_property(card, "scale", Vector2.ZERO, 0.2)
		t.parallel().tween_property(card, "modulate:a", 0.0, 0.2)
	await get_tree().create_timer(total_time + 0.02).timeout

func _on_continue_pressed() -> void:
	_proceed_after_confirm()

func _proceed_after_confirm() -> void:
	if scene_change_queued:
		return
	var resolved_indices: Array[int] = last_selected_indices.duplicate()
	if resolved_indices.is_empty() and gs.pending_sacrifice_indices.size() > 0:
		resolved_indices = gs.pending_sacrifice_indices.duplicate()
	gs.resolve_play_and_update_pool(resolved_indices)
	gs.pending_sacrifice_indices.clear()
	gs.pending_confirmed = false
	gs.pending_week = 0
	gs.pending_round = 0
	gs.pending_pass = false
	gs.pending_target = 0

	var target: int = gs.get_week_target(gs.current_week)
	var passed: bool = gs.week_total_devotion >= target or confirmed_pass
	if passed:
		if gs.week_round == 1 and gs.early_win_bonus_week != gs.current_week:
			var before_round_bonus: int = gs.blood_currency
			var early_bonus: int = gs.get_early_win_bonus()
			gs.add_blood(early_bonus)
			gs.early_win_bonus_week = gs.current_week
			gs.last_breakdown_text += "\nEarly Win Bonus: +%d Blood (Blood %d -> %d)" % [early_bonus, before_round_bonus, gs.blood_currency]
		var bonus_cup: int = gs.relic_inventory["Ceremonial Cup"]
		var bonus_geo: int = gs.relic_inventory["Blasphemous Geometry"]
		var bonus_bowl: int = gs.relic_inventory["Brass Tithe Bowl"]
		var bonus_total: int = bonus_cup + (bonus_geo * 3) + bonus_bowl
		if bonus_total > 0:
			var before: int = gs.blood_currency
			gs.add_blood(bonus_total)
			var bonus_line: String = "Success bonuses: Ceremonial Cup +%d, Blasphemous Geometry +%d (Blood %d -> %d)" % [
				bonus_cup,
				bonus_geo * 3,
				before,
				gs.blood_currency,
			]
			if bonus_bowl > 0:
				bonus_line = "Success bonuses: Cup +%d, Geometry +%d, Brass Bowl +%d (Blood %d -> %d)" % [
					bonus_cup,
					bonus_geo * 3,
					bonus_bowl,
					before,
					gs.blood_currency,
				]
			gs.last_breakdown_text += "\n" + bonus_line
			gs.log_message("SUCCESS BONUS | Week %d | +%d Blood (Cup %d, Geometry %d)" % [
				gs.current_week,
				bonus_total,
				bonus_cup,
				bonus_geo * 3,
			])
		if gs.relic_inventory.get("The Red Covenant", 0) > 0 and gs.red_covenant_active_week == gs.current_week:
			gs.add_blood(30)
			gs.guaranteed_rare_next_shop = true
			gs.last_breakdown_text += "\nThe Red Covenant: +30 Blood and guaranteed rare+ shop offer"
		if gs.relic_inventory.get("Ossuary Standards", 0) > 0:
			var standards_bones: int = int(last_result.get("bone_count", 0))
			if standards_bones > 0:
				var standards_gain: int = standards_bones * int(gs.relic_inventory.get("Ossuary Standards", 0))
				gs.ossuary_standards_bonus += standards_gain
				gs.last_breakdown_text += "\nOssuary Standards: +%d permanent BONE additive" % standards_gain
		if gs.relic_inventory.get("The Ossuary Engine", 0) > 0 and int(last_result.get("bone_count", 0)) >= 2:
			gs.ossuary_engine_bonus += 2 * int(gs.relic_inventory.get("The Ossuary Engine", 0))
		if gs.relic_inventory.get("The Skeleton Archive", 0) > 0 and not gs.skeleton_archive_awarded_run and gs.current_week >= 5:
			var pool_counts: Dictionary = gs.pool_summary_counts()
			var bone_majority: bool = int(pool_counts.get("bone", 0)) >= int(pool_counts.get("blood", 0)) and int(pool_counts.get("bone", 0)) >= int(pool_counts.get("void", 0))
			if gs.selected_doctrine == "RUIN" or bone_majority:
				gs.skeleton_archive_bonus += int(gs.relic_inventory.get("The Skeleton Archive", 0))
				gs.skeleton_archive_awarded_run = true
		var next_path: String = "res://scenes/Shop.tscn"
		if gs.is_tutorial_active() and gs.current_week >= gs.get_max_weeks():
			gs.tutorial_completed = true
			next_path = "res://scenes/TutorialComplete.tscn"
		elif gs.current_week >= gs.get_max_weeks():
			if gs.relic_inventory.get("The Sanguine Bank", 0) > 0:
				gs.last_breakdown_text += "\nThe Sanguine Bank: final-week blood banked = %d" % gs.blood_currency
			next_path = "res://scenes/Victory.tscn"
		else:
			gs.perform_weekly_breeding(gs.current_week)
			next_path = "res://scenes/Shop.tscn" if gs.current_week == 1 else "res://scenes/Breeding.tscn"
		_render_breakdown_from_state()
		_queue_scene_change(next_path, passed, target)
		return

	if gs.week_round == 1:
		gs.week_round = 2
		if gs.relic_inventory.get("The Awakening Bell", 0) > 0 and gs.awakening_bell_used_week != gs.current_week:
			gs.clear_exhausted()
			gs.awakening_bell_used_week = gs.current_week
		confirmed = false
		confirmed_pass = false
		last_selected_indices = []
		last_result = {}
		consumed_indices.clear()
		pit_indices.clear()
		selected_hand_index = -1
		scene_change_queued = false
		gs.reset_doctrine_for_play()
		gs.draw_hand_from_pool()
		_clear_info()
		_refresh_ui(false)
		return

	if gs.week_round == 2:
		get_tree().change_scene_to_file("res://scenes/GameOver.tscn")

func _queue_scene_change(path: String, passed: bool, target: int) -> void:
	if scene_change_queued:
		return
	scene_change_queued = true
	continue_button.disabled = true
	confirm_button.disabled = true
	call_deferred("_do_scene_change", path, passed, target)

func _do_scene_change(path: String, passed: bool, target: int) -> void:
	await get_tree().process_frame
	if not ResourceLoader.exists(path):
		scene_change_queued = false
		continue_button.disabled = false
		gs.log_message("ERROR | Scene missing path %s week %d round %d" % [path, gs.current_week, gs.week_round])
		_show_info("(Error) Scene missing: %s" % path)
		return
	var packed: PackedScene = load(path)
	if packed == null:
		scene_change_queued = false
		continue_button.disabled = false
		gs.log_message("ERROR | Scene load failed path %s week %d round %d" % [path, gs.current_week, gs.week_round])
		_show_info("(Error) Scene load failed.")
		return
	var err: int = get_tree().change_scene_to_packed(packed)
	if err != OK:
		scene_change_queued = false
		continue_button.disabled = false
		gs.log_message("ERROR | Change scene failed (%d) week %d round %d passed %s total %d target %d path %s" % [err, gs.current_week, gs.week_round, str(passed), gs.week_total_devotion, target, path])
		_show_info("(Error) Failed to change scene (%d)." % err)

func _on_doctrine_pressed() -> void:
	if gs.doctrine_used_this_play or confirmed or gs.pending_confirmed:
		return
	if selected_hand_index < 0 or selected_hand_index >= gs.current_hand.size():
		_show_info("(Info) Select exactly 1 follower for Doctrine Action.")
		return
	if pit_indices.has(selected_hand_index):
		_show_info("(Info) Select a follower outside the altar.")
		return
	var idx: int = selected_hand_index
	var follower: Dictionary = gs.current_hand[idx]
	if gs.selected_doctrine == "FLESH":
		if str(follower.get("trait", "")) == "BLOOD":
			_show_info("(Info) Doctrine (Flesh): Already BLOOD.")
		else:
			follower["trait"] = "BLOOD"
			gs.current_hand[idx] = follower
			_show_info("Doctrine (Flesh): Converted #%d to BLOOD." % [idx + 1])
			gs.doctrine_used_this_play = true
	elif gs.selected_doctrine == "RUIN":
		var new_tier: int = min(6, int(follower.get("tier", 0)) + 1)
		follower["tier"] = new_tier
		follower["exhausted"] = true
		gs.current_hand[idx] = follower
		_show_info("Doctrine (Ruin): Refined #%d to T%d (exhausted)." % [idx + 1, new_tier])
		gs.doctrine_used_this_play = true
	elif gs.selected_doctrine == "SILENCE":
		var replacement: Dictionary = _draw_silence_replacement_from_pool()
		if replacement.is_empty():
			_show_info("(Info) Doctrine (Silence): No available follower in pool to replace.")
		else:
			gs.current_hand[idx] = replacement
			_show_info("Doctrine (Silence): Banished #%d and replaced from pool." % [idx + 1])
			gs.doctrine_used_this_play = true
	selected_hand_index = -1
	_refresh_ui(false)

func _draw_silence_replacement_from_pool() -> Dictionary:
	var candidate_indices: Array[int] = []
	for i in range(gs.pool.size()):
		var follower: Dictionary = gs.pool[i]
		var fid: int = int(follower.get("id", -1))
		if gs.is_follower_nested(fid):
			continue
		candidate_indices.append(i)
	if candidate_indices.is_empty():
		gs.ensure_pool_minimum_for_draw()
		for i in range(gs.pool.size()):
			var follower_retry: Dictionary = gs.pool[i]
			var fid_retry: int = int(follower_retry.get("id", -1))
			if gs.is_follower_nested(fid_retry):
				continue
			candidate_indices.append(i)
	if candidate_indices.is_empty():
		return {}
	var pick_pos: int = candidate_indices[randi() % candidate_indices.size()]
	var picked: Dictionary = gs.pool[pick_pos]
	gs.pool.remove_at(pick_pos)
	return picked

func _get_required_sacrifice_count() -> int:
	if gs.contract_allow_five:
		return 5
	if gs.contract_allow_four:
		return 4
	return 3

func _on_contract_toggle() -> void:
	if confirmed or gs.pending_confirmed:
		return
	var has_four: bool = gs.relic_inventory.get("Black Contract", 0) > 0
	var has_five: bool = gs.relic_inventory.get("The Expanding Contract", 0) > 0
	if not has_four and not has_five:
		return
	if has_five and gs.contract_five_used_week == gs.current_week:
		return
	if has_five:
		gs.contract_allow_five = not gs.contract_allow_five
		if gs.contract_allow_five:
			gs.contract_allow_four = false
	elif has_four:
		if gs.contract_used_week == gs.current_week:
			return
		gs.contract_allow_four = not gs.contract_allow_four
	_refresh_ui(false)

func _update_contract_ui() -> void:
	var has_four: bool = gs.relic_inventory.get("Black Contract", 0) > 0
	var has_five: bool = gs.relic_inventory.get("The Expanding Contract", 0) > 0
	if not has_four and not has_five:
		contract_toggle.visible = false
		return
	contract_toggle.visible = true
	var used: bool = (has_five and gs.contract_five_used_week == gs.current_week) or (not has_five and has_four and gs.contract_used_week == gs.current_week)
	contract_toggle.disabled = used or confirmed or gs.pending_confirmed
	var state: String = "ON" if (gs.contract_allow_five or gs.contract_allow_four) else "OFF"
	var used_text: String = "1/1" if used else "0/1"
	if has_five:
		contract_toggle.text = "Contract: 5 (%s) %s" % [used_text, state]
	else:
		contract_toggle.text = "Contract: 4 (%s) %s" % [used_text, state]

func _on_ritual_use() -> void:
	if confirmed or gs.pending_confirmed:
		return
	if gs.ritual_card_slot == "":
		return
	gs.ritual_card_active = gs.ritual_card_slot
	gs.ritual_card_slot = ""
	_clear_info()
	_refresh_ui(false)

func _update_ritual_ui() -> void:
	var has_relic: bool = gs.relic_inventory["Scarlet Planetarium"] > 0
	ritual_use.visible = true
	if gs.ritual_card_slot == "":
		ritual_use.disabled = true
		ritual_use.text = "Rituals" if has_relic else "Rituals Locked"
	else:
		ritual_use.disabled = confirmed or gs.pending_confirmed
		ritual_use.text = "Rituals: %s" % gs.ritual_card_slot

func _show_info(msg: String) -> void:
	info_message = msg
	if confirmed or gs.pending_confirmed:
		_render_breakdown_from_state()
	else:
		_update_breakdown_preview()

func _clear_info() -> void:
	info_message = ""

func _render_breakdown_from_state() -> void:
	for child in breakdown_lines.get_children():
		child.queue_free()
	var source_text: String = str(last_result.get("breakdown", ""))
	if source_text == "":
		source_text = gs.last_breakdown_text
	var parsed: Dictionary = _parse_breakdown_text(source_text)
	var final_devotion: int = int(last_result.get("final_devotion", parsed.get("final_devotion", 0)))
	var target: int = int(last_result.get("target", parsed.get("target", gs.get_week_target(gs.current_week))))
	var passed: bool = final_devotion >= target
	if info_message != "":
		_add_breakdown_line(info_message, Color(1.0, 0.83, 0.56), 14)
		_add_breakdown_divider()
	_add_breakdown_line("BASE CONTRIBUTION", Color(0.82, 0.82, 0.86), 14)
	_add_breakdown_line("Base contribution: %d" % int(parsed.get("followers_subtotal", 0)))
	_add_breakdown_divider()
	_add_breakdown_line("ADDITIVE", Color(0.82, 0.82, 0.86), 14)
	for line in parsed.get("additive_lines", []):
		_add_breakdown_line("  - %s" % line)
	_add_breakdown_line("Additive total: %d" % int(last_result.get("additive_total", parsed.get("followers_subtotal", 0))), Color(0.92, 0.92, 0.96), 15)
	_add_breakdown_divider()
	_add_breakdown_line("MULTIPLIER", Color(0.82, 0.82, 0.86), 14)
	_add_breakdown_line("Multiplier base: %d" % int(parsed.get("multiplier_base", last_result.get("base", 1))))
	_add_breakdown_line("Multiplier exponent: %d" % int(parsed.get("multiplier_exp", last_result.get("exponent", 1))))
	_add_breakdown_line("Multiplier: x%d" % int(parsed.get("multiplier_total", last_result.get("multiplier", 1))), Color(0.94, 0.84, 0.65), 15)
	for line in parsed.get("multiplier_lines", []):
		_add_breakdown_line("  - %s" % line, Color(0.76, 0.78, 0.83), 13)
	_add_breakdown_divider()
	_add_breakdown_line("RESULT", Color(0.82, 0.82, 0.86), 14)
	_add_breakdown_line("Final devotion: %d" % final_devotion, Color(0.95, 0.95, 0.98), 16)
	_add_breakdown_line("Target: %d   %s" % [target, "CLEARED" if passed else "FAILED"], TARGET_PASS_COLOR if passed else Color(0.9, 0.38, 0.38), 16)

func _add_breakdown_line(text: String, color: Color = Color(0.9, 0.9, 0.94), size: int = 14) -> void:
	var label: Label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	breakdown_lines.add_child(label)

func _add_breakdown_divider() -> void:
	breakdown_lines.add_child(HSeparator.new())

func _parse_breakdown_text(text: String) -> Dictionary:
	var followers_subtotal: int = 0
	var target: int = 0
	var final_devotion: int = 0
	var additive_lines: Array[String] = []
	var multiplier_lines: Array[String] = []
	var multiplier_base: int = int(last_result.get("base", 1))
	var multiplier_exp: int = int(last_result.get("exponent", 1))
	var multiplier_total: int = int(last_result.get("multiplier", 1))
	var section: String = ""
	for raw in text.split("\n"):
		var line: String = raw.strip_edges()
		if line == "" or line == "SACRIFICE SUMMARY" or line.begins_with("--------------------------------"):
			continue
		if line.begins_with("1) FOLLOWERS"):
			section = "followers"
			continue
		if line.begins_with("2) DOCTRINE"):
			section = "doctrine"
			continue
		if line.begins_with("3) RELICS"):
			section = "relics"
			continue
		if line.begins_with("4) TRAITS"):
			section = "traits"
			continue
		if line == "MULTIPLIER SUMMARY":
			section = "multiplier"
			continue
		if line.begins_with("Target: "):
			var nums: Array[int] = _all_ints_from_text(line)
			if nums.size() >= 2:
				target = nums[0]
				final_devotion = nums[1]
			continue
		if line.begins_with("Subtotal (Followers):"):
			followers_subtotal = _last_int_from_text(line, followers_subtotal)
			continue
		if line.begins_with("- Multiplier base:"):
			multiplier_base = _last_int_from_text(line, multiplier_base)
			continue
		if line.begins_with("- Multiplier exponent:"):
			multiplier_exp = _last_int_from_text(line, multiplier_exp)
			continue
		if line.begins_with("- Multiplier ="):
			var mult_nums: Array[int] = _all_ints_from_text(line)
			if mult_nums.size() >= 3:
				multiplier_total = mult_nums[2]
			continue
		if section == "doctrine" or section == "relics" or section == "traits":
			if line.begins_with("- "):
				additive_lines.append(line.substr(2))
		elif section == "multiplier" and line.begins_with("- "):
			var mline: String = line.substr(2)
			if not mline.begins_with("Multiplier base:") and not mline.begins_with("Multiplier exponent:") and not mline.begins_with("Multiplier ="):
				multiplier_lines.append(mline)
	return {
		"followers_subtotal": followers_subtotal,
		"target": target,
		"final_devotion": final_devotion,
		"additive_lines": additive_lines,
		"multiplier_lines": multiplier_lines,
		"multiplier_base": multiplier_base,
		"multiplier_exp": multiplier_exp,
		"multiplier_total": multiplier_total,
	}

func _all_ints_from_text(text: String) -> Array[int]:
	var out: Array[int] = []
	var re: RegEx = RegEx.new()
	if re.compile("[-+]?\\d+") != OK:
		return out
	for match in re.search_all(text):
		out.append(int(match.get_string()))
	return out

func _last_int_from_text(text: String, fallback: int) -> int:
	var nums: Array[int] = _all_ints_from_text(text)
	return fallback if nums.is_empty() else nums[nums.size() - 1]

func _on_menu_pressed() -> void:
	var overlay: Node = get_node_or_null("/root/GlobalMenuOverlay")
	if overlay != null:
		if overlay.has_method("open_menu"):
			overlay.call("open_menu")
			return
		if overlay.has_method("_on_menu_pressed"):
			overlay.call("_on_menu_pressed")
			return
	_show_info("(Info) Menu unavailable.")

func _ensure_tutorial_overlay() -> void:
	if tutorial_overlay != null and is_instance_valid(tutorial_overlay):
		return
	tutorial_overlay = TutorialOverlayScript.new()
	add_child(tutorial_overlay)

func _start_tutorial_callouts() -> void:
	if not gs.is_tutorial_active():
		return
	if tutorial_callout_running:
		return
	var key: String = "run_intro_w%d_r%d" % [gs.current_week, gs.week_round]
	if gs.tutorial_has_seen_callout(key):
		return
	_ensure_tutorial_overlay()
	tutorial_callout_running = true
	var steps: Array[Dictionary] = []
	if gs.current_week == 1 and gs.week_round == 1:
		steps = [
			{"target": target_value, "title": "Devotion Target", "text": "This is your goal. You score devotion by sacrificing followers in the altar. Reach or pass this number this week."},
			{"target": week_label, "title": "Week and Round", "text": "Track your current week and round here."},
			{"target": follower_row, "title": "Followers", "text": "Each follower has a Tier and a Type. Tier is raw strength. Higher tier usually means more score."},
			{"target": follower_row, "title": "Types", "text": "Types shape scoring: BLOOD and BONE add direct devotion, VOID boosts your multiplier, and SOUL usually pays off through trait/relic effects."},
			{"target": pit_drop_area, "title": "Altar", "text": "Drag followers into the altar to stage sacrifices."},
			{"target": preview_text, "title": "Preview", "text": "This shows your live estimate before confirming. If the total is green, you're on pace to clear the target."},
			{"target": confirm_button, "title": "Confirm", "text": "Confirm Sacrifice locks this play in and applies the result."},
			{"target": pit_drop_area, "title": "Your Task", "text": "Try sacrificing some followers now. Drag cards into the altar, then press Confirm Sacrifice."},
		]
	elif gs.current_week == 2 and gs.week_round == 1:
		var bloodbrand_card: Control = _tutorial_find_hand_card_by_trait_id("bloodbrand")
		if bloodbrand_card == null:
			bloodbrand_card = follower_row
		steps = [
			{"target": follower_row, "title": "Traits", "text": "Traits are bonus rules on followers. Hover a card to read exactly what its trait does."},
			{"target": bloodbrand_card, "title": "Example Combo", "text": "Try the Bloodbrand follower this round. Bloodbrand gives +7 when sacrificed with at least 2 BLOOD followers."},
			{"target": follower_row, "title": "Multi-Trait Badges", "text": "The 4 badge slots at the bottom are trait slots. Through breeding, followers can inherit multiple traits."},
			{"target": preview_text, "title": "Lineage Bonus", "text": "If altar followers have lineage points, a lineage row appears here and boosts final devotion."},
		]
	elif gs.current_week == 2 and gs.week_round == 2:
		steps = [
			{"target": doctrine_button, "title": "Doctrine Action", "text": "Doctrine action is once per play. Use it before confirming sacrifice."},
		]
	elif gs.current_week == 4 and gs.week_round == 1:
		steps = [
			{"target": ritual_use, "title": "Rituals", "text": "Ritual cards are optional tactical effects for this play."},
			{"target": preview_text, "title": "Final Tutorial Week", "text": "Combine relics, traits, doctrine, and lineage to clear this week."},
		]
	for step in steps:
		tutorial_overlay.show_callout(step.get("target", null), str(step.get("text", "")), str(step.get("title", "Tutorial")), "next")
		await tutorial_overlay.callout_closed
	gs.tutorial_mark_callout_seen(key)
	tutorial_callout_running = false

func _tutorial_post_confirm_callout() -> void:
	if not gs.is_tutorial_active():
		return
	if gs.current_week != 1 or gs.week_round != 1:
		return
	var key: String = "run_post_confirm_w%d_r%d" % [gs.current_week, gs.week_round]
	if gs.tutorial_has_seen_callout(key):
		return
	_ensure_tutorial_overlay()
	tutorial_overlay.show_callout(breakdown_panel, "This breakdown shows exactly where devotion and blood came from in this play.", "Breakdown", "next")
	await tutorial_overlay.callout_closed
	gs.tutorial_mark_callout_seen(key)

func _tutorial_find_hand_card_by_trait_id(trait_id: String) -> Control:
	if trait_id == "":
		return null
	for i in range(min(gs.current_hand.size(), hand_card_nodes.size())):
		var follower: Dictionary = gs.current_hand[i]
		if str(follower.get("trait_id", "")) != trait_id:
			continue
		var root: Control = hand_card_nodes[i].get("root", null) as Control
		if root != null and root.visible:
			return root
	return null

func _on_pool_pressed() -> void:
	_refresh_pool_overlay()
	pool_overlay.visible = true

func _on_pool_close_pressed() -> void:
	pool_overlay.visible = false

func _refresh_pool_overlay() -> void:
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
		var row: PanelContainer = PanelContainer.new()
		var hbox: HBoxContainer = HBoxContainer.new()
		row.add_child(hbox)
		var stripe: ColorRect = ColorRect.new()
		stripe.custom_minimum_size = Vector2(12, 0)
		stripe.color = _get_trait_color(str(f.get("trait", "")))
		hbox.add_child(stripe)
		var label: Label = Label.new()
		label.text = "%s  T%d  %s  (%s #%d)" % [
			f["trait"],
			int(f["tier"]),
			_get_trait_display(str(f.get("trait_id", ""))) + _follower_trait_badge(f),
			f["origin_tag"],
			int(f["id"]),
		]
		var trait_rarity: String = str(gs._trait_rarity(str(f.get("trait_id", ""))))
		if trait_rarity == "RARE":
			label.add_theme_color_override("font_color", Color(0.85, 0.7, 0.2))
		elif trait_rarity == "LEGENDARY":
			label.add_theme_color_override("font_color", Color(0.95, 0.55, 0.2))
		hbox.add_child(label)
		if gs.relic_inventory.get("Crown of Tiers", 0) > 0:
			var crown_btn: Button = Button.new()
			crown_btn.text = "Crown +3 (5)"
			crown_btn.disabled = gs.crown_of_tiers_used_week == gs.current_week or gs.blood_currency < 5
			crown_btn.pressed.connect(_on_pool_crown_pressed.bind(int(f.get("id", -1))))
			hbox.add_child(crown_btn)
		row.tooltip_text = "\n".join(_follower_trait_tooltip_lines(f))
		pool_list.add_child(row)

func _on_pool_breed_pressed() -> void:
	_refresh_pool_overlay()

func _on_pool_crown_pressed(follower_id: int) -> void:
	var result: Dictionary = gs.use_crown_of_tiers(follower_id)
	if not bool(result.get("ok", false)):
		_show_info("(Crown) %s" % str(result.get("reason", "Could not use Crown of Tiers.")))
	else:
		_show_info("(Crown) Promoted #%d to T%d" % [follower_id, int(result.get("after_tier", 0))])
	_refresh_pool_overlay()
	_refresh_ui(false)

func _sacrifice_summary(selected_indices: Array[int]) -> String:
	var parts: Array[String] = []
	for i in selected_indices:
		if i >= 0 and i < gs.current_hand.size():
			var f: Dictionary = gs.current_hand[i]
			parts.append("#%d %s(%d)" % [i + 1, f["trait"], f["tier"]])
	if parts.is_empty():
		return "(none)"
	return ", ".join(parts)

func _get_trait_color(trait_name: String) -> Color:
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
			return Color(0.45, 0.45, 0.45)

func _get_trait_font_color(trait_name: String) -> Color:
	if trait_name == "VOID":
		return Color(0.95, 0.95, 0.98)
	return Color(0.08, 0.08, 0.08)

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

func _trait_info(trait_id: String) -> Dictionary:
	if trait_id == "":
		return {}
	if gs.TRAIT_REGISTRY.has(trait_id):
		return gs.TRAIT_REGISTRY[trait_id]
	var combo_info: Dictionary = gs.get_combo_trait(trait_id)
	if not combo_info.is_empty():
		return combo_info
	return {}

func _get_trait_display(trait_id: String) -> String:
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

func _get_trait_description_from_registry(trait_id: String) -> String:
	if trait_id == "":
		return "Trait: None."
	var info: Dictionary = _trait_info(trait_id)
	if info.is_empty():
		return "Trait: " + trait_id
	return "%s: %s" % [str(info.get("name", trait_id)), str(info.get("desc", ""))]

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

func _follower_trait_count(follower: Dictionary) -> int:
	return _follower_all_trait_ids(follower).size()

func _follower_trait_badge(follower: Dictionary) -> String:
	var count: int = _follower_trait_count(follower)
	return "" if count <= 1 else " x%d" % count

func _follower_trait_tooltip_lines(follower: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	lines.append(_get_trait_description(str(follower.get("trait", ""))))
	var all_traits: Array[String] = _follower_all_trait_ids(follower)
	if all_traits.is_empty():
		return lines
	if all_traits.size() == 1:
		lines.append(_get_trait_description_from_registry(all_traits[0]))
		return lines
	lines.append("Traits (%d total):" % all_traits.size())
	for i in range(all_traits.size()):
		var tid: String = all_traits[i]
		var prefix: String = "Primary" if i == 0 else "Extra %d" % i
		lines.append("- %s: %s" % [prefix, _get_trait_description_from_registry(tid)])
	return lines

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
	if card_root == null:
		return
	var lineage: int = _lineage_value(follower)
	var legacy_badge: Control = card_root.get_node_or_null("LineageBadge") as Control
	if legacy_badge != null:
		legacy_badge.queue_free()
	var inline_badge: PanelContainer = card_root.get_node_or_null("CardMargin/CardVBox/LineageRow/LineageInlineBadge") as PanelContainer
	if inline_badge != null:
		var inline_label: Label = inline_badge.get_node_or_null("LineageInlineLabel") as Label
		var inline_style: StyleBoxFlat = StyleBoxFlat.new()
		inline_style.bg_color = _lineage_badge_color(max(1, lineage))
		inline_style.corner_radius_top_left = 8
		inline_style.corner_radius_top_right = 8
		inline_style.corner_radius_bottom_left = 8
		inline_style.corner_radius_bottom_right = 8
		inline_style.content_margin_left = 4
		inline_style.content_margin_right = 4
		inline_style.content_margin_top = 1
		inline_style.content_margin_bottom = 1
		inline_badge.add_theme_stylebox_override("panel", inline_style)
		var overlay_for_hand: Control = card_root.get_node_or_null("LineageOverlay") as Control
		if overlay_for_hand != null:
			var overlay_badge: PanelContainer = overlay_for_hand.get_node_or_null("LineageBadge") as PanelContainer
			if overlay_badge != null:
				_lineage_pulse_stop(overlay_badge)
				overlay_badge.visible = false
			overlay_for_hand.visible = false
		if lineage <= 0:
			_lineage_pulse_stop(inline_badge)
			inline_badge.visible = false
			return
		if inline_label != null:
			inline_label.text = "L%d" % lineage
			inline_label.add_theme_color_override("font_color", _lineage_badge_text_color(lineage))
			inline_label.add_theme_font_size_override("font_size", 10)
		inline_badge.visible = true
		if lineage >= 10:
			_lineage_pulse_start(inline_badge)
		else:
			_lineage_pulse_stop(inline_badge)
		return
	var overlay: Control = card_root.get_node_or_null("LineageOverlay") as Control
	if overlay == null:
		overlay = Control.new()
		overlay.name = "LineageOverlay"
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		overlay.anchor_right = 1.0
		overlay.anchor_bottom = 1.0
		card_root.add_child(overlay)
	var badge: PanelContainer = overlay.get_node_or_null("LineageBadge") as PanelContainer
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
		badge.offset_left = -34.0
		badge.offset_top = -20.0
		badge.offset_right = -6.0
		badge.offset_bottom = -6.0
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var label: Label = Label.new()
		label.name = "LineageBadgeLabel"
		label.anchor_right = 1.0
		label.anchor_bottom = 1.0
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 10)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge.add_child(label)
		overlay.add_child(badge)
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
	var badge_label: Label = badge.get_node("LineageBadgeLabel") as Label
	badge_label.text = "L%d" % lineage
	badge_label.add_theme_color_override("font_color", _lineage_badge_text_color(lineage))
	badge.visible = true
	if lineage >= 10:
		_lineage_pulse_start(badge)
	else:
		_lineage_pulse_stop(badge)
