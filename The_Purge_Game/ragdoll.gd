extends CharacterBody2D

var joints : Array[PinJoint2D] = []
var limbs : Array[RigidBody2D] = []
@export var scale_body : float = 1.0
var timer := 0.0
var facing_direction : float = 1.0 # Set this from the enemy script

# for some fucking reason rigid bodies and pinjoints dont like to be resized very much as they just screw up alot of shits

func _ready():
	if has_node("Joints"): # get nodes
		for j in $Joints.get_children():
			if j is PinJoint2D: joints.append(j)
	for child in get_children():
		if child is RigidBody2D: limbs.append(child)

	for l in limbs: # get sprites and collision
		l.position.x *= facing_direction 
		l.position *= scale_body 
		
		for child in l.get_children():
			if child is Sprite2D or child is CollisionShape2D:
				child.scale.x *= facing_direction 
				child.scale *= scale_body
				child.position.x *= facing_direction
				child.position *= scale_body 

	for j in joints: # remove the joints and then rejoint it cause my god you do not want to see how it looked like without this
		j.position.x *= facing_direction # flip joint anchor point
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

	var push_side = 1 if global_position.x > Global.player_x else -1 # push random
	for l in limbs:
		l.apply_central_impulse(Vector2(randf_range(100, 500) * push_side, randf_range(-500, 200)))
	
func _process(delta: float) -> void:
	timer += delta
	if timer > 10:
		queue_free()
