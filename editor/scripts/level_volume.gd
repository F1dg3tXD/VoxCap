extends Node3D

enum TriggerMode { AUTO, PRESS, HOLD }

@export_file("*.tscn") var target_scene: String
@export var trigger_mode: TriggerMode = TriggerMode.AUTO
@export var hold_duration: float = 1.5
@export var input_action: String = "trigger_click"

@onready var area: Area3D = $Area3D
var _controller: XRController3D = null

var player_in_area: Node3D = null
var hold_timer: float = 0.0
var triggered: bool = false

func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	# Delay detection slightly
	await get_tree().process_frame
	_controller = XRHelpers.get_xr_controller(self)

func _process(delta):
	if triggered or not player_in_area or _controller == null:
		hold_timer = 0.0
		return

	match trigger_mode:
		TriggerMode.AUTO:
			load_target_scene()

		TriggerMode.PRESS:
			if _controller.is_button_pressed(input_action) and hold_timer == 0.0:
				hold_timer = 0.01  # Small non-zero value to detect "just pressed"
				load_target_scene()
			elif not _controller.is_button_pressed(input_action):
				hold_timer = 0.0

		TriggerMode.HOLD:
			if _controller.is_button_pressed(input_action):
				hold_timer += delta
				if hold_timer >= hold_duration:
					load_target_scene()
			else:
				hold_timer = 0.0

func _on_body_entered(body):
	if body.collision_layer & (1 << 19):  # Layer 20 (index 19)
		player_in_area = body

func _on_body_exited(body):
	if body == player_in_area:
		player_in_area = null
		hold_timer = 0.0

func load_target_scene():
	if triggered or not target_scene or target_scene == "":
		return
	triggered = true

	var scene_base := XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
	if not scene_base:
		push_error("XRToolsSceneBase not found in parent hierarchy!")
		return

	scene_base.load_scene(target_scene, "player_start") # <-- spawn at "player_start"
