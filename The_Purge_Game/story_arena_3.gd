extends StaticBody2D
@onready var detectplayer = $PlayerSpawn/Area2D
@export var wait_time : int
@export var strider : PackedScene
var trigger_once := false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if !trigger_once and body.is_in_group("player"):
		_start_stuff()

func _start_stuff():
	print("start timer")
	trigger_once = true
	await get_tree().create_timer(wait_time).timeout
	print("spawning")
	spawn_enemy("strider")
	
func spawn_enemy(enemy_type: String):
	print("spawned")
	var world = get_parent()
	var scene_to_spawn: PackedScene

	match enemy_type:
		"strider":
			scene_to_spawn = strider
		_:
			return
	var enemy = scene_to_spawn.instantiate() # copies stuff and prepares it	
	world.add_child(enemy) # then we add it into the world
