extends GPUParticles2D

@export var rain_height : float
@export var timer : float
@export var rain : int
var rains = process_material as ParticleProcessMaterial
@onready var Rain = $rainsound
@export var p :float
@export var thunder_timer: float

var thunder = preload("res://sounds/thunder.ogg")

func _ready() -> void:
	emitting = false
	
func _wind(dir:int):
	amount = randi_range(800,8000)
	print("intensity ",amount)
	if dir == 0:
		rains.gravity = Vector3(randf_range(-800, 800), 1200, 0)
		print("right/left")
	else:
		rains.gravity = Vector3(0, 1200, 0)
		print("straight")

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
				Rain.play()  #play sound
				print("rain sound playing")
				_wind(randi_range(0, 1))
				rain += 1
				print("raining!")
				timer = randf_range(300,520) * 5
				
			else:
				rain -= 1

		else:
			emitting = false
			Rain.stop()
			print("stop raining")
			timer = randf_range(180,360) * 5
			
	if emitting == true:
		thunder_timer -=delta
		print("thunder timer: ", thunder_timer)
		if thunder_timer <= 0:  #times up
			thunder_timer = randf_range(5,10)  #decide when is the next thunder
			if randf() < p:  
				play_sound(thunder,5)
				print("thunder!")
			else:
				print("no thunder!")
	else:
		thunder_timer = randf_range(5,10)
			
func play_sound (stream: AudioStream, volume:int = 0.0): 
	var r = AudioStreamPlayer2D.new() 
	r.stream = stream
	r.bus = "sounds"
	r.volume_db = 20
	add_child(r) # adds to the world
	r.play() # play first
	r.finished.connect(r.queue_free)
				
