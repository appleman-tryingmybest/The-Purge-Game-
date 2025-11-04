extends StaticBody2D

@export var tile_width: float
@export var tile_number: float
@export var texture: Texture2D
@export var num_tile: float
@export var furthest_x: float
@export var was_pressed: bool = false
@export var current_x: float = position.x
@export var current_number: int = 0
@export var is_generated := true
@export var wait_time := 0.5
@export var Floor_Debug := false
@export var Floor_random : bool
@export var random_tile : float
var done_generate : bool = false
signal finished_generate(furthest_x: float)	 # this thing is like @export var but for signals, please dont forget
signal getNumTile(num_Tile: float)
signal resetWorld #sends to tree_generator to trigger function to clear all trees

func _ready():
	z_index = 100 # z_index is layers, the bigger the number, the more front it will be
	if done_generate:
		return
	done_generate = true
	call_deferred("_generate_terrain")

@warning_ignore("unused_parameter")
func _process(delta):
	if Input.is_key_pressed(KEY_L) and not was_pressed:
		is_generated = false
		was_pressed = true
		_clear_Floor()
		await get_tree().create_timer(wait_time).timeout
		_generate_terrain()
		emit_signal("resetWorld")
	elif not Input.is_key_pressed(KEY_L):
		was_pressed = false

func _clear_Floor():
	current_x = 0 # reset all values
	current_number = 0
	num_tile = 0
	if is_generated:
		is_generated = false
	for Floor in get_tree().get_nodes_in_group("dirtFloor"): # we need to get group from get_tree()
		Floor.queue_free() # .queue_free() add the name before it so it will focus on that group
	await get_tree().create_timer(wait_time).timeout
	is_generated = true
	if Floor_Debug:
		print ("Cleared ", is_generated)

func _generate_terrain():
	if not is_generated: # if false then stop
		if Floor_Debug:
			print ("Stopped ", is_generated)
		return
	if texture and has_node("Ground"): # checking if theres textures
		$Ground.texture = texture
	if not texture:
		push_error("No textures found")
		return
	if Floor_random:
		random_tile = randi_range(30, 45)
		tile_number = random_tile
	tile_width = texture.get_width()
	while current_number < tile_number:
		var new_ground = duplicate() # we duplicate and then store it in new_ground
		new_ground.done_generate = true # the dot means the (new_ground)'s must set its own value to true
		current_x += tile_width
		new_ground.position.x = current_x
		new_ground.z_index = 100
		new_ground.add_to_group("dirtFloor") # we add to dirtFloor group so we can ONLY delete this and its better
		get_parent().add_child(new_ground) # now we put it into the game world by putting into child
		current_number += 1
		num_tile += 1
		furthest_x = new_ground.position.x
		
	if Floor_Debug:
		print(num_tile)
		print("Furthest is ", furthest_x)
	emit_signal("getNumTile", num_tile)
	emit_signal("finished_generate", furthest_x) # we emit signal to trigger signal finished_generate at the end
	# since its outside the loop, every duplicate does not emit but the original does, thats cool
