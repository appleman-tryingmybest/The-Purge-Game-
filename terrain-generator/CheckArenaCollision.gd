extends Area2D
var final_xPos : float

func _ready():
	var getFunction = get_parent().get_node("floorGenerator")
	getFunction.resetPosition.connect(_getValues)

func _on_body_entered(body: Node2D) -> void:
	print ("Entered the trigger space")
	
	pass # Replace with function body.
	
func _getValues():
	var getValue = get_parent().get_node("floorGenerator")
	final_xPos = getValue.furthest_x
	position.x = final_xPos
	print (position.x)
	
