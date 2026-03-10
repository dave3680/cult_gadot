extends CanvasLayer

const MENU_SCENE := "res://scenes/MainMenu.tscn"
const CodexBrowserScript = preload("res://scripts/CodexBrowser.gd")
const LOCAL_MENU_SCENES := {
	"res://scenes/RunGame.tscn": true,
	"res://scenes/Shop.tscn": true,
	"res://scenes/NestSelect.tscn": true,
	"res://scenes/Breeding.tscn": true,
	"res://scenes/TutorialComplete.tscn": true,
}

var menu_button: Button
var popup: PopupPanel
var close_button: Button
var main_menu_button: Button
var codex_button: Button
var exit_button: Button
var codex_popup: PopupPanel
var codex_browser: Control

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

	codex_button = Button.new()
	codex_button.text = "Codex"
	codex_button.custom_minimum_size = Vector2(180, 44)
	codex_button.pressed.connect(_on_codex_pressed)
	vbox.add_child(codex_button)

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

	codex_popup = PopupPanel.new()
	codex_popup.size = Vector2i(1280, 760)
	add_child(codex_popup)
	codex_browser = CodexBrowserScript.new()
	codex_browser.set("compact_mode", true)
	codex_browser.anchors_preset = Control.PRESET_FULL_RECT
	codex_browser.anchor_right = 1.0
	codex_browser.anchor_bottom = 1.0
	codex_browser.connect("close_requested", Callable(self, "_on_close_codex"))
	codex_popup.add_child(codex_browser)

func _on_menu_pressed() -> void:
	open_menu()

func open_menu() -> void:
	popup.popup_centered()

func _on_main_menu_pressed() -> void:
	popup.hide()
	codex_popup.hide()
	if get_tree().current_scene != null and get_tree().current_scene.scene_file_path == MENU_SCENE:
		return
	get_tree().change_scene_to_file(MENU_SCENE)

func _on_codex_pressed() -> void:
	if codex_browser != null and codex_browser.has_method("refresh_codex"):
		codex_browser.call("refresh_codex")
	codex_popup.popup_centered_ratio(0.92)

func _on_close_codex() -> void:
	codex_popup.hide()

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_close_pressed() -> void:
	popup.hide()

func _update_visibility() -> void:
	# Keep button always visible during gameplay and menus after boot.
	visible = true
	var scene_path: String = ""
	if get_tree().current_scene != null:
		scene_path = get_tree().current_scene.scene_file_path
	if menu_button != null:
		menu_button.visible = not LOCAL_MENU_SCENES.has(scene_path)
