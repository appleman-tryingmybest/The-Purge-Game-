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
var sound_timer : float
var run_cooldown : float = 1
var is_waiting := false
@export var ragdoll : PackedScene
#PRELOAD SOUND


func _ready() -> void:
	Global.enemy_count += 1
	randomize()
	safe_distance += randf_range(-65, 65)
	safe_Y += randf_range(0, 65)
	fly_sound.finished.connect(_on_fly_sound_finished)
	_on_fly_sound_finished()

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

func play_sound (stream: AudioStream): # YOU CAN JUST COPY AND PASTE THIS
	var p = AudioStreamPlayer2D.new() # make new audioplayer
	p.stream = stream
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
	Global.enemy_count -= 1
	var instance = ragdoll.instantiate()
	get_parent().add_child(instance)
	instance.global_position = global_position
	instance.global_position.y = global_position.y - 150
