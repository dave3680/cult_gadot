extends CanvasLayer

const MENU_SCENE := "res://scenes/MainMenu.tscn"

var menu_button: Button
var popup: PopupPanel
var close_button: Button
var main_menu_button: Button
var exit_button: Button

func _ready() -> void:
	layer = 100
	_build_ui()
	get_tree().node_added.connect(_on_tree_node_added)
	_update_visibility()

func _on_tree_node_added(_node: Node) -> void:
	# Scene changes can briefly rebuild the tree; defer visibility update.
	call_deferred("_update_visibility")

func _build_ui() -> void:
	menu_button = Button.new()
	menu_button.text = "Menu"
	menu_button.custom_minimum_size = Vector2(96, 42)
	menu_button.anchor_left = 1.0
	menu_button.anchor_top = 0.0
	menu_button.anchor_right = 1.0
	menu_button.anchor_bottom = 0.0
	menu_button.offset_left = -112
	menu_button.offset_top = 12
	menu_button.offset_right = -12
	menu_button.offset_bottom = 54
	menu_button.pressed.connect(_on_menu_pressed)
	add_child(menu_button)

	popup = PopupPanel.new()
	popup.size = Vector2i(280, 220)
	add_child(popup)

	var vbox := VBoxContainer.new()
	vbox.anchors_preset = Control.PRESET_FULL_RECT
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
	vbox.grow_vertical = Control.GROW_DIRECTION_BOTH
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	popup.add_child(vbox)

	var title := Label.new()
	title.text = "Menu"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	main_menu_button = Button.new()
	main_menu_button.text = "Main Menu"
	main_menu_button.custom_minimum_size = Vector2(180, 44)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	vbox.add_child(main_menu_button)

	exit_button = Button.new()
	exit_button.text = "Exit Game"
	exit_button.custom_minimum_size = Vector2(180, 44)
	exit_button.pressed.connect(_on_exit_pressed)
	vbox.add_child(exit_button)

	close_button = Button.new()
	close_button.text = "Close"
	close_button.custom_minimum_size = Vector2(180, 38)
	close_button.pressed.connect(_on_close_pressed)
	vbox.add_child(close_button)

func _on_menu_pressed() -> void:
	popup.popup_centered()

func _on_main_menu_pressed() -> void:
	popup.hide()
	if get_tree().current_scene != null and get_tree().current_scene.scene_file_path == MENU_SCENE:
		return
	get_tree().change_scene_to_file(MENU_SCENE)

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_close_pressed() -> void:
	popup.hide()

func _update_visibility() -> void:
	# Keep button always visible during gameplay and menus after boot.
	visible = true
