extends StaticBody2D
@export var enemy_shoot : PackedScene # if more enemy then repeat this
@export var sentryBuster : PackedScene
@export var fly_enemy : PackedScene
@export var enemy_shield : PackedScene
@export var dropship : PackedScene
@export var enemy_sword : PackedScene
@export var random_distance : float
@export var random_enemy : int
var timer : float
var enemy_amount : float
var was_pressed : bool
var spawned := false


func spawn_enemy(enemy_type: String):
	var world = get_parent()
	var scene_to_spawn: PackedScene

	match enemy_type:
		"enemy1":
			scene_to_spawn = enemy_shoot # if more enemy then repeat this
		"enemy5":
			scene_to_spawn = sentryBuster
		"enemy3":
			scene_to_spawn = fly_enemy
		"enemy4":
			scene_to_spawn = enemy_shield
		"dropship":
			scene_to_spawn = dropship
		"enemy2":
			scene_to_spawn = enemy_sword
		_:
			return
	var enemy = scene_to_spawn.instantiate() # copies stuff and prepares it
	var getPos = get_parent().get_node("Player")
	
	world.add_child(enemy) # then we add it into the world
	if enemy_type == "dropship":
		enemy.global_position = Vector2(2723.0, 4933.0)
	else:
		enemy.global_position.x = getPos.position.x + randf_range(0, 88) + random_distance
		enemy.global_position.y = position.y
	
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	print ("timer is now ", timer)
	if (Input.is_key_pressed(KEY_0) and not was_pressed) and !Global.arena_player: # spawn using the 0 key
		was_pressed = true
		random_enemy = randi_range(0, 4)
		match random_enemy:
			0: spawn_enemy("enemy1")
			1: spawn_enemy("enemy2")
			2: spawn_enemy("enemy3")
			3: spawn_enemy("enemy4")
			4: spawn_enemy("enemy5")
		await get_tree().create_timer(2).timeout
	if Input.is_key_pressed(KEY_9) and not was_pressed:
		was_pressed = true
		spawn_enemy("dropship")
		await get_tree().create_timer(2).timeout

	elif not Input.is_key_pressed(KEY_9) and not Input.is_key_pressed(KEY_0):
		was_pressed = false
	
	if Global.enemy_count == 0 and !Global.arena_player and !spawned and Global.allowSpawn:
		spawned = true
		_spawn_wave()
	elif Global.enemy_count != 0 and Global.arena_player:
		spawned = false
		return

func _spawn_wave():
	match Global.arena_num:
		0: timer = randf_range(6, 12)
		1: timer = randf_range(5, 8)
		2: timer = randf_range(8, 14)
		3: timer = randf_range(8, 18)
	while timer > 0:
		await get_tree().process_frame
		timer -= get_process_delta_time()
	match Global.arena_num:
		0: enemy_amount = randf_range(2, 4)
		1: enemy_amount = randf_range(4, 7)
		2: enemy_amount = randf_range(5, 9)
		3: enemy_amount = randf_range(7, 10)
	while enemy_amount > 0 and !Global.arena_player:
		match Global.arena_num:
			0: random_enemy = randi_range(0, 2)
			1: random_enemy = randi_range(0, 3)
			2: random_enemy = randi_range(0, 4)
			3: random_enemy = randi_range(0, 4)
		match random_enemy:
			0: spawn_enemy("enemy1")
			1: spawn_enemy("enemy2")
			2: spawn_enemy("enemy3")
			3: spawn_enemy("enemy4")
			4: spawn_enemy("enemy5")
		enemy_amount -= 1
	spawned = false
