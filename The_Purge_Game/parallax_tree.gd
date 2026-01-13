extends Parallax2D

@export var x_limit: float 
@export var treeNum: float
@export var tree_debug : bool = true
@export var y_offset : float
@onready var screen_width = get_viewport_rect().size.x
var currentTreeNum: float = 0
var is_generating := false
var allow_generate := true
var buffer = 200
var moved := false
func _ready():
	# Connect to your floor generator as before
	var floorGenerator = get_parent().get_node("floorGenerator")
	floorGenerator.resetWorld.connect(_clear_mountain)
	if tree_debug:
		print ("Found it")
	
	# Initial generation
	_get_ground_values()

func _clear_mountain():
	is_generating = false
	await get_tree().process_frame
	currentTreeNum = 0
	moved = false
	# Delete only the generated sprites, not the template
	for cloud in get_tree().get_nodes_in_group("generatedTreeB"):
		cloud.queue_free()
	if Global.tree:
		_get_ground_values()

func _get_ground_values():
	if tree_debug:
		print ("got the values")
	var floorGenerator = get_tree().current_scene.find_child("floorGenerator")
	if floorGenerator:
		# Double check if the value is actually there
		if floorGenerator.num_tile > 0:
			x_limit = floorGenerator.furthest_x
			treeNum = floorGenerator.num_tile * 12
			if tree_debug:
				print("Success! Found FloorGenerator. Tiles: ", floorGenerator.num_tile)
			_generate_clouds()
		else:
			# If it's still 0, the floor hasn't initialized yet.
			# Wait one frame and try again.
			if tree_debug: print("Floor found, but num_tile is 0. Retrying...")
			await get_tree().process_frame
			_get_ground_values()
	else:
		push_error("Cloud script could not find floorGenerator in the scene!")
		_generate_clouds()

func _generate_clouds():
	if is_generating: return
	is_generating = true
	var tree = $Sprite2D
	var spawn_x = 0.0 # Start at the beginning of the layer
	while currentTreeNum < treeNum and is_generating and Global.tree:
		# Randomize variety
		var distance = randf_range(75, 100)
		# Create the cloud sprite
		var new_treeB = tree.duplicate()
		new_treeB.visible = true
		new_treeB.add_to_group("generatedTreeB")
		self.scroll_scale = Vector2(0.7, 0)
		var treeSize = randf_range(0.6, 1.0)
		add_child(new_treeB) # Adds it inside this Parallax2D layer
		# Position it RELATIVE to this layer
		spawn_x += distance
		new_treeB.position.x = spawn_x
		new_treeB.position.y = y_offset + randf_range(-15, 45)
		if Global.arena_player:
			new_treeB.position.y += 15
		new_treeB.scale += Vector2(treeSize, treeSize)
		new_treeB.rotation += deg_to_rad(randf_range(-10, 10))
		if randi_range(0, 1) == 0:
			new_treeB.scale.x *= -1
			
		# STOP if we pass the world limit
		# Note: Since the layer moves, we check spawn_x directlyda
		currentTreeNum += 1
		
		if currentTreeNum:
			print("Mountain ", currentTreeNum, " x-pos ", spawn_x)

		await get_tree().process_frame
	is_generating = false

func _process(delta: float) -> void:
	if Global.arena_player and !moved:
		moved = true
		var all_trees = get_tree().get_nodes_in_group("generatedTreeB")
		for tree_node in all_trees:
			tree_node.position.y += 250
			if tree_debug:
				print("Moving generated tree down: ", tree_node.name)
	if !Global.start_game:
		visible = false
	else:
		visible = true
