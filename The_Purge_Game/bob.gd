extends CharacterBody2D

@export var teleport_timer : float
var state := 0
@export var distance : float
@export var speedX : float
@export var speedY : float
var allowAction := true
@onready var animation = $AnimationPlayer
@onready var gear1 = $gear1
@onready var gear2 = $gear2
@onready var pink = $visuals/CPUParticles2D


var normal = preload("res://sounds/bob sound/idle.ogg")
var scream = preload("res://sounds/bob sound/scream.ogg")

func _ready() -> void:
	gear1.play("gear1")
	gear2.play("gear2")
	animation.play("idle", 0, 1.7)
	play_sound(normal,10)
	print("playing idle")
	state = 0


func _physics_process(delta: float) -> void:
	print ("Bobs position ", global_position.x, " ", global_position.y)
	if state == 0: # move to player 
		if global_position.x < Global.player_x:
			velocity.x = speedX
		else:
			velocity.x = -speedX
			
		if global_position.y < Global.player_y:
			velocity.y = speedY
		else:
			velocity.y = -speedY
		teleport_timer -= delta
		if teleport_timer < 0 and allowAction:
			state = 1
			allowAction = false
			_teleport()

	elif state == 1: # teleport
		velocity = Vector2(0, 0) #not moving
	
	move_and_slide()
	

func _teleport():
	animation.play("scream", 0, 1.4)
	play_sound(scream,15,2)
	print("playing scream")
	await animation.animation_finished
	var getScaleX = get_parent().get_node("Player")
	var dir = getScaleX.visuals.scale.x
	position.x = Global.player_x + (distance * dir)
	position.y  = Global.player_y
	teleport_timer = 5
	allowAction = true
	state = 0
	animation.play("idle", 0, 1.7) #(start immediately,speed)
	play_sound(normal,10)
	pink.emitting = true
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var push_dir := 4500.0
		if position.x > Global.player_x: # right
			push_dir = push_dir * -1
		if position.x < Global.player_x: # left
			push_dir = abs(push_dir)
		if body.has_method("apply_knockback"):  #checking
			body.apply_knockback(Vector2(push_dir, -800))
		if body.has_method("take_damage"):
			body.take_damage(50)
			
			
func play_sound (stream: AudioStream, volume:int = 0.0, speed: float = 0.0): 
	var r = AudioStreamPlayer2D.new() 
	r.stream = stream
	r.bus = "sounds"
	r.volume_db = volume
	r.pitch_scale = speed
	add_child(r) # adds to the world
	r.play() # play first
	r.finished.connect(r.queue_free)
