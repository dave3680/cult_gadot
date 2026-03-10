extends Control
class_name CodexBrowser

signal close_requested

@export var compact_mode: bool = false

var gs: Node

var title_label: Label
var progress_label: Label
var search_edit: LineEdit
var visibility_filter: OptionButton
var tab_container: TabContainer
var refresh_button: Button
var close_button: Button

var relic_list: ItemList
var trait_list: ItemList
var combo_list: ItemList
var relic_detail: Label
var trait_detail: Label
var combo_detail: Label
var stats_detail: Label

var relic_entries: Array[Dictionary] = []
var trait_entries: Array[Dictionary] = []
var combo_entries: Array[Dictionary] = []

var visible_relic_entries: Array[Dictionary] = []
var visible_trait_entries: Array[Dictionary] = []
var visible_combo_entries: Array[Dictionary] = []
var _ui_ready: bool = false
var _ui_building: bool = false
var _ui_ensuring: bool = false

func _ready() -> void:
	if has_node("/root/GameState"):
		gs = get_node("/root/GameState")
	_ensure_ui()
	call_deferred("refresh_codex")

func refresh_codex() -> void:
	if _ui_building:
		return
	if gs == null and has_node("/root/GameState"):
		gs = get_node("/root/GameState")
	if gs == null:
		return
	_ensure_ui()
	if not _ui_ready:
		return
	_rebuild_entries()
	_refresh_progress()
	_refresh_active_tab()

func _ensure_ui() -> void:
	if _ui_ensuring:
		return
	_ui_ensuring = true
	if _ui_building:
		_ui_ensuring = false
		return
	if _has_valid_ui_refs():
		_ui_ready = true
		_ui_ensuring = false
		return
	_ui_ready = false
	_ui_building = true
	_clear_ui_refs()
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_build_ui()
	_ui_building = false
	_ui_ready = _has_valid_ui_refs()
	_ui_ensuring = false

func _clear_ui_refs() -> void:
	title_label = null
	progress_label = null
	search_edit = null
	visibility_filter = null
	tab_container = null
	refresh_button = null
	close_button = null
	relic_list = null
	trait_list = null
	combo_list = null
	relic_detail = null
	trait_detail = null
	combo_detail = null
	stats_detail = null

func _has_valid_ui_refs() -> bool:
	return is_instance_valid(tab_container) \
		and is_instance_valid(relic_list) \
		and is_instance_valid(trait_list) \
		and is_instance_valid(combo_list) \
		and is_instance_valid(relic_detail) \
		and is_instance_valid(trait_detail) \
		and is_instance_valid(combo_detail) \
		and is_instance_valid(stats_detail)

