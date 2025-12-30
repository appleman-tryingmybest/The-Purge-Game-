extends Node
var enemy_count : int

var bgm_player : AudioStreamPlayer
var is_combat : bool = false

var exploration_songs = [
	preload("res://music/ambient-1.ogg"),
	preload("res://music/ambient-2.ogg")
]
var combat_song = preload("res://music/combat-1.ogg")

func _ready() -> void:
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	play_random_exploration()
	
func fade_swtich_to(new_track: AudioStream):
	var tween = create_tween()
	tween.tween_property(bgm_player,"volume_db", -80, 0.5)
	tween.tween_callbacl(func():
		bgm_player.stream = new_track
		bgm_player.play()
	)
	tween.tween_property(bgm_player, "volume_db",0, 0.5)
	
func play_random_exploration():
	is_combat = false
	fade_switch_to(exploration_songs[randi() % exploration_songs.size()])
	
func play_combat_music():
	is_combat = true
	fade_switch_to(combat_song)
	
func fade_switch_to(new_track: AudioStream):
	var tween = create_tween()
	tween.tween_property(bgm_player,"volume_db", -80, 0.5)
	tween.tween_callback(func():
		bgm_player.stream = new_track
		bgm_player.play()
	)
	tween.tween_property(bgm_player, "volume_db",0, 0.5)

func _process(_delta: float) -> void:
	if Global.enemy_count >=3 and not is_combat:
		play_combat_music()
	elif Global.enemy_count <3 and is_combat:
		play_random_exploration()
		
	if not bgm_player.playing:
		if is_combat:
			bgm_player.play()
		else:
			play_random_exploration()
	
