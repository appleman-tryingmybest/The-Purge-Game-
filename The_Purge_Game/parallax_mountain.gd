extends Parallax2D

@export var x_limit: float 
@export var mountainNum: float
@export var mountain_debug : bool = true
@export var y_offset : float
@onready var screen_width = get_viewport_rect().size.x
var currentMountainNum: float = 0
var is_generating := false
var allow_generate := true
var buffer = 200
var moved := false
func _ready():
	var floorGenerator = get_parent().get_node("floorGenerator")
	floorGenerator.resetWorld.connect(_clear_mountain)
	if mountain_debug:
		print ("Found it")
	
	_get_ground_values()

func _clear_mountain():
	is_generating = false
	await get_tree().process_frame
	currentMountainNum = 0
	moved = false
	for cloud in get_tree().get_nodes_in_group("generatedMountain"):
		cloud.queue_free()
	_get_ground_values()

func _get_ground_values():
	if mountain_debug:
		print ("got the values")
	var floorGenerator = get_tree().current_scene.find_child("floorGenerator")
	if floorGenerator:
		if floorGenerator.num_tile > 0:
			x_limit = floorGenerator.furthest_x
			mountainNum = floorGenerator.num_tile * 2
			if mountain_debug:
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
	
	var template = $AnimatedSprite2D
	var spawn_x = 0.0
	var frame_count = template.sprite_frames.get_frame_count("mountain-variant")
	while currentMountainNum < mountainNum and is_generating and Global.mountain:
		var distance = randf_range(75, 100)
		var new_mountain = template.duplicate()
		new_mountain.animation = "mountain-variant"
		new_mountain.frame = randi_range(0, frame_count -1)
		new_mountain.pause()
		new_mountain.visible = true
		new_mountain.add_to_group("generatedMountain")
		self.scroll_scale = Vector2(0.1, 0)
		var mountainSize = randf_range(0.6, 1.0)
		add_child(new_mountain)
		spawn_x += distance
		new_mountain.position.x = spawn_x
		new_mountain.position.y = y_offset + randf_range(5, 35)
		if Global.arena_player:
			new_mountain.position.y += 15
		new_mountain.scale = Vector2(mountainSize, mountainSize)
		if randi_range(0, 1) == 0:
			new_mountain.scale.x *= -1
		currentMountainNum += 1
		
		if mountain_debug:
			print("Mountain ", currentMountainNum, " x-pos ", spawn_x)
			
		await get_tree().process_frame
	is_generating = false

func _process(delta: float) -> void:
	if Global.arena_player and !moved:
		moved = true
		var all_mountain = get_tree().get_nodes_in_group("generatedMountain")
		for tree_node in all_mountain:
			tree_node.position.y += 15
			if mountain_debug:
				print("Moving generated tree down: ", tree_node.name)
	if !Global.start_game:
		visible = false
	else:
		visible = true
