extends CharacterBody2D
# if want to make more enemy, then make enemy scene local and then save as scene
@export var speed : float
@export var health : float
@export var gravity : float
@export var max_speed : float = 100
@export var safe_distance : float = 250
@export var safe_zone : float = 45
@export var jump_prob : int
@export var can_jump : bool
@export var enemy_to_player_y : float
@export var jump_strength : float
@export var can_run : bool
@export var run_prob : int
@export var run_speed : float
@export var ray_length : int  = 100
@export var wall_correction := 20 # shoots enemy backwards if hugging wall
@export var attack_cooldown : float
@export var attack_prob : int
var idle : bool # animation states here
var run : bool
var hugging_wall := false
var just_fell := false
var can_jump_fall := false
var on_floor := true
var anim: AnimatedSprite2D
var animation: AnimationPlayer
@onready var visuals = $visuals
@onready var ray = $visuals/RayCast2D
var run_cooldown : float = 1
var is_waiting := false
var timer_footstep: float
var attacking := false
var attack_probb : float
var dead := false
var taunt_timer : float
@export var shockwave : PackedScene
@export var rocket : PackedScene
@export var turn_timer : float
@onready var here = $visuals/shockwavehere
var knockback_velocity := Vector2.ZERO
var lock_move := false

#PRELOAD SOUNDS
var FOOTSTEP = preload("res://sounds/enemy/heavy/heavy_footstep.ogg")
var swing = preload("res://sounds/enemy/heavy/swing.ogg")
var scream = preload("res://sounds/enemy/heavy/heavy-taunt.ogg")

func _ready() -> void:
	Global.enemy_count += 1
	anim = $visuals/AnimatedSprite2D
	animation = $AnimationPlayer
	randomize()
	safe_distance += randf_range(-65, 65)
	enemy_to_player_y *= -1
	enemy_to_player_y += randf_range(-50, 50)
	jump_strength *= -1

func play_sound (stream: AudioStream, pitch:= 1.0): # YOU CAN JUST COPY AND PASTE THIS
	var p = AudioStreamPlayer2D.new() # make new audioplayer
	p.stream = stream
	p.pitch_scale = pitch
	p.bus = "sounds"
	p.volume_db += 5
	add_child(p) # adds to the world
	p.play() # play first
	p.finished.connect(p.queue_free) # remove itself after finished playing

func shoot_ray():
	var direction = Vector2 (ray_length, 0)
	if ray.is_colliding():
		hugging_wall = true
		var collider = ray.get_collider()
		print("Hit: ", collider.name)
	else:
		hugging_wall = false

func _physics_process(delta):
	z_index = 7
	var distance = abs(Global.player_x - position.x)
	var yDistance = Global.player_y - position.y
	if dead or is_waiting:
		return # stop moving
	if attacking and lock_move:
		velocity.x = 0
		print ("attacking ", attacking, " locking move ", lock_move)
	if knockback_velocity != Vector2.ZERO:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 5000 * delta)
	if not is_on_floor() and !dead:
		on_floor = false
		shoot_ray()
		if hugging_wall:
			if position.x < Global.player_x:
				velocity.x += -wall_correction
			elif position.x > Global.player_x:
				velocity.x += wall_correction
		if not just_fell:
			just_fell = true
			if Global.player_y < position.y:
				can_jump_fall = true
			else:
				@warning_ignore("integer_division")
				can_jump_fall = randi_range(0, jump_prob) == 0
		else:
			velocity.y += gravity * delta
		if can_jump_fall:
			velocity.y = jump_strength - randf_range(30, 80)
			can_jump_fall = false
	elif is_on_floor() and !attacking and !dead:
		taunt_timer -= delta
		if taunt_timer < 0:
			taunt_timer = 3
			if randi_range(0, 2) == 0:
				_taunt()
				return
		attack_cooldown -= delta
		on_floor = true
		shoot_ray()
		just_fell = false
		if distance < safe_distance:
			print (attack_cooldown)
			if attack_cooldown < 0:
				if randi_range(0, attack_prob) == 0:
					_attack()
			else:
				if randi_range(0, jump_prob) == 0 and yDistance < enemy_to_player_y and can_jump: # if we are in range not in danger then we can choose to jump or not
					print ("Enemy jumps")
					print (yDistance)
					velocity.y = jump_strength - randf_range(30, 150) # to go up or jump we need the value to be negative for some reason
					move_and_slide()
				idle = true
				return # stop moving
		elif distance > safe_distance: # move to player if too far
			if can_run:
				run_cooldown -= delta # minus delta and delta is 1 second no matter the frame rate
				if run_cooldown < 1:
					run_cooldown = randi_range(1, 2)
					if randi_range(0, run_prob) == 0:
						run = true
						max_speed = run_speed
						print ("Enemy runs with ", max_speed)
						run_cooldown += randi_range(1, 3)
					else:
						run = false
						max_speed = 200
						print ("Stopped run ", max_speed)
			if distance > safe_distance - safe_zone:# player is very far
				if hugging_wall:
					if position.x < Global.player_x:
						velocity.y = jump_strength - randf_range(30, 150)
					elif position.x > Global.player_x:
						velocity.y = jump_strength - randf_range(30, 150)
				if position.x < Global.player_x:
					velocity.x += speed
				else:
					velocity.x -= speed
			else:
				idle = true
				return # stop moving
	idle = false
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	move_and_slide()
	
