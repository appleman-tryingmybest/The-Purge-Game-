extends CharacterBody2D

var joints : Array[PinJoint2D] = []
var limbs : Array[RigidBody2D] = []
@export var scale_body : float = 1.0
var timer := 0.0
var facing_direction : float = 1.0 

func _ready():

	var x_push_dir = 1 if global_position.x > Global.player_x else -1

	if has_node("Joints"):
		for j in $Joints.get_children():
			if j is PinJoint2D: joints.append(j)
	for child in get_children():
		if child is RigidBody2D: limbs.append(child)
	
	for l in limbs:
		l.position.x *= facing_direction 
		l.position *= scale_body 
		
		for child in l.get_children():
			if child is Sprite2D or child is CollisionShape2D:
				child.scale = Vector2(scale_body, scale_body)
				child.scale.x *= facing_direction 
				child.position.x *= facing_direction 
				child.position *= scale_body 

	for j in joints:
		j.position.x *= facing_direction
		j.position *= scale_body 

		var node_a = j.node_a
		var node_b = j.node_b
		j.node_a = "" 
		j.node_b = ""
		j.node_a = node_a 
		j.node_b = node_b

	for l in limbs:
		l.apply_central_impulse(Vector2(randf_range(800, 1000) * x_push_dir, randf_range(-500, 0)))
		
		if l.name == "gun":
			l.apply_central_impulse(Vector2(randf_range(500, 800) * x_push_dir, -300))

func _process(delta: float) -> void:
	timer += delta
	if timer > 10:
		queue_free()
