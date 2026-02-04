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
@export var health:float
@export var shield_cooldown:float
@export var bullet: PackedScene
@export var hammer_target:int=10
@export var ham_dam:float
@export var timer_death:float=1
@export var player_heal_amout:int
@export var heal_timer:float


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
var sword_cooldown := true
var intro_done := false
var block=false
var can_block=true
var respawn=false
var hammer_lock=true
var dead_pos:Vector2=Vector2.ZERO
var dropod_fall=false
var dropod_velocity = 0.0
var last_dam:float
var gravity: float = 980.0

@onready var animation = $AnimationPlayer
@onready var hand = %"player-hand"
@onready var handgun = $visuals/handcontainer
@onready var visuals = $visuals
@onready var gun=%"player-handgun"
@onready var muzzle=$visuals/handcontainer/muzzle
@onready var cam =$"../Camera2D"
@onready var ham_part=$"hammer-bang"
@onready var dropod=$Dropod
@onready var floor_checker=$Dropod/check_floor
@onready var boom=$BOOM
@onready var health_bar=$"CanvasLayer2/health-bar"
@onready var sword_pic=$CanvasLayer2/sword
@onready var gun_pic=$CanvasLayer2/gun
@onready var hammer_pic=$CanvasLayer2/hammer



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
var hammer_intro = preload("res://sounds/player/hammer-intro.ogg")
var hammer_hit = preload("res://sounds/player/hammer_hit.ogg")



func _ready() -> void:
	visible = false
	initial_health = health
	if health_bar:
		health_bar.max_value=initial_health
		health_bar.value=health
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
	health_bar.show()
	hammer_pic.show()
	if Global.hammer_num >= hammer_target: 
		hammer_pic.modulate=Color(1.0, 1.0, 1.0, 1.0)
		create_tween().tween_property(hammer_pic, "modulate", Color.WHITE, 0.3)
	elif Global.hammer_num <= hammer_target:
		hammer_pic.modulate=Color(0.5,0.5,0.5)
	if Global.hammer:
		hand.hide()
		handgun.hide()
	if current_weapon=="sword":
		sword_pic.show()
		gun_pic.hide()
	elif current_weapon=="gun":
		gun_pic.show()
		sword_pic.hide()
	if respawn:#let player cannot move when not on ground)
		velocity.x = 0
		if not is_on_floor():
			velocity.y += gravity * delta
		move_and_slide()
		return
	if dead or block :#can let animation don't move
		velocity=Vector2.ZERO
		if !is_on_floor():
			velocity.y += gravity * delta
		move_and_slide()
		return
	var hammer1= animation.current_animation=="hammer-intro"
	var hammer2= animation.current_animation=="hammer-up"
	var hammer3=animation.current_animation=="hammer-attack"
	if hammer1 or hammer2 or hammer3:
		velocity.y += gravity * delta
		move_and_slide()
		return
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
		velocity.y += gravity * delta
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
	if Input.is_action_just_pressed("dash") and can_dash and not is_dashing and is_on_floor():
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
	if !dead and !respawn and health < initial_health:
		last_dam += delta
		if last_dam>=heal_timer:
			health+=player_heal_amout* delta
			health=min(health,initial_health)
			health_bar.value = health
	if dropod_fall:
		if not floor_checker.is_colliding():#check the ground where the collision shape
			dropod_velocity += 5000* delta
			dropod.global_position.y += dropod_velocity * delta
		else:
			dropod_fall=false
			dropod_velocity = 0.0
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
	
func _process(_delta): #mostly ani here
	var hammer1= animation.current_animation=="hammer-intro"
	var hammer2= animation.current_animation=="hammer-up"
	var hammer3=animation.current_animation=="hammer-attack"
	if dead or respawn or hammer1 or hammer2 or hammer3:
		return
	if Input.is_action_pressed("shield") and is_on_floor() and can_block and current_weapon == "sword" and not is_dashing:
		if not block:
			block=true
			_block()
	else:
		if block:
			block=false
			_block_cooldown()
	if Input.is_action_just_pressed("switch"):
		switch_gun()
	if current_weapon == "gun":
		handgun.look_at(get_global_mouse_position())
		if Input.is_action_just_pressed("attack"):
			if current_weapon=="sword":
				return
			shoot()
			
	elif current_weapon=="sword":
		if Input.is_action_just_pressed("attack") and sword_cooldown and !is_dashing:
			if current_weapon=="gun":
				return
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
	var is_hit=animation.current_animation=="shield-hitted"
	if not is_attack and not is_dashing and not is_hit:
		if Input.is_action_pressed("ui_left") :
			visuals.scale.x = -1
		if Input.is_action_pressed("ui_right"):
			visuals.scale.x = 1
	if animation.is_playing():
		if is_attack or is_hit:
			return
	
	if Input.is_action_just_pressed("s_hammer_attack") and Global.hammer_num>=hammer_target :
		var weaponb4hammer=current_weapon
		hand.hide()
		handgun.hide()
		play_sound(hammer_intro)
		if is_on_floor():
			animation.play("hammer-intro", 0, 1.5)
			Global.hammer = true
			await animation.animation_finished
		Global.hammer = true
		animation.play("hammer-up")
		await animation.animation_finished
		animation.play("hammer-attack")
		play_sound(hammer_hit)
		Global.hammer_num=0
		await animation.animation_finished
		if weaponb4hammer=="sword":
			hand.show()
			sword_pic.show()
			gun_pic.hide()
		elif weaponb4hammer=="gun":
			handgun.show()
			gun_pic.show()
			sword_pic.hide()
		Global.hammer = false
		
	if is_on_floor() and !is_dashing and !block:
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
	block=false
	if current_weapon=="sword":
		current_weapon="gun"
		hand.hide()
		sword_pic.hide()
		handgun.show()
		gun_pic.show()
		sword_pic.hide()
		gun.play("idle")
		play_sound(gun_intro)
		if sword_idle.is_playing():
			sword_idle.stop()
	else:
		current_weapon="sword"
		hand.show()
		sword_pic.show()
		handgun.hide()
		gun_pic.hide()
		play_sound(chainsword_intro)
		sword_idle.play()

	
