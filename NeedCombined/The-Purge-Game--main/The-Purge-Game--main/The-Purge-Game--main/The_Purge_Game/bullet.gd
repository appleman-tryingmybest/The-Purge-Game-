extends Area2D

@export var speed =1000
@export var damage :float

func _ready():
	await get_tree().create_timer(3.0).timeout
	queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += Vector2.RIGHT.rotated(rotation) * speed * delta
	

	
func _on_body_entered(body: Node2D) -> void:
	print("bullet enter ", body.name)
	if body.is_in_group("player"):
		return
		
	if body.collision_layer == 16:
		if body.has_method("_take_damage"):
			body._take_damage(damage)
		queue_free() # Destroy bullet after hitting enemy

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
