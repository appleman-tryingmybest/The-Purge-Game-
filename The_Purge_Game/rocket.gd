extends CharacterBody2D
@export var speed : float
@export var speedX : float
@export var speedY : float
@export var target_time : float
@export var rotate_time : float
@onready var animation = $AnimationPlayer
@onready var sprite2d = $Sprite2D
@export var lifetime : float
var charge := false
var state := 0

#PRELOAD SOUNDS
var spawn = preload("res://sounds/enemy/icbm/rocket_spawn.ogg")
var boom = preload("res://addons/godot-git-plugin/funny-explosion-sound.ogg")

func _ready() -> void:
	play_sound(spawn)
	print ("crockets go")
	velocity.y = -80
	speedX += randf_range(-10, 10)
	speedY += randf_range(-10, 10)
	rotate_time += randf_range(-0.2, 0.2)

func _physics_process(delta: float) -> void:
	lifetime -= delta
	if lifetime < 0:
		queue_free()
	if !charge and state == 0:
		velocity.x = speedX * 5
		velocity.y = speedY * 10
		animation.play("speen", -1, 1.5)
		rotate_time -= delta
		if rotate_time < 0:
			speedX = 0
			speedY = 0
			velocity = Vector2(0, 0)
			animation.stop()
			animation.play("charge")
			charge = true
	elif charge and state == 0:
		sprite2d.rotation = 0
		var forward_direction = Vector2.UP.rotated(rotation)
		velocity += forward_direction * speed / 2
		target_time -= delta
		if target_time > 0:
			var target = get_parent().get_node("Player").global_position
			look_at(target)
			rotation += PI/2
	elif charge and state == 1:
		velocity = Vector2(0, 0)
	move_and_slide()

func play_sound (stream: AudioStream): # YOU CAN JUST COPY AND PASTE THIS
	var p = AudioStreamPlayer2D.new() # make new audioplayer
	p.stream = stream
	p.bus = "sounds"
	p.pitch_scale = randf_range(0.5, 1.5)
	add_child(p) # adds to the world
	p.play() # play first
	p.finished.connect(p.queue_free) # remove itself after finished playing

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print ("boom player")
		var push_dir := 500.0
		if Global.player_x < position.x: # right
			push_dir = push_dir * -1
		if Global.player_x > position.x: # left
			push_dir = abs(push_dir)
		if body.has_method("apply_knockback"):
			body.apply_knockback(Vector2(push_dir, 650))
		if body.has_method("take_damage"):
			body.take_damage(15)

func _on_floorcheck_body_entered(body: Node2D) -> void:
	if body.get_collision_layer_value(1) or body.get_collision_layer_value(7):
		state = 1
		animation.play("explode")
		await animation.animation_finished
		queue_free()

func _boom():
	play_sound(boom)