func _random_footstep_sound():
	if randi_range(0, 1) == 0:#random range
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
	play_sound(death, randf_range(0.8, 2), 25)
	dead = true
	dead_pos = global_position
	visuals.hide()
	boom.show()
	animation.play("boom")
	await animation.animation_finished
	boom.hide()
	print("Congratulations! You died")
	await get_tree().create_timer(timer_death).timeout
	respawn_player()

# RECEIVE DAMAGE

func take_damage(amount:float):#enemy attack player
	play_sound(unf, randf_range(0.8, 1.4), 4)
	var hammer1= animation.current_animation=="hammer-intro"
	var hammer2= animation.current_animation=="hammer-up"
	var hammer3=animation.current_animation=="hammer-attack"
	if dead or block or is_dashing or respawn or hammer1 or hammer2 or hammer3:#wiill break the aniamtion
		return
	health -= amount
	last_dam=0
	health_bar.value = health
	health_bar.create_tween().tween_property(health_bar, "value", health, 0.1)#let it mmore smooth
	print ("Your remaining health: ", health)
	animation.play("shield-hitted")
	_cam_shake(15)
	_flash_damage()
	if health <= 0 :
		_death_sequence()
	

func _on_hurt_area_area_entered(area: Area2D) -> void:#enemy enter hurt box
	if area.has_method("give_damage"):
		var damage_taken = area.give_damage()
		take_damage(damage_taken)

# GIVE DAMAGE

func _on_sword_hit_area_entered(area: Area2D) -> void:
	if current_weapon!="sword":
		print("oi why gun leh")
	if area.get_collision_layer_value(16):
		var enemy = area.owner 
		if enemy and enemy.has_method("_take_damage"):
			enemy._take_damage(sword_dam, 1500, -600)
			Global.hammer_num+=2
			print("Hit enemy: ", enemy.name)
		else:
			print("Hit Layer 16 but no _take_damage method found!")


		
func sword_attack():
	if block or current_weapon!="sword":
		return
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
	
func respawn_player():
	dead =false
	respawn=true
	velocity = Vector2.ZERO
	health=initial_health
	
	visuals.hide()
	dropod.top_level = true# let this become independent from player
	dropod.global_position = dead_pos+ Vector2(0, -100)
	dropod.show()
	dropod_velocity = 0.0
	dropod_fall= true
	animation.play("reset play")
	health_bar.value = health
	await animation.animation_finished
	visuals.show()
	
	apply_knockback(Vector2(2500, 30))
	respawn=false
	current_weapon="sword" #direct force the weaopon ==sword if use if current... hand hide or gun hide is only eye see it  
	handgun.hide()
	hand.show()
	animation.play("idle")

func _play_jump_sound():
	play_sound(jump)
	print ("played sound")

func _block():
	animation.play("shield intro")
	await animation.animation_finished
	animation.play("shield loop")

func _block_cooldown():
	can_block=false
	await get_tree().create_timer(shield_cooldown).timeout
	can_block=true
	
func _cam_shake(strenght:float):
	if cam.has_method("apply_shake"):
		cam.apply_shake(strenght)


func _on_hammer_area_entered(area: Area2D) -> void:
	if area.get_collision_layer_value(16):
		var enemy = area.owner 
		
		if enemy and enemy.has_method("_take_damage"):
			enemy._take_damage(ham_dam,1500,-900)
			print("ham Hit enemy: ", enemy.name)
		else:
			print("Hit Layer 16 but no _take_damage method found!")

func _hammer_jump(up:float):
	velocity.y=-up
	
func _flash_damage():
	var tween = create_tween()
	visuals.modulate = Color(10, 10, 10, 1)
	tween.tween_property(visuals, "modulate", Color.WHITE, 0.1)
