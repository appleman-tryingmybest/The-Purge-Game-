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

func _ready() -> void:
	head1 = $visuals/Head1
	jaw = $visuals/Head1/Jaw1
	start_posHead = head1.position
	start_posJaw = jaw.position

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
	if timer < 0 and allowAction:
		show()
		if !startscream:
			print ("reset timer2")
			timer2 = 3
		state = 0
		startscream = true
		animation.play("idle")
		if timer2 < 0:
			allowAction = false
			_scream()
	if startscream:
		timer2 -= delta
		print ("timer2 is ", timer2)
		
		
func _scream():
	state = 1
	animation.play("screaming")
	await animation.animation_finished
	state = 0
	timer = randf_range(0.1,2)
	allowAction = true
	startscream = false
	hide()
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	print("something entered the area:", body.name)
	if body.is_in_group("player"):
		if body.is_on_floor():
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
