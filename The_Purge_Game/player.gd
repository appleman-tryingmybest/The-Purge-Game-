extends CharacterBody2D


@export var SPEED = 300.0
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
@export var dash_duration: float = 0.3
@export var dash_cooldown: float = 1.0
signal camera_limits_changed(new_limits: Vector4)

func _ready() -> void:
	JUMP_VELOCITY *= -1
	var getPosition = get_parent().get_node("AreaTrigger")
	getPosition.teleportPlayer.connect(setPosition)
	add_to_group("player")
	if has_node("dash timer"):
		$"dash timer".timeout.connect(stop_dash)
		setup_particles()

func setPosition():
	var getPosition = get_parent().get_node("AreaTrigger")
	position.x = getPosition.teleportX
	position.y = getPosition.teleportY
	print ("where do we go ", position.x, " ", position.y)

func _physics_process(delta: float) -> void:
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
	var direction := Input.get_axis("ui_left", "ui_right")
	if is_dashing:
		velocity.x = direction * SPEED * dash_speed
	elif direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()
	if velocity.x>0:
		$"dash particles".gravity.x=-2000
	
	if velocity.x<0:
		$"dash particles".gravity.x=2000

func start_dash():
	var input_direction := Input.get_axis("ui_left", "ui_right")
	dash_direction = input_direction if input_direction != 0 else dash_direction
	is_dashing = true
	can_dash = false
	velocity.y = 0  # ????
	if has_node("dash timer"):
		$"dash timer".start(dash_duration)
	$"dash particles".emitting = true
	start_particles()

func stop_dash():
	is_dashing=false
	$"dash particles".emitting=false
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash=true
	print("dash cooldown end can continue to dash")
	stop_particles()

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

func setup_particles():
	if has_node("dash_timer/CPUParticles2D"):
		var particles =$"dash particles"
		particles.amount = 20
		particles.lifetime = 0.15
		particles.explosiveness = 0.1
func start_particles():
	if has_node("dash_timer/CPUParticles2D"):
		var particles =$"dash particles"
		particles.emitting = true
func stop_particles():
	if has_node("dash_timer/CPUParticles2D"):
		var particles = $"dash particles"
		particles.emitting = false
