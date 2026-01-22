extends CharacterBody2D
@export var SPEED = 200.0
@export var runspeed= 300
@export var JUMP_VELOCITY : float
@export var Player_x : float = 0
@export var Player_y : float = 0
@export var dash_speed = 4
@export var push_strength : int
@export var initial_health:float
@export var dash_duration: float = 0.3
@export var dash_cooldown: float = 1.0
@export var shoot_cooldown= 0.0
@export var sword_dam :float
@export var sword_force:float



var jump_count=0
var max_jump=2
var is_dashing=false
var can_dash = true
var dash_direction=1
var was_on_floor=true
var direction : float
signal camera_limits_changed(new_limits: Vector4)
var knockback_velocity := Vector2.ZERO
var current_weapon = "sword"
var can_fire=true
var dead=false
var sword_idle : AudioStreamPlayer2D
var respawn:Vector2
@export var health:float
var sword_cooldown := true
var intro_done := false

@onready var animation = $AnimationPlayer
@onready var hand = %"player-hand"
@onready var handgun = $visuals/handcontainer
@onready var visuals = $visuals
@onready var gun=%"player-handgun"
@export var bullet: PackedScene
@onready var muzzle=$visuals/handcontainer/muzzle
@onready var dead_ani=$visuals/BOOM


#PRELOAD SOUNDS
var chainsword_idle = preload("res://sounds/player/chainsword-idle.ogg")
var chainsword_intro = preload("res://sounds/player/chainsword-intro.ogg")
var chainsword_swing = preload("res://sounds/player/chainsword-swing.ogg")
var dash = preload("res://sounds/player/dash.ogg")
var footstep1 = preload("res://sounds/player/footstep1.ogg")
var footstep2 = preload("res://sounds/player/footstep2.ogg")
var gun_intro = preload("res://sounds/player/gun-intro.ogg")
var gun_shoot = preload("res://sounds/player/gun-shoot.ogg")
var jump = preload("res://sounds/player/jump-jump.ogg")
var unf = preload("res://sounds/player/unf.ogg")
var death = preload("res://sounds/player/death-sound.ogg")


func _ready() -> void:
	visible = false
	initial_health = health
	JUMP_VELOCITY *= -1
	var getPosition = get_parent().get_node("AreaTrigger")
	getPosition.teleportPlayer.connect(setPosition)
	add_to_group("player")
	if has_node("dash timer"):
		$"dash timer".timeout.connect(stop_dash)
	sword_idle = AudioStreamPlayer2D.new()
	add_child(sword_idle)
	sword_idle.stream = chainsword_idle
	play_sound(chainsword_intro)
	sword_idle.play()
	respawn=global_position

func play_sound (stream: AudioStream, pitch:= 1.0, volume:= 0): # YOU CAN JUST COPY AND PASTE THIS
	var p = AudioStreamPlayer2D.new() # make new audioplayer
	p.stream = stream
	p.pitch_scale = pitch
	p.volume_db = 1 + volume
	p.bus = "sounds"
	add_child(p) # adds to the world
	p.play() # play first
	p.finished.connect(p.queue_free) # remove itself after finished playing

func setPosition():
	var getPosition = get_parent().get_node("AreaTrigger")
	position.x = getPosition.teleportX
	position.y = getPosition.teleportY
	print ("where do we go ", position.x, " ", position.y)

func _physics_process(delta: float) -> void:
	if !intro_done:
		intro_done = true
		visible = true
		apply_knockback(Vector2(2500, 25))
	Global.player_x = global_position.x
	Global.player_y = global_position.y
	Global.player_position = global_position
	if knockback_velocity != Vector2.ZERO:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 5000 * delta)
	z_index = 10
	Player_x = position.x
	Player_y = position.y
	var currently_on_floor = is_on_floor()
	if currently_on_floor:
		jump_count = 0
	elif was_on_floor and not currently_on_floor:
		jump_count = 1
	was_on_floor = currently_on_floor
	# Add the gravity.
	if not is_on_floor() and not is_dashing:
		velocity += get_gravity() * delta
	direction=Input.get_axis("ui_left", "ui_right")
	if(direction !=0 or Input.is_action_just_pressed("ui_up")) and Global.game_started == false:
			Global.game_started = true
			print("timer started")   #timer start when the play move
			
	if is_on_floor():
		jump_count=0
	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and jump_count<max_jump:
		velocity.y = JUMP_VELOCITY
		jump_count+=1
		if jump_count ==1:
			animation.play("jump")
		else:
			animation.play("double jump")
		_play_jump_sound()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if Input.is_action_just_pressed("dash") and can_dash and not is_dashing:
		if sword_cooldown: # Only dash if the sword isn't mid-swing
			start_dash()
	var is_attack=animation.current_animation == "attack" or animation.current_animation == "attack 2"
	if is_attack:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta * 10)
	elif is_dashing:
	# Use dash_direction (which we set in start_dash)
	# Use float() to force Godot to treat these as numbers
		var s = float(SPEED) if SPEED != null else 200.0
		var d = float(dash_speed) if dash_speed != null else 4.0
		velocity.x = dash_direction * s * d
	else:
		var current_speed = SPEED
		if Input.is_action_pressed("run"):
			current_speed = runspeed
		if direction:
			velocity.x =direction * current_speed + knockback_velocity.x 
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()


func start_dash():
	var dir := Input.get_axis("ui_left", "ui_right")
	dash_direction = dir if dir != 0 else (visuals.scale.x) # Use facing direction if no input
	is_dashing = true
	can_dash = false
	play_sound(dash, 1.2)
	animation.play("dash", 0, 2)
	if has_node("dash timer"):
		$"dash timer".start(dash_duration)


