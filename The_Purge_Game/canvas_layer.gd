extends CanvasLayer

@onready var anim_gear = $AnimationPlayer
@onready var blur_bg = $blurry_bg
@onready var resume = $Resume_button
@onready var optionspm = $Option_button
@onready var options_panel = $options_panel
@onready var exit = $Exit
@onready var back = $options_panel/back_button
@onready var start = %startgame
@onready var exitmm = %exit
@onready var optionsmm = %options
@onready var bobb = $options_panel/bob
@onready var adamm = $options_panel/adam
@onready var tuto = %tutorial

var is_paused = false

@onready var treeNode = get_tree().current_scene.find_child("ParallaxTree")
@onready var mountainNode = get_tree().current_scene.find_child("ParallaxMountain")
@onready var cloudNode = get_tree().current_scene.find_child("ParallaxCloud")
@onready var bob = preload("res://bob.tscn")
@onready var adam = preload("res://adam.tscn")

func _ready():
	Global.start_game = false
	blur_bg.hide()
	resume.hide()
	optionspm.hide()
	options_panel.hide()
	exit.hide()
	
	$options_panel/HSlider.value = 70
	$options_panel/HSlider2.value = 70
	
func _on_texture_button_mouse_entered():
	if is_paused == false:
		anim_gear.play("hover move_setting")
	
func _on_texture_button_mouse_exited():
	if not is_paused:
		anim_gear.play_backwards("hover move_setting")
	
func _on_texture_button_pressed():
	if is_paused == false:
		is_paused = true
		get_tree().paused = true
		anim_gear.play("clicking_gear")
		await anim_gear.animation_finished
		anim_gear.stop()
		anim_gear.play_backwards("hover move_setting")
		blur_bg.modulate.a = 0.0
		optionspm.modulate.a = 0.0
		resume.modulate.a = 0.0
		exit.modulate.a = 0.0
		back.modulate.a = 0.0
		var tween: Tween = create_tween().set_parallel(true)
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(blur_bg,"modulate:a",1.0,1.0)
		tween.tween_property(optionspm,"modulate:a",1.0,1.0)
		tween.tween_property(back,"modulate:a",1.0,1.0)
		tween.tween_property(resume,"modulate:a",1.0,1.0)
		tween.tween_property(exit,"modulate:a",1.0,1.0)
		blur_bg.show()
		resume.show()
		optionspm.show()
		exit.show()
	

	
func _on_resume_button_pressed():
	print("Resume")
	is_paused = false
	await get_tree().create_timer(0.2).timeout
	resume.hide()
	blur_bg.hide()
	optionspm.hide()
	exit.hide()
	get_tree().paused = false
	anim_gear.play_backwards("pause_in")
	
