extends Camera2D

@export var camera_Type := 0
@export var testingMode := true
@export var cameraX : float = 0
@export var cameraY : float = 0
@export var cameraXOffset : float
@export var cameraYOffset : float
func _ready() -> void:
	cameraYOffset *= -1 # I have invert the value here cause for some reason godot's y-axis is flipped so when you put positive value it reverts to correct stuff

func _process(_delta):
	var player = get_parent().get_node("player/CharacterBody2D") as CharacterBody2D # this is how we get values from other code, but since the code is under something we need to put it as player/CharacterBody2D just so it knows its under player
	cameraX = player.Player_x
	cameraY = player.Player_y + cameraYOffset # we need to add an offset just so we can adjust the cameras y position
	if camera_Type == 0:
		position.x = cameraX
		if testingMode: # I wanted to test if it worked but this will be used in game as well
			position.y = cameraY
		else:
			position.y = 0
	if camera_Type == 1: # In the future we need to have the position of the arenas so the camera will just stay there
		return # like we can put the arenas somewhere far from the camera and when the player gets to the arena we teleport the player there and the camera aswell
