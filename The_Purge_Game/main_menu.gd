extends Control

@onready var options = $options
@onready var options_panel = %options_panel
@onready var back = %back_button
@onready var start = $startgame
@onready var exitmm = $exit
@onready var blur_bg = %blurry_bg

func _ready():
	self.show()
	get_tree().paused = true
	
func _process(_delta):
	if Input.is_action_just_pressed("esc"):
		_on_exit_pressed()

func _on_startgame_pressed() -> void:
	print("start")
	get_tree().paused = false
	Global.start_game = true
	Global.camera_Type = 0
	self.hide()
	
func _on_exit_button_pressed():
	print("exit game")
	_on_exit_pressed()
	
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
	exitmm.hide()
	options.hide()
	blur_bg.show()
	options_panel.show()
	back.show()
	print("Options page opened")
