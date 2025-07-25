extends Control

@onready var color0_picker_button: ColorPickerButton = $HBoxContainer/Color0/ColorPickerButton
@onready var color1_picker_button: ColorPickerButton = $HBoxContainer/Color1/ColorPickerButton
@onready var color2_picker_button: ColorPickerButton = $HBoxContainer/Color3/ColorPickerButton

var player_mesh: MeshInstance3D

func _ready():
	color0_picker_button.color_changed.connect(_on_color0_changed)
	color1_picker_button.color_changed.connect(_on_color1_changed)
	color2_picker_button.color_changed.connect(_on_color2_changed)

	# Defer the search for player mesh until scene is ready
	call_deferred("_find_player_mesh")


func _find_player_mesh():
	await get_tree().process_frame  # Wait one more frame just to be safe

	# Search for the player using group or name; assuming player is under current scene
	var player = get_tree().current_scene.get_node_or_null("player")
	if not player:
		player = get_tree().current_scene.get_node_or_null("Player")  # fallback

	if player:
		var mesh = player.get_node_or_null("XRCamera3D/playerHead/headGodot")
		if mesh and mesh is MeshInstance3D:
			player_mesh = mesh
		else:
			push_warning("Player mesh not found or wrong type.")
	else:
		push_warning("Player node not found.")


func _on_color0_changed(color: Color):
	_set_material_color(0, color)

func _on_color1_changed(color: Color):
	_set_material_color(1, color)

func _on_color2_changed(color: Color):
	_set_material_color(3, color)


func _set_material_color(slot: int, color: Color):
	if not player_mesh:
		push_warning("Mesh not assigned yet.")
		return

	var mat = player_mesh.get_surface_override_material(slot)
	if not mat:
		mat = player_mesh.material_override
		if not mat:
			push_warning("No material found.")
			return

	mat.albedo_color = color
