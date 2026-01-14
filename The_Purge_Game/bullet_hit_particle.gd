extends CPUParticles2D

func _ready() -> void:
	await get_tree().process_frame
	emitting = true
	get_tree().create_timer(lifetime + 0.5).timeout.connect(queue_free)
