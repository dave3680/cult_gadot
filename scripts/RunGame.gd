extends Control

const DRAG_THRESHOLD := 10.0
const PIT_HIGHLIGHT_COLOR := Color(0.82, 0.42, 0.22, 0.95)
const PIT_IDLE_BORDER_COLOR := Color(0.46, 0.2, 0.12, 0.85)
const TARGET_PASS_COLOR := Color(0.38, 0.85, 0.45)
const TARGET_DEFAULT_COLOR := Color(0.93, 0.86, 0.77)

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
		root.gui_input.connect(_on_hand_card_gui_input.bind(i))
		hand_card_nodes.append({
			"root": root,
			"tier": root.get_node("CardMargin/CardVBox/TierLabel"),
			"type": root.get_node("CardMargin/CardVBox/TypeLabel"),
			"trait": root.get_node("CardMargin/CardVBox/TraitLabel"),
		})

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
	var trait_id: String = str(follower.get("trait_id", ""))
	var exhausted: bool = bool(follower.get("exhausted", false))
	var committed: bool = pit_indices.has(i)
	var selected: bool = selected_hand_index == i and not committed and not confirmed
	var ghosting: bool = drag_active and drag_source == "hand" and drag_index == i

	tier_label.text = "T%d" % int(follower.get("tier", 0))
	type_label.text = trait_name
	var trait_text: String = _get_trait_display(trait_id) + _follower_trait_badge(follower)
	if exhausted and not committed:
		trait_text += "  EXHAUSTED"
	trait_label.text = trait_text

	tier_label.add_theme_font_size_override("font_size", 34)
	type_label.add_theme_font_size_override("font_size", 20)
	trait_label.add_theme_font_size_override("font_size", 14)
	tier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	trait_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

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
	var trait_color: Color = Color(0.12, 0.12, 0.12)
	if trait_id != "":
		var tinfo: Dictionary = _trait_info(trait_id)
		var rarity: String = str(tinfo.get("rarity", ""))
		if rarity == "RARE":
			trait_color = Color(0.85, 0.7, 0.2)
		elif rarity == "LEGENDARY":
			trait_color = Color(0.95, 0.55, 0.2)
	if committed:
		type_color = type_color.lerp(Color(0.52, 0.52, 0.52), 0.55)
		trait_color = trait_color.lerp(Color(0.6, 0.6, 0.6), 0.45)
	type_label.add_theme_color_override("font_color", type_color)
	trait_label.add_theme_color_override("font_color", trait_color)

	root.tooltip_text = "\n".join(_follower_trait_tooltip_lines(follower))
	if confirmed or committed or exhausted:
		root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		root.mouse_filter = Control.MOUSE_FILTER_STOP

func _refresh_pit_cards() -> void:
	for child in pit_cards_row.get_children():
		child.queue_free()
	for idx in pit_indices:
		var card: PanelContainer = _build_small_card(idx)
		card.gui_input.connect(_on_pit_card_gui_input.bind(idx, card))
		pit_cards_row.add_child(card)

func _build_small_card(hand_index: int) -> PanelContainer:
	var follower: Dictionary = gs.current_hand[hand_index]
	var card: PanelContainer = PanelContainer.new()
	card.custom_minimum_size = Vector2(108, 126)
	card.mouse_filter = Control.MOUSE_FILTER_STOP

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 2)
	card.add_child(vbox)

	var tier: Label = Label.new()
	tier.text = "T%d" % int(follower.get("tier", 0))
	tier.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tier.add_theme_font_size_override("font_size", 24)
	vbox.add_child(tier)

	var tlabel: Label = Label.new()
	tlabel.text = str(follower.get("trait", ""))
	tlabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tlabel.add_theme_font_size_override("font_size", 14)
	tlabel.add_theme_color_override("font_color", _get_trait_font_color(str(follower.get("trait", ""))))
	vbox.add_child(tlabel)

	var spacer: Control = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	var trait_label: Label = Label.new()
	trait_label.text = _get_trait_display(str(follower.get("trait_id", ""))) + _follower_trait_badge(follower)
	trait_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	trait_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	trait_label.add_theme_font_size_override("font_size", 11)
	vbox.add_child(trait_label)

	var bg: Color = _get_trait_color(str(follower.get("trait", ""))).lerp(Color(0.08, 0.08, 0.08), 0.18)
	var dragging_this: bool = drag_active and drag_source == "pit" and drag_index == hand_index
	if dragging_this:
		bg = Color(bg.r, bg.g, bg.b, 0.2)
	card.add_theme_stylebox_override("panel", _make_card_style(bg, Color(0.12, 0.12, 0.12, 0.95), 1))
	card.tooltip_text = "\n".join(_follower_trait_tooltip_lines(follower))
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
	var follower: Dictionary = gs.current_hand[hand_index]
	var card: PanelContainer = PanelContainer.new()
	card.custom_minimum_size = Vector2(112, 126)
	card.size = card.custom_minimum_size
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 2)
	card.add_child(vbox)

	var tier: Label = Label.new()
	tier.text = "T%d" % int(follower.get("tier", 0))
	tier.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tier.add_theme_font_size_override("font_size", 24)
	vbox.add_child(tier)

	var tlabel: Label = Label.new()
	tlabel.text = str(follower.get("trait", ""))
	tlabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tlabel.add_theme_font_size_override("font_size", 14)
	tlabel.add_theme_color_override("font_color", _get_trait_font_color(str(follower.get("trait", ""))))
	vbox.add_child(tlabel)

	var spacer: Control = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	var trait_label: Label = Label.new()
	trait_label.text = _get_trait_display(str(follower.get("trait_id", ""))) + _follower_trait_badge(follower)
	trait_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	trait_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	trait_label.clip_text = true
	trait_label.add_theme_font_size_override("font_size", 11)
	vbox.add_child(trait_label)

	var bg: Color = _get_trait_color(str(follower.get("trait", ""))).lerp(Color(0.08, 0.08, 0.08), 0.18)
	card.add_theme_stylebox_override("panel", _make_card_style(bg, Color(0.12, 0.12, 0.12, 0.95), 1))
	return card

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
	var body: String = "Base:      %d\nAdditive: +%d\nMultiplier: x%d\n----------------------\n[color=%s]Total:     %d  /  Target: %d  %s[/color]" % [
		int(numbers.get("base", 0)),
		int(numbers.get("additive", 0)),
		int(numbers.get("multiplier", 1)),
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
		confirm_button.disabled = true
		continue_button.disabled = scene_change_queued
		contract_toggle.disabled = true
		doctrine_button.disabled = true
		ritual_use.disabled = true
		return
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
		if gs.current_week >= gs.get_max_weeks():
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
