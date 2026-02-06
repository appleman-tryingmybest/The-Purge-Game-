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

	var floorGenerator = get_parent().get_node("floorGenerator")
	floorGenerator.resetWorld.connect(_clear_mountain)
	if tree_debug:
		print ("Found it")

	_get_ground_values()

func _clear_mountain():
	is_generating = false
	await get_tree().process_frame
	currentTreeNum = 0
	moved = false
	for cloud in get_tree().get_nodes_in_group("generatedTreeB"):
		cloud.queue_free()
	if Global.tree:
		_get_ground_values()

func _get_ground_values():
	if tree_debug:
		print ("got the values")
	var floorGenerator = get_tree().current_scene.find_child("floorGenerator")
	if floorGenerator:
		if floorGenerator.num_tile > 0:
			x_limit = floorGenerator.furthest_x
			treeNum = floorGenerator.num_tile * 12
			if tree_debug:
				print("Success! Found FloorGenerator. Tiles: ", floorGenerator.num_tile)
			_generate_clouds()
		else:
			await get_tree().process_frame
			_get_ground_values()
	else:
		_generate_clouds()

func _generate_clouds():
	if is_generating: return
	is_generating = true
	var tree = $Sprite2D
	var spawn_x = 0.0
	while currentTreeNum < treeNum and is_generating and Global.tree:
		var distance = randf_range(75, 100)
		var new_treeB = tree.duplicate()
		new_treeB.visible = true
		new_treeB.add_to_group("generatedTreeB")
		self.scroll_scale = Vector2(0.7, 0)
		var treeSize = randf_range(0.6, 1.0)
		add_child(new_treeB)
		spawn_x += distance
		new_treeB.position.x = spawn_x
		new_treeB.position.y = y_offset + randf_range(-15, 45)
		if Global.arena_player:
			new_treeB.position.y += 15
		new_treeB.scale += Vector2(treeSize, treeSize)
		new_treeB.rotation += deg_to_rad(randf_range(-10, 10))
		if randi_range(0, 1) == 0:
			new_treeB.scale.x *= -1
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
