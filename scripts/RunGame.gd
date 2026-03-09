extends Control

const SHOW_VERBOSE_PREVIEW := false

@onready var week_label: Label = $RootVBox/TopBar/TopBarHBox/WeekBox/WeekLabel
@onready var target_label: Label = $RootVBox/TopBar/TopBarHBox/TargetBox/TargetLabel
@onready var blood_label: Label = $RootVBox/TopBar/TopBarHBox/BloodBox/BloodLabel

@onready var breakdown_text: Label = $RootVBox/MiddleArea/BreakdownPanel/BreakdownVBox/BreakdownScroll/BreakdownText
@onready var doctrine_label: Label = $RootVBox/MiddleArea/DoctrinePanel/DoctrineHBox/DoctrineLabel
@onready var doctrine_hint: Label = $RootVBox/MiddleArea/DoctrinePanel/DoctrineHBox/DoctrineHint
@onready var doctrine_button: Button = $RootVBox/MiddleArea/DoctrinePanel/DoctrineHBox/DoctrineAction
@onready var pool_button: Button = $RootVBox/MiddleArea/DoctrinePanel/DoctrineHBox/PoolButton
@onready var pool_overlay: Control = $PoolOverlay
@onready var pool_summary: Label = $PoolOverlay/PoolCenter/PoolPanel/PoolVBox/PoolSummary
@onready var pool_breed: Button = $PoolOverlay/PoolCenter/PoolPanel/PoolVBox/PoolBreed
@onready var pool_list: VBoxContainer = $PoolOverlay/PoolCenter/PoolPanel/PoolVBox/PoolScroll/PoolList
@onready var pool_close: Button = $PoolOverlay/PoolCenter/PoolPanel/PoolVBox/PoolClose

@onready var confirm_button: Button = $RootVBox/BottomBar/BottomHBox/ConfirmButton
@onready var clear_button: Button = $RootVBox/BottomBar/BottomHBox/ClearButton
@onready var contract_toggle: Button = $RootVBox/BottomBar/BottomHBox/ContractToggle
@onready var ritual_use: Button = $RootVBox/BottomBar/BottomHBox/RitualUse
@onready var gs: Node = get_node("/root/GameState")

var card_buttons: Array[Button] = []
var confirmed: bool = false
var confirmed_pass: bool = false
var last_selected_indices: Array[int] = []
var scene_change_queued: bool = false
var score_popup_layer: Control
var score_popup_dim: ColorRect
var score_popup_panel: PanelContainer
var score_popup_formula: HBoxContainer
var score_popup_additive: Label
var score_popup_times: Label
var score_popup_multiplier: Label
var score_popup_final: Label
var score_popup_subtitle: Label
var score_popup_tween: Tween
var score_popup_target_additive: int = 0
var score_popup_target_multiplier: int = 1

func _ready() -> void:
	_build_score_popup()
	card_buttons = [
		$RootVBox/MiddleArea/HandPanel/HandVBox/HandBox/Card1,
		$RootVBox/MiddleArea/HandPanel/HandVBox/HandBox/Card2,
		$RootVBox/MiddleArea/HandPanel/HandVBox/HandBox/Card3,
		$RootVBox/MiddleArea/HandPanel/HandVBox/HandBox/Card4,
		$RootVBox/MiddleArea/HandPanel/HandVBox/HandBox/Card5,
		$RootVBox/MiddleArea/HandPanel/HandVBox/HandBox/Card6,
	]

	for i in range(card_buttons.size()):
		var btn: Button = card_buttons[i]
		btn.toggled.connect(_on_card_toggled.bind(i))

	confirm_button.pressed.connect(_on_confirm_pressed)
	clear_button.pressed.connect(_on_clear_pressed)
	contract_toggle.pressed.connect(_on_contract_toggle)
	ritual_use.pressed.connect(_on_ritual_use)
	doctrine_button.pressed.connect(_on_doctrine_pressed)
	pool_button.pressed.connect(_on_pool_pressed)
	pool_close.pressed.connect(_on_pool_close_pressed)
	pool_breed.pressed.connect(_on_pool_breed_pressed)
	pool_breed.visible = false

	if gs.current_hand.size() != 6:
		gs.draw_hand_from_pool()

	if gs.pending_confirmed and gs.pending_sacrifice_indices.size() > 0:
		confirmed = true
		confirmed_pass = gs.pending_pass
		last_selected_indices = gs.pending_sacrifice_indices.duplicate()

	_refresh_ui()

