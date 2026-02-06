extends CharacterBody2D
@export var speedX : float
@export var lifetime : float
@export var direction : int
@onready var particle = $CPUParticles2D

func _ready() -> void:
	print ("spawned shockwave")
	if direction == 1:
		particle.direction.x = -0.5
	elif direction == -1:
		particle.direction.x = 0.5

func _physics_process(delta: float) -> void:
	velocity.x = speedX * direction
	lifetime -= delta
	if lifetime < 0:
		queue_free()
	move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var push_dir := 1500.0
		if Global.player_x < position.x: # right
			push_dir = push_dir * -1
		if Global.player_x > position.x: # left
			push_dir = abs(push_dir)
		if body.has_method("apply_knockback"):
			body.apply_knockback(Vector2(push_dir, -800))
		if body.has_method("take_damage"):
			body.take_damage(25)
		queue_free()
