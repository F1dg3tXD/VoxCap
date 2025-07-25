extends Node3D

enum TriggerMode { AUTO, PRESS, HOLD }

@export_node_path("Node3D") var target_node_path: NodePath
@export var trigger_mode: TriggerMode = TriggerMode.AUTO
@export var hold_duration: float = 1.5
@export var input_action: String = "trigger_click"

var _controller: XRController3D = null
var hold_timer: float = 0.0
var triggered: bool = false
var target_node: Node3D = null

func _ready():
	_controller = XRHelpers.get_xr_controller(self)
	if target_node_path != NodePath(""):
		target_node = get_node(target_node_path)
	else:
		push_error("No target_node_path set on %s" % name)

func _process(delta):
	if triggered or _controller == null or target_node == null:
		hold_timer = 0.0
		return

	match trigger_mode:
		TriggerMode.AUTO:
			toggle_visibility()

		TriggerMode.PRESS:
			if _controller.is_button_pressed(input_action) and hold_timer == 0.0:
				hold_timer = 0.01  # just pressed
				toggle_visibility()
			elif not _controller.is_button_pressed(input_action):
				hold_timer = 0.0

		TriggerMode.HOLD:
			if _controller.is_button_pressed(input_action):
				hold_timer += delta
				if hold_timer >= hold_duration:
					toggle_visibility()
			else:
				hold_timer = 0.0

func toggle_visibility():
	if triggered:
		return
	triggered = true
	target_node.visible = not target_node.visible
