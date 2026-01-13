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
@export var am_I_sentry_buster: bool = false
@export var ray_length : int  = 100
@export var wall_correction := 20 # shoots enemy backwards if hugging wall
var hugging_wall := false
var just_fell := false
var can_jump_fall := false
@onready var ray = $RayCast2D
@onready var anim = $AnimatedSprite2D  # first we make anim = to the animatedsprite2d child in here first
@onready var animation = $AnimationPlayer
@onready var collider = $Area2D/CollisionShape2D2
@onready var light = $PointLight2D
var run_cooldown : float = 1
var is_waiting := false
var timer : float = 1
var timer_foot : float = 0.4
var exploding := false
var exploder := true

# PRELOAD SOUNDS HERE VERY IMPORTANT AS IT IS MORE EASIER AND CAN BE USED BY ALL
var SFX_SPAWN = preload("res://addons/godot-git-plugin/Sentry_buster_spawn.ogg") # need to preload sounds here
var SFX_CLOCK = preload("res://addons/godot-git-plugin/Sentry_buster_clock.ogg") # if more sounds then add sound here
var SFX_FOOTSTEP = preload("res://addons/godot-git-plugin/Sentry_buster_footstep.ogg")
var SFX_STARTEXPLODE = preload("res://addons/godot-git-plugin/Sentry_buster_explode.ogg")
var SFX_EXPLOSION = preload("res://addons/godot-git-plugin/funny-explosion-sound.ogg")

func _ready() -> void: # I would suggest you to watch youtube tutorial on animations though but i try explain
	light.enabled = false
	Global.enemy_count += 1
	collider.disabled = true
	play_sound(SFX_SPAWN)
	if anim == null:
		push_error("no animation is assigned to me")
	if anim:
		anim.play("walk") # then we make it play walk animation from it, make sure name is the same refer to the animatedsprite2d node
	randomize()
	enemy_to_player_y *= -1
	enemy_to_player_y += randf_range(-50, 50)
	jump_strength *= -1

func shoot_ray():
	var player = get_parent().get_node("Player")
	var direction = Vector2 (ray_length, 0)
	if position.x > player.position.x:
		direction.x = -abs(direction.x)
	elif position.x < player.position.x:
		direction.x = abs(direction.x)
	ray.target_position = direction
	ray.force_raycast_update()
	if ray.is_colliding():
		hugging_wall = true
		var collider = ray.get_collider()
		print("Hit: ", collider.name)
	else:
		hugging_wall = false

func play_sound (stream: AudioStream): # YOU CAN JUST COPY AND PASTE THIS
	var p = AudioStreamPlayer2D.new() # make new audioplayer
	p.stream = stream
	p.bus = "sounds"
	add_child(p) # adds to the world
	p.play() # play first
	p.finished.connect(p.queue_free) # remove itself after finished playing

func _physics_process(delta):
	print ("my size is ", anim.scale)
	print ("exploder is ", exploder)
	if anim and exploder:
		if velocity.x < 0:
			anim.scale.x = 1
		elif velocity.x > 0:
			anim.scale.x = -1
	z_index = 7
	var player = get_parent().get_node("Player")
	var Xdistance = abs(player.position.x - position.x)
	var distance = position.distance_to(player.position)
	var yDistance = player.position.y - position.y
	if is_waiting:
		return
	if not is_on_floor() and !exploding: # if it is exploding then dont move at all
		shoot_ray()
		if hugging_wall:
			if position.x < player.Player_x:
				velocity.x += -wall_correction
			elif position.x > player.Player_x:
				velocity.x += wall_correction
		if not just_fell:
			just_fell = true
			if player.position.y < position.y:
				can_jump_fall = true
			else:
				@warning_ignore("integer_division")
				can_jump_fall = randi_range(0, jump_prob/2) == 0
		else:
			velocity.y += gravity * delta
		if can_jump_fall:
			velocity.y = jump_strength - randf_range(30, 80)
			can_jump_fall = false
	else:
		shoot_ray()
		just_fell = false
		if Xdistance < safe_distance:
			if distance < safe_distance - safe_zone: # check if we are in danger
				exploding = true
				print ("ambatublow")
			else:
				if randi_range(0, jump_prob) == 0 and yDistance < enemy_to_player_y and can_jump: # if we are in range not in danger then we can choose to jump or not
					print ("Enemy jumps")
					print (yDistance)
					velocity.y = jump_strength - randf_range(30, 150) # to go up or jump we need the value to be negative for some reason
					move_and_slide()
				if !am_I_sentry_buster:
					return
				else:
					if position.x < player.Player_x:
						velocity.x += speed
					else:
						velocity.x -= speed

		elif Xdistance > safe_distance: # move to player if too far
			if can_run:
				run_cooldown -= delta # minus delta and delta is 1 second no matter the frame rate
				if run_cooldown < 1:
					run_cooldown = randi_range(1, 2)
					if randi_range(0, run_prob) == 0:
						max_speed = run_speed
						print ("Enemy runs with ", max_speed)
						run_cooldown += randi_range(1, 3)
					else:
						max_speed = 200
						print ("Stopped run ", max_speed)
			if Xdistance > safe_distance - safe_zone:# player is very far
				if hugging_wall:
					if position.x < player.Player_x:
						velocity.y = jump_strength - randf_range(30, 150)
					elif position.x > player.Player_x:
						velocity.y = jump_strength - randf_range(30, 150)
				if position.x < player.Player_x:
					velocity.x += speed
				else:
					velocity.x -= speed
			else:
					return
	if !exploding: # continue to move_and_slide() when its not exploding 
		velocity.x = clamp(velocity.x, -max_speed, max_speed)
		move_and_slide()
	elif exploding and exploder: # exploder makes sure it only triggers it once
		explode_sequence() # we trigger explode sequence
		exploder = false

func explode_sequence() -> void:
		animation.play("explode")
		play_sound(SFX_STARTEXPLODE)
		await animation.animation_finished
		$CPUParticles2D.emitting = true
		animation.play("exploder")
		play_sound(SFX_EXPLOSION)
		await animation.animation_finished
		Global.enemy_count -= 1
		queue_free()

func _process(delta: float) -> void: # able to start multipe timer in here, its good for footsteps and stuff
	timer -= delta 
	if timer < 0 and !exploding:
		play_sound(SFX_CLOCK) # the ticking sound effect
		timer = 1
	timer_foot -= delta
	if timer_foot < 0 and !exploding:
		play_sound(SFX_FOOTSTEP) # footsteps
		timer_foot = 0.35


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var push_dir := 2500.0
		if anim.scale.x == 1: # right
			push_dir = push_dir * -1
		if anim.scale.x == -1: # left
			push_dir = abs(push_dir)
		if body.has_method("apply_knockback"):
			body.apply_knockback(Vector2(push_dir, -1800))
			print ("I PUSHED")

func _on_remove_area_entered(area: Area2D) -> void:
	if area.get_collision_layer_value(13):
		print ("im killing myself")
		Global.enemy_count -= 1
		queue_free()
