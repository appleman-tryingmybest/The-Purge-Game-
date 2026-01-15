extends StaticBody2D
@onready var detectplayer = $PlayerSpawn/Area2D
@export var wait_time : int
var trigger_once := false
var enemy1 = preload("res://enemy_1.tscn")
var enemy2 = preload("res://enemy_2.tscn")
var enemy3 = preload("res://robot_fly.tscn")
var enemy4 = preload("res://robot_shield.tscn")
var boss = preload("res://heavy.tscn")
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
var boss_spawned := false

#PRELOAD SOUNDS
var arena4_intro = preload("res://music/arena_music/arena_4/arena_4_intro.ogg")
var arena4_p1 = preload("res://music/arena_music/arena_4/arena_4_part1.ogg")
var arena4_p2 = preload("res://music/arena_music/arena_4/arena_4_part2.ogg")
var cannon_shoot = preload("res://sounds/enemy/cannon_shoot.ogg")
var boomsound = preload("res://addons/godot-git-plugin/funny-explosion-sound.ogg")

func _on_area_2d_body_entered(body: Node2D) -> void:
	animation.play("idle")
	if !trigger_once and body.is_in_group("player"):
		var getFunction = get_parent().get_node("music-system")
		getFunction.play_arena_music()
		play_sound_intro(arena4_intro, 2)
		_start_stuff()
		Global.arena_player = true

func play_sound (stream: AudioStream, volume:float =0.0 ):
	var arena_music = AudioStreamPlayer.new()
	arena_music.stream = stream
	arena_music.volume_db = volume
	arena_music.bus = "sounds"
	add_child(arena_music) # adds to the world
	arena_music.play() # play first
	arena_music.finished.connect(arena_music.queue_free) # remove itself after finished playing

func play_sound_intro (stream: AudioStream, volume:float =0.0 ):
	var arena_music = AudioStreamPlayer.new()
	arena_music.stream = stream
	arena_music.bus = "Music"
	arena_music.volume_db = volume
	add_child(arena_music) # adds to the world
	arena_music.play() # play first
	arena_music.finished.connect(arena_music.queue_free) # remove itself after finished playing

func _manage_arena_music():
	# Determine which track SHOULD be playing
	var target_stream = arena4_p1 if !boss_spawned else arena4_p2
	
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
	l.bus = "Music"
	l.process_mode = Node.PROCESS_MODE_ALWAYS
	l.volume_db = -7
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
	_activate_cannon()
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
		"boss":
			scene_to_spawn = boss
		_:
			return
	var enemy = scene_to_spawn.instantiate() # copies stuff and prepares it	
	world.add_child(enemy) # then we add it into the world
	if randi_range(0, 1) == 0:
		enemy.global_position = enemyspawn1.global_position
	else:
		enemy.global_position = enemyspawn2.global_position
	print ("enemy amount ", enemy_amount)
	print ("wave ", wave)
	
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if Global.arena_player and spawn:
		_manage_arena_music()
	if !spawn or Global.enemy_count > 0 or spawning or pause:
		return # Stop here if we aren't ready to spawn yet
	if spawn and wave == 1 and !boss_spawned and Global.enemy_count == 0:
		boss_spawned = true
		spawn_enemy("boss")
		spawn_enemy("boss")
	# Handle Spawning
	if spawn and enemy_amount == 0 and wave != 0 and Global.enemy_count == 0:
		print ("starting to spawn")
		enemy_amount = randi_range(7, 10)
		if enemy_amount > 0 and !spawning:
			_spawnwave()
			print ("testing if spawned")
			wave -= 1
	if spawn and wave == 0 and Global.enemy_count == 0 and Global.arena_player:
		destroy_gun()
		Global.arena_player = false
		if is_instance_valid(current_loop_player):
			current_loop_player.stop()
			current_loop_player.queue_free()


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

func _activate_cannon():
	var cooldown : float
	cooldown = randf_range(1, 5)
	while wave != 0: 
		await get_tree().create_timer(cooldown).timeout
		animation.play("point_up")
		await animation.animation_finished
		animation.play("idle_up")
		await animation.animation_finished
		await get_tree().create_timer(randf_range(2, 6)).timeout
		animation.play("fire")
		await animation.animation_finished
		await get_tree().create_timer(1).timeout
		animation.play("point_down")
		await animation.animation_finished
		animation.play("idle")
		cooldown = randf_range(1, 5)

func _shoot_sound():
	play_sound(cannon_shoot, 25)
	
func boom():
	play_sound(boomsound)
	
func Mmu():
	get_tree().paused = true
	
func destroy_gun():
	print("hi")
	animation.play("destroy")
	await animation.animation_finished
	await get_tree().create_timer(6).timeout
	print("pls")
	animation.play("mmu_boom")
	Global.camera_Type = 3
	
