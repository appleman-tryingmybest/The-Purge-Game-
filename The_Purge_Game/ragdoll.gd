extends CharacterBody2D

var joints : Array[PinJoint2D] = []
var limbs : Array[RigidBody2D] = []
@export var scale_body : float = 1.0
var timer := 0.0
var facing_direction : float = 1.0 # Set this from the enemy script

func _ready():
	# 1. Collect nodes
	if has_node("Joints"):
		for j in $Joints.get_children():
			if j is PinJoint2D: joints.append(j)
	for child in get_children():
		if child is RigidBody2D: limbs.append(child)
	
	# 2. Position and Scale the Limbs
	for l in limbs:
		# Flip the limb's starting position based on direction
		l.position.x *= facing_direction 
		l.position *= scale_body 
		
		for child in l.get_children():
			if child is Sprite2D or child is CollisionShape2D:
				# Flip the visual/shape itself
				child.scale.x *= facing_direction 
				child.scale *= scale_body
				# Flip the internal offset of the sprite/shape
				child.position.x *= facing_direction
				child.position *= scale_body 
	
	# 3. Scale and RE-ANCHOR the Joints
	for j in joints:
		j.position.x *= facing_direction # Flip joint anchor point
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

	# 4. Apply Forces (Impulse)
	var push_side = 1 if global_position.x > Global.player_x else -1
	for l in limbs:
		l.apply_central_impulse(Vector2(randf_range(100, 500) * push_side, randf_range(-500, 200)))
	
func _process(delta: float) -> void:
	timer += delta
	if timer > 10:
		queue_free()
