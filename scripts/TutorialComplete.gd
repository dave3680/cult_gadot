extends Control

@onready var summary_label: Label = $Center/Panel/VBox/Summary
@onready var start_run_button: Button = $Center/Panel/VBox/StartRunButton
@onready var menu_button: Button = $Center/Panel/VBox/MenuButton
@onready var gs: Node = get_node("/root/GameState")

func _ready() -> void:
	start_run_button.pressed.connect(_on_start_run_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	summary_label.text = "You have completed the tutorial.\n\nYou now understand sacrifice flow, relic economy, traits, nests, and lineage compounding."

func _on_start_run_pressed() -> void:
	gs.end_tutorial_run()
	get_tree().change_scene_to_file("res://scenes/DoctrineSelect.tscn")

func _on_menu_pressed() -> void:
	gs.end_tutorial_run()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
