extends Node

var player_1 : AudioStreamPlayer
var player_2 : AudioStreamPlayer
var bgm_player : AudioStreamPlayer
var is_combat : bool = false

var exploration_songs = [
	preload("res://music/ambient-1.ogg"),
	preload("res://music/ambient-2.ogg")
]
var combat_song = preload("res://music/combat-1.ogg")

func _ready() -> void:
	player_1 = AudioStreamPlayer.new()
	player_2 = AudioStreamPlayer.new()
	
	player_1.bus = AudioServer.get_bus_name(0)
	player_2.bus = AudioServer.get_bus_name(0)
	
	player_1.process_mode = Node.PROCESS_MODE_ALWAYS
	player_2.process_mode = Node.PROCESS_MODE_ALWAYS
	
	player_1.bus = "Master"
	player_2.bus = "Master" #slider 
	
	add_child(player_1)
	add_child(player_2)
	
	bgm_player = player_1
	play_random_exploration()
	
	
func play_random_exploration():
	is_combat = false
	var random_song = exploration_songs[randi() % exploration_songs.size()]
	fade_to(random_song)
	
func play_combat_music():
	is_combat = true
	fade_to(combat_song)
	
func fade_to(new_track: AudioStream):
	var next_player = player_2 if bgm_player == player_1 else player_1
	
	next_player.stream = new_track
	next_player.volume_db = -80 #decreasing sound
	next_player.play()
	
	var tween = create_tween().set_parallel(true) #strat fading songs at the same time
	tween.tween_property(bgm_player,"volume_db", -80, 2) #fade out the current song
	tween.tween_property(next_player, "volume_db", 0, 2) #fade in the new song
	bgm_player =next_player #update which player is now the active one
	tween.chain().tween_callback(func():
		if bgm_player == player_1:
			player_2.stop()
		else:
			player_1.stop()
	)
	#wait for the fade to finish, then stop the song

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
	
