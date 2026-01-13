extends RigidBody2D

func apply_animation_impulse(x_force: float, y_force: float):
	# apply_central_impulse is a "one-time" kick
	apply_central_impulse(Vector2(x_force, y_force))
