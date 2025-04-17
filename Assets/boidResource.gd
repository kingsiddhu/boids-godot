extends Resource
class_name Boid


@export var boidScene: PackedScene
@export var visualRange: float = 30
@export var separationDistance: float = 80
@export var predatorMinDist: float = 300


@export var cohesionWeight: float = 0.3
@export var separationWeight: float = 50
@export var alignmentWeight: float = 1

@export var bordersWeight: float = 300
@export var predatorWeight: float = 500


@export var maxVelocity: float = 280
@export var maxAcceleration: float = 1000
