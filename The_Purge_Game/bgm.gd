extends Node2D

var wait_timer:float=1
@export var timer:float
var rand_sound : int
var current_plane: AudioStreamPlayer2D


var explosion= preload("res://sounds/explosion.ogg")
var gun1=preload("res://sounds/gun_1.ogg")
var gun2=preload("res://sounds/gun_2.ogg")
var plane=preload("res://sounds/plane.ogg")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wait_timer=timer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print ("bgm timer is ", wait_timer)
	if Global.start_game:
		wait_timer-=delta
		if wait_timer<=0:
			wait_timer=timer
			rand_sound = randi_range(0, 2)
			
			if rand_sound==0:
				play_sound(explosion,1,15)
				print("bgm explssssss")
			elif rand_sound==1:
				if  randi_range(0,1):
					play_sound(gun1,1,15)
				else:
					play_sound(gun2,1,15)
					print("bgm gunnnnnn")
			elif rand_sound==2:
				current_plane=play_sound(plane,1.15,8)
				print("bgm plannnnnnnnn")
			if rand_sound == 2 and is_instance_valid(current_plane):#check current got plane sound or not
				print("bgm got plannnnnn")
				rand_sound = randi_range(0, 1)
				
				
			
		
		
func play_sound (stream: AudioStream, pitch:= 1.0, volume:= 0): # YOU CAN JUST COPY AND PASTE THIS
	var p = AudioStreamPlayer2D.new() # make new audioplayer
	p.stream = stream
	p.pitch_scale = pitch
	p.volume_db = 1 + volume
	p.bus = "sounds"
	add_child(p) # adds to the world
	p.play() # play first
	p.finished.connect(p.queue_free) # remove itself after finished playing
	return p

	
	
