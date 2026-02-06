extends Node2D

var wait_timer:float=1
@export var timer:float
@export var chance : int
var rand_sound : int
var current_plane: AudioStreamPlayer2D
var amount := 0

var explosion= preload("res://sounds/explosion.ogg")
var gun1=preload("res://sounds/gun_1.ogg")
var gun2=preload("res://sounds/gun_2.ogg")
var plane=preload("res://sounds/plane.ogg")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wait_timer=timer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var cam = get_parent().get_node("Camera2D")
	var cam_center = cam.get_screen_center_position()
	position = cam_center
	print ("bgm timer is ", wait_timer)
	if Global.start_game:
		wait_timer-=delta
		if wait_timer<=0:
			wait_timer=timer
			if randi_range(0, chance):
				chance += 1
				rand_sound = randi_range(0, 2)
				if rand_sound==0:
					play_sound(explosion)
					print("bgm explssssss")
				elif rand_sound==1:
					amount = randi_range(8, 15)
					while amount > 0:
						if randi_range(0,1) == 0:
							play_sound(gun1)
						else:
							play_sound(gun2)
							print("bgm gunnnnnn")
						amount -= 1
						await get_tree().create_timer(randf_range(0.1, 1)).timeout
				elif rand_sound==2:
					current_plane=play_sound(plane)
					print("bgm plannnnnnnnn")
				if rand_sound == 2 and is_instance_valid(current_plane):#check current got plane sound or not
					print("bgm got plannnnnn")
					rand_sound = randi_range(0, 1)
			else:
				chance -= 1
				print ("nothing happens")

func play_sound (stream: AudioStream, pitch:= 1.0, volume:= 0): # YOU CAN JUST COPY AND PASTE THIS
	var p = AudioStreamPlayer2D.new() # make new audioplayer
	p.stream = stream
	p.pitch_scale = randi_range(-1, 1)
	p.volume_db = randi_range(8, 15)
	p.bus = "sounds"
	add_child(p) # adds to the world
	p.global_position += Vector2(randf_range(-500, 500), randf_range(-100, 100))
	p.play() # play first
	p.finished.connect(p.queue_free) # remove itself after finished playing
	return p

	
	
