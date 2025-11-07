extends CharacterBody2D

@export var speed : float
@export var health : float
@export var gravity : float
@export var max_speed : float = 100
@export var safe_distance : float = 250
@export var safe_zone : float = 45
@export var jump_prob : int
@export var enemy_to_player_y : float
@export var jump_strength : float
@export var can_run : bool
@export var run_prob : int
@export var run_speed : float

var run_cooldown : float = 1
var is_waiting := false
func _ready() -> void:
	randomize()
	safe_distance += randf_range(-65, 65)
	enemy_to_player_y *= -1
	enemy_to_player_y += randf_range(-50, 50)
	jump_strength *= -1
func _physics_process(delta):
	z_index = 7
	var player = get_parent().get_node("Player")
	var distance = position.distance_to(player.position)
	var yDistance = player.position.y - position.y
	if is_waiting:
		return
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if distance < safe_distance:
			if distance < safe_distance - safe_zone: # check if we are in danger
				if position.x < player.Player_x: # if we are in danger then we back up
					velocity.x -= speed
				else:
					velocity.x += speed
			else:
				if randi_range(0, jump_prob) == 0 and yDistance < enemy_to_player_y: # if we are in range not in danger then we can choose to jump or not
					print ("Enemy jumps")
					print (yDistance)
					velocity.y = jump_strength
					move_and_slide()
				return
		elif distance > safe_distance: # move to player if too far
			if can_run:
				run_cooldown -= delta # minus delta and delta is 1 second no matter the frame rate
				if run_cooldown < 1:
					run_cooldown = randi_range(1, 2)
					if randi_range(0, run_prob) == 0:
						max_speed = run_speed
						print ("Enemy runs with ", max_speed)
						run_cooldown += randi_range(1, 3)
					else:
						max_speed = 200
						print ("Stopped run ", max_speed)
			if distance > safe_distance - safe_zone:# player is very far
				if position.x < player.Player_x:
					velocity.x += speed
				else:
					velocity.x -= speed
			else:
				return

	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	move_and_slide()
	
func pause_movement_for(seconds: float):
	is_waiting = true
	await get_tree().create_timer(seconds).timeout
	is_waiting = false
