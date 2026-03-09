extends Control

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

func _ready() -> void:
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

	if gs.current_hand.size() != 6:
		gs.draw_hand_from_pool()

	_refresh_ui()

func _refresh_ui() -> void:
	week_label.text = "Week %d/5 (Round %d/2)" % [gs.current_week, gs.week_round]
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
		_:
			return "Unknown trait."

func _get_trait_display(trait_id: String) -> String:
	if trait_id == "":
		return "None"
	if not gs.TRAIT_REGISTRY.has(trait_id):
		return trait_id
	var info: Dictionary = gs.TRAIT_REGISTRY[trait_id]
	var rarity: String = str(info.get("rarity", ""))
	var name: String = str(info.get("name", trait_id))
	var mark: String = "[C]" if rarity == "COMMON" else "[R]"
	return "%s %s" % [mark, name]

func _get_trait_description_from_registry(trait_id: String) -> String:
	if trait_id == "":
		return "Trait: None."
	if not gs.TRAIT_REGISTRY.has(trait_id):
		return "Trait: " + trait_id
	var info: Dictionary = gs.TRAIT_REGISTRY[trait_id]
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
	if trait_id != "" and gs.TRAIT_REGISTRY.has(trait_id) and str(gs.TRAIT_REGISTRY[trait_id].get("rarity", "")) == "RARE":
		font_color = Color(0.85, 0.7, 0.2)
	btn.add_theme_color_override("font_color", font_color)
	btn.add_theme_color_override("font_pressed_color", font_color)
	var tooltip_lines: Array[String] = []
	tooltip_lines.append(_get_trait_description(trait_name))
	if trait_id != "":
		tooltip_lines.append(_get_trait_description_from_registry(trait_id))
	btn.tooltip_text = "\n".join(tooltip_lines)

func _format_preview_breakdown(preview: Dictionary, remaining_target: int) -> String:
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
	if confirmed:
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
	gs.week_total_devotion += int(result["final_devotion"])
	var overflow_target: int = gs.get_week_target(gs.current_week)
	var overflow_now: int = max(0, gs.week_total_devotion - overflow_target)
	var overflow_delta: int = overflow_now - gs.week_overflow_blood_granted
	if overflow_delta > 0:
		gs.week_overflow_blood_granted += overflow_delta
		gs.add_blood(overflow_delta)
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
	if overflow_delta > 0:
		gs.last_breakdown_text += "\nOverflow Bonus: +%d Blood" % overflow_delta
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
	gs.resolve_play_and_update_pool(last_selected_indices)
	var target: int = gs.get_week_target(gs.current_week)
	if gs.week_total_devotion >= target:
		if gs.week_round == 1:
			var before_round_bonus: int = gs.blood_currency
			gs.add_blood(20)
			gs.last_breakdown_text += "\nEarly Win Bonus: +20 Blood (Blood %d -> %d)" % [
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
		if gs.current_week >= 5:
			get_tree().change_scene_to_file("res://scenes/Victory.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/Shop.tscn")
		return

	if gs.week_round == 1:
		gs.week_round = 2
		confirmed = false
		confirmed_pass = false
		last_selected_indices = []
		gs.reset_doctrine_for_play()
		gs.draw_hand_from_pool()
		_on_clear_pressed()
		_refresh_ui()
		return

	if gs.week_round == 2:
		get_tree().change_scene_to_file("res://scenes/GameOver.tscn")

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
	if not has_relic and gs.ritual_card_slot == "":
		ritual_use.visible = false
		return
	ritual_use.visible = true
	if gs.ritual_card_slot == "":
		ritual_use.disabled = true
		ritual_use.text = "Use Ritual"
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
	pool_summary.text = "Pool Size: %d | Blood: %d  Bone: %d  Void: %d | Avg Tier: %.1f" % [
		summary["total"],
		summary["blood"],
		summary["bone"],
		summary["void"],
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
		if str(f.get("trait_rarity", "")) == "RARE":
			label.add_theme_color_override("font_color", Color(0.85, 0.7, 0.2))
		hbox.add_child(label)
		pool_list.add_child(row)

func _on_pool_breed_pressed() -> void:
	gs.perform_weekly_breeding(gs.current_week)
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
