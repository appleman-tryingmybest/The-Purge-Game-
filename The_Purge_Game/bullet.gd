extends Area2D

@export var speed =1000
@export var damage :float
@onready var particle = $CPUParticles2D
@export var particleHit : PackedScene

func _ready():
	particle.emitting = true
	await get_tree().create_timer(3.0).timeout
	print ("deleted player bullet")
	queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += Vector2.RIGHT.rotated(rotation) * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.get_collision_layer_value(16):
		var enemy = area.owner 
		
		if enemy and enemy.has_method("_take_damage"):
			enemy._take_damage(damage, 250, 0)
			print("Shot enemy: ", enemy.name)
			var hit =  particleHit.instantiate()
			get_parent().add_child(hit)
			hit.global_position = global_position
			hit.rotation = rotation
			queue_free()
		else:
			print("Shot Layer 16 but no _take_damage method found!")
