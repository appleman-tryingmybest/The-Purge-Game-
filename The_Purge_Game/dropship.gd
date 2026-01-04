extends CharacterBody2D
# if want to make more enemy, then make enemy scene local and then save as scene
@export var speed : float
@export var max_speed : float = 100
@export var safe_distance : float = 250
@export var friction : float = 1000
@onready var animation = $AnimationPlayer
@export var enemy_1 : PackedScene
@export var enemy_2 : PackedScene
@export var enemy_3 : PackedScene
@export var enemy_4 : PackedScene
@onready var dropship_sound = $dropship_sound
var on_player := false
var stop_intro := false
var leave := false
var done := false
@export var enemy_amount : int
var enemy_rand : int
var rand_distance : float
#PRELOAD SOUNDS
var dropship_release = preload("res://sounds/enemy/dropship-release-sound.ogg")

func _ready() -> void:
	Global.enemy_count += 1
	randomize()
	safe_distance += randf_range(25, 255)
	animation.play("intro")
	dropship_sound.finished.connect(_on_fly_sound_finished)
	_on_fly_sound_finished()
	rand_distance = randf_range(-326, 1173)


func play_sound (stream: AudioStream): # YOU CAN JUST COPY AND PASTE THIS
	var p = AudioStreamPlayer2D.new() # make new audioplayer
	p.stream = stream
	add_child(p) # adds to the world
	p.play() # play first
	p.finished.connect(p.queue_free) # remove itself after finished playing

func _physics_process(delta):
	z_index = 7
	print (position.x, " ", rand_distance)
	if !stop_intro:
		if position.x > rand_distance:
			velocity.x -= speed
			print ("moving")
		else:
			print("we are here")
			velocity.x = 0
			stop_intro = true
			_next_sequence()
	if leave:
		velocity.x -= speed
		velocity.x = clamp(velocity.x, -max_speed, max_speed)
		move_and_slide()
	move_and_slide()

func _on_fly_sound_finished():
	dropship_sound.play()

func _next_sequence():
	animation.play("stop", 0, 0.4)
	await get_tree().create_timer(1).timeout
	print ("check first place")
	animation.play("idle")
	while enemy_amount != 0:
		enemy_rand = randi_range(1, 4)
		if enemy_rand == 1:
			spawn_enemy("enemy_1")
		if enemy_rand == 2:
			spawn_enemy("enemy_2")
		if enemy_rand == 3:
			spawn_enemy("enemy_3")
		if enemy_rand == 4:
			spawn_enemy("enemy_4")
		enemy_amount -= 1
		await get_tree().create_timer(0.1).timeout
		play_sound(dropship_release)
	animation.play("leave", -1, 1)
	print ("lets go")
	await get_tree().create_timer(1).timeout
	leave = true
	animation.play("intro")
	print ("leaving")
	time_limit()

func spawn_enemy(enemy_type: String):
	print("spawned")
	var world = get_parent()
	var scene_to_spawn: PackedScene

	match enemy_type:
		"enemy_1":
			scene_to_spawn = enemy_1
		"enemy_2":
			scene_to_spawn = enemy_2
		"enemy_3":
			scene_to_spawn = enemy_3
		"enemy_4":
			scene_to_spawn = enemy_4
		_:
			return
	var enemy = scene_to_spawn.instantiate() # copies stuff and prepares it
	world.add_child(enemy) # then we add it into the world
	enemy.global_position = global_position + Vector2(randf_range(-250, 250), 20)

func time_limit():
	await get_tree().create_timer(4).timeout
	print ("remove")
	Global.enemy_count -= 1
	queue_free()
	
