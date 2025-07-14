extends Node3D

func _ready() -> void:
	if FileAccess.file_exists("user://cam.json"):
		var x = JSON.parse_string(FileAccess.get_file_as_string("user://cam.json"))
		rotation.x =float(x[0])
		rotation.y = float(x[1])
		$Camera3D.position.z = float(x[2])
	save()
func save() -> void:
	await get_tree().create_timer(3).timeout
	FileAccess.open("user://cam.json", FileAccess.WRITE).store_string(JSON.stringify([rotation.x, rotation.y, $Camera3D.position.z, ]))
	save()

func _physics_process(delta: float) -> void:
	var d: Vector3
	
	d.y+= (int(Input.is_key_pressed(KEY_SHIFT)) - int(Input.is_key_pressed(KEY_CTRL)))
	d.x+= (int(Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_A)))
	d.z-= (int(Input.is_key_pressed(KEY_W)) - int(Input.is_key_pressed(KEY_S)))
	position += transform.basis * d * delta * 100
	
	

func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_R):
		position = Vector3.ZERO
		$Camera3D.position.z = 120
		rotation = Vector3.ZERO
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		var x = event.relative
		rotation.y += x.x * 0.01
		rotation.x += x.y * 0.01
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			$Camera3D.position.z = clampf($Camera3D.position.z - 100 * get_physics_process_delta_time(), 0, 1000)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			$Camera3D.position.z = clampf($Camera3D.position.z + 100 * get_physics_process_delta_time(), 0, 1000)
		$Marker3D.gizmo_extents = clamp($Camera3D.position.z, 1, 1000)
