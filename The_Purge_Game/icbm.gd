extends CharacterBody2D
@export var speed : float
@export var threshold : float
var state := 0
var done := false

@onready var animation = $AnimationPlayer

#PRELOAD SOUNDS
var icbm_launch = preload("res://sounds/enemy/icbm/icbm-launch.ogg")
var icbm_loop = preload("res://sounds/enemy/icbm/icbm-loop.ogg")

func _ready() -> void:
	print ("icbm inbound")
	animation.play("back")
	rotation += deg_to_rad(randf_range(-10, 10))
	speed += randf_range(-20, 20)
	play_sound(icbm_launch)
	play_sound(icbm_loop)

func play_sound (stream: AudioStream): # YOU CAN JUST COPY AND PASTE THIS
	var p = AudioStreamPlayer2D.new() # make new audioplayer
	p.stream = stream
	p.bus = "sounds"
	p.pitch_scale = randf_range(0.5, 1.5)
	add_child(p) # adds to the world
	p.play() # play first
	p.finished.connect(p.queue_free) # remove itself after finished playing

func _physics_process(delta: float) -> void:
	if state == 0:
		var forward_direction = Vector2.UP.rotated(rotation)
		velocity += forward_direction * speed / 2
		if position.y < Global.player_y - (threshold + randf_range(0, 400)):
			_set_pos()
			state = 1
			animation.play("front")
	elif state == 1:
		rotation = deg_to_rad(0)
		velocity.x = 0
		velocity.y += speed
	elif state == 2:
		print ("alright we boom")
		return
	move_and_slide()

func _set_pos():
	velocity.y = 0
	print ("position set for icbm")
	if done:
		return
	done = true
	if randf_range(0, 3) == 0:
		position.x = Global.player_x + randf_range(-30, 30)
	else:
		position.x = randf_range(-1303.0, 1303.0)
	if position.x < -1303.0 or position.x > 1303.0:
		queue_free()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var push_dir := 2000.0
		if Global.player_x < position.x: # right
			push_dir = push_dir * -1
		if Global.player_x > position.x: # left
			push_dir = abs(push_dir)
		if body.has_method("apply_knockback"):
			body.apply_knockback(Vector2(push_dir, 1000))
		if body.has_method("take_damage"):
			body.take_damage(30)


func _on_floor_check_body_entered(body: Node2D) -> void:
	if body.get_collision_layer_value(11):
		state = 2
		animation.play("explode")
		await animation.animation_finished
		queue_free()

func _shake_camera(strength : float):
	var cam = get_parent().find_child("Camera2D")
	cam.apply_shake(strength)
