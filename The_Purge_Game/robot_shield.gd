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
@export var charge_prob : int
@export var charge_cooldown : int
@export var charge_speed : float
var idle : bool # animation states here
var run : bool
var hugging_wall := false
var just_fell := false
var can_jump_fall := false
var on_floor := true
var anim: AnimatedSprite2D
var animation: AnimationPlayer
var is_stun := false
@onready var visuals = $visuals
@onready var ray = $visuals/RayCast2D
@onready var rayGround = $visuals/ChargeFloorChecker
var run_cooldown : float = 1
var is_waiting := false
var charging := false
var charge_move := false
var pushed := false
var timer_footstep : float
var hitted := false
var charge_on_floor := false
var rand_distance : float
@export var ragdoll : PackedScene
@export var turn_timer : float
var knockback_velocity := Vector2.ZERO
@export var attack_cooldown : float
@export var attack_prob : int
var attacking := false
var attack_probb : float
@export var enemy_bullet : PackedScene

#PRELOAD SOUNDS
var FOOTSTEP = preload("res://sounds/enemy/enemy-footsteps.ogg")
var CHARGE_INTRO = preload("res://sounds/enemy/enemy-charge-intro.ogg")
var CHARGE_LOOP = preload("res://sounds/enemy/enemy-charge-loop.ogg")
var CHARGE_CRASH = preload("res://sounds/enemy/enemy-charge-crash.ogg")
var gun_shoot = preload("res://sounds/enemy/enemy-gun-shot.ogg")

func _ready() -> void:
	Global.enemy_count += 1
	anim = $visuals/AnimatedSprite2D
	animation = $AnimationPlayer
	randomize()
	safe_distance += randf_range(-65, 65)
	enemy_to_player_y *= -1
	enemy_to_player_y += randf_range(-50, 50)
	jump_strength *= -1

func shoot_ray():
	var direction = Vector2 (ray_length, 0)
	if ray.is_colliding():
		hugging_wall = true
		var collider = ray.get_collider()
		print("Hit: ", collider.name)
		hitted = true
	else:
		hugging_wall = false
		hitted = false
	if charging:
		if rayGround.is_colliding():
			charge_on_floor = true
		else:
			charge_on_floor = false

func play_sound (stream: AudioStream): # YOU CAN JUST COPY AND PASTE THIS
	var p = AudioStreamPlayer2D.new() # make new audioplayer
	p.stream = stream
	p.bus = "sounds"
	p.pitch_scale = randf_range(0.45, 0.6)
	add_child(p) # adds to the world
	p.play() # play first
	p.finished.connect(p.queue_free) # remove itself after finished playing

func _physics_process(delta):
	z_index = 7
	var distance = abs(Global.player_x - position.x)
	var yDistance = Global.player_y - position.y
	if knockback_velocity != Vector2.ZERO:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 5000 * delta)
	if is_waiting:
		return # stop moving
	charge_cooldown -= 1
	if charge_cooldown < 0 and !charging:
		charge_cooldown = 5
		if randi_range(0, charge_prob) == 0 and is_on_floor() and distance < (safe_distance + 300):
			charging = true
			_charging()
	if not is_on_floor():
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
	elif !charging and is_on_floor():
		on_floor = true
		shoot_ray()
		just_fell = false
		attack_cooldown -= delta
		if distance < safe_distance + 650 and !charging:
			print (attack_cooldown)
			if attack_cooldown < 0:
				if randi_range(0, attack_prob) == 0:
					_attack()
		if distance < safe_distance:
			if distance < safe_distance - safe_zone: # check if we are in danger
				if position.x < Global.player_x: # if we are in danger then we back up
					velocity.x -= speed
				else:
					velocity.x += speed
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
	if !charging:
		velocity.x = clamp(velocity.x, -max_speed, max_speed)
		move_and_slide()
	if charge_on_floor and !hitted and charge_move:
		if health < 0:
			_spawn_ragdoll()
			queue_free()
		if charge_on_floor and !hitted and charge_move:
		# ADD THIS CHECK: 
		# If the distance is greater than, say, your safe_distance + 600
			if distance > (safe_distance + 450):
				_stop_charging_early() # We will create this helper function
				return
		timer_footstep -= delta
		if timer_footstep < 0 and !run:
			play_sound(CHARGE_LOOP)
			timer_footstep = randf_range(0.3, 0.4)
		if visuals.scale.x == 1: # right
			max_speed = charge_speed
			velocity.x += speed * -2
			velocity.y += gravity/4
			velocity.x = clamp(velocity.x, -charge_speed, charge_speed)
			move_and_slide()
			shoot_ray()
		if visuals.scale.x == -1: # left
			max_speed = charge_speed
			velocity.x += speed * 2
			velocity.y += gravity/4
			velocity.x = clamp(velocity.x, -charge_speed, charge_speed)
			move_and_slide()
			shoot_ray()
	elif !charge_on_floor:
		charging = false
		charge_move = false
		max_speed = 100
	elif hitted and charging:
		if !is_stun:
			_stun()

