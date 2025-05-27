@tool
extends Node3D
@export var update : bool = false:
	get:
		return update
	set(val):
		var aabb = get_parent().aabb
		print(val)
		update = false
		$Area3D/CollisionShape3D.shape.size = aabb.size
		$Area3D2/CollisionShape3D.shape.size = aabb.size * get_parent().bordermag

func _process(delta: float) -> void:
	pass
	#rotation.x+=delta*10
