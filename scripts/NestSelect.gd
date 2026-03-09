extends Control

const DraggablePoolRowScript = preload("res://scripts/DraggablePoolRow.gd")
const NestSlotScript = preload("res://scripts/NestSlot.gd")

@onready var pool_list: VBoxContainer = $RootVBox/MainHBox/PoolPanel/PoolVBox/PoolScroll/PoolList
@onready var nest_list: VBoxContainer = $RootVBox/MainHBox/NestPanel/NestVBox/NestList
@onready var summary_label: Label = $RootVBox/TopInfo
@onready var continue_button: Button = $RootVBox/BottomBar/ContinueButton
@onready var gs: Node = get_node("/root/GameState")

var nest_slots: Array[Dictionary] = []

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	_build_nests()
	_refresh_all()

func _build_nests() -> void:
	for child in nest_list.get_children():
		child.queue_free()
	nest_slots.clear()
	for i in range(gs.nests.size()):
		var row: HBoxContainer = HBoxContainer.new()
		nest_list.add_child(row)
		var nest_label: Label = Label.new()
		nest_label.text = "Nest %d" % [i + 1]
		nest_label.custom_minimum_size = Vector2(72, 0)
		row.add_child(nest_label)

		var slot_a := NestSlotScript.new()
		slot_a.nest_index = i
		slot_a.parent_slot = 0
		slot_a.custom_minimum_size = Vector2(240, 42)
		var text_a: Label = Label.new()
		text_a.name = "Text"
		slot_a.add_child(text_a)
		slot_a.follower_dropped.connect(_on_nest_slot_dropped)
		row.add_child(slot_a)

		var clear_a: Button = Button.new()
		clear_a.text = "Clear A"
		clear_a.pressed.connect(_on_clear_slot.bind(i, 0))
		row.add_child(clear_a)

		var slot_b := NestSlotScript.new()
		slot_b.nest_index = i
		slot_b.parent_slot = 1
		slot_b.custom_minimum_size = Vector2(240, 42)
		var text_b: Label = Label.new()
		text_b.name = "Text"
		slot_b.add_child(text_b)
		slot_b.follower_dropped.connect(_on_nest_slot_dropped)
		row.add_child(slot_b)

		var clear_b: Button = Button.new()
		clear_b.text = "Clear B"
		clear_b.pressed.connect(_on_clear_slot.bind(i, 1))
		row.add_child(clear_b)

		nest_slots.append({"a": slot_a, "b": slot_b})

func _refresh_all() -> void:
	_refresh_pool()
	_refresh_nests()
	var s: Dictionary = gs.pool_summary_counts()
	summary_label.text = "Assign parents for next week. Nested followers will not appear in battle. Pool: %d | Blood: %d Bone: %d Void: %d Soul: %d" % [
		s["total"], s["blood"], s["bone"], s["void"], s["soul"]
	]

func _refresh_pool() -> void:
	for child in pool_list.get_children():
		child.queue_free()
	for f in gs.pool:
		var row: Button = DraggablePoolRowScript.new()
		row.follower_id = int(f.get("id", -1))
		row.text = "%s T%d  %s  (%s #%d)%s" % [
			str(f.get("trait", "")),
			int(f.get("tier", 0)),
			_trait_display(str(f.get("trait_id", ""))),
			str(f.get("origin_tag", "")),
			int(f.get("id", -1)),
			(" [NESTED]" if gs.is_follower_nested(int(f.get("id", -1))) else ""),
		]
		var trait_rarity: String = str(gs._trait_rarity(str(f.get("trait_id", ""))))
		if trait_rarity == "RARE":
			row.add_theme_color_override("font_color", Color(0.85, 0.7, 0.2))
		elif trait_rarity == "LEGENDARY":
			row.add_theme_color_override("font_color", Color(0.95, 0.55, 0.2))
		var tooltip_lines: Array[String] = []
		tooltip_lines.append(_get_trait_description(str(f.get("trait", ""))))
		var tid: String = str(f.get("trait_id", ""))
		if tid != "":
			tooltip_lines.append(_get_trait_description_from_registry(tid))
		row.tooltip_text = "\n".join(tooltip_lines)
		pool_list.add_child(row)

func _refresh_nests() -> void:
	for i in range(gs.nests.size()):
		if i >= nest_slots.size():
			continue
		var entry: Dictionary = gs.nests[i]
		var a_id: int = int(entry.get("a", -1))
		var b_id: int = int(entry.get("b", -1))
		var slot_info: Dictionary = nest_slots[i]
		var a_slot: PanelContainer = slot_info["a"]
		var b_slot: PanelContainer = slot_info["b"]
		var a_text: Label = a_slot.get_node("Text")
		var b_text: Label = b_slot.get_node("Text")
		a_text.text = _slot_text(a_id, "A")
		b_text.text = _slot_text(b_id, "B")

func _slot_text(follower_id: int, label: String) -> String:
	if follower_id < 0:
		return "Parent %s: empty" % label
	for f in gs.pool:
		if int(f.get("id", -1)) == follower_id:
			return "Parent %s: %s T%d #%d" % [label, str(f.get("trait", "")), int(f.get("tier", 0)), follower_id]
	return "Parent %s: missing #%d" % [label, follower_id]

func _on_nest_slot_dropped(nest_index: int, parent_slot: int, follower_id: int) -> void:
	if gs.assign_follower_to_nest(nest_index, parent_slot, follower_id):
		_refresh_all()

func _on_clear_slot(nest_index: int, parent_slot: int) -> void:
	gs.clear_nest_slot(nest_index, parent_slot)
	_refresh_all()

func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/RunGame.tscn")

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
