extends CharacterBody2D
@export var x_limit : float
@export var cooldown : int
var random_action := 0
var speed := 55.0
var max_speed := 250.0
var start_action := false
var stop_timer := false
@export var health := 1.0
@export var ragdoll : PackedScene

@onready var animation = $AnimationPlayer
@onready var animation_effect = $AnimatedSprite2D2
@onready var line = $LinePivot

#PRELOAD SOUNDS
var footstep1 = preload("res://sounds/enemy/strider/footstep1.ogg")
var footstep2 = preload("res://sounds/enemy/strider/footstep2.ogg")
var footstep3 = preload("res://sounds/enemy/strider/footstep3.ogg")
var horn = preload("res://sounds/enemy/strider/strider-scream.ogg")
var shoot = preload("res://sounds/enemy/strider/strider-shot.ogg")

func _ready() -> void:
	line.visible = false
	line.modulate.a = 0.0
	animation_effect.visible = false
	position = Vector2(0, 9987.0)
	print("IM HERE NOW")
	print ("IM AT ", position)
	animation.play("wakeup", 0, 0.8)
	await get_tree().create_timer(2.7).timeout
	play_sound(horn)
	animation.play("idle", 0, 0.6)
	start_action = true
	random_action = randi_range(0, 3)
	_action_cooldown_loop()
	x_limit += position.x
	print("x limit ", x_limit)

func play_sound (stream: AudioStream, pitch:= 1.0): # YOU CAN JUST COPY AND PASTE THIS
	var p = AudioStreamPlayer2D.new() # make new audioplayer
	p.stream = stream
	p.pitch_scale = pitch
	add_child(p) # adds to the world
	p.play() # play first
	p.finished.connect(p.queue_free) # remove itself after finished playing

func _physics_process(delta: float) -> void:
	if start_action:
		if random_action == 0:
			animation.play("idle", 0, 0.6)
			velocity.x = 0
		if random_action == 1 and !(position.x < -x_limit):
			animation.play("walk")
			velocity.x -= speed
		if random_action == 2 and !(position.x > x_limit):
			animation.play("walk", 0, -1)
			velocity.x += speed
		if random_action == 3:
			_play_shoot()
		velocity.x = clamp(velocity.x, -max_speed, max_speed)
		move_and_slide()

func _action_cooldown_loop():
	while !stop_timer:
		cooldown += randi_range(-2, 2)
		await get_tree().create_timer(cooldown).timeout
		random_action = randi_range(0, 3)
		print ("action is ", random_action)

func _play_shoot():
	start_action = false
	animation_effect.visible = true
	animation.play("shoot")
	velocity.x = 0
	await get_tree().create_timer(4.1).timeout
	random_action = randi_range(0, 2)
	start_action = true
	animation_effect.visible = false
 
func _process(delta: float) -> void:
	if position.x > x_limit:
		print ("too far right")
		random_action = 1
	if position.x < -x_limit:
		print ("too far left")
		random_action = 2
	if health < 0:
		_spawn_ragdoll()
		queue_free()

func _footstep_sound():
	var rand_sound : int
	rand_sound = randi_range(0, 2)
	if rand_sound == 0:
		play_sound(footstep1, randi_range(0.8, 2))
	if rand_sound == 1:
		play_sound(footstep2, randi_range(0.8, 2))
	if rand_sound == 2:
		play_sound(footstep3, randi_range(0.8, 2))

func _shoot_sound():
	stop_timer = true
	var timer = 0.0
	line.scale.y = 1
	play_sound(shoot, 0.94)
	if position.x > Global.player_x:
		print ("in line of sight")
		line.modulate.a = 0.0
		line.visible = true
		while timer < 2.1:
			var d = get_process_delta_time()
			print (line.modulate.a)
			line.modulate.a += 0.01
			line.scale.y -= 0.001
			var target = get_parent().get_node("Player").global_position
			line.look_at(target)
			timer += d
			await get_tree().process_frame
	await get_tree().create_timer(1).timeout
	line.visible = false
	print (line.visible)
	line.scale.y = 1
	stop_timer = false

func _spawn_ragdoll():
	var instance = ragdoll.instantiate()
	get_parent().add_child(instance)
	instance.global_position = global_position
	instance.global_position.y = global_position.y - 1200
