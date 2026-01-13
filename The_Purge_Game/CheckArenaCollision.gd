extends Area2D
var final_xPos : float
var teleportX: float
var teleportY: float
@export var Enable := false
var player_inside := false
signal teleportPlayer
@export var arena : int

func _ready():
	print ("where is trigger space ", position.x, " ", position.y)
	var getFunction = get_parent().get_node("floorGenerator")
	getFunction.resetPosition.connect(_getValues)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	print ("Entered the trigger space")
	if Enable:
		if Global.arena_num == 0:
			var getPosition = get_parent().get_node("StoryArena1/PlayerSpawn")
			teleportX = getPosition.global_position.x
			teleportY = getPosition.global_position.y
		if Global.arena_num == 1:
			var getPosition = get_parent().get_node("StoryArena2/PlayerSpawn")
			teleportX = getPosition.global_position.x
			teleportY = getPosition.global_position.y
		if Global.arena_num == 2:
			var getPosition = get_parent().get_node("StoryArena3/PlayerSpawn")
			teleportX = getPosition.global_position.x
			teleportY = getPosition.global_position.y
		if Global.arena_num == 3:
			var getPosition = get_parent().get_node("StoryArena4/PlayerSpawn")
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
	