func stop_dash():
	is_dashing=false
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash=true
	print("dash cooldown end can continue to dash")


func update_camera_for_new_area():
	var story_arena = get_parent().get_node("StoryArena1")
	if story_arena:
		var arena_rect = story_arena.get_global_rect()
		var new_limits = Vector4(
			arena_rect.position.x,
			arena_rect.position.y,
			arena_rect.end.x,
			arena_rect.end.y)
		emit_signal("camera_limits_changed", new_limits)


func apply_knockback(force: Vector2):
	knockback_velocity = force
	
func _process(_delta):
	if Input.is_action_just_pressed("switch"):
		switch_gun()
	if current_weapon == "gun":
		handgun.look_at(get_global_mouse_position())
		if Input.is_action_just_pressed("attack"):
			shoot()
	elif current_weapon=="sword":
		if Input.is_action_just_pressed("attack") and sword_cooldown and !is_dashing:
			sword_attack()
	if position.x> get_global_mouse_position().x and visuals.scale.x == 1 and current_weapon == "gun":
		handgun.scale.y=-1
	elif position.x< get_global_mouse_position().x and visuals.scale.x == 1 and current_weapon == "gun":
		handgun.scale.y=1
	elif position.x> get_global_mouse_position().x and visuals.scale.x == -1 and current_weapon == "gun":
		handgun.scale.y=1
	elif position.x< get_global_mouse_position().x and visuals.scale.x == -1 and current_weapon == "gun":
		handgun.scale.y=-1
	if is_dashing:
		animation.play("dash")
	var is_attack=animation.current_animation == "attack" or animation.current_animation == "attack 2"
	if not is_attack and not is_dashing:
		if Input.is_action_pressed("ui_left") :
			visuals.scale.x = -1
		if Input.is_action_pressed("ui_right"):
			visuals.scale.x = 1
	if animation.is_playing():
		if is_attack:
			return

	
	if is_on_floor() and !is_dashing:
		if velocity.x==0:
			animation.play("idle")
		elif velocity.x != 0:
			if Input.is_action_pressed("run"):
				animation.play("run")
			else:
				animation.play("walk")
		
	if !is_on_floor():
		if velocity.y<0:
			pass
		else:
			animation.play("fall")
	if animation.current_animation == "jump" and animation.is_playing():
		return

func switch_gun():
	if current_weapon=="sword":
		current_weapon="gun"
		hand.hide()
		handgun.show()
		gun.play("idle")
		play_sound(gun_intro)
		if sword_idle.is_playing():
			sword_idle.stop()
	else:
		current_weapon="sword"
		hand.show()
		handgun.hide()
		play_sound(chainsword_intro)
		sword_idle.play()

	
func _random_footstep_sound():
	if randi_range(0, 1) == 0:
		play_sound(footstep1, randf_range(0.8, 1.5))
	else:
		play_sound(footstep2, randf_range(0.8, 1.5))

func shoot():
	if current_weapon!="gun" or  can_fire== false:
		return
	if bullet:
		can_fire=false
		var bullet_out=bullet.instantiate()
		bullet_out.global_position = muzzle.global_position 
		bullet_out.global_rotation=muzzle.global_rotation
		get_tree().current_scene.add_child(bullet_out)
		play_sound(gun_shoot, randf_range(0.9, 2))
		gun.play("shoot",2)
		await get_tree().create_timer(shoot_cooldown).timeout
		can_fire=true
		


func _on_playerhandgun_animation_finished() -> void:
	if gun.animation=="shoot":
		gun.play("idle")
		
		
func _death_sequence():
	play_sound(death, randf_range(0.8, 2), 4)
	dead = true
	print("Congratulations! You died")
	await get_tree().create_timer(2).timeout
	reset_player()

# RECEIVE DAMAGE

func take_damage(amount:float):
	play_sound(unf, randf_range(0.8, 1.4), 4)
	if dead:
		return
	health -= amount 
	print ("Your remaining health: ", health)
	if health <= 0 :
		_death_sequence()

func _on_hurt_area_area_entered(area: Area2D) -> void:
	if area.has_method("give_damage"):
		var damage_taken = area.give_damage()
		take_damage(damage_taken)	

# GIVE DAMAGE

func get_damage():
	return sword_dam
	

func _on_sword_hit_area_entered(area: Area2D) -> void:
	if area.get_collision_layer_value(16):
		var enemy = area.owner 
		
		if enemy and enemy.has_method("_take_damage"):
			enemy._take_damage(sword_dam, 1500, -600)
			print("Hit enemy: ", enemy.name)
		else:
			print("Hit Layer 16 but no _take_damage method found!")


		
func sword_attack():
	sword_cooldown = false
	var random_attack = randi_range(0, 1)
	var attack_dir=visuals.scale.x
	velocity.x=attack_dir*sword_force
	if random_attack == 1:
		animation.play("attack", 0, 1.5)
		hand.play("sword-attack")
	else:
		animation.play("attack 2", 0 , 1.5)
		hand.play("sword-attack2")
	play_sound(chainsword_swing, randf_range(0.8, 2))
	await animation.animation_finished
	await get_tree().create_timer(0.1).timeout
	sword_cooldown = true
	
func reset_player():
	dead =false
	global_position=respawn#initial place
	health=initial_health
	animation.play("idle")
	if current_weapon == "sword":
		sword_idle.play()

func _play_jump_sound():
	play_sound(jump)
	print ("played sound")