func _build_score_popup() -> void:
	score_popup_layer = Control.new()
	score_popup_layer.name = "ScorePopupLayer"
	score_popup_layer.anchor_right = 1.0
	score_popup_layer.anchor_bottom = 1.0
	score_popup_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	score_popup_layer.visible = false
	score_popup_layer.z_index = 100
	add_child(score_popup_layer)

	score_popup_dim = ColorRect.new()
	score_popup_dim.anchor_right = 1.0
	score_popup_dim.anchor_bottom = 1.0
	score_popup_dim.color = Color(0.0, 0.0, 0.0, 0.0)
	score_popup_layer.add_child(score_popup_dim)

	var center: CenterContainer = CenterContainer.new()
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	score_popup_layer.add_child(center)

	score_popup_panel = PanelContainer.new()
	score_popup_panel.custom_minimum_size = Vector2(440, 210)
	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.06, 0.08, 0.95)
	panel_style.border_color = Color(0.95, 0.55, 0.2, 0.95)
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.corner_radius_top_left = 12
	panel_style.corner_radius_top_right = 12
	panel_style.corner_radius_bottom_left = 12
	panel_style.corner_radius_bottom_right = 12
	panel_style.content_margin_left = 18
	panel_style.content_margin_right = 18
	panel_style.content_margin_top = 18
	panel_style.content_margin_bottom = 18
	score_popup_panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(score_popup_panel)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 8)
	score_popup_panel.add_child(vbox)

	var score_popup_stage: Control = Control.new()
	score_popup_stage.custom_minimum_size = Vector2(380, 96)
	score_popup_stage.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(score_popup_stage)

	var formula_center: CenterContainer = CenterContainer.new()
	formula_center.anchor_right = 1.0
	formula_center.anchor_bottom = 1.0
	score_popup_stage.add_child(formula_center)

	score_popup_formula = HBoxContainer.new()
	score_popup_formula.custom_minimum_size = Vector2(380, 72)
	score_popup_formula.alignment = BoxContainer.ALIGNMENT_CENTER
	score_popup_formula.add_theme_constant_override("separation", 16)
	score_popup_formula.pivot_offset = Vector2(190, 36)
	formula_center.add_child(score_popup_formula)

	score_popup_additive = Label.new()
	score_popup_additive.text = "0"
	score_popup_additive.custom_minimum_size = Vector2(120, 72)
	score_popup_additive.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_popup_additive.add_theme_font_size_override("font_size", 56)
	score_popup_additive.add_theme_color_override("font_color", Color(0.95, 0.96, 1.0))
	score_popup_formula.add_child(score_popup_additive)

	score_popup_times = Label.new()
	score_popup_times.text = "x"
	score_popup_times.add_theme_font_size_override("font_size", 44)
	score_popup_times.add_theme_color_override("font_color", Color(0.96, 0.78, 0.45))
	score_popup_formula.add_child(score_popup_times)

	score_popup_multiplier = Label.new()
	score_popup_multiplier.text = "1"
	score_popup_multiplier.custom_minimum_size = Vector2(120, 72)
	score_popup_multiplier.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_popup_multiplier.add_theme_font_size_override("font_size", 56)
	score_popup_multiplier.add_theme_color_override("font_color", Color(0.96, 0.96, 1.0))
	score_popup_formula.add_child(score_popup_multiplier)

	var final_center: CenterContainer = CenterContainer.new()
	final_center.anchor_right = 1.0
	final_center.anchor_bottom = 1.0
	score_popup_stage.add_child(final_center)

	score_popup_final = Label.new()
	score_popup_final.text = "0"
	score_popup_final.custom_minimum_size = Vector2(240, 72)
	score_popup_final.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_popup_final.pivot_offset = Vector2(120, 36)
	score_popup_final.add_theme_font_size_override("font_size", 68)
	score_popup_final.add_theme_color_override("font_color", Color(0.95, 0.55, 0.2))
	final_center.add_child(score_popup_final)

	score_popup_subtitle = Label.new()
	score_popup_subtitle.text = "DEVOTION"
	score_popup_subtitle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	score_popup_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_popup_subtitle.add_theme_font_size_override("font_size", 24)
	score_popup_subtitle.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	vbox.add_child(score_popup_subtitle)

