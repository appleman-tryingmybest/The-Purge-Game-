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
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	print("玩家进入了触发区域!")
	print("玩家位置: ", body.position)
	print("触发区域位置: ", position)
	if Enable and body.is_in_group("player"):
		var spawn_point = get_parent().get_node("StoryArena/PlayerSpawn")
		if spawn_point:
			teleportX = spawn_point.global_position.x
			teleportY = spawn_point.global_position.y
			print("传送目标位置: ", teleportX, " ", teleportY)
			emit_signal("teleportPlayer")
	else:
		print("错误: 找不到PlayerSpawn节点!")

func _getValues():
	var getValue = get_parent().get_node("floorGenerator")
	final_xPos = getValue.furthest_x
	position.x = final_xPos
	position.y = getValue.global_position.y
	print (position.x, " ", position.y)
	await get_tree().create_timer(2).timeout
	monitoring = true
	
