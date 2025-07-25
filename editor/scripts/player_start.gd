extends Node3D

@export var player_scene: PackedScene
@export var auto_spawn_player: bool = true

@onready var debug_visuals: Node = $debug

func _ready():
	debug_draw(false)

	if Engine.is_editor_hint():
		return

	if not auto_spawn_player:
		return

	if player_scene == null:
		push_error("PlayerStart: 'player_scene' is not assigned.")
		return

	var player_instance = player_scene.instantiate()
	get_tree().current_scene.call_deferred("add_child", player_instance)
	player_instance.global_transform = global_transform

func debug_draw(enabled: bool = true) -> void:
	if debug_visuals:
		debug_visuals.visible = enabled

func _enter_tree():
	if Engine.is_editor_hint():
		debug_draw(true)

func _exit_tree():
	if Engine.is_editor_hint():
		debug_draw(false)
