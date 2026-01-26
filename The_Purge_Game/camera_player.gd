extends Camera2D

@export var testingMode := true
@export var cameraX : float = 0
@export var cameraY : float = 0
@export var cameraXOffset : float
@export var cameraYOffset : float
@export var camera_debug := false
@export var transition_speed: float = 3.0
@export var initial_map_limits: Vector4 = Vector4(-201, -100000, 10000000, 177)
@export var shake_decay : float = 20.0#this more bigger will dissapear faster


var fading := false
var target_limits: Vector4
var is_transitioning: bool = false
var shake_strength : float = 0.0 


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
		
func update_right_limits():#see the floor length
	var floor=get_parent().get_node("floorGenerator")
	if floor:
		initial_map_limits.z =floor.furthest_x + (floor.tile_width / 2.0)#since the floor maybe will random length so/2 to get the length that actually the camera need to apply
		limit_right = initial_map_limits.z
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
	var arena_num = Global.arena_num
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
	if shake_strength > 0:
		offset = Vector2(randf_range(-1, 1) * shake_strength, randf_range(-1, 1) * shake_strength)
		shake_strength = move_toward(shake_strength, 0, shake_decay * delta)
	else:
		offset = Vector2.ZERO
	Global.camera_y = global_position.y
	var player = get_parent().get_node("Player")  # this is how we get values from other code, but since the code is under something we need to put it as player/CharacterBody2D just so it knows its under player
	if Global.camera_Type == 0:
		if limit_left == -10000000: 
			_apply_initial_limits()
		if !fading:
			background.play("main")
		cameraX = player.global_position.x+ cameraXOffset
		cameraY =player.global_position.y+ cameraYOffset # we need to add an offset just so we can adjust the cameras y position
		if player.Player_x > initial_map_limits.z - 500:
			update_right_limits()
			_apply_initial_limits()
		zoom = Vector2(0.8, 0.8)
		position.x = cameraX
		if testingMode:
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
		var mainMenuPosition = get_parent().get_node("camerahere")
		position = mainMenuPosition.position
		background.play("black")
		limit_left = -1000000
		limit_top = -1000000
		limit_right = 1000000
		limit_bottom = 1000000
		
	elif Global.camera_Type == 3:
		_remove_all_limits()
		print("outro")
		top_level = true
		position =Vector2(0,17205.0)
		print("where r u ", position)
		zoom = Vector2(0.5, 0.5)

		
	if camera_debug:
			print("Camera position ", position.x, " ", position.y)
			print("Camera type: ", Global.camera_Type)
			
			
func _clamp_to_initial_limits():#see the width
	if Global.camera_Type==0:
		var half_screen_width = (get_viewport_rect().size.x * zoom.x) / 2.0#put a safe range to ensure camera will no show the map without floor
		var min_x = initial_map_limits.x + half_screen_width
		var max_x = initial_map_limits.z - half_screen_width
		var half_screen_height = (get_viewport_rect().size.y * zoom.y) / 2.0
		var min_y = initial_map_limits.y + half_screen_height
		var max_y = initial_map_limits.w - half_screen_height
		if max_x < min_x:
			position.x = min_x
		else:
			position.x = clamp(position.x, min_x, max_x)
		if max_y < min_y:
			position.y = (initial_map_limits.y + initial_map_limits.w) / 2.0
		else:
			position.y = clamp(position.y, min_y, max_y)

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

func _fade():
	fading = true
	print ("must play once")
	background.play("fade_in")
	await background.animation_finished
	print ("Fading out burh")
	background.play("fade_out")
	await background.animation_finished
	fading = false

func apply_shake(strength: float):
	shake_strength = strength
