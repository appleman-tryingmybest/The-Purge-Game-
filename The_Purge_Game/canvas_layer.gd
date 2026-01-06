extends CanvasLayer

@onready var anim_gear = $AnimationPlayer
@onready var blur_bg = $blurry_bg
@onready var resume = $Resume_button
@onready var options = $Option_button
@onready var options_panel = $options_panel
@onready var exit = $Exit
@onready var back = $options_panel/back_button

var is_paused = false

func _ready():
	blur_bg.hide()
	resume.hide()
	options.hide()
	options_panel.hide()
	exit.hide()
	
	$options_panel/HSlider.value = 70
	
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
		
		blur_bg.show()
		resume.show()
		options.show()
		exit.show()
		anim_gear.play("pause_in")
	

	
func _on_resume_button_pressed():
	print("Resume")
	is_paused = false
	await get_tree().create_timer(0.2).timeout
	resume.hide()
	blur_bg.hide()
	options.hide()
	exit.hide()
	get_tree().paused = false
	anim_gear.play_backwards("pause_in")
	
func _on_option_button_pressed():

	await get_tree().create_timer(0.2).timeout
	resume.hide()
	options.hide()
	exit.hide()
	options_panel.show()
	print("Options page opened")
	
func _on_back_button_pressed():
	print("back")
	await get_tree().create_timer(0.2).timeout
	
	options_panel.hide()
	resume.show()
	options.show()
	exit.show()
	anim_gear.play("pause_in")
	anim_gear.seek(anim_gear.current_animation_length, true)

func _on_exit_button_pressed():
	print("exit")
	await get_tree().create_timer(0.2).timeout
	resume.hide()
	options.hide()
	options_panel.hide()
	
	
func _on_h_slider_value_changed(value:float) -> void:
	var bus_index = 0
	if bus_index != -1:
		var linear_volume = value / 100.0
		var db_volume = linear_to_db(linear_volume)
	
		print("slider value:", value, " | DB: ", db_volume)
		AudioServer.set_bus_volume_db(bus_index, db_volume)
		print("setting bus 0 to:", db_volume, "dB")
	
	
