extends CharacterBody2D
# if want to make more enemy, then make enemy scene local and then save as scene
@export var speedX : float
@export var speedY : float
@export var health : float
@export var max_speed : float = 100
@export var safe_distance : float = 250
@export var safe_zone : float = 45
@export var safe_Y : float = 90
@export var ray_length : int  = 100
@export var wall_correction := 20 # shoots enemy backwards if hugging wall
var hugging_wall := false
var just_fell := false
var can_jump_fall := false
@onready var visuals = $visuals
@onready var ray = $visuals/RayCast2D
@onready var anim = $AnimatedSprite2D
@onready var fly_sound = $AudioStreamPlayer2D
@onready var yipi = $AudioStreamPlayer2D2
@onready var ball = %ball
var sound_timer : float
var run_cooldown : float = 1
var is_waiting := false
@export var ragdoll : PackedScene
var knockback_velocity := Vector2.ZERO
@export var attack_cooldown : float
@export var attack_prob : int
var attacking := false
var attack_probb : float
@export var enemy_bullet : PackedScene
@export var ebee_chance : int

#PRELOAD SOUND
var gun_shoot = preload("res://sounds/enemy/enemy-gun-shot.ogg")

func _ready() -> void:
	Global.enemy_count += 1
	randomize()
	ebee_chance = randi_range(0, Global.ebeeChance)
	if ebee_chance != 0:
		ball.play("normal")
		Global.ebeeChance -= 1
	elif ebee_chance == 0:
		ball.play("ebee")
		ball.scale = Vector2(0.395, 0.395)
		Global.ebeeChance = 25
	safe_distance += randf_range(-65, 65)
	safe_Y += randf_range(0, 65)
	if ebee_chance != 0:
		fly_sound.finished.connect(_on_fly_sound_finished)
		_on_fly_sound_finished()
	elif ebee_chance == 0:
		yipi.finished.connect(_yipi_sound_finished)
		_yipi_sound_finished()

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
	var distance = position.distance_to(Global.player_position)
	if knockback_velocity != Vector2.ZERO:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 5000 * delta)
	if health > 0:
		shoot_ray()
		just_fell = false
		if distance < safe_distance:
			if distance < safe_distance - safe_zone: # check if we are in danger
				if position.x < Global.player_x: # if we are in danger then we back up
					velocity.x -= speedX
				else:
					velocity.x += speedX
				if position.y > Global.player_x:
					velocity.y -= speedY
				else:
					velocity.y -= speedY
		attack_cooldown -= delta
		if distance < safe_distance + 650:
			print (attack_cooldown)
			if attack_cooldown < 0:
				if randi_range(0, attack_prob) == 0 and !attacking:
					_attack()
		elif distance > safe_distance: # move to player if too far
			if distance > safe_distance - safe_zone:# player is very far
				if hugging_wall:
					if position.x < Global.player_x:
						velocity.x -= wall_correction
					elif position.x > Global.player_x:
						velocity.x += wall_correction
						
				if position.x < Global.player_x:
					velocity.x += speedX
				else:
					velocity.x -= speedX

				if position.y < Global.player_y - safe_Y:
					velocity.y += speedY
				else:
					velocity.y -= speedY
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	velocity.y = clamp(velocity.y, -max_speed, max_speed)
	move_and_slide()

	if velocity.x > 0:
		rotation_degrees += 1
		rotation_degrees = clamp(rotation_degrees + 1, -30, 30)
	elif velocity.x < 0:
		rotation_degrees -= 1
		rotation_degrees = clamp(rotation_degrees - 1, -30, 30)

func _on_fly_sound_finished():
	fly_sound.play()

func _yipi_sound_finished():
	yipi.play()

func play_sound (stream: AudioStream): # YOU CAN JUST COPY AND PASTE THIS
	var p = AudioStreamPlayer2D.new() # make new audioplayer
	p.stream = stream
	p.bus = "sounds"
	add_child(p) # adds to the world
	p.play() # play first
	p.finished.connect(p.queue_free) # remove itself after finished playing

func _process(delta: float) -> void:
	anim.play("blades")
	if position.x < Global.player_x:
		visuals.scale.x = -1 # right
	elif position.x > Global.player_x:
		visuals.scale.x = 1 # left
	if health < 0:
		_spawn_ragdoll()
		queue_free()

func _spawn_ragdoll():
	Global.enemy_kill_count += 1
	Global.enemy_count -= 1
	Global.hammer_num+=2
	var instance = ragdoll.instantiate()
	if visuals.scale.x == 1:
		instance.facing_direction = 1
	elif visuals.scale.x == -1:
		instance.facing_direction = -1
	get_parent().add_child(instance)
	instance.global_position = global_position
	instance.global_position.y = global_position.y - 150


func _on_remove_area_entered(area: Area2D) -> void:
	if area.get_collision_layer_value(13):
		Global.enemy_count -= 1
		queue_free()

func _take_damage(amount: float, velo_x: float, velo_y : float):
	health -= amount
	var dir = 1 if position.x > Global.player_x else -1
	knockback_velocity = Vector2(dir * velo_x/2, velo_y/2)
	_flash_damage()

func _attack():
	attacking = true
	print ("IM GONNA KILL YOU")
	_shoot(randi_range(2, 5))

func _shoot(amount : int):
	while amount != 0:
		var spawn_at = $visuals/bullethole
		var bullet = enemy_bullet.instantiate()
		if visuals.scale.x == 1:
			bullet.Rotation = -PI + rotation
		if visuals.scale.x == -1:
			bullet.Rotation = 0 + rotation
		bullet.Rotation += deg_to_rad(randf_range(-6, 6))
		get_parent().add_child(bullet)
		play_sound(gun_shoot)
		bullet.global_position = spawn_at.global_position
		amount -= 1
		await get_tree().create_timer(0.6).timeout
	attacking = false
	attack_cooldown = randf_range(4, 5)

func _flash_damage():
	var tween = create_tween()
	visuals.modulate = Color(10, 10, 10, 1)
	tween.tween_property(visuals, "modulate", Color.WHITE, 0.1)