func _on_option_button_pressed():
	await get_tree().create_timer(0.2,true,false,true).timeout
	resume.hide()
	optionspm.hide()
	exit.hide()
	
	options_panel.modulate.a = 0.0
	back.modulate.a = 0.0
	var tween = create_tween().set_parallel(true) #fading together
	tween.set_process_mode(tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(options_panel,"modulate:a",1.0,0.5)
	tween.tween_property(back,"modulate:a",1.0,0.5)
	print("fading in.")
	blur_bg.show()
	back.show()
	options_panel.show()
	print("Options page opened")
		
	
func _on_back_button_pressed():
	print("back")
	await get_tree().create_timer(0.2).timeout
	if Global.start_game == false:
		blur_bg.modulate.a = 1.0
		options_panel.modulate.a = 1.0
		back.modulate.a = 1.0
		var tween: Tween = create_tween().set_parallel(true)
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(blur_bg,"modulate:a",0.0,0.3)
		tween.tween_property(options_panel,"modulate:a",0.0,0.3)
		tween.tween_property(back,"modulate:a",0.0,0.3)
		
		await tween.finished
		
		blur_bg.hide()
		back.hide()
		options_panel.hide()
		print("fading out..")
		var tweenn = create_tween().set_parallel(true)
		tweenn.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) #to continue tween,even the game paused
		tuto.modulate.a = 0.0
		start.modulate.a = 0.0
		exitmm.modulate.a = 0.0
		optionsmm.modulate.a = 0.0
		tuto.show()
		start.show()
		exitmm.show()
		optionsmm.show()
		tweenn.tween_property(tuto,"modulate:a",1.0,2.5)
		tweenn.tween_property(start,"modulate:a",1.0,2.5)
		tweenn.tween_property(exitmm,"modulate:a",1.0,2.5)
		tweenn.tween_property(optionsmm,"modulate:a",1.0,2.5)

		Global.camera_Type = 2
		print("back to main menu")
		return
	
	exit.modulate.a = 0.0
	optionspm.modulate.a = 0.0
	resume.modulate.a = 0.0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(exit,"modulate:a",1.0,3.0)
	tween.tween_property(optionspm,"modulate:a",1.0,3.0)
	tween.tween_property(resume,"modulate:a",1.0,3.0)
	options_panel.hide()
	resume.show()
	optionspm.show()
	exit.show()
	anim_gear.play("pause_in")
	anim_gear.seek(anim_gear.current_animation_length, true)

func _on_exit_button_pressed():
	print("exit")
	await get_tree().create_timer(0.2).timeout
	resume.hide()
	optionspm.hide()
	options_panel.hide()
	
	
func _on_h_slider_value_changed(value:float) -> void:
	var bus_index = AudioServer.get_bus_index("sounds")
	if bus_index != -1:
		var linear_volume = value / 100.0
		var db_volume = linear_to_db(linear_volume)
	
		print("slider value:", value, " | DB: ", db_volume)
		AudioServer.set_bus_volume_db(bus_index, db_volume)
		print("setting bus 0 to:", db_volume, "dB")
	
func _on_h_slider_2_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Music")
	if bus_index != -1:
		var linear_volume = value / 100.0
		var db_volume = linear_to_db(linear_volume)
	
		print("slider value:", value, " | DB: ", db_volume)
		AudioServer.set_bus_volume_db(bus_index, db_volume)
		print("Music Volume set to: ", db_volume, " dB")

func _on_exit_pressed() -> void:
	print("return to main menu")
	Global.start_game = false
	Global.camera_Type = 2
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_mountain_toggled(toggled_on: bool) -> void:
	if toggled_on:
		print ("no more mountains :(")
		Global.mountain = false
		mountainNode._clear_mountain()
	else:
		print ("yay more mountains :)")
		Global.mountain = true
		mountainNode._clear_mountain()

func _on_tree_toggled(toggled_on: bool) -> void:
	if toggled_on:
		print ("no more trees :(")
		Global.tree = false
		treeNode._clear_mountain()
	else:
		print ("yay more trees :)")
		Global.tree = true
		treeNode._clear_mountain()

func _on_cloud_toggled(toggled_on: bool) -> void:
	if toggled_on:
		print ("no more clouds :(")
		Global.cloud = false
		cloudNode._clear_clouds()
	else:
		print ("yay more clouds :)")
		Global.cloud = true
		cloudNode._clear_clouds()

func _on_bob_toggled(toggled_on: bool) -> void:
	if toggled_on:
		print("bob added")
		var BOB = bob.instantiate()  #object creation
		BOB.global_position = Vector2(1018,-290) 
		get_parent().add_child(BOB)
		bobb.hide()
	
func _on_adam_toggled(toggled_on: bool) -> void:
	if toggled_on:
		print("adam added")
		var ADAM = adam.instantiate()
		get_parent().add_child(ADAM)
		adamm.hide()
		


func _on_rain_toggled(toggled_on: bool) -> void:
	var rain = get_parent().get_node("rain")
	if toggled_on:
		print("rain stopped")
		rain.emitting = false
	else:
		rain.emitting = true
		print("rain continue")
