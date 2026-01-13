extends Area2D
@onready var limit = $CollisionShape2D

func _process(delta: float) -> void:
	if Global.arena_player:
		limit.rotation = deg_to_rad(180)
	elif !Global.arena_player:
		limit.rotation = deg_to_rad(0)
