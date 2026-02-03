extends Control

@onready var options = $options
@onready var options_panel = %options_panel
@onready var back = $backfortuto
@onready var start = $startgame
@onready var exitmm = $exit
@onready var blur_bg = %blurry_bg
@onready var anim_ship = $anim_spaceship
@onready var setting = %setting
@onready var animation = $AnimationPlayer
@onready var cameraAnimation = %AnimationPlayer
@onready var _tutorial = %tuto
@onready var tuto = %tutorial
@onready var black = %bg
@onready var purge = $Purge
@onready var rules = $container

func _ready():
	self.show()
	setting.hide()
	rules.hide()
	back.hide()
	get_tree().paused = true
	
func _process(_delta):
	if Input.is_action_just_pressed("esc"):
		_on_exit_pressed()

func _on_startgame_pressed() -> void:
	start.disabled = true
	tuto.disabled = true
	options.disabled = true
	exitmm.disabled = true
	print("start")
	animation.play("start")
	await animation.animation_finished
	Global.start_game = true
	Global.camera_Type = 0
	animation.play("intro_first")
	self.hide()
	setting.show()
	await animation.animation_finished
	get_tree().paused = false

	
func _on_exit_pressed():
	get_tree().quit()
	print("Exiting game")

func esc():
	if Input.is_action_just_pressed("esc") and get_tree()._on_exit_pressed() == false:
		_on_exit_pressed()
	else:
		return

func _on_options_pressed() -> void:
	start.hide()
	tuto.hide()
	exitmm.hide()
	options.hide()
	var back_button = %back_button
	print("Options page opened")
	blur_bg.modulate.a = 0.0
	options_panel.modulate.a = 0.0
	back_button.modulate.a = 0.0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(blur_bg,"modulate:a",1.0,1.0)
	tween.tween_property(options_panel,"modulate:a",1.0,1.0)
	tween.tween_property(back_button,"modulate:a",1.0,1.0)
	print("fading in.")
	blur_bg.show()
	options_panel.show()
	back_button.show()
	start.disabled = true
	tuto.disabled = true
	exitmm.disabled =  true

func _on_tutorial_pressed() -> void:
	print("tutorial mode")
	black.show()
	
	back.show()
	_tutorial.show()
	black.visible = true
	print("r u there my black", black.visible, black.global_position)
	rules.show()
	
	black.modulate.a = 0.0
	rules.modulate.a = 0.0
	back.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(black,"modulate:a",1.0,1.0)
	tween.tween_property(rules,"modulate:a",1.0,2.0)
	tween.tween_property(back,"modulate:a",1.0,2.0)
	print("fading in")
	start.disabled = true
	tuto.disabled = true
	options.disabled = true
	exitmm.disabled = true

func _on_backfortuto_pressed() -> void:
	print("r u working my bro")
	black.modulate.a = 1.0
	rules.modulate.a = 1.0
	back.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(rules,"modulate:a",0.0,0.3)
	tween.tween_property(back,"modulate:a",0.0,1.0 )
	tween.tween_property(black,"modulate:a",0.0,1.0)
	
	print("fading out")
	await tween.finished
	back.hide()
	rules.hide()
	black.hide()
	options_panel.hide()
	start.disabled = false
	tuto.disabled = false
	options.disabled = false
	exitmm.disabled = false
	