func _set_popup_additive_value(value: float) -> void:
	if score_popup_additive == null:
		return
	score_popup_additive.text = str(max(0, int(round(value))))

func _set_popup_multiplier_value(value: float) -> void:
	if score_popup_multiplier == null:
		return
	score_popup_multiplier.text = str(max(1, int(round(value))))

func _set_popup_final_value(value: int) -> void:
	if score_popup_final == null:
		return
	score_popup_final.text = str(value)

func _set_popup_additive_progress(progress: float) -> void:
	var p: float = clamp(progress, 0.0, 1.0)
	var curved: float = pow(p, 1.85)
	_set_popup_additive_value(float(score_popup_target_additive) * curved)

func _set_popup_multiplier_progress(progress: float) -> void:
	var p: float = clamp(progress, 0.0, 1.0)
	var curved: float = pow(p, 1.85)
	var value: float = 1.0 + (float(score_popup_target_multiplier - 1) * curved)
	_set_popup_multiplier_value(value)

func _hide_score_popup() -> void:
	if score_popup_layer == null:
		return
	score_popup_layer.visible = false
	score_popup_layer.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _cancel_score_popup() -> void:
	if score_popup_tween != null and is_instance_valid(score_popup_tween):
		score_popup_tween.kill()
		score_popup_tween = null
	_hide_score_popup()

func _play_score_popup(result: Dictionary) -> void:
	if score_popup_layer == null:
		return
	_cancel_score_popup()
	var additive_total: int = max(0, int(result.get("additive_total", 0)))
	var multiplier_total: int = max(1, int(result.get("multiplier", 1)))
	var final_total: int = max(0, int(result.get("final_devotion", 0)))
	score_popup_target_additive = additive_total
	score_popup_target_multiplier = multiplier_total
	score_popup_layer.visible = true
	score_popup_layer.modulate = Color(1.0, 1.0, 1.0, 1.0)
	score_popup_dim.color = Color(0.0, 0.0, 0.0, 0.0)
	score_popup_panel.scale = Vector2(0.9, 0.9)
	score_popup_formula.scale = Vector2(1.0, 1.0)
	score_popup_formula.modulate = Color(1.0, 1.0, 1.0, 1.0)
	score_popup_times.modulate = Color(1.0, 1.0, 1.0, 0.0)
	score_popup_final.modulate = Color(1.0, 1.0, 1.0, 0.0)
	score_popup_final.scale = Vector2(0.4, 0.4)
	score_popup_subtitle.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_set_popup_additive_value(0.0)
	_set_popup_multiplier_value(1.0)
	_set_popup_final_value(final_total)
	var t: Tween = create_tween()
	score_popup_tween = t
	t.set_trans(Tween.TRANS_CUBIC)
	t.set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(score_popup_dim, "color", Color(0.0, 0.0, 0.0, 0.2), 0.12)
	t.parallel().tween_property(score_popup_panel, "scale", Vector2(1.0, 1.0), 0.12)
	var add_tweener := t.tween_method(Callable(self, "_set_popup_additive_progress"), 0.0, 1.0, 0.34)
	add_tweener.set_trans(Tween.TRANS_QUAD)
	add_tweener.set_ease(Tween.EASE_IN)
	t.tween_property(score_popup_times, "modulate:a", 1.0, 0.09)
	var mult_tweener := t.tween_method(Callable(self, "_set_popup_multiplier_progress"), 0.0, 1.0, 0.30)
	mult_tweener.set_trans(Tween.TRANS_QUAD)
	mult_tweener.set_ease(Tween.EASE_IN)
	t.tween_property(score_popup_formula, "scale", Vector2(1.18, 1.18), 0.11)
	t.tween_property(score_popup_formula, "scale", Vector2(0.80, 0.80), 0.11)
	t.parallel().tween_property(score_popup_formula, "modulate:a", 0.0, 0.10)
	t.tween_property(score_popup_final, "modulate:a", 1.0, 0.06)
	t.parallel().tween_property(score_popup_subtitle, "modulate:a", 1.0, 0.07)
	t.tween_property(score_popup_final, "scale", Vector2(1.24, 1.24), 0.14)
	t.tween_property(score_popup_final, "scale", Vector2(1.0, 1.0), 0.10)
	t.tween_interval(0.45)
	t.tween_property(score_popup_layer, "modulate:a", 0.0, 0.22)
	t.tween_callback(Callable(self, "_hide_score_popup"))
	t.finished.connect(func() -> void:
		score_popup_tween = null
	)

