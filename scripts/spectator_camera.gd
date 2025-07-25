extends Camera3D

enum HeightMode { LEVEL, LOWER, HIGHER }

@export_node_path("Node3D") var target_path: NodePath
@export var follow_distance: float = 5.0
@export var height_offset: float = 2.0
@export var height_mode: HeightMode = HeightMode.LEVEL
@export var position_lerp_speed: float = 5.0
@export var look_lerp_speed: float = 5.0

var target: Node3D = null

func _ready():
	if target_path != NodePath(""):
		target = get_node_or_null(target_path)
	if target == null:
		push_warning("CameraFollow: Target not assigned or not found.")

func _process(delta):
	if target == null:
		return

	var target_pos = target.global_transform.origin
	var direction = (global_transform.origin - target_pos).normalized()
	direction.y = 0.0  # keep camera direction horizontal when calculating distance

	var desired_pos = target_pos + direction * follow_distance

	match height_mode:
		HeightMode.LEVEL:
			desired_pos.y = target_pos.y + height_offset
		HeightMode.LOWER:
			desired_pos.y = target_pos.y - height_offset
		HeightMode.HIGHER:
			desired_pos.y = target_pos.y + abs(height_offset)

	global_transform.origin = global_transform.origin.lerp(desired_pos, delta * position_lerp_speed)

	# Look at target with smooth rotation
	var current_basis = global_transform.basis
	var target_basis = Transform3D().looking_at(target_pos - global_transform.origin, Vector3.UP).basis
	global_transform.basis = current_basis.slerp(target_basis, delta * look_lerp_speed)
