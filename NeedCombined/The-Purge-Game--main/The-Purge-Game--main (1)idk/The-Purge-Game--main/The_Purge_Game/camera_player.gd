extends Camera2D

@export var testingMode := true
@export var cameraX : float = 0
@export var cameraY : float = 0
@export var cameraXOffset : float
@export var cameraYOffset : float
@export var camera_debug := false
var target_limits: Vector4
var is_transitioning: bool = false
@export var transition_speed: float = 3.0
@export var initial_map_limits: Vector4 = Vector4(-201, -100000, 10000000, 177)
@onready var background = $AnimationPlayer

func _ready() -> void:
	cameraYOffset *= -1 # I have invert the value here cause for some reason godot's y-axis is flipped so when you put positive value it reverts to correct stuff
	var getPosition = get_parent().get_node("AreaTrigger")
	getPosition.teleportPlayer.connect(setPosition)
	var player=get_parent().get_node("Player")
	if player:
		player.camera_limits_changed.connect(_on_camera_limits_changed)
	_apply_initial_limits()
	update_right_limits()
	
func _apply_initial_limits():
	limit_left = initial_map_limits.x
	limit_top = initial_map_limits.y
	limit_right = initial_map_limits.z
	limit_bottom = initial_map_limits.w
	if camera_debug:
		print("initial map limited: ", initial_map_limits)
		
func update_right_limits():
	var floor=get_parent().get_node("floorGenerator")
	if floor:
		initial_map_limits.z = floor.furthest_x + 200
	if camera_debug:
		print("initial right limit update: ", initial_map_limits.z)
		
func _remove_all_limits():
	limit_left = -10000000
	limit_top = -10000000
	limit_right = 10000000
	limit_bottom = 10000000
	if camera_debug:
		print("clear all cam limit")
func _on_camera_limits_changed(new_limits: Vector4):
	Global.camera_Type = 1  
	target_limits = new_limits
	is_transitioning = true
	_remove_all_limits()
	if camera_debug:
		print("Camera limits changed to: ", new_limits)
		
func setPosition():
	var arena_type = get_parent().get_node("AreaTrigger")
	var arena_num = arena_type.arena_num
	if arena_num == 0:
		var getPosition = get_parent().get_node("StoryArena1")
		cameraX = getPosition.position.x
		cameraY = getPosition.position.y + cameraYOffset
	if arena_num == 1:
		var getPosition = get_parent().get_node("StoryArena2")
		cameraX = getPosition.position.x
		cameraY = getPosition.position.y + cameraYOffset
	if arena_num == 2:
		var getPosition = get_parent().get_node("StoryArena3")
		cameraX = getPosition.position.x
		cameraY = getPosition.position.y + cameraYOffset
	if arena_num == 3:
		var getPosition = get_parent().get_node("StoryArena4")
		cameraX = getPosition.position.x
		cameraY = getPosition.position.y + cameraYOffset
	Global.camera_Type = 1
	_remove_all_limits()
	position.x = cameraX
	position.y = cameraY + 100
	print("Camera switched to arena mode at: ", cameraX, ", ", cameraY)
	
func _process(delta):
	Global.camera_y = global_position.y
	var player = get_parent().get_node("Player")  # this is how we get values from other code, but since the code is under something we need to put it as player/CharacterBody2D just so it knows its under player
	if Global.camera_Type == 0:
		background.play("main")
		cameraX = player.Player_x + cameraXOffset
		cameraY = player.Player_y + cameraYOffset # we need to add an offset just so we can adjust the cameras y position
		if player.Player_x > initial_map_limits.z - 500:
			update_right_limits()
			_apply_initial_limits()
		zoom = Vector2(0.8, 0.8)
		position.x = cameraX
		if testingMode: # I wanted to test if it worked but this will be used in game as well
			position.y = cameraY
		else:
			position.y = 0 + cameraYOffset
		_clamp_to_initial_limits()
	elif Global.camera_Type == 1:
		zoom = Vector2(0.5, 0.5)
		position.x = lerp(position.x, cameraX, delta * transition_speed)
		position.y = lerp(position.y, cameraY + 100, delta * transition_speed)
		if is_transitioning:
			_apply_smooth_limits(delta)
	elif Global.camera_Type == 2:
		print ("Go to main menu please")
		var mainMenuPosition = get_parent().get_node("camerahere")
		position = mainMenuPosition.position
		background.play("black")
		limit_left = initial_map_limits.x
		limit_top = initial_map_limits.y
		limit_right = initial_map_limits.z
		limit_bottom = initial_map_limits.w
		
	if camera_debug:
			print("Camera position ", position.x, " ", position.y)
			print("Camera type: ", Global.camera_Type)
func _clamp_to_initial_limits():
	if Global.camera_Type==0:
		position.x = clamp(position.x, initial_map_limits.x, initial_map_limits.z)
		position.y = clamp(position.y, initial_map_limits.y, initial_map_limits.w)

func _apply_smooth_limits(delta):
	limit_left = lerp(limit_left, target_limits.x, delta * transition_speed)
	limit_top = lerp(limit_top, target_limits.y, delta * transition_speed)
	limit_right = lerp(limit_right, target_limits.z, delta * transition_speed)
	limit_bottom = lerp(limit_bottom, target_limits.w, delta * transition_speed)
	var tolerance = 5.0
	var limits_close = (
	abs(limit_left - target_limits.x) < tolerance and
	abs(limit_top - target_limits.y) < tolerance and
	abs(limit_right - target_limits.z) < tolerance and
	abs(limit_bottom - target_limits.w) < tolerance)
	if limits_close:
		is_transitioning=false
	if camera_debug:
		print("Camera limits transition completed")
