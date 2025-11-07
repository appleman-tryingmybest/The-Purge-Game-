extends Camera2D

@export var camera_Type := 0
@export var testingMode := true
@export var cameraX : float = 0
@export var cameraY : float = 0
@export var cameraXOffset : float
@export var cameraYOffset : float
@export var camera_debug := false
func _ready() -> void:
	cameraYOffset *= -1 # I have invert the value here cause for some reason godot's y-axis is flipped so when you put positive value it reverts to correct stuff
	var getPosition = get_parent().get_node("AreaTrigger")
	getPosition.teleportPlayer.connect(setPosition)

func setPosition():
	var getPosition = get_parent().get_node("StoryArena")
	cameraX = getPosition.position.x
	cameraY = getPosition.position.y
	camera_Type = 1
	
func _process(_delta):
	var player = get_parent().get_node("Player")  # this is how we get values from other code, but since the code is under something we need to put it as player/CharacterBody2D just so it knows its under player
	if camera_Type == 0:
		cameraX = player.Player_x + cameraXOffset
		cameraY = player.Player_y + cameraYOffset # we need to add an offset just so we can adjust the cameras y position
	if camera_Type == 0:
		zoom = Vector2(0.8, 0.8)
		position.x = cameraX
		if testingMode: # I wanted to test if it worked but this will be used in game as well
			position.y = cameraY
		else:
			position.y = 0 + cameraYOffset
	if camera_Type == 1: # In the future we need to have the position of the arenas so the camera will just stay there
		zoom = Vector2(0.5, 0.5)
		position.x = cameraX
		position.y = cameraY + 100
		if camera_debug:
			print ("Camera position ", cameraX, " ", cameraY)
