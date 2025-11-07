extends Area2D
var final_xPos : float
var teleportX: float
var teleportY: float
@export var Enable := false
var player_inside := false
signal teleportPlayer

func _ready():
	print ("where is trigger space ", position.x, " ", position.y)
	var getFunction = get_parent().get_node("floorGenerator")
	getFunction.resetPosition.connect(_getValues)

@warning_ignore("unused_parameter")
func _on_body_entered(body: Node2D) -> void:
	print ("Entered the trigger space")
	if Enable:
		var getPosition = get_parent().get_node("StoryArena/PlayerSpawn")
		teleportX = getPosition.global_position.x
		teleportY = getPosition.global_position.y
		print (teleportX," ", teleportY)
		emit_signal ("teleportPlayer")

	pass # Replace with function body.

func _getValues():
	var getValue = get_parent().get_node("floorGenerator")
	final_xPos = getValue.furthest_x
	position.x = final_xPos
	position.y = getValue.global_position.y
	print (position.x, " ", position.y)
	await get_tree().create_timer(2).timeout
	monitoring = true
	
