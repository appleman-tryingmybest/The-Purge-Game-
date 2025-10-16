extends Camera2D

@export var move_speed: float = 300.0  # Pixels per second

func _process(delta):
	var input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):  # Arrow right or D
		input_vector.x += 1
	if Input.is_action_pressed("ui_left"):   # Arrow left or A
		input_vector.x -= 1
	if Input.is_action_pressed("ui_down"):   # Arrow down or S
		input_vector.y += 1
	if Input.is_action_pressed("ui_up"):     # Arrow up or W
		input_vector.y -= 1
	
	# Normalize for diagonal movement and apply speed
	position += input_vector.normalized() * move_speed * delta
