extends GPUParticles2D

@export var rain_height : float
@export var timer : float = 0
@export var rain : int
var rains = process_material as ParticleProcessMaterial

func _wind(dir:int):
	if dir == 0:
		rains.gravity = Vector3(-800, 1200, 0)
		print("right")
	else:
		rains.gravity = Vector3(800, 1200, 0)
		print("left")

func _physics_process(delta: float) -> void:
	print ("rain time ", timer)
	var cam = get_parent().get_node("Camera2D")
	if cam:
		var cam_center = cam.get_screen_center_position()
		global_position = cam_center + Vector2(0,rain_height)

	timer -= 1
	if timer < 0:
		if emitting == false:
			if randi_range(0, rain) == 0:
				emitting = true
				_wind(randi_range(0,1))
				rain += 1
				print("raining!")
				timer = randf_range(300,520) * 3
			else:
				rain -= 1

		else:
			emitting = false
			print("stop raining")
			timer = randf_range(180,360) * 3
				
