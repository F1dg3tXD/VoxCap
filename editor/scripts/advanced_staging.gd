extends Node3D

signal scene_loaded(new_scene: Node)

@export var auto_load_path: String
var current_scene: Node = null
var loading_env: Environment = null

@onready var stage_env: Node = $StageENV
@onready var stage_ui: CanvasLayer = $StageUI
@onready var world_env_node: WorldEnvironment = $StageENV/WorldEnvironment


func _ready():
	if auto_load_path != "":
		load_scene(auto_load_path)


func load_scene(scene_path: String):
	if current_scene:
		current_scene.queue_free()
		current_scene = null

	# Save the loading environment so we can restore it
	loading_env = world_env_node.environment

	# Show staging visuals
	stage_env.visible = true
	stage_ui.visible = true
	world_env_node.environment = loading_env

	var scene_resource = load(scene_path)
	if not scene_resource:
		push_error("Failed to load scene: %s" % scene_path)
		return

	current_scene = scene_resource.instantiate()
	add_child(current_scene)

	# Defer scene_loaded call if scene supports it
	if current_scene.has_method("scene_loaded"):
		current_scene.call_deferred("scene_loaded", self)

	# Hide staging visuals again
	stage_env.visible = false
	stage_ui.visible = false

	# Remove staging environment so current_scene takes over
	world_env_node.environment = null

	# Emit loaded signal
	emit_signal("scene_loaded", current_scene)
