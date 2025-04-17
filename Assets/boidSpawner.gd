extends VisibleOnScreenNotifier3D

@export var boidData : Boid
@export var numberOfBoids: int


var _boids = []

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	randomize()
	
	for i in range(numberOfBoids):
		var instance = boidData.boidScene.instantiate()
		$Avoiders.add_child(instance)
		_boids.append(instance)
		instance.set_position( Vector3(
			randf_range(aabb.position.x, aabb.size.x+aabb.position.x),
			randf_range(aabb.position.y, aabb.size.y+aabb.position.y),
			randf_range(aabb.position.z, aabb.size.z+aabb.position.z)
		))
		instance.maxVelocity = boidData.maxVelocity
		instance.maxAcceleration = boidData.maxAcceleration

func _process(delta):
	_detectNeighbors()
	
	_cohesion()	
	_separation()
	_alignment()
	
	_borders(delta)
	for i in $Avoiders.get_children():
		_escapePredator(i)
	
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


func _borders(delta):
	for boid in _boids:
		var pos = boid.get_position()
		
		if (
			(pos.x < aabb.position.x or pos.x > aabb.size.x+aabb.position.x) or 
			(pos.y < aabb.position.y or pos.y > aabb.size.y+aabb.position.y) or
			(pos.z < aabb.position.z or pos.z > aabb.size.z+aabb.position.z)):
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
			var multiplier = sqrt(1 - (dist / boidData.predatorMinDist))
			boid.acceleration += dir * multiplier * boidData.predatorWeight / ($Avoiders.get_children().size())
