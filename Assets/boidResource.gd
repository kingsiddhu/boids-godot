extends Resource
class_name BoidRes


@export var boidScene: PackedScene
@export var visualRange: float = 3
@export var separationDistance: float = 8
@export var predatorMinDist: float = 30


@export var cohesionWeight: float = 0.3
@export var separationWeight: float = 5
@export var alignmentWeight: float = 1

@export var bordersWeight: float = 30
@export var predatorWeight: float = 50

@export var randomnessFactor: float = 10

@export var maxVelocity: float = 28
@export var maxAcceleration: float = 100

@export var terrainAvoidness : float =10
