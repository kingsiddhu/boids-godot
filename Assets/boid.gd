extends Node3D
class_name Boid
@export var maxVelocity: float = 280
@export var maxAcceleration: float = 1000

var paused : bool
var frameskip : int
var frame = 0
var Parent : VisibleOnScreenNotifier3D
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
	frame+=1
	if Parent.is_on_screen() and frame>=frameskip and not paused:
		velocity += acceleration.limit_length(maxAcceleration * delta)
		velocity = velocity.limit_length(maxVelocity)
		acceleration.x = 0
		acceleration.y = 0
		acceleration.z = 0
	
		position += velocity * delta
	
		look_at(position + velocity)
		frame = 0
