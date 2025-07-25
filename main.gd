extends Node3D

func _ready():
	var xr_interface : XRInterface = XRServer.find_interface("OpenXR")
	if xr_interface == null or not xr_interface.is_initialized():
		print("OpenXR not available or not initialized, trying WebXR...")
		xr_interface = XRServer.find_interface("WebXR")

	if xr_interface and xr_interface.is_initialized():
		print("Using XR interface:", xr_interface.get_name())
		XRServer.set_primary_interface(xr_interface)
		
		# Optionally disable vsync to prevent screen tearing on standalone builds
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		
		# Enable XR rendering on the main viewport
		get_viewport().use_xr = true
	else:
		print("No XR interface available or initialized.")

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()
