extends RigidBody2D

func apply_animation_impulse(x_force: float, y_force: float, spin_force: float = 0.0):
	var final_spin = spin_force * 1000
	# apply_central_impulse is a "one-time" kick
	apply_central_impulse(Vector2(x_force, y_force))
	# the angular impulse
	apply_torque_impulse(final_spin)
	print("Angular Velocity: ", angular_velocity)
