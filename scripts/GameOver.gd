extends Control

@onready var restart_button: Button = $Center/Panel/VBox/RestartButton
@onready var gs: Node = get_node("/root/GameState")

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_pressed)

func _on_restart_pressed() -> void:
	gs.reset_run()
	get_tree().change_scene_to_file("res://scenes/DoctrineSelect.tscn")
