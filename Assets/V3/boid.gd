extends Node3D

@export var maxVelocity: float = 280
@export var maxAcceleration: float = 1000


var velocity := Vector3.ZERO
var acceleration := Vector3.ZERO

var neighbors := []
var neighborsDistances := []
var timeOutOfBorders := 0.0

func _ready():
	
	velocity = Vector3(randf_range(-maxVelocity, maxVelocity),
						randf_range(-maxVelocity, maxVelocity),
						randf_range(-maxVelocity, maxVelocity))
	
func _process(delta):
	print(position)
	velocity += acceleration.limit_length(maxAcceleration * delta)
	velocity = velocity.limit_length(maxVelocity)
	acceleration.x = 0
	acceleration.y = 0
	acceleration.z = 0
	
	position += velocity * delta
	
	look_at(position + velocity)
	
