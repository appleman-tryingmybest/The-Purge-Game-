extends CharacterBody2D
@export var speedX : float
@export var speedY : float
@export var lifetime : float

func _ready() -> void:
	speedX = randf_range(45, 125)
	speedY = randf_range(100, 400)

func _physics_process(delta: float) -> void:
	velocity.x = speedX
	velocity.y = speedY
	lifetime -= delta
	if lifetime < 0 or !Global.arena_player:
		queue_free()
	move_and_slide()
