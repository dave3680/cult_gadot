extends PanelContainer

signal follower_dropped(nest_index: int, parent_slot: int, follower_id: int)

var nest_index: int = 0
var parent_slot: int = 0

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.has("follower_id")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if typeof(data) != TYPE_DICTIONARY:
		return
	var follower_id: int = int(data.get("follower_id", -1))
	if follower_id < 0:
		return
	follower_dropped.emit(nest_index, parent_slot, follower_id)