func _build_ui() -> void:
	if _ui_ready:
		return
	anchors_preset = Control.PRESET_FULL_RECT
	anchor_right = 1.0
	anchor_bottom = 1.0

	var margin := MarginContainer.new()
	margin.anchors_preset = Control.PRESET_FULL_RECT
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 14)
	add_child(margin)

	var root_vbox := VBoxContainer.new()
	root_vbox.anchors_preset = Control.PRESET_FULL_RECT
	root_vbox.anchor_right = 1.0
	root_vbox.anchor_bottom = 1.0
	root_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(root_vbox)

	var top_row := HBoxContainer.new()
	top_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_vbox.add_child(top_row)

	title_label = Label.new()
	title_label.text = "Codex"
	title_label.add_theme_font_size_override("font_size", 26 if not compact_mode else 20)
	top_row.add_child(title_label)

	progress_label = Label.new()
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	progress_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(progress_label)

	search_edit = LineEdit.new()
	search_edit.placeholder_text = "Search name..."
	search_edit.custom_minimum_size = Vector2(220 if compact_mode else 280, 0)
	search_edit.text_changed.connect(_on_filter_changed)
	top_row.add_child(search_edit)

	visibility_filter = OptionButton.new()
	visibility_filter.add_item("All")
	visibility_filter.add_item("Discovered")
	visibility_filter.add_item("Undiscovered")
	visibility_filter.item_selected.connect(_on_filter_mode_changed)
	top_row.add_child(visibility_filter)

	refresh_button = Button.new()
	refresh_button.text = "Refresh"
	refresh_button.pressed.connect(_on_refresh_pressed)
	top_row.add_child(refresh_button)

	close_button = Button.new()
	close_button.text = "Close"
	close_button.visible = compact_mode
	close_button.pressed.connect(func() -> void:
		close_requested.emit()
	)
	top_row.add_child(close_button)

	var sep := HSeparator.new()
	root_vbox.add_child(sep)

	tab_container = TabContainer.new()
	tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tab_container.tab_changed.connect(_on_tab_changed)
	root_vbox.add_child(tab_container)

	var relic_tab := _build_split_tab("Relics")
	relic_list = relic_tab["list"]
	relic_detail = relic_tab["detail"]
	relic_list.item_selected.connect(_on_relic_selected)

	var trait_tab := _build_split_tab("Traits")
	trait_list = trait_tab["list"]
	trait_detail = trait_tab["detail"]
	trait_list.item_selected.connect(_on_trait_selected)

	var combo_tab := _build_split_tab("Combo Traits")
	combo_list = combo_tab["list"]
	combo_detail = combo_tab["detail"]
	combo_list.item_selected.connect(_on_combo_selected)

	var stats_tab := VBoxContainer.new()
	stats_tab.name = "Stats"
	stats_tab.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stats_tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats_detail = Label.new()
	stats_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stats_detail.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	stats_detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stats_tab.add_child(stats_detail)
	tab_container.add_child(stats_tab)

func _build_split_tab(tab_name: String) -> Dictionary:
	var split := HSplitContainer.new()
	split.name = tab_name
	split.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.split_offset = 360 if not compact_mode else 300

	var list := ItemList.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list.select_mode = ItemList.SELECT_SINGLE
	split.add_child(list)

	var detail_panel := PanelContainer.new()
	detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_child(detail_panel)

	var detail_margin := MarginContainer.new()
	detail_margin.anchors_preset = Control.PRESET_FULL_RECT
	detail_margin.anchor_right = 1.0
	detail_margin.anchor_bottom = 1.0
	detail_margin.add_theme_constant_override("margin_left", 12)
	detail_margin.add_theme_constant_override("margin_top", 12)
	detail_margin.add_theme_constant_override("margin_right", 12)
	detail_margin.add_theme_constant_override("margin_bottom", 12)
	detail_panel.add_child(detail_margin)

	var detail := Label.new()
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_margin.add_child(detail)

	tab_container.add_child(split)
	return {"list": list, "detail": detail}

func _rebuild_entries() -> void:
	relic_entries.clear()
	for relic_name in gs.RELICS:
		var name: String = str(relic_name)
		if not gs.RELIC_DEFS.has(name):
			continue
		var def: Dictionary = gs.RELIC_DEFS[name]
		relic_entries.append({
			"id": name,
			"name": name,
			"rarity": str(def.get("rarity", "COMMON")),
			"category": str(def.get("category", "RELIC")),
			"seen": bool(gs.codex_has_relic_seen(name)),
			"unlocked": bool(gs.codex_is_relic_unlocked(name)),
		})
	relic_entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return str(a.get("name", "")) < str(b.get("name", ""))
	)

	trait_entries.clear()
	for trait_id in gs.TRAIT_REGISTRY.keys():
		var tid: String = str(trait_id)
		var info: Dictionary = gs.TRAIT_REGISTRY[tid]
		trait_entries.append({
			"id": tid,
			"name": str(info.get("name", tid)),
			"rarity": str(info.get("rarity", "COMMON")),
			"type": str(info.get("type", "")),
			"seen": bool(gs.codex_has_trait_seen(tid)),
		})
	trait_entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return str(a.get("name", "")) < str(b.get("name", ""))
	)

	combo_entries.clear()
	var catalog: Dictionary = gs.get_combo_trait_catalog()
	for combo_id in catalog.keys():
		var cid: String = str(combo_id)
		var info: Dictionary = catalog[cid]
		combo_entries.append({
			"id": cid,
			"name": str(info.get("name", cid)),
			"rarity": str(info.get("rarity", "RARE")),
			"seen": bool(gs.codex_has_trait_seen(cid)),
			"bred": bool(gs.codex_has_combo_trait_bred(cid)),
		})
	combo_entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return str(a.get("name", "")) < str(b.get("name", ""))
	)

