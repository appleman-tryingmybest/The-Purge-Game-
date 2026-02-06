extends CharacterBody2D

var joints : Array[PinJoint2D] = []
var limbs : Array[RigidBody2D] = []
@export var scale_body : float = 1.0
@onready var boom = $AnimatedSprite2D
var timer := 0.0

#PRELOAD SOUNDS
var funny_explode = preload("res://addons/godot-git-plugin/funny-explosion-sound.ogg")

func _ready():
	boom.play("funny-explode")
	play_sound(funny_explode) # make boom when strider dies

	if has_node("Joints"):
		for j in $Joints.get_children():
			if j is PinJoint2D: joints.append(j)
	for child in get_children():
		if child is RigidBody2D: limbs.append(child)

	for l in limbs:
		l.position *= scale_body
		for child in l.get_children():
			if child is Sprite2D or child is CollisionShape2D:
				child.scale = Vector2(scale_body, scale_body)
				child.position *= scale_body

	for j in joints:
		j.position *= scale_body
		
		var node_a = j.node_a
		var node_b = j.node_b
		j.node_a = ""
		j.node_b = ""
		j.node_a = node_a
		j.node_b = node_b

		var r_angle = randf_range(0, 180)
		j.angular_limit_enabled = true
		j.angular_limit_lower = deg_to_rad(-r_angle)
		j.angular_limit_upper = deg_to_rad(r_angle)

	for l in limbs:
		var x_dir = 1 if position.x > Global.player_x else -1
		l.apply_central_impulse(Vector2(randf_range(100, 500) * x_dir, randf_range(-500, 500)))
		if l.name == "gun":
			x_dir = 1 if position.x > Global.player_x else -1
			l.apply_central_impulse(Vector2(randf_range(555, 888) * x_dir, 1000))

func play_sound (stream: AudioStream): # YOU CAN JUST COPY AND PASTE THIS
	var p = AudioStreamPlayer2D.new() # make new audioplayer
	p.stream = stream
	p.pitch_scale = randf_range(0.45, 0.6)
	add_child(p) # adds to the world
	p.play() # play first
	p.finished.connect(p.queue_free) # remove itself after finished playing

func _process(delta: float) -> void:
	if !(timer > 10):
		timer += delta
		print (timer)
	else:
		queue_free()
