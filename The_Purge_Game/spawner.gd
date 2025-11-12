extends StaticBody2D
@export var enemy_1 : PackedScene # if more enemy then repeat this
@export var random_distance : float
var was_pressed : bool
func spawn_enemy(enemy_type: String):
	var world = get_parent()
	var scene_to_spawn: PackedScene

	match enemy_type:
		"enemy_1":
			scene_to_spawn = enemy_1 # if more enemy then repeat this
		
		_:
			return
	var enemy = scene_to_spawn.instantiate() # copies stuff and prepares it
	var getPos = get_parent().get_node("Player")
	world.add_child(enemy) # then we add it into the world
	enemy.global_position.x = getPos.position.x + randf_range(-random_distance, random_distance)
	enemy.global_position.y = getPos.position.y - 5
	
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_0) and not was_pressed: # spawn using the 0 key
		was_pressed = true
		spawn_enemy("enemy_1")
		await get_tree().create_timer(2).timeout


	elif not Input.is_key_pressed(KEY_0):
		was_pressed = false

	 
