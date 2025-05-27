@tool
extends VisibleOnScreenNotifier3D

@export var boidData : Boid
@export var numberOfBoids: int


var _boids = []
var _avoiders = []


@export var bordermag : float = .9
@onready var enve := aabb.position
@onready var epve := aabb.size + enve

@onready var bsafen := enve * bordermag 
@onready var bsafep := epve * bordermag 
@onready var thread : Thread = Thread.new()

@export var update : bool = false:
	get:
		return update
	set(val):
		print(val)
		update = false
		$DEBUG/Area3D/CollisionShape3D.shape.size = aabb.size
		$DEBUG/Area3D2/CollisionShape3D.shape.size = aabb.size *bordermag


# Called when the node enters the scene tree for the first time.
func _ready():
	if not Engine.is_editor_hint():
		_avoiders = $Avoiders.get_children()
		prints(enve,epve)
		randomize()
		
		for i in range(numberOfBoids):
			var instance = boidData.boidScene.instantiate()
			$Boids.add_child(instance)
			_boids.append(instance)
			instance.set_position( Vector3(
				randf_range(aabb.position.x, aabb.size.x+aabb.position.x),
				randf_range(aabb.position.y, aabb.size.y+aabb.position.y),
				randf_range(aabb.position.z, aabb.size.z+aabb.position.z)
			))
			instance.Parent = self
			instance.maxVelocity = boidData.maxVelocity
			instance.maxAcceleration = boidData.maxAcceleration

func _process(delta):
	if not Engine.is_editor_hint():
		if is_on_screen():
			#thread.start(_run.bind(delta, $Avoiders.get_children()))
			_run(delta)

func _run(delta):
	_detectNeighbors()
	_cohesion()
	_separation()
	_alignment()
	_randomness()
	_borders(delta)
	for i in _avoiders:
		_escapePredator(i)
	
	#call_deferred("_detectNeighbors")
	#call_deferred("_cohesion")
	#call_deferred("_separation")
	#call_deferred("_alignment")
	#call_deferred("_randomness")
	#call_deferred("_borders", delta)
	#for i in _avoiders:
	#	call_deferred("_escapePredator",i)

func _detectNeighbors():
	for i in range(_boids.size()):
		_boids[i].neighbors.clear()
		_boids[i].neighborsDistances.clear()
	
	for i in range(_boids.size()):		
		for j in range(i+1, _boids.size()):
			var distance = _boids[i].get_position().distance_to(_boids[j].get_position())
			if (distance <= boidData.visualRange):
				_boids[i].neighbors.append(_boids[j])
				_boids[j].neighbors.append(_boids[i])
				_boids[i].neighborsDistances.append(distance)
				_boids[j].neighborsDistances.append(distance)

func _cohesion():
	for i in range(_boids.size()):
		var neighbors = _boids[i].neighbors
		
		if (neighbors.is_empty()):
			continue;
		
		var averagePos = Vector3(0,0,0)
		for closeBoid in neighbors:
			averagePos += closeBoid.get_position()
		averagePos /= neighbors.size()
		
		var direction = averagePos - _boids[i].get_position()
		_boids[i].acceleration += direction * boidData.cohesionWeight
func _separation():
	for i in range(_boids.size()):
		var neighbors = _boids[i].neighbors
		var distances = _boids[i].neighborsDistances
		
		if (neighbors.is_empty()):
			continue;
			
		for j in range(neighbors.size()):
			if (distances[j] >= boidData.separationDistance):
				continue
			
			var distMultiplier = 1 - (distances[j] / boidData.separationDistance)
			var direction = _boids[i].get_position() - neighbors[j].get_position()
			direction = direction.normalized()
			_boids[i].acceleration += direction * distMultiplier * boidData.separationWeight
func _alignment():
	for i in range(_boids.size()):
		var neighbors = _boids[i].neighbors
		
		if (neighbors.is_empty()):
			continue;
		
		var averageVel = Vector3.ZERO
		for j in range(neighbors.size()):
			averageVel += neighbors[j].velocity
		averageVel /= neighbors.size()
		
		_boids[i].acceleration += averageVel * boidData.alignmentWeight
func _randomness():
	randomize()
	for boid in _boids:
		boid.acceleration += Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1)).normalized() * boidData.randomnessFactor

func _borders(delta):
	for boid in _boids:
		var pos = boid.position
		if (
			(pos.x < enve.x or pos.x > epve.x) or 
			(pos.y < enve.y or pos.y > epve.y) or
			(pos.z < enve.z or pos.z > epve.z)):
			if pos.x < enve.x:
				pos.x= enve.x
			if pos.y < enve.y:
				pos.y= enve.y
			if pos.z < enve.z:
				pos.z= enve.z
			if pos.x > epve.x:
				pos.x= epve.x
			if pos.y > epve.y:
				pos.y= epve.y
			if pos.z > epve.z:
				pos.z= epve.z
			var midsPoint = Vector3.ZERO
			var disr = (midsPoint - pos).normalized()
			boid.acceleration = disr
			boid.position = pos
		if (
			(pos.x < bsafen.x or pos.x > bsafep.x) or 
			(pos.y < bsafen.y or pos.y > bsafep.y) or
			(pos.z < bsafen.z or pos.z > bsafep.z)):
			boid.timeOutOfBorders += delta
			var midPoint = Vector3.ZERO
			var dir = (midPoint - boid.get_position()).normalized()
			boid.acceleration += dir * boid.timeOutOfBorders * boidData.bordersWeight
		else:
			boid.timeOutOfBorders = 0
func _escapePredator(i):
	for boid in _boids:
		var dist = boid.get_position().distance_to(i.get_position())
		if (dist < boidData.predatorMinDist):
			var dir = (boid.get_position() - i.get_position()).normalized()
			var multiplier = sqrt(1 - (dist / boidData.predatorMinDist)) * i.mul
			boid.acceleration += dir * multiplier * boidData.predatorWeight / (_avoiders.size())

func _exit_tree() -> void:
	thread.wait_to_finish()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Avoider_boid"):
		_avoiders.append(body)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Avoider_boid"):
		_avoiders.erase(body)
