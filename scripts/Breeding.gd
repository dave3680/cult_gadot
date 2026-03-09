extends Control

@onready var summary_label: Label = $Center/Panel/VBox/Summary
@onready var title_label: Label = $Center/Panel/VBox/Title
@onready var continue_button: Button = $Center/Panel/VBox/ContinueButton
@onready var gs: Node = get_node("/root/GameState")

func _ready() -> void:
	title_label.text = "Nest Update"
	var lines: Array[String] = []
	if gs.last_nest_results.is_empty():
		lines.append("No active nests.")
	else:
		for item in gs.last_nest_results:
			var nest_no: int = int(item.get("nest", 0))
			var a_id: int = int(item.get("a_id", -1))
			var b_id: int = int(item.get("b_id", -1))
			var a_text: String = _follower_text(a_id)
			var b_text: String = _follower_text(b_id)
			lines.append("Nest %d" % nest_no)
			lines.append("Parents: %s + %s" % [a_text, b_text])
			if bool(item.get("success", false)):
				var baby: Dictionary = item.get("baby", {})
				lines.append("New Follower: %s" % _follower_desc(baby))
			else:
				lines.append("Outcome: %s" % str(item.get("reason", "no offspring")))
			lines.append("")
	if gs.last_breeding_summary != "":
		lines.append(gs.last_breeding_summary)
	summary_label.text = "\n".join(lines)
	continue_button.pressed.connect(_on_continue_pressed)

func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Shop.tscn")

func _follower_text(follower_id: int) -> String:
	if follower_id < 0:
		return "(empty)"
	for f in gs.pool:
		if int(f.get("id", -1)) == follower_id:
			return _follower_desc(f)
	return "(missing #%d)" % follower_id

func _follower_desc(f: Dictionary) -> String:
	if f.is_empty():
		return "(none)"
	return "%s T%d #%d" % [str(f.get("trait", "")), int(f.get("tier", 0)), int(f.get("id", -1))]
