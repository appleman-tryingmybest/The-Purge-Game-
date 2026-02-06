extends Parallax2D

@export var x_limit: float 
@export var cloudNum: float
@export var cloud_debug : bool = true
@export var y_offset : float
@onready var screen_width = get_viewport_rect().size.x
var currentCloudNum: float = 0
var is_generating := false
var allow_generate := true
var buffer = 200

func _ready():
	# Connect to your floor generator as before
	var floorGenerator = get_parent().get_node("floorGenerator")
	floorGenerator.resetWorld.connect(_clear_clouds)
	if cloud_debug:
		print ("Found it")
	
	# Initial generation
	_get_ground_values()

func _clear_clouds():
	is_generating = false
	currentCloudNum = 0
	# Delete only the generated sprites, not the template
	for cloud in get_tree().get_nodes_in_group("generatedCloud"):
		cloud.queue_free()
	_get_ground_values()

func _get_ground_values():
	if cloud_debug:
		print ("got the values")
	var floorGenerator = get_tree().current_scene.find_child("floorGenerator")
	if floorGenerator:
		# Double check if the value is actually there
		if floorGenerator.num_tile > 0:
			x_limit = floorGenerator.furthest_x
			cloudNum = floorGenerator.num_tile * 6
			if cloud_debug:
				print("Success! Found FloorGenerator. Tiles: ", floorGenerator.num_tile)
			_generate_clouds()
		else:
			# If it's still 0, the floor hasn't initialized yet.
			# Wait one frame and try again.
			if cloud_debug: print("Floor found, but num_tile is 0. Retrying...")
			await get_tree().process_frame
			_get_ground_values()
	else:
		push_error("Cloud script could not find floorGenerator in the scene!")
		_generate_clouds()

func _generate_clouds():
	if is_generating: return
	is_generating = true
	
	var template = $AnimatedSprite2D # The Sprite2D child
	var spawn_x = 0.0 # Start at the beginning of the layer
	var frame_count = template.sprite_frames.get_frame_count("cloud-variant")
	while currentCloudNum < randi_range(100, 200) and is_generating and Global.cloud:
		# Randomize variety
		var distance = randf_range(15, 100)
		# Create the cloud sprite
		var new_cloud = template.duplicate()
		new_cloud.animation = "cloud-variant"
		new_cloud.frame = randi_range(0, frame_count -1)
		new_cloud.pause()
		new_cloud.visible = true
		new_cloud.add_to_group("generatedCloud")
		self.scroll_scale = Vector2(0.2, 0)
		var random_windspeed = randf_range(-5, -45)
		var cloudSize = remap(abs(random_windspeed), 5, 45, randf_range(2, 4),randf_range(4, 6) )
		var alpha_vary = remap(abs(random_windspeed), 5, 45, 0.4, 0.8)
		new_cloud.modulate.a = alpha_vary
		new_cloud.set_meta("speed", random_windspeed)
		add_child(new_cloud) # Adds it inside this Parallax2D layer
		
		# Position it RELATIVE to this layer
		spawn_x += distance
		new_cloud.position.x = spawn_x
		new_cloud.position.y = y_offset + randf_range(-250, 10)
		new_cloud.scale = Vector2(cloudSize, cloudSize)
		if randi_range(0, 1) == 0:
			new_cloud.scale.x *= -1
			
		# STOP if we pass the world limit
		# Note: Since the layer moves, we check spawn_x directlyda
		currentCloudNum += 1
		
		if cloud_debug:
			print("Cloud ", currentCloudNum, " x-pos ", spawn_x)
			
		await get_tree().process_frame
	is_generating = false

func _process(delta: float) -> void:
	for cloud in get_tree().get_nodes_in_group("generatedCloud"):
		if cloud.has_meta("speed"):
			var speed = cloud.get_meta("speed")
			cloud.position.x += speed * delta
# LOOPING LOGIC
			# 1. Get the cloud's position on the screen
			var screen_pos = cloud.get_global_transform_with_canvas().origin.x
			
			# 2. If moving LEFT (speed is negative) and goes off left side
			if speed < 0 and screen_pos < -buffer:
				# Move it to the right side of the screen in world space
				cloud.global_position.x += (screen_width + (buffer * 2)) / self.scroll_scale.x
				# Randomize height so it looks like a "new" cloud
				cloud.position.x += (screen_width + (buffer * 2)) / self.scroll_scale.x
				cloud.position.y = y_offset + randf_range(-250, 10)
				
			# 3. If moving RIGHT (speed ils positive) and goes off right side
			elif speed > 0 and screen_pos > screen_width + buffer:
				cloud.global_position.x -= (screen_width + (buffer * 2)) / self.scroll_scale.x
				cloud.position.x += (screen_width + (buffer * 2)) / self.scroll_scale.x
				cloud.position.y = y_offset + randf_range(-250, 10)
	if !Global.start_game:
		visible = false
	else:
		visible = true
