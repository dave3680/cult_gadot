extends Button

var follower_id: int = -1

func _get_drag_data(_at_position: Vector2) -> Variant:
	if follower_id < 0:
		return null
	var preview: Label = Label.new()
	preview.text = text
	set_drag_preview(preview)
	return {"follower_id": follower_id}
