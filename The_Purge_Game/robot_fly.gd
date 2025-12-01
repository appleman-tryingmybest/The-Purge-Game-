extends CharacterBody2D
# if want to make more enemy, then make enemy scene local and then save as scene
@export var speedX : float
@export var speedY : float
@export var health : float
@export var max_speed : float = 100
@export var safe_distance : float = 250
@export var safe_zone : float = 45
@export var safe_Y : float = 90
@export var ray_length : int  = 100
@export var wall_correction := 20 # shoots enemy backwards if hugging wall
var hugging_wall := false
var just_fell := false
var can_jump_fall := false
@onready var ray = $RayCast2D

var run_cooldown : float = 1
var is_waiting := false
func _ready() -> void:
	randomize()
	safe_distance += randf_range(-65, 65)
	safe_Y += randf_range(-65, 65)

func shoot_ray():
	var player = get_parent().get_node("Player")
	var direction = Vector2 (ray_length, 0)
	if position.x > player.position.x:
		direction.x = -abs(direction.x)
	elif position.x < player.position.x:
		direction.x = abs(direction.x)
	ray.target_position = direction
	ray.force_raycast_update()
	if ray.is_colliding():
		hugging_wall = true
		var collider = ray.get_collider()
		print("Hit: ", collider.name)
	else:
		hugging_wall = false

func _physics_process(delta):
	z_index = 7
	var player = get_parent().get_node("Player")
	var distance = position.distance_to(player.position)
	if health > 0:
		shoot_ray()
		just_fell = false
		if distance < safe_distance:
			if distance < safe_distance - safe_zone: # check if we are in danger
				if position.x < player.Player_x: # if we are in danger then we back up
					velocity.x -= speedX
				else:
					velocity.x += speedX
				if position.y > player.Player_y:
					velocity.y -= speedY
				else:
					velocity.y -= speedY
		elif distance > safe_distance: # move to player if too far
			if distance > safe_distance - safe_zone:# player is very far
				if hugging_wall:
					if position.x < player.Player_x:
						velocity.x -= wall_correction
					elif position.x > player.Player_x:
						velocity.x += wall_correction
						
				if position.x < player.Player_x:
					velocity.x += speedX
				else:
					velocity.x -= speedX

				if position.y < player.Player_y - 100:
					velocity.y += speedY
				else:
					velocity.y -= speedY
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	velocity.y = clamp(velocity.y, -max_speed, max_speed)
	move_and_slide()

	if velocity.x > 0:
		rotation_degrees += 1
		rotation_degrees = clamp(rotation_degrees + 1, -30, 30)
	elif velocity.x < 0:
		rotation_degrees -= 1
		rotation_degrees = clamp(rotation_degrees - 1, -30, 30)