func _refresh_ui() -> void:
	week_label.text = "Week %d/%d (Round %d/2)" % [gs.current_week, gs.get_max_weeks(), gs.week_round]
	target_label.text = "Target: %d" % gs.get_week_target(gs.current_week)
	blood_label.text = "Blood: %d" % gs.blood_currency
	breakdown_text.text = gs.last_breakdown_text
	_update_doctrine_ui()
	_update_contract_ui()
	_update_ritual_ui()

	for i in range(card_buttons.size()):
		_update_card_visual(i)

	_update_breakdown_preview()
	_update_confirm_state()

func _update_doctrine_ui() -> void:
	var name: String = gs.selected_doctrine
	if name == "":
		doctrine_label.text = "Doctrine: -"
		doctrine_hint.text = "Choose a doctrine"
		doctrine_button.disabled = true
		return
	if name == "FLESH":
		doctrine_label.text = "Doctrine: Path of Flesh"
		doctrine_hint.text = "Convert one follower to BLOOD"
	elif name == "RUIN":
		doctrine_label.text = "Doctrine: Path of Ruin"
		doctrine_hint.text = "Refine +1 tier, exhaust this play"
	else:
		doctrine_label.text = "Doctrine: Path of Silence"
		doctrine_hint.text = "Banish one follower, replace it"
	doctrine_button.disabled = gs.doctrine_used_this_play or confirmed
	pool_button.disabled = false

func _get_trait_color(trait_name: String) -> Color:
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

func _get_trait_font_color(trait_name: String) -> Color:
	if trait_name == "VOID":
		return Color(0.95, 0.95, 0.95)
	return Color(0.1, 0.1, 0.1)

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
	var name: String = str(info.get("name", trait_id))
	var desc: String = str(info.get("desc", ""))
	return "%s: %s" % [name, desc]

func _make_style(bg: Color, selected: bool) -> StyleBoxFlat:
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = Color(1.0, 0.9, 0.2) if selected else Color(0.1, 0.1, 0.1)
	var bw: int = 4 if selected else 1
	sb.border_width_left = bw
	sb.border_width_right = bw
	sb.border_width_top = bw
	sb.border_width_bottom = bw
	sb.corner_radius_top_left = 6
	sb.corner_radius_top_right = 6
	sb.corner_radius_bottom_left = 6
	sb.corner_radius_bottom_right = 6
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	return sb