func _process(delta: float) -> void:
	if dead or attacking:
		return
	timer_footstep -= delta
	turn_timer -= delta
	if turn_timer <= 0 and on_floor and !attacking:
		if position.x < Global.player_x:
			visuals.scale.x = -1 # right
		elif position.x > Global.player_x:
			visuals.scale.x = 1 # left
		turn_timer = 0.6
	if on_floor and !attacking and !dead:
		if (velocity.x != 0) and !run:
			animation.play("walk", 0, 0.5)
			if timer_footstep < 0 and !run and !idle:
				play_sound(FOOTSTEP, randf_range(1, 1.5))
				timer_footstep = randf_range(0.8, 1)
		if idle:
			animation.play("idle")
	elif !on_floor and !attacking and !dead:
		animation.stop()
		if velocity.y < 0:
			anim.play("jump")
		elif velocity.y > 0:
			anim.play("fall")
	if health < 0 and !dead:
		Global.enemy_count -= 1
		_death_sequence()

func _death_sequence():
	Global.enemy_kill_count += 1
	dead = true
	Global.hammer_num+=8
	animation.play("death", 0, 0.3)
	await animation.animation_finished
	animation.play("death-idle")
	await get_tree().create_timer(80).timeout
	queue_free()

func _attack():
	attacking = true
	velocity.x = 0
	velocity.y = 0
	var randAttack := 0
	randAttack = randi_range(0, 3)
	print ("IM GONNA KILL YOU")
	if randAttack == 0:
		lock_move = true
		animation.play("attack2", 0, 0.5)
		velocity.x = 0
		await animation.animation_finished
	elif randAttack == 1:
		lock_move = false
		velocity.x = 0
		animation.play("attack", 0, 0.7)
		await animation.animation_finished
	elif randAttack == 2:
		lock_move = true
		velocity.x = 0
		animation.play("taunt", 0, 0.2)
		await get_tree().create_timer(2.2).timeout
	attacking = false
	attack_cooldown = 1
	lock_move = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var push_dir := 2000.0
		if visuals.scale.x == 1: # right
			push_dir = push_dir * -1
		if visuals.scale.x == -1: # left
			push_dir = abs(push_dir)
		if body.has_method("apply_knockback") and attacking:
			body.apply_knockback(Vector2(push_dir, -1200))
			print ("I PUSHED")
		if body.has_method("take_damage"):
			body.take_damage(30)

func _take_damage(amount: float, velo_x: float, velo_y : float):
	health -= amount
	var dir = -1 if position.x > Global.player_x else 1
	knockback_velocity = Vector2(dir * velo_x, velo_y*0)
	_flash_damage()

func _taunt():
	attacking = true
	var rand_attack = randi_range(0, 1)
	if rand_attack == 0:
		animation.play("taunt", 0, 0.2)
		await get_tree().create_timer(2.2).timeout
	elif rand_attack == 1:
		animation.play("attack2", 0, 0.5)
		await animation.animation_finished
	attacking = false



func _move_back():
	var dir = 1 if position.x > Global.player_x else -1
	knockback_velocity = Vector2(dir * 2000, 0)

func _shockwave():
	var rightwave = shockwave.instantiate()
	rightwave.direction = 1
	get_parent().add_child(rightwave)
	rightwave.global_position = here.global_position
	var leftwave = shockwave.instantiate()
	leftwave.direction = -1
	get_parent().add_child(leftwave)
	leftwave.global_position = here.global_position

func _rocket():
	var rocketHere = $visuals/rockethere
	var amount = randi_range(1, 3)
	for i in amount:
		var rocket_spawn = rocket.instantiate()
		rocket_spawn.speedX *= visuals.scale.x
		rocket_spawn.global_position = rocketHere.global_position
		get_parent().add_child(rocket_spawn)
		await get_tree().process_frame

func _flash_damage():
	var tween = create_tween()
	visuals.modulate = Color(10, 10, 10, 1)
	tween.tween_property(visuals, "modulate", Color.WHITE, 0.1)

func _shake_camera(strength : float):
	var cam = get_parent().find_child("Camera2D")
	cam.apply_shake(strength)

func _swing_sound():
	play_sound(swing)

func _taunt_sound():
	play_sound(scream)

func _footstep_soud():
	play_sound(FOOTSTEP)
