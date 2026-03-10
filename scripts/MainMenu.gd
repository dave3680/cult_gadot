extends Control

@onready var start_button: Button = $Center/Panel/VBox/StartButton
@onready var tutorial_button: Button = $Center/Panel/VBox/TutorialButton
@onready var settings_button: Button = $Center/Panel/VBox/SettingsButton
@onready var codex_button: Button = $Center/Panel/VBox/CodexButton
@onready var settings_popup: PopupPanel = $SettingsPopup
@onready var exit_button: Button = $SettingsPopup/PopupVBox/ExitButton
@onready var close_button: Button = $SettingsPopup/PopupVBox/CloseButton
@onready var gs: Node = get_node("/root/GameState")

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	tutorial_button.pressed.connect(_on_tutorial_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	codex_button.pressed.connect(_on_codex_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	close_button.pressed.connect(_on_close_settings_pressed)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/DoctrineSelect.tscn")

func _on_tutorial_pressed() -> void:
	gs.start_tutorial_run()
	get_tree().change_scene_to_file("res://scenes/RunGame.tscn")

func _on_settings_pressed() -> void:
	settings_popup.popup_centered()

func _on_codex_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/CodexMenu.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_close_settings_pressed() -> void:
	settings_popup.hide()