func _update_card_visual(i: int) -> void:
	var btn: Button = card_buttons[i]
	var follower: Dictionary = gs.current_hand[i]
	var tier: int = follower["tier"]
	var trait_name: String = follower["trait"]
	var trait_id: String = str(follower.get("trait_id", ""))
	var exhausted: bool = follower["exhausted"]
	var trait_label: String = _get_trait_display(trait_id)

	if exhausted:
		btn.text = "T%d\n%s\n%s\nEXHAUSTED" % [tier, trait_name, trait_label]
	else:
		btn.text = "T%d\n%s\n%s" % [tier, trait_name, trait_label]
	var bg: Color = _get_trait_color(trait_name)
	var selected: bool = btn.button_pressed
	var style: StyleBoxFlat = _make_style(bg, selected)

	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_stylebox_override("disabled", style)
	btn.add_theme_stylebox_override("focus", style)
	var font_color: Color = _get_trait_font_color(trait_name)
	if trait_id != "":
		var tinfo: Dictionary = _trait_info(trait_id)
		var rarity: String = str(tinfo.get("rarity", ""))
		if rarity == "RARE":
			font_color = Color(0.85, 0.7, 0.2)
		elif rarity == "LEGENDARY":
			font_color = Color(0.95, 0.55, 0.2)
	btn.add_theme_color_override("font_color", font_color)
	btn.add_theme_color_override("font_pressed_color", font_color)
	var tooltip_lines: Array[String] = []
	tooltip_lines.append(_get_trait_description(trait_name))
	if trait_id != "":
		tooltip_lines.append(_get_trait_description_from_registry(trait_id))
	btn.tooltip_text = "\n".join(tooltip_lines)

func _format_preview_breakdown(preview: Dictionary, remaining_target: int) -> String:
	if not SHOW_VERBOSE_PREVIEW:
		var max_allowed: int = _get_required_sacrifice_count()
		if preview.is_empty():
			return "Select 1 to %d followers to preview the sacrifice." % max_allowed
		var final_val: int = int(preview.get("final_devotion", 0))
		var additive_val: int = int(preview.get("additive_total", 0))
		var multiplier_val: int = int(preview.get("multiplier", 1))
		var blood_gain: int = int(preview.get("blood_gain", 0))
		var status: String = "PASS" if final_val >= remaining_target else "FAIL"
		return "Preview: %d x %d = %d devotion (%s vs %d remaining) | Blood +%d" % [
			additive_val,
			multiplier_val,
			final_val,
			status,
			remaining_target,
			blood_gain,
		]
	var text: String = str(preview.get("breakdown", ""))
	if text == "":
		var max_allowed: int = _get_required_sacrifice_count()
		return "Select 1 to %d followers to preview the sacrifice." % max_allowed
	var lines: PackedStringArray = text.split("\n")
	for i in range(lines.size()):
		if lines[i].begins_with("Target: "):
			var final_val: int = int(preview.get("final_devotion", 0))
			var pass_fail: String = "PASS" if final_val >= remaining_target else "FAIL"
			lines[i] = "Target: %d   Final Devotion: %d   Result: %s" % [
				remaining_target,
				final_val,
				pass_fail,
			]
			break
	return "\n".join(lines)

func _update_breakdown_preview() -> void:
	if confirmed:
		return
	var selected_indices: Array[int] = []
	for i in range(card_buttons.size()):
		if card_buttons[i].button_pressed:
			selected_indices.append(i)
	var max_allowed: int = _get_required_sacrifice_count()
	if selected_indices.size() > max_allowed:
		for j in range(max_allowed, selected_indices.size()):
			var idx: int = int(selected_indices[j])
			card_buttons[idx].button_pressed = false
			_update_card_visual(idx)
		selected_indices = selected_indices.slice(0, max_allowed)
	if selected_indices.size() == 0:
		if gs.last_breakdown_text == "":
			breakdown_text.text = "Select 1 to %d followers to preview the sacrifice." % max_allowed
		return
	var preview: Dictionary = gs.preview_selected(selected_indices)
	var remaining_target: int = max(0, gs.get_week_target(gs.current_week) - gs.week_total_devotion)
	breakdown_text.text = _format_preview_breakdown(preview, remaining_target)

