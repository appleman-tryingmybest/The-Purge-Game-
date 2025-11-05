extends CharacterBody2D

@export var speed : float
@export var health : float
@export var gravity : float
@export var max_speed : float = 100
@export var safe_distance : float = 250
var is_waiting := false

func _ready() -> void:
	safe_distance += randf_range(-65, 65)
func _physics_process(delta):
	z_index = 7
	var player = get_parent().get_node("Player/CharacterBody2D") as CharacterBody2D
	var distance = position.distance_to(player.position)
	print (distance)
	if is_waiting:
		return
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if distance < safe_distance:
			if position.x < player.Player_x:
				velocity.x -= speed
			else:
				velocity.x += speed
		elif distance > safe_distance:
			if position.x < player.Player_x:
				velocity.x += speed
			else:
				velocity.x -= speed

	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	move_and_slide()
	
func pause_movement_for(seconds: float):
	is_waiting = true
	await get_tree().create_timer(seconds).timeout
	is_waiting = false
