extends CharacterBody2D

@onready var animation = $AnimationPlayer
@onready var head1 = $visuals/Head1
@onready var jaw = $visuals/Head1/Jaw1
@export var head_rand : float
@export var jaw_rand : float
@export var head_rota : float
@export var offsetY : float
var start_posHead : Vector2
var start_posJaw : Vector2
var state := 0
var allowAction = true
var startscream := false
@export var timer2 :float
@export var timer :float
@onready var shaking = $Chain
@onready var heartbeat = $Heart

var scream = preload("res://sounds/adam sound/scream.ogg")


func _ready() -> void:
	head1 = $visuals/Head1
	jaw = $visuals/Head1/Jaw1
	start_posHead = head1.position
	start_posJaw = jaw.position
	shaking.stop()
	heartbeat.stop()
	hide()
	print("r u hiding adam")

#o = normal, 1= scream
func _process(delta: float) -> void:
	if state == 0:
		head1.position += Vector2(randf_range(-head_rand,head_rand), randf_range(-head_rand, head_rand))
		head1.rotation_degrees += randf_range(-head_rota, head_rota)
		jaw.position += Vector2(randf_range(-jaw_rand,jaw_rand),randf_range(-jaw_rand,jaw_rand))
		await get_tree().process_frame
		head1.position = start_posHead
		jaw.position = start_posJaw
		head1.rotation_degrees = 0
		
	else:
		head1.position = start_posHead
		jaw.position = start_posJaw
		head1.rotation_degrees = 0
	
func _physics_process(delta: float) -> void:
	var cam = get_parent().get_node("Camera2D")
	var cam_center = cam.get_screen_center_position()
	position = cam_center + Vector2(0, offsetY)
	timer -= delta
	if timer < 0 and allowAction and Global.start_game:
		show()
		print("adam is here")
		if !startscream:
			print ("reset timer2")
			timer2 = 3
			state = 0
			startscream = true
			animation.play("idle")
			heartbeat.play()
			shaking.play()
		if timer2 < 0:
			allowAction = false
			heartbeat.stop()
			shaking.stop()
			_scream()
	elif !Global.start_game:
		heartbeat.stop()
		shaking.stop()
		hide()
	if startscream:
		timer2 -= delta
		print ("timer2 is ", timer2)
		
		
func _scream():
	state = 1
	animation.play("screaming")
	play_sound(scream,20)
	await animation.animation_finished
	state = 0
	timer = randf_range(5,10)
	allowAction = true
	startscream = false
	hide()
	print("bye adam")
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	print("something entered the area:", body.name)
	if body.is_in_group("player"):
		if body.is_on_floor() and Global.start_game:
			print("is on floor")
			var push_dir := 0
			if position.x < Global.player_x: # right
				push_dir = push_dir * -1
			if position.x > Global.player_x: # left
				push_dir = abs(push_dir)
			if body.has_method("apply_knockback"):
				body.apply_knockback(Vector2(push_dir, -2000))
			if body.has_method("take_damage"):
				body.take_damage(50)
		else:
			print("is not on floor")
	elif !Global.start_game:
		hide()
		
func play_sound (stream: AudioStream, volume:int = 0.0): 
	var r = AudioStreamPlayer2D.new() 
	r.stream = stream
	r.bus = "sounds"
	r.volume_db = volume
	add_child(r) # adds to the world
	r.play() # play first
	r.finished.connect(r.queue_free)
