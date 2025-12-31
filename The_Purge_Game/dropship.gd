extends CharacterBody2D
# if want to make more enemy, then make enemy scene local and then save as scene
@export var speed : float
@export var max_speed : float = 100
@export var safe_distance : float = 250
@export var friction : float = 1000
@onready var animation = $AnimationPlayer
var on_player := false
var stop_intro := false
var leave := false
#PRELOAD SOUNDS


func _ready() -> void:
	randomize()
	safe_distance += randf_range(25, 255)
	animation.play("intro")

func play_sound (stream: AudioStream): # YOU CAN JUST COPY AND PASTE THIS
	var p = AudioStreamPlayer2D.new() # make new audioplayer
	p.stream = stream
	p.pitch_scale = randf_range(0.5, 1.5)
	add_child(p) # adds to the world
	p.play() # play first
	p.finished.connect(p.queue_free) # remove itself after finished playing

func _physics_process(delta):
	z_index = 7
	var distance = abs(Global.player_x - position.x)
	if !stop_intro:
		if distance > safe_distance and !on_player:
			velocity.x -= speed
		if distance < safe_distance:
			velocity.x = move_toward(velocity.x, 0, friction * delta)
			on_player = true
		if on_player:
			print ("stopped?")
			_next_sequence()
			stop_intro = true
			on_player = false
		velocity.x = clamp(velocity.x, -max_speed, max_speed)
		move_and_slide()
	if leave:
		velocity.x -= speed
		velocity.x = clamp(velocity.x, -max_speed, max_speed)
		move_and_slide()

func _next_sequence():
	animation.play("stop", 0, 0.4)
	await get_tree().create_timer(1).timeout
	print ("check first place")
	animation.play("idle")
	await get_tree().create_timer(5).timeout
	animation.play("leave", -1, 1)
	print ("lets go")
	await get_tree().create_timer(0.1).timeout
	leave = true
	animation.play("intro")
	print ("leaving")
