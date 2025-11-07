extends StaticBody2D
@export var x_limit: float 
@export var treeNum: float
@export var currentTreeNum: float
@export var current_x: float
@export var tileToTree: float
@export var wait_time: float = 0.5
@export var was_pressed: bool = false
@export var tree_debug : bool
var is_generating := false
var done_generate := false
var allow_generate := true
#github test
func _ready():
	var getFunction = get_parent().get_node("floorGenerator")
	getFunction.resetWorld.connect(_clear_tree)
	if not done_generate:
		done_generate = true
		randomize()
		await get_tree().create_timer(wait_time).timeout
		call("_getGroundValue")
		
func _clear_tree():
	is_generating = false
	allow_generate = false
	treeNum = 0
	current_x = 0
	currentTreeNum = 0
	
	for tree in get_tree().get_nodes_in_group("generatedTree"):
		tree.queue_free()

	allow_generate = true
	_getGroundValue()

func _getGroundValue(): # get num_tile from grass_test
	if not allow_generate:
		return
	var floorGenerator = get_parent().get_node("floorGenerator") # must always use this if you want to get values from others
	if floorGenerator:
		x_limit = floorGenerator.furthest_x
		tileToTree = floorGenerator.num_tile * randi_range(2, 6)
		if tree_debug:
			print("The x limit is, ", x_limit)
			print("tileToTree value is, ", tileToTree)
	else:
		push_warning("floorGenerator not found")
	call_deferred("_on_floor_finished", x_limit)

func _on_floor_finished(received_x: float):
	if not allow_generate:
		return
	x_limit = received_x
	if tree_debug:
		print ("Furtherst x received ", received_x)
		print ("Making sure the limit is right ", x_limit)
	call_deferred("_get_total_tiles", tileToTree)
	
func _get_total_tiles(totalTiles: float):
	if not allow_generate:
		return
	treeNum = totalTiles * 6
	call_deferred("_generateTree")

func _generateTree():
	if is_generating:
		return
	is_generating = true
	current_x = position.x
	while currentTreeNum < treeNum and is_generating: # this is really bad but if it works i dont care anymore
		var treeSizeRandom = randf_range(0.85, 1.2)
		var treeDistanceRandom = randf_range(20, 35)
		var treeOffsetRandom = randf_range(-35, 35)
		var treeRotateRandom = randf_range(-8, 8)
		var treeLayerRandom = randf_range(1, 2)
		var new_tree = duplicate()
		new_tree.done_generate = true
		current_x += treeDistanceRandom
		new_tree.position.x = current_x + treeOffsetRandom
		new_tree.scale = Vector2(treeSizeRandom, treeSizeRandom)
		new_tree.rotation = deg_to_rad(treeRotateRandom)
		new_tree.z_index = treeLayerRandom
		if new_tree.position.x > x_limit:
			currentTreeNum += treeNum
		new_tree.add_to_group("generatedTree")
		get_parent().add_child(new_tree)
		currentTreeNum += 1
		if tree_debug:
			print (currentTreeNum, ". Wheres the x position ", new_tree.position.x)
		await get_tree().process_frame
	is_generating = false
