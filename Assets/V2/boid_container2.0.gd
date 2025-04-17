extends VisibleOnScreenNotifier3D


@export var BoidData:Boid

var amount = 100

var speed = 10





# Called when the node enters the scene tree for the first time.
func _ready():
	for x in amount:
		var boid :Node3D= BoidData.model.instantiate()
		boid.position = Vector3(
			randf_range(aabb.position.x, aabb.size.x+aabb.position.x),
			randf_range(aabb.position.y, aabb.size.y+aabb.position.y),
			randf_range(aabb.position.z, aabb.size.z+aabb.position.z)
		)
		boid.velocity = Vector3(randf(),randf(), randf()).normalized() * randf_range(1,3)
		boid.look_at(Vector3(randf()-.5,randf()-.5, randf()-.5))
		$Boids.add_child(boid)
	$TargetNode.position = Vector3(
			randf_range(aabb.position.x, aabb.size.x+aabb.position.x),
			randf_range(aabb.position.y, aabb.size.y+aabb.position.y),
			randf_range(aabb.position.z, aabb.size.z+aabb.position.z)
		)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mini = []
	for boid in $Boids.get_children():
		var cohesion_vec:Vector3
		var allignment_vec:Vector3
		var seperation_vec:Vector3
		var velocity :Vector3= boid.transform *Vector3.FORWARD * -1
		
		cohesion_vec = cohesion_rule(boid)
		seperation_vec = seperation_rule(boid)
		allignment_vec = allignment_rule(boid)
		
		changeCenter(boid.position)
		mini.append($TargetNode.position.distance_to(boid.position))
		#print(boid.global_position.distance_to($TargetNode.global_position))
		velocity = velocity + cohesion_vec + allignment_vec + seperation_vec + (-boid.global_position +$TargetNode.global_position)
		boid.velocity = velocity.normalized() * speed
		
		boid.look_at(boid.velocity)
		
		boid.position = lerp(boid.position, boid.position + boid.velocity * delta ,100*delta)
	print(mini.min())


func changeCenter(center):
	if not $TargetNode.global_position.distance_to(center)>100:
		$TargetNode.global_position = Vector3(
			randf_range(aabb.position.x, aabb.size.x+aabb.position.x),
			randf_range(aabb.position.y, aabb.size.y+aabb.position.y),
			randf_range(aabb.position.z, aabb.size.z+aabb.position.z)
		)
		#print("CHAHA", $TargetNode.position)
func cohesion_rule(individual_boid) -> Vector3:
	var perceived_centre:Vector3
	
	for boid in $Boids.get_children():
		if boid != individual_boid and boid.position.distance_to(individual_boid.position)<30:
			
			perceived_centre = perceived_centre + boid.position
	
	perceived_centre = perceived_centre / (amount-1)
	
	return (perceived_centre-individual_boid.position) / 10
	

func seperation_rule(individual_boid) -> Vector3:
	var seperation_vec:Vector3
	
	for boid in $Boids.get_children():
		if boid != individual_boid:
			if (boid.position - individual_boid.position).length() < 10:
				seperation_vec = seperation_vec - (boid.position - individual_boid.position)
	
	return seperation_vec
	
func allignment_rule(individual_boid) -> Vector3:
	var perceived_velocity:Vector3
	
	for boid in get_tree().get_nodes_in_group("boids"):
		if boid != individual_boid:
			perceived_velocity = perceived_velocity + boid.velocity
	
	perceived_velocity = perceived_velocity / (amount-1)
	
	return (perceived_velocity-individual_boid.velocity) / 2
