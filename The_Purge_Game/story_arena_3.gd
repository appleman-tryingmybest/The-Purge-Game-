extends StaticBody2D
@onready var detectplayer = $PlayerSpawn/Area2D
@export var wait_time : int
var trigger_once := false
var enemy1 = preload("res://enemy_1.tscn")
var enemy2 = preload("res://enemy_2.tscn")
var enemy3 = preload("res://robot_fly.tscn")
var enemy4 = preload("res://robot_shield.tscn")
var strider = preload("res://strider.tscn")
@export var random_distance : float
@export var random_enemy : int
var spawn := false
var timer : float
var enemy_amount : int = 0
var spawning := false
var boss_spawned := false
@export var wave : int

var current_loop_player: AudioStreamPlayer
var arena3_intro = preload("res://music/arena_music/arena_3/arena_3_intro.ogg")
var arena3_p1 = preload("res://music/arena_music/arena_3/arena_3_part1.ogg")
var arena3_p2 = preload("res://music/arena_music/arena_3/arena_3_part2.ogg")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if !trigger_once and body.is_in_group("player"):
		var getFunction = get_parent().get_node("music-system")
		getFunction.play_arena_music()
		play_sound(arena3_intro)
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
	var target_stream = arena3_p2 if boss_spawned else arena3_p1
	
	# 1. If no player exists, create one
	if !is_instance_valid(current_loop_player):
		_start_new_track(target_stream)
		return

	# 2. If the WRONG track is playing, swap it
	if current_loop_player.stream != target_stream:
		print("Boss spawned! Swapping music to: ", target_stream.resource_path)
		current_loop_player.queue_free()
		_start_new_track(target_stream)

func _start_stuff():
	print("start timer")
	trigger_once = true
	await get_tree().create_timer(wait_time).timeout
	spawn = true
	print("spawning")

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

func spawn_enemy(enemy_type: String):
	var enemyspawn1 = $"level-detail-shared/enemy_spawn"
	var enemyspawn2 = $"level-detail-shared/enemy_spawn2"
	var striderspawn = $platform/Sprite2D
	var world = get_parent()
	var scene_to_spawn: PackedScene

	match enemy_type:
		"enemy1":
			scene_to_spawn = enemy1 # if more enemy then repeat this
		"enemy2":
			scene_to_spawn = enemy2
		"enemy3":
			scene_to_spawn = enemy3
		"strider":
			scene_to_spawn = strider
		_:
			return
	var enemy = scene_to_spawn.instantiate() # copies stuff and prepares it	
	world.add_child(enemy) # then we add it into the world
	if enemy_type == "strider":
		enemy.global_position = striderspawn.global_position + Vector2(0, 600)
	elif randi_range(0, 1) == 0 and enemy_type != "strider":
		enemy.global_position = enemyspawn1.global_position
	elif randi_range(0, 1) == 1 and enemy_type != "strider":
		enemy.global_position = enemyspawn2.global_position
	print ("enemy amount ", enemy_amount)
	print ("wave ", wave)
	
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if Global.arena_player and spawn:
		_manage_arena_music()
	if spawn and enemy_amount == 0 and wave != 0 and Global.enemy_count == 0:
		print ("starting to spawn")
		enemy_amount = randi_range(6, 8)
		if enemy_amount > 0 and !spawning:
			_spawnwave()
	if wave == 4 and !boss_spawned and spawn:
		boss_spawned = true
		spawn_enemy("strider")
		
	if spawn and wave == 0 and Global.enemy_count == 0:
		Global.arena_player = false
		

func _spawnwave():
	spawning = true
	while enemy_amount != 0:
		random_enemy = randi_range(0, 2)
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
