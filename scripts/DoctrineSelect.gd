extends Control

@onready var flesh_button: Button = $Center/Panel/VBox/Cards/Flesh/FleshVBox/FleshButton
@onready var ruin_button: Button = $Center/Panel/VBox/Cards/Ruin/RuinVBox/RuinButton
@onready var silence_button: Button = $Center/Panel/VBox/Cards/Silence/SilenceVBox/SilenceButton
@onready var gs: Node = get_node("/root/GameState")

func _ready() -> void:
	flesh_button.pressed.connect(_on_flesh_pressed)
	ruin_button.pressed.connect(_on_ruin_pressed)
	silence_button.pressed.connect(_on_silence_pressed)

func _on_flesh_pressed() -> void:
	_start_run("FLESH")

func _on_ruin_pressed() -> void:
	_start_run("RUIN")

func _on_silence_pressed() -> void:
	_start_run("SILENCE")

func _start_run(doctrine: String) -> void:
	gs.reset_run()
	gs.selected_doctrine = doctrine
	gs.init_starting_pool(doctrine)
	gs.start_week()
	get_tree().change_scene_to_file("res://scenes/RunGame.tscn")
