extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@export var Player_x : float = 0
@export var Player_y : float = 0

func _ready() -> void:
	var getPosition = get_parent().get_node("AreaTrigger")
	getPosition.teleportPlayer.connect(setPosition)
	
func setPosition():
	var getPosition = get_parent().get_node("AreaTrigger")
	position.x = getPosition.teleportX - 61
	position.y = getPosition.teleportY - 404
	print ("where do we go ", position.x, " ", position.y)

func _physics_process(delta: float) -> void:
	z_index = 10
	Player_x = position.x
	Player_y = position.y
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
