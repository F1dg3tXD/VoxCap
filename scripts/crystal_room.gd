@tool
extends Node3D

# Exported properties to assign in the editor
@export var meshes: Array[MeshInstance3D] = []
@export var materials: Array[Material] = []

# Editor button to trigger assignment
@export var run_randomize := false:
	set(value):
		run_randomize = value
		if run_randomize:
			assign_random_materials()
			run_randomize = false

func assign_random_materials():
	if meshes.is_empty() or materials.is_empty():
		push_error("Meshes and Materials must both be filled.")
		return

	for mesh in meshes:
		if mesh and mesh.mesh:
			var surface_count: int = mesh.mesh.get_surface_count()
			for i in range(surface_count):
				var random_material: Material = materials[randi() % materials.size()]
				mesh.set_surface_override_material(i, random_material)