func _process(delta: float) -> void:
	timer_footstep -= delta
	if charge_move:
		return
	if !charging:
		turn_timer -= delta
		if turn_timer <= 0 and on_floor:
			if position.x < Global.player_x:
				visuals.scale.x = -1 # right
			elif position.x > Global.player_x:
				visuals.scale.x = 1 # left
			turn_timer = 1
		if on_floor:
			if (velocity.x != 0) and !run:
				animation.play("walk", 0, 0.7) # name, transition fading, speed
				if timer_footstep < 0 and !run and !idle:
					play_sound(FOOTSTEP)
					timer_footstep = randf_range(0.45, 0.5)
			elif run:
				animation.play("run", 0, 1.3)
				if timer_footstep < 0 and !idle:
					play_sound(FOOTSTEP)
					timer_footstep = randf_range(0.25, 0.34)
			if idle:
				animation.play("idle")
		elif !on_floor:
			animation.stop()
			if velocity.y < 0:
				anim.play("jump")
			elif velocity.y > 0:
				anim.play("fall")
	if health < 0:
		_spawn_ragdoll()
		queue_free()

func _charging():
	charge_on_floor = true
	print ("IM GOING TO CHARGE")
	velocity.x = 0
	play_sound(CHARGE_INTRO)
	animation.play("charge-intro", 0, 1.1)
	await get_tree().create_timer(0.5).timeout
	animation.play("charge-loop", 0, 4)
	charge_move = true

func _stun():
	is_stun = true
	animation.stop()
	charge_move = false
	anim.play("stun-front")
	play_sound(CHARGE_CRASH)
	await get_tree().create_timer(0.5).timeout
	charging = false
	max_speed = 100
	is_stun = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var push_dir := 2500.0
		if visuals.scale.x == 1: # right
			push_dir = push_dir * -1
		if visuals.scale.x == -1: # left
			push_dir = abs(push_dir)
		if body.has_method("apply_knockback") and !pushed and charge_move:
			body.apply_knockback(Vector2(push_dir, -455))
			pushed = true
			print ("finished push")
			_stun()
		if body.has_method("take_damage"):
			body.take_damage(30)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		pushed = false

func _spawn_ragdoll():
	Global.enemy_kill_count += 1
	Global.enemy_count -= 1
	var instance = ragdoll.instantiate()
	if visuals.scale.x == 1:
		instance.facing_direction = 1
	elif visuals.scale.x == -1:
		instance.facing_direction = -1
	get_parent().add_child(instance)
	instance.global_position = global_position
	instance.global_position.y = global_position.y - 150

func _stop_charging_early():
	print("Player too far, stopping charge.")
	charging = false
	charge_move = false
	max_speed = 100
	animation.play("idle") # Or walk, to return to normal behavior


func _on_remove_area_entered(area: Area2D) -> void:
	if area.get_collision_layer_value(13):
		print ("im killing myself")
		Global.enemy_count -= 1
		queue_free()

func _take_damage(amount: float, velo_x: float, velo_y : float):
	var player_is_right = Global.player_x > position.x
	var enemy_face_left = visuals.scale.x == 1
	var enemy_face_right = visuals.scale.x == -1
	var can_take_damage = false
	if player_is_right and enemy_face_left:
		can_take_damage = true
	elif !player_is_right and enemy_face_right:
		can_take_damage = true
	if can_take_damage:
		print ("eheheh that hurts")
		health -= amount
		var dir = 1 if position.x > Global.player_x else -1
		knockback_velocity = Vector2(dir * velo_x, velo_y)

func _attack():
	attacking = true
	print ("IM GONNA KILL YOU")
	_shoot(8)

func _shoot(amount : int):
	while amount != 0:
		var spawn_at = $visuals/bullethole
		var bullet = enemy_bullet.instantiate()
		if visuals.scale.x == 1:
			bullet.Rotation = -PI
		if visuals.scale.x == -1:
			bullet.Rotation = 0
		bullet.Rotation += deg_to_rad(randf_range(-20, 20))
		bullet.shotgun = true
		get_parent().add_child(bullet)
		play_sound(gun_shoot)
		bullet.global_position = spawn_at.global_position
		amount -= 1
	attacking = false
	attack_cooldown = randf_range(4, 5)