func _refresh_progress() -> void:
	if not is_instance_valid(progress_label):
		return
	var counts: Dictionary = gs.codex_get_counts()
	progress_label.text = "Relics unlocked %d/%d | Traits seen %d/%d | Combos seen %d/%d | bred %d" % [
		int(counts.get("relic_unlocked", 0)),
		int(counts.get("relic_total", 0)),
		int(counts.get("trait_seen", 0)),
		int(counts.get("trait_total", 0)),
		int(counts.get("combo_seen", 0)),
		int(counts.get("combo_total", 0)),
		int(counts.get("combo_bred", 0)),
	]

func _refresh_active_tab() -> void:
	if not _ui_ready:
		_ensure_ui()
		if not _ui_ready:
			return
	if not is_instance_valid(tab_container):
		return
	var tab: int = tab_container.current_tab
	if tab == 0:
		_populate_relic_list()
	elif tab == 1:
		_populate_trait_list()
	elif tab == 2:
		_populate_combo_list()
	_refresh_stats()

func _entry_matches_filters(entry: Dictionary, discovered: bool) -> bool:
	var query: String = ""
	if is_instance_valid(search_edit):
		query = search_edit.text.strip_edges().to_lower()
	if query != "":
		var entry_name: String = str(entry.get("name", "")).to_lower()
		if entry_name.find(query) < 0:
			return false
	var mode: int = 0
	if is_instance_valid(visibility_filter):
		mode = visibility_filter.selected
	if mode == 1 and not discovered:
		return false
	if mode == 2 and discovered:
		return false
	return true

func _populate_relic_list() -> void:
	if not is_instance_valid(relic_list):
		return
	relic_list.clear()
	visible_relic_entries.clear()
	for entry in relic_entries:
		var seen: bool = bool(entry.get("seen", false))
		if not _entry_matches_filters(entry, seen):
			continue
		visible_relic_entries.append(entry)
		var unlocked: bool = bool(entry.get("unlocked", false))
		var status: String = " "
		if unlocked:
			status = "U"
		elif seen:
			status = "S"
		var label: String = "[%s] %s (%s)" % [status, str(entry.get("name", "")), str(entry.get("rarity", ""))]
		relic_list.add_item(label)
	if visible_relic_entries.is_empty():
		relic_detail.text = "No relic entries match current filters."
		return
	relic_list.select(0)
	_on_relic_selected(0)

func _populate_trait_list() -> void:
	if not is_instance_valid(trait_list):
		return
	trait_list.clear()
	visible_trait_entries.clear()
	for entry in trait_entries:
		var seen: bool = bool(entry.get("seen", false))
		if not _entry_matches_filters(entry, seen):
			continue
		visible_trait_entries.append(entry)
		var status: String = "[S]" if seen else "[ ]"
		var label: String = "%s %s (%s)" % [status, str(entry.get("name", "")), str(entry.get("rarity", ""))]
		trait_list.add_item(label)
	if visible_trait_entries.is_empty():
		trait_detail.text = "No trait entries match current filters."
		return
	trait_list.select(0)
	_on_trait_selected(0)

func _populate_combo_list() -> void:
	if not is_instance_valid(combo_list):
		return
	combo_list.clear()
	visible_combo_entries.clear()
	for entry in combo_entries:
		var seen: bool = bool(entry.get("seen", false))
		if not _entry_matches_filters(entry, seen):
			continue
		visible_combo_entries.append(entry)
		var bred: bool = bool(entry.get("bred", false))
		var status: String = "[B]" if bred else ("[S]" if seen else "[ ]")
		var label: String = "%s %s (%s)" % [status, str(entry.get("name", "")), str(entry.get("rarity", ""))]
		combo_list.add_item(label)
	if visible_combo_entries.is_empty():
		combo_detail.text = "No combo entries match current filters."
		return
	combo_list.select(0)
	_on_combo_selected(0)

