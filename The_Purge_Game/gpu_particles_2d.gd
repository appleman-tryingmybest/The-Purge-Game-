extends GPUParticles2D

@export var rain_height : float
@export var timer : float = 0
@export var rain : int

	
func _physics_process(delta: float) -> void:
	print ("raibn time ", timer)
	var cam = get_parent().get_node("Camera2D")
	if cam:
		var cam_center = cam.get_screen_center_position()
		global_position = cam_center + Vector2(0,rain_height)

	timer -= 1
	if timer < 0:
		if emitting == false:
			if randi_range(0, rain) == 0:
				emitting = true
				rain += 1
				print("raining!")
				timer = randf_range(300,520) * 3
			else:
				rain -= 1

		else:
			emitting = false
			print("stop raining")
			timer = randf_range(180,360) * 3
				