func _update_confirm_state() -> void:
	if confirmed or gs.pending_confirmed:
		confirm_button.show()
		confirm_button.text = "Continue"
		confirm_button.disabled = false
		clear_button.disabled = true
		doctrine_button.disabled = true
		pool_button.disabled = true
		contract_toggle.disabled = true
		for btn in card_buttons:
			btn.disabled = true
		return

	for btn in card_buttons:
		btn.disabled = false
	var selected_count: int = 0
	for btn in card_buttons:
		if btn.button_pressed:
			selected_count += 1
	confirm_button.show()
	confirm_button.text = "Confirm Sacrifice"
	var max_allowed: int = _get_required_sacrifice_count()
	confirm_button.disabled = selected_count == 0 or selected_count > max_allowed
	clear_button.disabled = selected_count == 0
	doctrine_button.disabled = gs.doctrine_used_this_play
	pool_button.disabled = false

func _on_card_toggled(toggled_on: bool, index: int) -> void:
	if toggled_on and gs.current_hand[index]["exhausted"]:
		card_buttons[index].button_pressed = false
		_update_card_visual(index)
		_show_info("(Info) Exhausted: cannot sacrifice this play.")
		return
	if toggled_on:
		var selected_count: int = 0
		for btn in card_buttons:
			if btn.button_pressed:
				selected_count += 1
		var max_allowed: int = _get_required_sacrifice_count()
		if selected_count > max_allowed:
			card_buttons[index].button_pressed = false
			_update_card_visual(index)
			_show_info("(Info) Max %d sacrifices per play." % max_allowed)
			_update_breakdown_preview()
			_update_confirm_state()
			return
	_update_card_visual(index)
	_update_breakdown_preview()
	_update_confirm_state()

func _on_clear_pressed() -> void:
	for i in range(card_buttons.size()):
		card_buttons[i].button_pressed = false
		_update_card_visual(i)
	_update_breakdown_preview()
	_update_confirm_state()

func _on_confirm_pressed() -> void:
	if gs.pending_confirmed or (gs.pending_week == gs.current_week and gs.pending_round == gs.week_round and gs.pending_sacrifice_indices.size() > 0):
		_proceed_after_confirm()
		return
	if confirmed:
		_proceed_after_confirm()
		return

	var selected_indices: Array[int] = []
	for i in range(card_buttons.size()):
		if card_buttons[i].button_pressed:
			selected_indices.append(i)

	var required: int = _get_required_sacrifice_count()
	if selected_indices.size() == 0 or selected_indices.size() > required:
		_show_info("(Info) Select 1 to %d followers." % required)
		return

	var blood_before: int = gs.blood_currency
	if gs.contract_allow_four:
		gs.contract_used_week = gs.current_week
		gs.contract_allow_four = false
		_update_contract_ui()
	var result: Dictionary = gs.score_selected(selected_indices)
	last_selected_indices = selected_indices
	confirmed = true
	confirmed_pass = result["pass"]
	gs.pending_sacrifice_indices = selected_indices.duplicate()
	gs.pending_confirmed = true
	gs.pending_week = gs.current_week
	gs.pending_round = gs.week_round
	gs.pending_pass = bool(result["pass"])
	gs.pending_target = int(result["target"])
	gs.week_total_devotion += int(result["final_devotion"])
	var overflow_target: int = gs.get_week_target(gs.current_week)
	var overflow_grant: int = gs.apply_overflow_blood_for_target(overflow_target)
	_play_score_popup(result)
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
	breakdown_text.text = gs.last_breakdown_text
	blood_label.text = "Blood: %d" % gs.blood_currency
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
	_update_confirm_state()
	_update_doctrine_ui()

