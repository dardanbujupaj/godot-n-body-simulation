extends Spatial

# Gravity constant
export(float) var G = 10.0

# Time multiplier
export(float) var time_multiplier = 1.0

# treshold
export(float) var theta =  0.5


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _physics_process(delta):
	_simulation_step(delta)


var max_distance = 100
var next_center = Vector3(0, 0, 0)

func _simulation_step(delta):
	var half_size = Vector3(max_distance, max_distance, max_distance)
	var octree = preload("OctreeNode.gd").new(AABB(next_center - half_size, half_size + half_size))
	max_distance = 0
	
	
	for child in get_children():
		if "mass" in child and "velocity" in child:
			octree.insert_body(child)
	#octree.print_tree()
	
	for child in get_children():
		var force = _calculate_force(child, octree)
		child.velocity += force / child.mass * delta * time_multiplier
		child.translation += child.velocity * delta * time_multiplier
		
		var distance_to_center = child.translation - octree.center_of_mass
		max_distance = max(max_distance, abs(distance_to_center.x))
		max_distance = max(max_distance, abs(distance_to_center.y))
		max_distance = max(max_distance, abs(distance_to_center.z))
	
#	var center_offset = octree.center_of_mass - next_center
#	max_distance += max(abs(center_offset.max_axis()), abs(center_offset.min_axis()))
	next_center = octree.center_of_mass
	max_distance += 1
	

func _calculate_force(body: Spatial, octreeNode):
	var force = Vector3()
	
	# calculate force from external nodes
	# check if node doesn't contain body and is a different than the one currently being calculated
	if octreeNode.is_external_node():
		if octreeNode.body != null and octreeNode.body != body:
			
			var distance = octreeNode.center_of_mass - body.translation
			var scalar_force = G * octreeNode.mass * body.mass / distance.length_squared()
			
			force = scalar_force * distance.normalized()
	else:
		
		# calculate quotient s / d and compare to theta
		var distance = octreeNode.center_of_mass - body.translation
		
		if octreeNode.bounds.size.x / distance.length() < theta:
			# Node is far enough away, calculate force for whole node
			var scalar_force = G * octreeNode.mass * body.mass / distance.length_squared()
			force = scalar_force * distance.normalized()
		else:
			# Node is near enough, calculate forces for subnodes
			for node in octreeNode.nodes:
				force += _calculate_force(body, node)
			
	return force





	
	

