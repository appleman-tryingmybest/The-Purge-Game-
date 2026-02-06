extends StaticBody2D

@onready var boundary1 = $boundary
@onready var boundary2 = $boundary2

func _ready() -> void:
	boundary1.disabled = true
	boundary2.disabled = true

func _process(delta: float) -> void:
	if Global.arena_player and !Global.arena_num == 3:
		boundary1.disabled = false
		boundary2.disabled = false
	else:
		boundary1.disabled = true
		boundary2.disabled = true
