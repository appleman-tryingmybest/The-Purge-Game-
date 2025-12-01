extends StaticBody2D
@export var enemy_1 : PackedScene # if more enemy then repeat this
@export var sentryBuster : PackedScene
@export var fly_enemy : PackedScene
@export var random_distance : float
@export var random_enemy : int
var was_pressed : bool
func spawn_enemy(enemy_type: String):
	var world = get_parent()
	var scene_to_spawn: PackedScene

	match enemy_type:
		"enemy_1":
			scene_to_spawn = enemy_1 # if more enemy then repeat this
		"sentryBuster":
			scene_to_spawn = sentryBuster
		"fly_enemy":
			scene_to_spawn = fly_enemy
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
		random_enemy = randi_range(0, 2)
		if random_enemy == 0:
			spawn_enemy("enemy_1")
		if random_enemy == 1:
			spawn_enemy("sentryBuster")
		if random_enemy == 2:
			spawn_enemy("fly_enemy")
		await get_tree().create_timer(2).timeout


	elif not Input.is_key_pressed(KEY_0):
		was_pressed = false

	 
