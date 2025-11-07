extends Area2D
var final_xPos : float
var teleportX: float
var teleportY: float
signal teleportPlayer

func _ready():
	var getFunction = get_parent().get_node("floorGenerator")
	getFunction.resetPosition.connect(_getValues)

@warning_ignore("unused_parameter")
func _on_body_entered(body: Node2D) -> void:
	print ("Entered the trigger space")
	var getPosition = get_parent().get_node("StoryArena")
	teleportX = getPosition.position.x
	teleportY = getPosition.position.y
	print (teleportX," ", teleportY)
	emit_signal ("teleportPlayer")
	
	pass # Replace with function body.
	
func _getValues():
	var getValue = get_parent().get_node("floorGenerator")
	final_xPos = getValue.furthest_x
	position.x = final_xPos
	print (position.x)
	
