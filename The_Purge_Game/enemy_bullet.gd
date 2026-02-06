extends CharacterBody2D

@export var speed = 2100
var Rotation : float # This is the variable passed from your Enemy script
var shotgun : bool = false
var life_time : float

func _ready() -> void:
	# Set the visual rotation
	global_rotation = Rotation
	print("pew pew")
	life_time = 0.1 if shotgun else 4.0

func _physics_process(delta: float) -> void:
	# Use global_rotation to determine the direction of travel
	velocity = Vector2.RIGHT.rotated(global_rotation) * speed
	move_and_slide()
	life_time -= delta
	if life_time < 0:
		print ("deleted enemy bullet")
		queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var push_dir := 800.0
		if Global.player_x < position.x: # right
			push_dir = push_dir * -1
		if Global.player_x > position.x: # left
			push_dir = abs(push_dir)
		if body.has_method("apply_knockback"):
			body.apply_knockback(Vector2(push_dir, 0))
		if body.has_method("take_damage"):
			body.take_damage(8)
		queue_free()
