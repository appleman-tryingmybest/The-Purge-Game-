extends CharacterBody2D
@export var SPEED = 200.0
@export var runspeed= 300
@export var JUMP_VELOCITY : float
@export var Player_x : float = 0
@export var Player_y : float = 0
@export var dash_speed = 4
@export var push_strength : int
var jump_count=0
var max_jump=2
var is_dashing=false
var can_dash = true
var dash_direction=1
var was_on_floor=true
var direction : float
@export var dash_duration: float = 0.3
@export var dash_cooldown: float = 1.0
signal camera_limits_changed(new_limits: Vector4)
var knockback_velocity := Vector2.ZERO
@onready var animation = $AnimationPlayer
@onready var hand = %"player-hand"
@onready var handgun = %"player-handgun"
@onready var visuals = $visuals

#PRELOAD SOUNDS
var chainsword_idle = preload("res://sounds/player/chainsword-idle.ogg")
var chainsword_intro = preload("res://sounds/player/chainsword-intro.ogg")
var chainsword_swing = preload("res://sounds/player/chainsword-swing.ogg")
var dash = preload("res://sounds/player/dash.ogg")
var footstep1 = preload("res://sounds/player/footstep1.ogg")
var footstep2 = preload("res://sounds/player/footstep2.ogg")
var gun_intro = preload("res://sounds/player/gun-intro.ogg")
var gun_shoot = preload("res://sounds/player/gun-shoot.ogg")
var jump = preload("res://sounds/player/jump-jump.ogg")

func _ready() -> void:
	JUMP_VELOCITY *= -1
	var getPosition = get_parent().get_node("AreaTrigger")
	getPosition.teleportPlayer.connect(setPosition)
	add_to_group("player")
	if has_node("dash timer"):
		$"dash timer".timeout.connect(stop_dash)

func play_sound (stream: AudioStream, pitch:= 1.0): # YOU CAN JUST COPY AND PASTE THIS
	var p = AudioStreamPlayer2D.new() # make new audioplayer
	p.stream = stream
	p.pitch_scale = pitch
	p.volume_db += 5
	add_child(p) # adds to the world
	p.play() # play first
	p.finished.connect(p.queue_free) # remove itself after finished playing

func setPosition():
	var getPosition = get_parent().get_node("AreaTrigger")
	position.x = getPosition.teleportX
	position.y = getPosition.teleportY
	print ("where do we go ", position.x, " ", position.y)

func _physics_process(delta: float) -> void:
	Global.player_x = global_position.x
	Global.player_y = global_position.y
	Global.player_position = global_position
	if knockback_velocity != Vector2.ZERO:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 5000 * delta)
	z_index = 10
	Player_x = position.x
	Player_y = position.y
	var currently_on_floor = is_on_floor()
	if currently_on_floor:
		jump_count = 0
	elif was_on_floor and not currently_on_floor:
		jump_count = 1
	was_on_floor = currently_on_floor
	# Add the gravity.
	if not is_on_floor() and not is_dashing:
		velocity += get_gravity() * delta
	if is_on_floor():
		jump_count=0
	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and jump_count<max_jump:
		velocity.y = JUMP_VELOCITY
		jump_count+=1
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if Input.is_action_just_pressed("dash") and can_dash and not is_dashing:
			start_dash()
	direction = Input.get_axis("ui_left", "ui_right")
	var current_speed = SPEED
	if Input.is_action_pressed("run"):
		current_speed = runspeed
	if is_dashing:
		velocity.x = direction * SPEED * dash_speed
	elif direction:
		velocity.x = direction * current_speed + knockback_velocity.x
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()


func start_dash():
	var input_direction := Input.get_axis("ui_left", "ui_right")
	dash_direction = input_direction if input_direction != 0 else dash_direction
	is_dashing = true
	can_dash = false
	play_sound(dash, 1.2)
	animation.play("dash")
	velocity.y = 0  # ????
	if has_node("dash timer"):
		$"dash timer".start(dash_duration)


func stop_dash():
	is_dashing=false
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash=true
	print("dash cooldown end can continue to dash")


func update_camera_for_new_area():
	var story_arena = get_parent().get_node("StoryArena1")
	if story_arena:
		var arena_rect = story_arena.get_global_rect()
		var new_limits = Vector4(
			arena_rect.position.x,
			arena_rect.position.y,
			arena_rect.end.x,
			arena_rect.end.y)
		emit_signal("camera_limits_changed", new_limits)


func apply_knockback(force: Vector2):
	knockback_velocity = force
func _process(_delta):
	if Input.is_action_just_pressed("ui_left"):
		visuals.scale.x = -1
	if Input.is_action_just_pressed("ui_right"):
		visuals.scale.x = 1
	if is_on_floor() and !is_dashing:
		if velocity.x==0:
			animation.play("idle")
			handgun.hide()
		elif velocity.x != 0:
			if Input.is_action_pressed("run"):
				animation.play("run")
				handgun.hide()
			else:
				animation.play("walk")
				handgun.hide()
		
	if !is_on_floor():
		if velocity.y<0:
			if jump_count==1:
				animation.play("jump")
			else:
				animation.play("double jump")
		else:
			animation.play("fall")

func _random_footstep_sound():
	if randi_range(0, 1) == 0:
		play_sound(footstep1, randf_range(0.8, 1.5))
	else:
		play_sound(footstep2, randf_range(0.8, 1.5))
