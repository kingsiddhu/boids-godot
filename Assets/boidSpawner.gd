@tool
extends VisibleOnScreenNotifier3D

@export var boidData : BoidRes
@export var numberOfBoids: int


var _boids = []
var _avoiders = []
var _terrain = []


@export var bordermag : float = .9
@onready var enve := aabb.position     #-ve min box
@onready var epve := aabb.size + enve  #+ve max box

@onready var bsafen := enve * bordermag #-ve warning zone
@onready var bsafep := epve * bordermag #+ve warning zone

@onready var bTn := enve * .5 #-ve Terrain search
@onready var bTp := epve * .5 #+ve Terrain search

const midPoint = Vector3.ZERO
var raylen :int
var frame : int
var frameskip : int
var oldframeskip:int

@onready var thread : Thread = Thread.new()
@export_flags_3d_physics var AvoiderMask :int = 0:
	get:
		return AvoiderMask
	set(val):
		$DEBUG/Master.collision_mask = val
@export var update : bool = false:
	get:
		return update
	set(val):
		update = false
		$DEBUG/Master/CollisionShape3D.shape.size = aabb.size
		$DEBUG/OuterLimit/CollisionShape3D.shape.size = aabb.size *bordermag
		$DEBUG/BorderCheck/CollisionShape3D.shape.size = aabb.size *.5
		$RayCast3D.target_position = Vector3(0,-enve.distance_to(Vector3.ZERO),0)
@export var debug:bool
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
				randf_range(enve.x, epve.x),
				randf_range(enve.y, epve.y),
				randf_range(enve.z, epve.z)
			))
			instance.Parent = self
			instance.maxVelocity = boidData.maxVelocity
			instance.maxAcceleration = boidData.maxAcceleration
	$RayCast3D.target_position = Vector3(0,-enve.distance_to(Vector3.ZERO),0)
	raylen=enve.distance_to(Vector3.ZERO)
	update = true

func _process(delta):
	if not Engine.is_editor_hint():
		if is_on_screen():
			frame+=1
			frameskip = int(0.01*get_viewport().get_camera_3d().global_position.distance_to(global_position))**1.5
			#prints(frame,frameskip)
			if frame>=frameskip:
				#thread.start(_run.bind(delta, $Avoiders.get_children()))
				_run(delta)
				frame = 0
				oldframeskip = frameskip
			
func _run(delta):
	
	for i in _avoiders:
		_escapePredator(i)
	_detectNeighbors()
	_cohesion()
	_separation()
	_alignment()
	_randomness()
	_detectTerrain()
	_borders(delta)
	
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
		_boids[i].frameskip = frameskip
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
func _detectTerrain():
	for boid in _boids as Array[Boid]:
		var pos :Vector3= boid.position
		if ((pos.x < bTn.x or pos.x > bTp.x) or 
			(pos.y < bTn.y or pos.y > bTp.y) or
			(pos.z < bTn.z or pos.z > bTp.z)):
			var dir :Vector3= (midPoint - pos).normalized()
			#$RayCast3D.look_at(dir )
			$RayCast3D.target_position = -dir * raylen
			$RayCast3D.force_raycast_update()
			if $RayCast3D.is_colliding():
				var colpoint :Vector3= $RayCast3D.get_collision_point()
				
				if pos.distance_to(midPoint)>colpoint.distance_to(midPoint)*bordermag:
					#prints(colpoint.y, pos.y, )
					if debug and pos.distance_to(midPoint)>colpoint.distance_to(midPoint): #Phasing
						var deb = CSGBox3D.new()
						deb.position = colpoint
						add_child(deb)
					$RayCast3D.debug_shape_custom_color = Color("ffffff")
					#boid.velocity /=2*get_physics_process_delta_time()
					boid.acceleration += dir * boidData.terrainAvoidness
					boid.velocity = $RayCast3D.get_collision_normal() * boid.velocity.length()  #dir * boidData.terrainAvoidness
				else:
					$RayCast3D.debug_shape_custom_color = Color("ffff00")
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
		if (dist < min(i.mul,boidData.predatorMinDist)):
			var dir = (boid.get_position() - i.get_position()).normalized()
			var multiplier = sqrt((1 - (dist / boidData.predatorMinDist))) 
			boid.acceleration += dir * multiplier * boidData.predatorWeight / (_avoiders.size())

func _exit_tree() -> void:
	if not Engine.is_editor_hint():
		thread.wait_to_finish()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Avoider_boid"):
		_avoiders.append(body)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Avoider_boid"):
		_avoiders.erase(body)


func _on_property_list_changed() -> void:
	$DEBUG/Master/CollisionShape3D.shape.size = aabb.size
	$DEBUG/OuterLimit/CollisionShape3D.shape.size = aabb.size *bordermag
	$DEBUG/BorderCheck/CollisionShape3D.shape.size = aabb.size *.5
	$RayCast3D.target_position = Vector3(0,-enve.distance_to(Vector3.ZERO),0)