func _proceed_after_confirm() -> void:
	if scene_change_queued:
		return
	_cancel_score_popup()
	var resolved_indices: Array[int] = last_selected_indices
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
			gs.last_breakdown_text += "\nEarly Win Bonus: +%d Blood (Blood %d -> %d)" % [
				early_bonus,
				before_round_bonus,
				gs.blood_currency,
			]
			breakdown_text.text = gs.last_breakdown_text
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
			breakdown_text.text = gs.last_breakdown_text
			gs.log_message("SUCCESS BONUS | Week %d | +%d Blood (Cup %d, Geometry %d)" % [
				gs.current_week,
				bonus_total,
				bonus_cup,
				bonus_geo * 3,
			])
		var next_path: String = "res://scenes/Shop.tscn"
		if gs.current_week >= gs.get_max_weeks():
			next_path = "res://scenes/Victory.tscn"
		else:
			gs.perform_weekly_breeding(gs.current_week)
			next_path = "res://scenes/Breeding.tscn"
		_queue_scene_change(next_path, passed, target)
		return

	if gs.week_round == 1:
		gs.week_round = 2
		confirmed = false
		confirmed_pass = false
		last_selected_indices = []
		scene_change_queued = false
		gs.reset_doctrine_for_play()
		gs.draw_hand_from_pool()
		_on_clear_pressed()
		_refresh_ui()
		return

	if gs.week_round == 2:
		get_tree().change_scene_to_file("res://scenes/GameOver.tscn")

func _queue_scene_change(path: String, passed: bool, target: int) -> void:
	if scene_change_queued:
		return
	scene_change_queued = true
	confirm_button.disabled = true
	call_deferred("_do_scene_change", path, passed, target)

func _do_scene_change(path: String, passed: bool, target: int) -> void:
	await get_tree().process_frame
	if not ResourceLoader.exists(path):
		scene_change_queued = false
		confirm_button.disabled = false
		gs.log_message("ERROR | Scene missing path %s week %d round %d" % [
			path,
			gs.current_week,
			gs.week_round,
		])
		_show_info("(Error) Scene missing: %s" % path)
		return
	var packed: PackedScene = load(path)
	if packed == null:
		scene_change_queued = false
		confirm_button.disabled = false
		gs.log_message("ERROR | Scene load failed path %s week %d round %d" % [
			path,
			gs.current_week,
			gs.week_round,
		])
		_show_info("(Error) Scene load failed.")
		return
	var err: int = get_tree().change_scene_to_packed(packed)
	if err != OK:
		scene_change_queued = false
		confirm_button.disabled = false
		gs.log_message("ERROR | Change scene failed (%d) week %d round %d passed %s total %d target %d path %s" % [
			err,
			gs.current_week,
			gs.week_round,
			str(passed),
			gs.week_total_devotion,
			target,
			path,
		])
		_show_info("(Error) Failed to change scene (%d). Check logs." % err)

func _on_doctrine_pressed() -> void:
	if gs.doctrine_used_this_play or confirmed:
		return
	var selected_indices: Array[int] = []
	for i in range(card_buttons.size()):
		if card_buttons[i].button_pressed:
			selected_indices.append(i)
	if selected_indices.size() != 1:
		_show_info("(Info) Select exactly 1 card for Doctrine Action.")
		return
	var idx: int = int(selected_indices[0])
	var follower: Dictionary = gs.current_hand[idx]
	if gs.selected_doctrine == "FLESH":
		if follower["trait"] == "BLOOD":
			_show_info("(Info) Doctrine (Flesh): Already BLOOD.")
		else:
			follower["trait"] = "BLOOD"
			gs.current_hand[idx] = follower
			_show_info("Doctrine (Flesh): Converted #%d to BLOOD." % [idx + 1])
			gs.doctrine_used_this_play = true
	elif gs.selected_doctrine == "RUIN":
		var new_tier: int = min(6, int(follower["tier"]) + 1)
		follower["tier"] = new_tier
		follower["exhausted"] = true
		gs.current_hand[idx] = follower
		card_buttons[idx].button_pressed = false
		_show_info("Doctrine (Ruin): Refined #%d to T%d (exhausted)." % [idx + 1, new_tier])
		gs.doctrine_used_this_play = true
	elif gs.selected_doctrine == "SILENCE":
		gs.current_hand[idx] = gs.make_random_follower("random")
		card_buttons[idx].button_pressed = false
		_show_info("Doctrine (Silence): Banished #%d and replaced it." % [idx + 1])
		gs.doctrine_used_this_play = true
	_update_card_visual(idx)
	_update_breakdown_preview()
	_update_confirm_state()

