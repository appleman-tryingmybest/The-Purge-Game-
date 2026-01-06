extends StaticBody2D
@onready var detectplayer = $PlayerSpawn/Area2D
@export var wait_time : int
var trigger_once := false
var enemy1 = preload("res://enemy_1.tscn")
var enemy2 = preload("res://enemy_2.tscn")
var enemy3 = preload("res://robot_fly.tscn")
var enemy4 = preload("res://robot_shield.tscn")
var dropship = preload("res://dropship.tscn")
@export var random_distance : float
@export var random_enemy : int
var spawn := false
var timer : float
var enemy_amount : int = 0
var spawning := false
var special_event := false
var pause := false
@export var wave : int
@onready var animation = $AnimationPlayer
var current_loop_player: AudioStreamPlayer

#PRELOAD SOUNDS
var intro_sound = preload("res://sounds/enemy/tower-alarm.ogg")
var explode_sound = preload("res://addons/godot-git-plugin/DETECTORTOWER/tower-destroy-sound.ogg")
var arena2_intro = preload("res://music/arena_music/arena_2/arena_2_intro.ogg")
var arena2_p1 = preload("res://music/arena_music/arena_2/arena_2_part1.ogg")
var arena2_p2 = preload("res://music/arena_music/arena_2/arena_2_part2.ogg")

func _on_area_2d_body_entered(body: Node2D) -> void:
	animation.play("off")
	if !trigger_once and body.is_in_group("player"):
		var getFunction = get_parent().get_node("music-system")
		getFunction.play_arena_music()
		play_sound(arena2_intro, 5)
		_start_stuff()
		Global.arena_player = true

func play_sound (stream: AudioStream, volume:float =0.0 ):
	var arena_music = AudioStreamPlayer.new()
	arena_music.stream = stream
	arena_music.volume_db = volume
	add_child(arena_music) # adds to the world
	arena_music.play() # play first
	arena_music.finished.connect(arena_music.queue_free) # remove itself after finished playing
	
func _manage_arena_music():
	# Determine which track SHOULD be playing
	var target_stream = arena2_p2 if special_event else arena2_p1
	
	# 1. If no player exists, create one
	if !is_instance_valid(current_loop_player):
		_start_new_track(target_stream)
		return

	# 2. If the WRONG track is playing, swap it
	if current_loop_player.stream != target_stream:
		print("Boss spawned! Swapping music to: ", target_stream.resource_path)
		current_loop_player.queue_free()
		_start_new_track(target_stream)

func _start_new_track(stream: AudioStream):
	var l = AudioStreamPlayer.new()
	l.stream = stream
	l.bus = "Master"
	l.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(l)
	l.play()
	current_loop_player = l
	
	# Handle the loop simply
	l.finished.connect(func():
		if is_instance_valid(l):
			l.play() # Just restart the same player instead of re-running the whole logic
	)

func _start_stuff():
	animation.play("off")
	print("start timer")
	trigger_once = true
	await get_tree().create_timer(wait_time).timeout
	spawn = true
	print("spawning")


func spawn_enemy(enemy_type: String):
	var enemyspawn1 = $"level-detail-shared/enemy_spawn"
	var enemyspawn2 = $"level-detail-shared/enemy_spawn2"
	var world = get_parent()
	var scene_to_spawn: PackedScene

	match enemy_type:
		"enemy1":
			scene_to_spawn = enemy1 # if more enemy then repeat this
		"enemy2":
			scene_to_spawn = enemy2
		"enemy3":
			scene_to_spawn = enemy3
		"enemy4":
			scene_to_spawn = enemy4
		"dropship":
			scene_to_spawn = dropship
		_:
			return
	var enemy = scene_to_spawn.instantiate() # copies stuff and prepares it	
	world.add_child(enemy) # then we add it into the world
	if randi_range(0, 1) == 0:
		enemy.global_position = enemyspawn1.global_position
	else:
		enemy.global_position = enemyspawn2.global_position
	if enemy_type == "dropship":
		enemy.global_position = Vector2(2723.0, 4933.0 + randf_range(-45, 45))
	print ("enemy amount ", enemy_amount)
	print ("wave ", wave)
	
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if Global.arena_player and spawn:
		_manage_arena_music()
	if !spawn or Global.enemy_count > 0 or spawning or pause:
		return # Stop here if we aren't ready to spawn yet
	# Trigger the Tower Activation once when wave hits 4
	if spawn and wave == 4 and !special_event and Global.enemy_count == 0:
		special_event = true
		_activate_tower()
		return
	# Handle Spawning
	if enemy_amount == 0:
		if special_event and Global.enemy_count == 0:
			print("spawning dropships")
			enemy_amount = 2
			_spawndropship()
		elif !special_event:
			print("starting to spawn normal wave")
			enemy_amount = randi_range(5, 7)
			_spawnwave()
			
	if spawn and wave == 0 and Global.enemy_count == 0:
		Global.arena_player = false

func _spawnwave():
	spawning = true
	while enemy_amount != 0:
		random_enemy = randi_range(0, 3)
		if random_enemy == 0:
			spawn_enemy("enemy1")
		if random_enemy == 1:
			spawn_enemy("enemy2")
		if random_enemy == 2:
			spawn_enemy("enemy3")
		if random_enemy == 3:
			spawn_enemy("enemy4")
		enemy_amount -= 1
	spawning = false

func _spawndropship():
	spawning = true
	animation.play("calling")
	await animation.animation_finished
	while enemy_amount != 0:
		spawn_enemy("dropship")
		enemy_amount -= 1
		await get_tree().create_timer(0.2).timeout
	spawning = false

func _activate_tower():
	pause = true
	animation.play("intro")
	await animation.animation_finished
	pause = false

func _play_intro_sound():
	play_sound(intro_sound)

func _play_destroy_sound():
	play_sound(explode_sound)
