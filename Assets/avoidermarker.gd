@tool
extends Marker3D

@export var mul : float = 1.0:
	get:
		return mul
	set(val):
		if Engine.is_editor_hint():
			get_child(0).get_child(0).shape.radius = val
		mul = val

func _enter_tree() -> void:
	var shape = SphereShape3D.new()
	shape.radius = mul
	get_child(0).get_child(0).shape = shape
