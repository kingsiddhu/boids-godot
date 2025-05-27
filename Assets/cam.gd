extends Node3D


func _physics_process(delta: float) -> void:
	var d: Vector3
	
	d.y+= (int(Input.is_key_pressed(KEY_SHIFT)) - int(Input.is_key_pressed(KEY_CTRL)))
	d.x+= (int(Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_A)))
	d.z-= (int(Input.is_key_pressed(KEY_W)) - int(Input.is_key_pressed(KEY_S)))
	position += transform.basis * d * delta * 100
	
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		var x = event.relative
		rotation.y += x.x * 0.01
		rotation.x += x.y * 0.01
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			$Camera3D.position.z = clampf($Camera3D.position.z + 100 * get_physics_process_delta_time(), 0, 1000)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			$Camera3D.position.z= clampf($Camera3D.position.z - 100 * get_physics_process_delta_time(), 0, 1000)
