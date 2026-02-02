extends Node

#Player
var player_x := 0.0
var player_y := 0.0
var player_position := Vector2.ZERO
var camera_y := 0.0
var enemy_count := 0
var dropship_count := 0
var arena_player := false
var start_game := false
var camera_Type := 2
var mountain := true
var cloud := true
var tree := true
var arena_num := 3
var enemy_kill_count := 0
var ebeeChance := 25
var allowSpawn := true
var current_score : int
var start_time := 0.0
var final_time_display := ""
var bullets_count = 0
var hammer_num:=0
var hammer := false
var death_count : int = 0
var total_damage_taken: float = 0
var restart = false
