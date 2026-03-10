extends Control

@onready var back_button: Button = $Root/TopRow/BackButton
@onready var refresh_button: Button = $Root/TopRow/RefreshButton
@onready var browser: CodexBrowser = $Root/CodexBrowser

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	refresh_button.pressed.connect(_on_refresh_pressed)
	browser.compact_mode = false
	browser.refresh_codex()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_refresh_pressed() -> void:
	browser.refresh_codex()