func _refresh_stats() -> void:
	if not is_instance_valid(stats_detail):
		return
	var counts: Dictionary = gs.codex_get_counts()
	stats_detail.text = "Progress\n\nRelics seen: %d / %d\nRelics unlocked (purchased): %d / %d\nTraits seen: %d / %d\nCombo traits seen: %d / %d\nCombo traits bred: %d / %d\n\nLegend\n[U] = purchased at least once\n[S] = seen/discovered\n[B] = combo trait bred" % [
		int(counts.get("relic_seen", 0)),
		int(counts.get("relic_total", 0)),
		int(counts.get("relic_unlocked", 0)),
		int(counts.get("relic_total", 0)),
		int(counts.get("trait_seen", 0)),
		int(counts.get("trait_total", 0)),
		int(counts.get("combo_seen", 0)),
		int(counts.get("combo_total", 0)),
		int(counts.get("combo_bred", 0)),
		int(counts.get("combo_total", 0)),
	]

func _on_relic_selected(index: int) -> void:
	if index < 0 or index >= visible_relic_entries.size():
		return
	var entry: Dictionary = visible_relic_entries[index]
	var name: String = str(entry.get("id", ""))
	var seen: bool = bool(entry.get("seen", false))
	var unlocked: bool = bool(entry.get("unlocked", false))
	var purchases: int = int(gs.codex_get_relic_purchase_count(name))
	var desc: String = gs.codex_get_relic_description(name)
	relic_detail.text = "%s\n\nRarity: %s\nCategory: %s\nSeen in shop: %s\nUnlocked: %s\nTimes purchased: %d\n\nDescription\n%s" % [
		name,
		str(entry.get("rarity", "")),
		str(entry.get("category", "")),
		"Yes" if seen else "No",
		"Yes" if unlocked else "No",
		purchases,
		desc,
	]

func _on_trait_selected(index: int) -> void:
	if index < 0 or index >= visible_trait_entries.size():
		return
	var entry: Dictionary = visible_trait_entries[index]
	var trait_id: String = str(entry.get("id", ""))
	var seen: bool = bool(entry.get("seen", false))
	trait_detail.text = "%s\n\nID: %s\nRarity: %s\nType: %s\nSeen: %s\n\nDescription\n%s" % [
		str(entry.get("name", "")),
		trait_id,
		str(entry.get("rarity", "")),
		str(entry.get("type", "")),
		"Yes" if seen else "No",
		gs.codex_get_trait_description(trait_id),
	]

func _on_combo_selected(index: int) -> void:
	if index < 0 or index >= visible_combo_entries.size():
		return
	var entry: Dictionary = visible_combo_entries[index]
	var combo_id: String = str(entry.get("id", ""))
	var info: Dictionary = gs.get_combo_trait(combo_id)
	var parents: Array = info.get("parents", [])
	var parent_line: String = "(unknown)"
	if parents.size() >= 2:
		parent_line = "%s + %s" % [str(parents[0]), str(parents[1])]
	var seen: bool = bool(entry.get("seen", false))
	var bred: bool = bool(entry.get("bred", false))
	combo_detail.text = "%s\n\nID: %s\nRarity: %s\nSeen: %s\nBred: %s\nParents: %s\n\nDescription\n%s" % [
		str(entry.get("name", "")),
		combo_id,
		str(entry.get("rarity", "")),
		"Yes" if seen else "No",
		"Yes" if bred else "No",
		parent_line,
		gs.codex_get_trait_description(combo_id),
	]

func _on_filter_changed(_new_text: String) -> void:
	if _ui_building:
		return
	_refresh_active_tab()

func _on_filter_mode_changed(_index: int) -> void:
	if _ui_building:
		return
	_refresh_active_tab()

func _on_tab_changed(_tab: int) -> void:
	if _ui_building:
		return
	_refresh_active_tab()

func _on_refresh_pressed() -> void:
	refresh_codex()
