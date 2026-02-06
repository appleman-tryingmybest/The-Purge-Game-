extends CharacterBody2D

@export var speedY : float
@export var speedX : float
@export var lifetime : float

@onready var debris = $visuals/debris

func _ready() -> void:
	speedY += randf_range(-100, 100)
	speedX += randf_range(-80, 80)
	var frame_count = debris.sprite_frames.get_frame_count("variation")
	debris.frame = randi_range(0, frame_count -1)
	debris.pause()
	debris.rotation_degrees = randf_range(0, 360)

func _physics_process(delta: float) -> void:
	velocity.y = speedY
	velocity.x = speedX
	lifetime -= delta
	if lifetime < 0:
		queue_free()
	move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print ("get fucked, says the debris")
		var push_dir := 1250.0
		if Global.player_x < position.x: # right
			push_dir = push_dir * -1
		if Global.player_x > position.x: # left
			push_dir = abs(push_dir)
		if body.has_method("apply_knockback"):
			body.apply_knockback(Vector2(push_dir, -100))
		if body.has_method("take_damage"):
			body.take_damage(25)
