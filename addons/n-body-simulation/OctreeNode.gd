extends Reference


var bounds: AABB
var body: Spatial = null
var mass: float = 0.0
var center_of_mass: Vector3 = Vector3()
var nodes = []#: OctreeNode[]



func _init(node_bounds = AABB(Vector3(), Vector3.ONE)):
	bounds = node_bounds
	center_of_mass = bounds.position + bounds.size / 2


# Check if this node is an external node
# External nodes do not have inner nodes
func is_external_node():
	return !len(nodes) > 0


# insert a new body into the nodetree
func insert_body(new_body: Spatial):
	
	# accumulate mass
	var current_mass = mass
	mass += new_body.mass
	
	# calculate the new center of mass
	center_of_mass = (center_of_mass * current_mass + new_body.translation * new_body.mass) / mass
	
	# if subnodes exist already, add the body to the corresponding node
	if len(nodes) > 0:
		var ins = 0
		for node in nodes:
			if node.bounds.has_point(new_body.translation):
				node.insert_body(new_body)
				ins += 1
				# break loop to prevent body beeing inserted into multiple nodes (if exactly ond edge)
				return
	
	# if no other body present add the new body to this node
	elif body == null:
		body = new_body
	
	# if theres already a body present, create subnodes and add the bodies
	else:
		_create_subnodes()
		# insert presend and new
		for b in [body, new_body]:
			for node in nodes:
				if node.bounds.has_point(b.translation):
					node.insert_body(b)
					# break loop to prevent body beeing inserted into multiple nodes (if exactly on edge)
					break
		body = null
	

# Create subnodes for this node
func _create_subnodes():
	# calculate helper vectors for new bounds
	var half_size = bounds.size / 2
	var half_size_x = Vector3(half_size.x, 0, 0)
	var half_size_y = Vector3(0, half_size.y, 0)
	var half_size_z = Vector3(0, 0, half_size.z)
	
	# Create eight subnodes
	# using get_script().new() instead of class_name to avoid cyclic reference
	# I
	nodes.append(get_script().new(AABB(bounds.position + half_size, half_size)))
	# II
	nodes.append(get_script().new(AABB(bounds.position + half_size_y + half_size_z, half_size)))
	# III
	nodes.append(get_script().new(AABB(bounds.position + half_size_z, half_size)))
	# IV
	nodes.append(get_script().new(AABB(bounds.position + half_size_x + half_size_z, half_size)))
	# V
	nodes.append(get_script().new(AABB(bounds.position + half_size_x + half_size_y, half_size)))
	# VI
	nodes.append(get_script().new(AABB(bounds.position + half_size_y, half_size)))
	# VII
	nodes.append(get_script().new(AABB(bounds.position + half_size_x, half_size)))
	# VIII
	nodes.append(get_script().new(AABB(bounds.position, half_size)))
	

# Print current nodetree
# Print properties and contents of all nodes in this tree recursively
func print_tree(indent = ""):
	print(indent + str(self))
	print(indent + "mass %d" % mass)
	print(indent + "bounds %s" % bounds)
	print(indent + "body %s" % body)
	for n in nodes:
		n.print_tree(indent + "-")