func _get_required_sacrifice_count() -> int:
	if gs.contract_allow_four:
		return 4
	return 3

func _on_contract_toggle() -> void:
	if gs.relic_inventory["Black Contract"] <= 0:
		return
	if gs.contract_used_week == gs.current_week:
		return
	gs.contract_allow_four = not gs.contract_allow_four
	_update_contract_ui()
	_update_confirm_state()

func _update_contract_ui() -> void:
	if gs.relic_inventory["Black Contract"] <= 0:
		contract_toggle.visible = false
		return
	contract_toggle.visible = true
	var used: bool = gs.contract_used_week == gs.current_week
	contract_toggle.disabled = used
	var state: String = "ON" if gs.contract_allow_four else "OFF"
	var used_text: String = "1/1" if used else "0/1"
	contract_toggle.text = "Contract: 4 (%s) %s" % [used_text, state]

func _on_ritual_use() -> void:
	if gs.ritual_card_slot == "":
		return
	gs.ritual_card_active = gs.ritual_card_slot
	gs.ritual_card_slot = ""
	_update_ritual_ui()
	_update_breakdown_preview()

func _update_ritual_ui() -> void:
	var has_relic: bool = gs.relic_inventory["Scarlet Planetarium"] > 0
	ritual_use.visible = true
	if gs.ritual_card_slot == "":
		ritual_use.disabled = true
		if has_relic:
			ritual_use.text = "Use Ritual"
		else:
			ritual_use.text = "Rituals Locked"
	else:
		ritual_use.disabled = false
		ritual_use.text = "Use Ritual: %s" % gs.ritual_card_slot

func _show_info(msg: String) -> void:
	if gs.last_breakdown_text == "":
		breakdown_text.text = msg
	else:
		breakdown_text.text = msg + "\n\n" + gs.last_breakdown_text

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
		stripe.color = _get_trait_color(f["trait"])
		hbox.add_child(stripe)
		var label: Label = Label.new()
		label.text = "%s  T%d  %s  (%s #%d)" % [
			f["trait"],
			int(f["tier"]),
			_get_trait_display(str(f.get("trait_id", ""))),
			f["origin_tag"],
			int(f["id"]),
		]
		var trait_rarity: String = str(gs._trait_rarity(str(f.get("trait_id", ""))))
		if trait_rarity == "RARE":
			label.add_theme_color_override("font_color", Color(0.85, 0.7, 0.2))
		elif trait_rarity == "LEGENDARY":
			label.add_theme_color_override("font_color", Color(0.95, 0.55, 0.2))
		hbox.add_child(label)
		pool_list.add_child(row)

func _on_pool_breed_pressed() -> void:
	_refresh_pool_overlay()

func _sacrifice_summary(selected_indices: Array[int]) -> String:
	var parts: Array[String] = []
	for i in selected_indices:
		if i >= 0 and i < gs.current_hand.size():
			var f: Dictionary = gs.current_hand[i]
			parts.append("#%d %s(%d)" % [i + 1, f["trait"], f["tier"]])
	if parts.is_empty():
		return "(none)"
	return ", ".join(parts)
